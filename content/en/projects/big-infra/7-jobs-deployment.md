---
title: "7. Jobs Deployment"
menuTitle: "7. Jobs Deployment"
description: "Jobs Deployment"
weight: 17
---

{{< toc >}}

## The jobs

Creating Nomad jobs is really straight-forward. 

### Traefik

The different steps to deploy **traefik** are:
- run the Nomad job that will:
    - execute the **traefik** process on the VMs:
        - respecting the constraints
        - declaring a service in Consul

### This website

The sources of this webiste are available [here](https://github.com/tristan-weil/www-t18s):
- its a hugo site, so there are only static files
- the Docker image is [nginx](https://nginx.org/) publishing those files

The different steps to deploy this website are:
- generate the pages
- copy them in a Docker image stored at [Github](https://github.com/users/tristan-weil/packages/container/package/www-t18s%2Fnginx)
- run the Nomad job that will:
    - download the Docker image from Github
    - deploy it on the node VMs:
        - respecting the constraints
        - declaring a service in Consul with tags allowing **traefik**:
            - to route the traffic
            - to apply middlewares and Let's Encrypt's certificates

{{% notice note %}}
See [here](https://github.com/tristan-weil/www-t18s/actions) for the Github Actions that creates the Docker image
{{% /notice %}}

### Run the jobs

To start a job, you only need to call its file.

{{< highlight shell >}}
nomad run <job name>.nomad
{{< /highlight >}}

## Check the status

Check the status:
{{< highlight shell >}}
nomad job status <job name>
{{< /highlight >}}

On important part is the stats about deployed instances:
{{< highlight shell >}}
Latest Deployment
ID          = e243a9eb
Status      = failed
Description = Failed due to progress deadline

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
http        0       0         2        7       69        0
{{< /highlight >}}

## Check the logs

Identify the alloc id:
{{< highlight shell >}}
nomad job status <job name>
{{< /highlight >}}

You should have as a result:
{{< highlight shell >}}
Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created     Modified
168711f9  867e4021  http        72       run      running  17h35m ago  17h30m ago
8b45c8c1  65dec082  http        72       run      running  17h35m ago  17h30m ago
{{< /highlight >}}

For logs on stdout:
{{< highlight shell >}}
nomad alloc logs -f <alloc id>
{{< /highlight >}}

For logs on stderr:
{{< highlight shell >}}
nomad alloc logs -f -stderr <alloc id>
{{< /highlight >}}

## Some screenshots

You should end with everything working together:

!["Consul"](/images/projects/bi/consul.png)

!["Traefik dashboard"](/images/projects/bi/traefik_dashboard.png)
