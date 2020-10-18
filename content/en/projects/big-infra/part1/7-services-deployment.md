---
title: "7. Services' Deployment"
menuTitle: "7. Services' Deployment"
description: "Services' Deployment"
weight: 7
---

{{< toc >}}

## What I want?

The infrastructure should be running now: the last steps are to **deploy our services**.

## The services

### Traefik

See [here]({{< relref "/projects/big-infra/part1/6-traefik-deployment" >}})

### This website

#### The container

The sources of this webiste are available [here](https://github.com/tristan-weil/www-t18s):
- it's a [Hugo](http://gohugo.io/) site, so there are only static files
- the [Docker](https://www.docker.com/) image is a [nginx](https://nginx.org/) daemon
- The [Nomad](https://www.nomadproject.io/) job's source can also be found here

{{% notice note %}}
See [here](https://github.com/tristan-weil/www-t18s/actions) for the Github Actions that creates the Docker image
{{% /notice %}}

#### The job

The different steps to deploy this website are:
- on [Github Actions]((https://github.com/tristan-weil/www-t18s/actions)), pushing a new tag that will trigger:
    - the generation of the pages
    - their copy in a [Docker](https://www.docker.com/) image stored at 
    [Github](https://github.com/users/tristan-weil/packages/container/package/www-t18s%2Fnginx)

- manually running the [Nomad](https://www.nomadproject.io/) job that will:
    - download the [Docker](https://www.docker.com/) image from 
    [Github](https://github.com/users/tristan-weil/packages/container/package/www-t18s%2Fnginx)
    - deploy it on the node VMs:
        - respecting the constraints
        - declaring a service in Consul with tags allowing [traefik](https://www.traefik.io/):
            - to route the traffic
            - to apply middlewares and Let's Encrypt's certificates
        - using a random port (passed to the container using an environment variable)    

## Run the jobs

To start a job, you only need to call its file.

{{< highlight shell >}}
nomad run <job name>.nomad
{{< /highlight >}}

## Check the status

Check the status of the different jobs:
{{< highlight shell >}}
nomad job status
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

It is also possible to access the logs of the different allocations.

Identify the allocation's id:
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

You should end now with everything working together:

!["Consul"](/images/projects/bi/consul.png)

!["Traefik dashboard"](/images/projects/bi/traefik_dashboard.png)
