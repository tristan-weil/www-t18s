---
title: "2. Provision the VMs"
menuTitle: "2. Provision the VMs"
description: "Provision the VMs"
weight: 2
---

{{< toc >}}

## What I want?

The VMs are up and running, now I need to provision them.

## How?

For this first attempt to build this infrastructure, I'll use [Ansible](https://www.ansible.com) to provision all the VMs.

I really like Ansible because:
- you can easily deploy fine-grained configurations (OpenNTPd, OpenSMTPd, firewall, skel files, etc.)
- the code is quite straightforward and easy to understand
- it's fast to fix an error and redeploy

I use the different roles and playbooks you can found on my [GitHub](https://github.com/tristan-weil).

## The Bastion

The bastion machine will be the first to be installed because we will then use it as the only entrance to others machines
(see [SSH ProxyJump]({{< relref "/tips/ssh/proxy-jump" >}}))

{{% notice info %}}
Note that I push the [SSHFP]({{< relref "/tips/ssh/sshfp" >}}) record of the bastion host to my DNS registrar.
{{% /notice %}}

## The VMs

The provisioning has 2 steps:
- the first one:
    - installs the requirements (Ansible's user + python)

- the second one:
    - installs and configures the system
    - finally closes the Internet facing ports

Even if the Internet facing SSH port is only closed at the end, the VMs are provisioned by jumping the bastion:
- to avoid the final network cut
- to be able to validate completely this "path" in order to be confident for further deployments

So we need to override the `ansible_ssh_common_args` variable for all my hosts:

{{< highlight yaml >}}
ansible_ssh_common_args: "-o StrictHostKeyChecking=accept-new {% if ansible_host == bi_internal_ip %}-o ProxyCommand=\"ssh -W %h:%p -i {{ bi_proxyjump_privkey }} -q proxyjump@{{ hostvars[ groups['bastion'] | first ]['bi_external_ip'] }}\"{% endif %}"
{{< /highlight >}}

With a `host` file looking this:
{{< highlight yaml >}}
[all]
bi-core-sbg-1       ansible_host=x.x.x.x    bi_external_ip=x.x.x.x     bi_internal_ip=x.x.x.x    bi_gateway=x.x.x.x
bi-core-sbg-2       ansible_host=x.x.x.x    bi_external_ip=x.x.x.x     bi_internal_ip=x.x.x.x    bi_gateway=x.x.x.x
bi-core-sbg-3       ansible_host=x.x.x.x    bi_external_ip=x.x.x.x     bi_internal_ip=x.x.x.x    bi_gateway=x.x.x.x
{{< /highlight >}}

{{% notice info %}}
An Ansible dynamic inventory could here be usefull.
{{% /notice %}}

## Note on the DNS server

I have installed a DNS server because:
- OVH does not provide one
- I don't request the Openstack API to gather meta-data from hosts (and thus not using the 
[auto-join](https://www.consul.io/docs/install/cloud-auto-join) feature from Consul)
- I need to make the services find each other
- I want to have a DNS resolver for my infrastructure

Each new provisioned VM will register itself in the DNS server using [nsupdate](https://en.wikipedia.org/wiki/Nsupdate).

{{% notice info %}}
The server is [knot](https://www.knot-dns.cz/).
{{% /notice %}}