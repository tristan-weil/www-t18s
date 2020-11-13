---
title: "ipmoveOvh"
menuTitle: "ipmoveOvh"
description: "A little tool to move FailOver IP at OVH"
chapter: false
weight: 2
---

{{< toc >}}


## What ?

{{< icon "fab fa-github" >}}&nbsp;[**ipmoveOvh**](https://github.com/tristan-weil/ipmoveOvh) is a simple tool
dedicated to move an OVH [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) from one instance to another.

It uses [go-ovh](https://github.com/ovh/go-ovh) and thus uses the [OVH API](https://api.ovh.com).

See the dedicated [Github](https://github.com/tristan-weil/ipmoveOvh) for more information on how to use it.

## Why ?

For the [Big Infra]({{< relref "/projects/big-infra" >}}) project, I need to have 2 nodes in a Master/Backup
configuration to handle the incoming traffic **for only one public IP**.

Because:
- there is no equivalent for the Amazon Web Services' ELB at OVH
- the FailOver IP can only be moved through the OVH API (you cannot declare in advance the instances),

I had to create this little tool.

## What have I learned ?

The [OVH API](https://api.ovh.com) is really well designed and complete.

It also seems to be well-secured with different kind of tokens.
By default they need to be validated by a human action, but for automatic processes you can use:
https://eu.api.ovh.com/createToken/
