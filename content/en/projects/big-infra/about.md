---
title: "About"
menuTitle: "About"
description: "About"
weight: 1
---

## The current infrastructure

The current infra looks like this:
!["Infra V1"](/images/projects/bi/infra_v1.png)

## Why ?

I like building and testing new infrastructure tools {{< icon "fas fa-user-cog" >}} {{< icon "fas fa-cogs" >}} 
{{< icon "fas fa-cog" >}}

{{% notice warning %}}
The main goal of these pages:\
&nbsp;&nbsp;\- **is not to explain in details** how each services work and communicate with each others\
&nbsp;&nbsp;\- **is to list** the different steps I took and solutions I found
{{% /notice %}}

### What?

This infrastructure will hosts my services:
- this website ([Github](https://github.com/tristan-weil/www-t18s))
- the [gopher](gopher://gopher.t18s.fr) space ([Github](https://github.com/tristan-weil/xxx))
- the [finger](telnet://home@finger.t18s.fr) space ([Github](https://github.com/tristan-weil/xxx))
- more ?

### Why [OpenBSD](https://www.openbsd.org)?

When building "cloud" infrastructures, nowadays there is only one magical-word: *Docker* {{< icon "fas fa-hat-wizard" >}}

[Docker](https://www.docker.com/) (and other containers) and the ecosystem ([Kubernetes](https://kubernetes.io/), 
[Swarm](https://docs.docker.com/engine/swarm/), etc.) are a tremendous benefit for SysAdmins/DevOps/SysOps 
(insert something in Ops).

But it only makes sense if they are used wisely: where complex and repetitve deployments needs to be eased in order help 
and empower your entire team/project/company.
But keep in mind, it comes with its own complexity too, but at other levels.

That's why for some parts of your infrastructure, you can stick to old recipes if you don't want to lose your mind 
{{< icon "fas fa-ambulance" >}}

For this project, some parts won't need Docker because they won't move a lot / don't need to scale quickly or need 
special cares (security easily auditable, some manual actions needed, etc.): 
- the `core` stack (Consul Servers, Nomad Servers)
- the `edge` nodes (traefik)

And here comes [OpenBSD](https://www.openbsd.org). 

*OpenBSD* is my OS of choice for a ton of reasons: [some smart people](https://www.openbsdhandbook.com/) have 
already listed the main qualities and written a lots of helpful resources.
It's a great OS and is able to run everything I need and listed below.

Besides this, it's also a great way to learn on how programs and services work.
Indeed, running such complex services on a totally different OS will lead you to a lot of misconfigurations, bugs and 
questionings on how they really work. They don't benefit from total integration and tests 
you could usually find in popular Linux distributions.

### Why [Debian](https://www.debian.org)?

I've been using [Debian](https://www.debian.org) for a long time and it's still an efficient distribution for hobbyists
and professionals.

I will use it on the `node` (apps) nodes to deploy Docker containers.

### Why [Consul](https://www.consul.io)?

I want to build an infrastructure I can orchestrate with a high level of automation.

[Consul](https://www.consul.io) is a simple and complete services discovery tool that brings tons of benefits 
in an infrastructure. 
Thus, it's the first brick to make all the other tools flexible and smart.
It also integrates perfectly (of course) with [Nomad](https://www.nomadproject.io).

I have already used it in the past so I am just keeping my knowledge up-to-date.

### Why [Nomad](https://www.nomadproject.io)? 

I am building an infrastructure where the different services can:
- be deployed quickly
- scale
- communicates and be aware of other services' changes

So I need an orchestrator that can implement this directly or by using an already installed service.
And [Nomad](https://www.nomadproject.io):
- has a lots of connectors to Consul, Vault, etc.
- can manage containers and processes (and even VMs)
- is really simple to use and deploy

I have never used it and I really want to discover it.
There is not so many articles on the Internet but the official documentation is rather complete 
(as usual with [Hashicorp](https://www.hashicorp.com))

### Why [traefik](https://www.traefik.io)?

[traefik](https://www.traefik.io) seems to be the de-facto tool to easily:
- handle the routing between your applications
- act as a trafic proxy 
- manage Let's Encrypt/Acme certificates (without adding external tools and configurations)

I have never used it, so I wanted to give it a try as the main entrypoint for my infrastructure.

## And the ohers?

Of course, I also use [Ansible](https://www.ansible.com): it's the perfect tool to provision a system and to maintain it.\
Check my roles on my [GitHub](https://github.com/tristan-weil).

I also need OpenBSD's [carp](https://www.openbsd.org/faq/pf/carp.html) and [ifstated](https://man.openbsd.org/ifstated.8):
they are used to handle the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) from OVH
(you probably know a similar tool: [keepalived](https://keepalived.readthedocs.io/en/latest/)).

## Where?

All VMs are hosted on the [OVH Public Cloud](https://www.ovhcloud.com/fr/public-cloud/) offer.

## What about the security?

A lot more work is needed to achieve a decent secured infrastructure.

Here is what is already implemented:
- all VMs are not reachable from the Internet
- except for the bastion host (only SSH) and the edge nodes (only exposed services like HTTP/S)
- the fingerprint of the bastion is stored in DNS ([SSHFP]({{< relref "/tips/ssh/sshfp" >}}) record)
- they can communicate inside a [private network](https://www.ovh.com/world/solutions/vrack/) but firewall rules only 
allow expected services
- restricted SSH users' access on all VMs
- manually generated SSL certificates for Consul and Nomad communications

Here is what I need to do:
- TLS for all communications inside the private network
- SSL certificates automatically generated and short-lived
- ACL / tokens for communications inside the private network 

## So let'build!

{{< icon "fas fa-wrench" >}} The current infrastructure has been built using:
- [Part 1]({{< relref "/projects/big-infra/part1" >}}): the initial infrastructure
