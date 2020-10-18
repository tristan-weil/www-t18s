---
title: "6. Traefik's deployment"
menuTitle: "6. Traefik's deployment"
description: "Traefik's deployment"
weight: 6
---

{{< toc >}}

## What I want?

[traefik](https://www.traefik.io/) will be configured to:
- use Consul as a provider for source services
- generate [Let's Encrypt](https://letsencrypt.org/) certificates for Internet facing entrypoints
- prepare some middlewares for the backends that want to use them

There will be 2 instances installed on the `edge` nodes and thus using the Master/Backup configuration deployed
[here]({{< relref "/projects/big-infra/part1/5-failover-ip" >}}).

[traefik](https://www.traefik.io/) instances will entirely (binary + configurations) be managed by 
[Nomad](https://www.nomadproject.io/).

## Deployment

[traefik](https://www.traefik.io/) binaries are available from the main site or from the packages' manager.

We could also use the [artifact stanza](https://www.nomadproject.io/docs/job-specification/artifact) from 
[Nomad](https://www.nomadproject.io/) to handle the installation: but I was not able to test it yet.

{{% notice warning %}}
The binaries are currently (v2.3.1) [bugged](https://github.com/traefik/traefik/issues/7409) 
on [OpenBSD](https://www.openbsd.org) so I use a manually compiled version.
{{% /notice %}}

## Problems

### Nomad's driver

[traefik](https://www.traefik.io/) is deployed on hosts running [OpenBSD](https://www.openbsd.org).
Thus, it won't be running in a [Docker](https://www.docker.com/) container.

[Nomad](https://www.nomadproject.io/), to handle this case, will:
- only allow the [raw_exec](https://www.nomadproject.io/docs/drivers/raw_exec) driver to be used
- thus, need to be run as `root` because it will launch [traefik](https://www.traefik.io/), that needs to open privileged 
ports

### Deployment / Update / Configuration

We will probably update the binary or change the configurations from time to time.

But when [Nomad](https://www.nomadproject.io/) deploys a new allocation on a target, it first removes the oldest.
It is, of course a problem, when it deploys on the `edge` node that is currently **Master** and thus receiving 
the Internet traffic.

Of course, we want to **minimize the downtime of the services**: that's why we will obviously rely on the 
[FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) and the [carp](https://www.openbsd.org/faq/pf/carp.html) 
configuration set up [here]({{< relref "/projects/big-infra/part1/5-failover-ip" >}}).

So we must found a way to:
- trigger the switch of the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) before terminating the current
[traefik](https://www.traefik.io/) process
- configure the [Nomad](https://www.nomadproject.io/)'s timeout used to force-kill processes taking to much time to 
stop

### Let's encrypt

We plan to have 2 parallel instances: this means they will both ask for the creation/renewal of the certificates.\
This is a problem during the challenge step.

[Nomad](https://www.nomadproject.io/)'s allocations store their files under a working directory managed by the former:
they are not reused.\
This is a problem because [traefik](https://www.traefik.io/) stores the data of the certificates in a file and if it
is not present, it will ask for a certification creation: and this can trigger the
 [Let's encrypt's rate limits](https://letsencrypt.org/docs/rate-limits/)

## Solutions

### Nomad's driver: allow Nomad to be run as root

Edit `/etc/rc.d/nomad` and remove the line:
{{< highlight ini >}}
daemon_user="_nomad"
{{< /highlight >}}

Don't forget to restart the daemon:
{{< highlight shell >}}
rcctl restart nomad
{{< /highlight >}}

### Deployment / Update / Configuration

#### Trigger the switch of the FailOver IP

The only way to trigger the switch of the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) to the **Backup** 
node, before stopping the current running [traefik](https://www.traefik.io/) process on the **Master** node, is to 
**trap** the signals sent by [Nomad](https://www.nomadproject.io/) (it sends a SIGINT signal to stop a process) and 
ask for the switch.

We need a wrapper script that will handle this:

{{< highlight shell >}}
#!/bin/ksh
# From https://gist.github.com/bronger/acce7736141b3fa118b0d47f1a2035ac#file-signal_propagation-sh-L45
# Inspired by <https://unix.stackexchange.com/a/444676/78728>.
#
# Makes a my_long_running_process interruptable by a SIGINT or SIGTERM which
# the shell receive.  The respective signal is propagated to the child process.
#
# Note that this only works for child processes which never return exit codes
# 130 or 143, unless they received SIGINT or SIGTERM, respectively.  If they
# do, you must wrap them in a subshell.
#
# Usage:
#
# prep_term
# my_long_running_process &
# wait_term
# echo $?

prep_term() {
    unset term_child_pid
    unset term_kill_needed
    trap 'handle_term' TERM INT
    trap 'handle_update' HUP
}

handle_update() {
    if [ "${term_child_pid}" ]; then
        kill -HUP "${term_child_pid}" 2>/dev/null
    fi
}

handle_term() {
    if [ "${term_child_pid}" ]; then
    	/sbin/ifconfig -g carp carpdemote
        sleep 15
    	/sbin/ifconfig -g carp -carpdemote
        kill -TERM "${term_child_pid}" 2>/dev/null
    else
        term_kill_needed="yes"
    fi
}

wait_term() {
    term_child_pid=$!
    if [ "${term_kill_needed}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    fi
    wait ${term_child_pid}
    exit_code=$?
    trap - TERM INT
    if [ $exit_code -eq 143 -o $exit_code -eq 130 ]; then
        wait ${term_child_pid}
        exit_code=$?
    fi
    return $exit_code
}

prep_term
traefik "$@" &
wait_term
{{< /highlight >}}

You can see that the script will **demote** the [carp](https://www.openbsd.org/faq/pf/carp.html) interface when asked
to stop.

And if you remember the [ifstated](https://man.openbsd.org/ifstated.8)'s script 
[available here]({{< relref "/projects/big-infra/part1/5-failover-ip#ifstated" >}}), this will trigger:
- the **demoted** state (if on a **Master** node) and
- the removing of the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/)

There is also a 15 seconds `sleep`: this is the maximum delay observed when using the [OVH API](https://api.ovh.com).

#### Nomad's timeouts

In order to avoid to be killed by the [Nomad](https://www.nomadproject.io/)'s process stopping routine, we need
to raise the timeout.
So, in the `task` block:

{{< highlight ini >}}
kill_timeout = "20s"
{{< /highlight >}}

### Let's encrypt

#### The Challenge

To avoid the problem of the challenge, the only one we can use is **DNS**.\
It implies to have the credentials of DNS provider stored on the system.

I have chosen to store them in a file `/etc/traefik/myprovider.key` that can be pointed to a environment variable read by
[traefik](https://www.traefik.io/):

{{< highlight ini >}}
env {
    GANDIV5_API_KEY_FILE = "/etc/traefik/myprovider.key"
}
{{< /highlight >}}

#### acme.json

In order to keep the data of the certificates from one allocation to another, we'll just store it outside the
[Nomad](https://www.nomadproject.io/)'s working directory:

{{< highlight ini >}}
certificatesResolvers:
  letsencrypt:
    acme:
      email: "xxxxxx"
      storage: "/etc/traefik/acme.json"
      dnsChallenge:
        provider: "myprovider"
{{< /highlight >}}

## Manual maintenance

The `edge` nodes are not part of a scalable infrastructure because they handle an unscalable resource: the 
[FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/).

[Nomad](https://www.nomadproject.io/) won't help when time comes to update/maintain the system.
So here is a list of different useful commands.

### Demote the carp interface

If the node is in **Master** mode, this will trigger the switch of the 
[FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/).

{{< highlight shell >}}
ifconfig -g carp carpdemote
{{< /highlight >}}

{{% notice warning %}}
Don't forget to **Promote the carp interface**
{{% /notice %}}

### Drain the node

This command will tell [Nomad](https://www.nomadproject.io/) to stop the current allocations on the node and exclude
the node from further allocations:

{{< highlight shell >}}
nomad node drain -self -yes -enable
{{< /highlight >}}

{{% notice warning %}}
Don't forget to **Disable the drain mode on the node**
{{% /notice %}}

### Disable the drain mode on the node

This command will tell [Nomad](https://www.nomadproject.io/) to include the node for further allocations:

{{< highlight shell >}}
nomad node drain -self -yes -disable
{{< /highlight >}}

### Promote the carp interface

This will remove the counter on the [carp](https://www.openbsd.org/faq/pf/carp.html) interface, allowing it to have
a chance to be **Master**.

{{< highlight shell >}}
ifconfig -g carp -carpdemote
{{< /highlight >}}

## The Nomad's job

### The job

Here is the current job handling the [traefik](https://www.traefik.io/)'s instances:

{{< highlight python >}}
job "traefik" {
  datacenters = [
    "bi-sbg"]

  group "http" {
    count = 2

    reschedule {
      attempts = 5
      interval = "1h"
      delay = "30s"
      delay_function = "constant"
      unlimited = false
    }

    restart {
      attempts = 3
      interval = "5m"
      delay = "30s"
      mode = "fail"
    }

    update {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "2m"
      progress_deadline = "10m"
      stagger = "15s"
    }

    migrate {
      max_parallel = 1
      health_check = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "5m"
    }

    constraint {
      attribute = "${meta.client_type}"
      value = "edge"
    }

    constraint {
      operator = "distinct_hosts"
      value = "true"
    }

    task "service" {
      kill_timeout = "20s"

      driver = "raw_exec"

      config {
        command = "/usr/local/bin/traefik-nomad"
        args = [
          "--configfile",
          "local/traefik.yml"]
      }

      resources {
        network {
          port "api_dashboard" {
            static = 8080
          }
        }
      }

      service {
        name = "traefik"

        check {
          type = "http"
          port = "api_dashboard"
          path = "/ping"
          interval = "15s"
          timeout = "2s"
        }
      }

      env {
        MYPROVIDER_API_KEY_FILE = "/etc/traefik/myprovider.key"
      }

      template {
        data = <<EOF
http:
  routers:
    api:
      entryPoints:
        - "api_dashboard"
      rule: "PathPrefix(`/api`) || PathPrefix(`/dashboard`)"
      service: "api@internal"
      middlewares:
        - "api_dashboard_ipwhitelist@file"

  middlewares:
    api_dashboard_ipwhitelist:
      ipWhiteList:
        sourcerange: "127.0.0.1/32"
EOF

        destination = "local/traefik.d/api-dashboard.yml"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
http:
  middlewares:
    secure-headers:
      headers:
        customResponseHeaders:
          server: ""

tls:
  options:
    default:
      sniStrict: true
      minVersion: "VersionTLS12"
      cipherSuites:
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
        - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256

EOF

        destination = "local/traefik.d/middlewares-security.yml"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
entryPoints:
  web:
    address: ":80"

    http:
      redirections:
        entryPoint:
          to: "websecure"
          scheme: "https"

  websecure:
    address: ":443"

  api_dashboard:
    address: ":8080"

certificatesResolvers:
  letsencrypt:
    acme:
      email: "xxx"
      storage: "/etc/traefik/acme.json"
      dnsChallenge:
        provider: "myprovider"

api:
  dashboard: true

ping:
  entryPoint: "api_dashboard"

providers:
  file:
    directory: "local/traefik.d"

  consulCatalog:
    prefix: "traefik"
    exposedByDefault: false
    refreshInterval: "15s"

    endpoint:
      address: "127.0.0.1:8500"
      scheme: "http"

log:
  level: "DEBUG"
EOF

        destination = "local/traefik.yml"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
{{< /highlight >}}

### Run the job

To start the job, you only need to call its file.

{{< highlight shell >}}
nomad run <job name>.nomad
{{< /highlight >}}

### Check the status

Check the status of the different jobs:
{{< highlight shell >}}
nomad job status <job name>
{{< /highlight >}}

### The logs

It is also possible to access the logs of the different allocations.

Identify the allocation's id:
{{< highlight shell >}}
nomad job status <job name>
{{< /highlight >}}

You should have as a result:
{{< highlight shell >}}
Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created     Modified
168711f9  867e4021  traefik     72       run      running  17h35m ago  17h30m ago
8b45c8c1  65dec082  traefik     72       run      running  17h35m ago  17h30m ago
{{< /highlight >}}

For logs on stdout:
{{< highlight shell >}}
nomad alloc logs -f <alloc id>
{{< /highlight >}}

For logs on stderr:
{{< highlight shell >}}
nomad alloc logs -f -stderr <alloc id>
{{< /highlight >}}
