---
title: "5. FailOver IP"
menuTitle: "5. FailOver IP"
description: "FailOver IP"
weight: 5
---

{{< toc >}}

So far, we have:
- all VMs provisioned
- a Consul cluster
- a Nomad cluster

The different services still need to be deployed, configured and **connected to the Internet**.

## What I want?

In the current infrastructure, there is only one edge node that handle all the incoming Web traffic.\
The second one is a backup and is activated only in case of failure of the other.

This is achieved by using a [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) from OVH.

Because this IP can only be attached to one instance at a time and must be moved only with the 
[OVH API](https://api.ovh.com) we will need some configuration.

We'll use OpenBSD's [carp](https://www.openbsd.org/faq/pf/carp.html), [ifstated](https://man.openbsd.org/ifstated.8) 
features to handle the fail-over at the system's level and [ipmoveOvh]({{< relref "/projects/ipmoveOvh" >}}) at 
OVH's level.

Of course, this part will be executed on the `edge` nodes.

{{% notice note %}}
OVH does not offer an ELB like feature like Amazon Web Services.
You are on your own to implement redundancy.
{{% /notice %}}

## Prepare the network

### Get a FailOver IP

In the OVH console, buy a [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) and attach it to one of the `edge` node.

## Problems

Usually, [carp](https://www.openbsd.org/faq/pf/carp.html) is in charge to handle the IP address(es) and the 
traffic through the underlying network interface it manages.

Because we are on the [OVH Public Cloud](https://www.ovhcloud.com/fr/public-cloud/) offer, we cannot (and don't want) 
to have our [carp](https://www.openbsd.org/faq/pf/carp.html) interfaces communicate their states on a public network.

{{% notice info %}}
It's possible to use carp inside an IPsec tunnel.
{{% /notice %}}

## Solutions 

That's why we need a second **private network**: the communication will only take place on this VLAN. \
But of course, the [carp](https://www.openbsd.org/faq/pf/carp.html) interfaces won't be able to handle the 
**FailOver IP** anymore.

We also need the [ifstated](https://man.openbsd.org/ifstated.8) daemon: it will detect the change on the 
[carp](https://www.openbsd.org/faq/pf/carp.html) interface and manage the 
[FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) accordingly but on another interface. 

### Create a private network

In the OVH console, put the 2 edge VMs in a second **private network**: this will allow to configure a third interface.

!["Vrack"](/images/projects/bi/ovh_vrack.png)

### Carp

[carp](https://www.openbsd.org/faq/pf/carp.html) is configured on the interface connected to the new **private network**.

#### Choose a password

[carp](https://www.openbsd.org/faq/pf/carp.html) communication can be authenticated with a password: choose one 
(stay with the range [a-Z0_9-_]).

#### On the Master

Pick one node as the **master** and apply these configurations:

On `/etc/hostname.vio2`:
{{< highlight text >}}
up
{{< /highlight >}}

On `/etc/hostname.carp0`:
{{< highlight text >}}
inet 10.25.0.10 255.255.0.0 10.25.255.255 vhid 1 carpdev vio2 pass xxx advskew 1
up
{{< /highlight >}}

#### On the Backup

On `/etc/hostname.vio2`:
{{< highlight text >}}
up
{{< /highlight >}}

On `/etc/hostname.carp0`:
{{< highlight text >}}
inet 10.25.0.10 255.255.0.0 10.25.255.255 vhid 1 carpdev vio2 pass xxx advskew 50
up
{{< /highlight >}}

#### Apply the configurations

On both VMs:
{{< highlight shell >}}
sh /etc/netstart carp0
{{< /highlight >}}

Don't forget to edit `/etc/pf.conf` and add:
{{< highlight text >}}
pass on vio2 proto carp
{{< /highlight >}}

and reload it:
{{< highlight shell >}}
pfctl -f /etc/pf.conf
{{< /highlight >}}

#### Result

On the **master** node, you should see:
{{< highlight text >}}
carp0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	lladdr 00:00:5e:00:01:01
	index 6 priority 15 llprio 3
	carp: MASTER carpdev vio2 vhid 1 advbase 1 advskew 50
	groups: carp
	status: master
	inet 10.25.0.10 netmask 0xffff0000 broadcast 10.25.255.255
{{< /highlight >}}

On the **backup** node, you should see:
{{< highlight shell >}}
carp0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	lladdr 00:00:5e:00:01:01
	index 6 priority 15 llprio 3
	carp: BACKUP carpdev vio2 vhid 1 advbase 1 advskew 1
	groups: carp
	status: backup
	inet 10.25.0.10 netmask 0xffff0000 broadcast 10.25.255.255
{{< /highlight >}}

### ifstated

Now, we have a working [carp](https://www.openbsd.org/faq/pf/carp.html) group.
As said, it is not enough to handle the switch of the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/)
from one instance to another.

We need [ifstated](https://man.openbsd.org/ifstated.8) because it can:
- detect the modification of the status of an interface but also check the execution of a command
- execute commands in reaction of this changes

So, we will be able to use it:
- when the node is in **master** state:
    - to add the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) as an alias of the Internet facing interface
    - to attach the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) to this node through the 
    [OVH API](https://api.ovh.com) with [ipmoveOvh]({{< relref "/projects/ipmoveOvh" >}})
- when the node is in **backup** state:
    - to remove the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) alias

#### The script

Here is the script I am using:

{{< highlight shell >}}
external_if_up = 'vio0.link.up'  
external_if_down = 'vio0.link.down'
                                                           
internal_if_up = 'vio1.link.up'                                                                                        
internal_if_down = 'vio1.link.down'
                                                           
carp_if_up = 'carp0.link.up'
carp_if_down = 'carp0.link.down'                                                                                       
                                                           
ping_ok = '"ping -q -c 1 -w 1 8.8.8.8 >/dev/null 2>&1" every 15'

# the first state defined is the initial state
state promoted {
        # a problem occured, try to remove our master status by being demoted
        if $external_if_down {
                set-state demoted
        }
        if $internal_if_down {
                set-state demoted
        }
        if ! $ping_ok {
                set-state demoted
        }
        if $carp_if_down {
                set-state demoted
        }

        # we are the master, claim the failover ip
        if $external_if_up && $internal_if_up && $ping_ok && $carp_if_up {
            run "logger -p daemon.info -sit ifstated '=> configure an alias for the failover public ip'"
            run "ifconfig vio0 inet alias 146.59.143.231 netmask 255.255.255.255 2>&1 | logger -p daemon.info -sit ifstated"
            run "logger -p daemon.info -sit ifstated '=> claim failover public ip'"
            run "/usr/local/bin/ipmoveOvh -project t18s -ip 146.59.143.231 -instance bi-edge-sbg-1 2>&1 | logger -p daemon.info -sit ifstated"
        }
}

state demoted {
        init {
                # force the demotion, increase the counter
                run "logger -p daemon.info -sit ifstated '=> carpdemote'"
                run "ifconfig -g carp carpdemote" 
        }

        # only remove the alias when no traffic are going to this host
        if $carp_if_down {
                run "logger -p daemon.info -sit ifstated '=> remove the alias of the failover public ip'"
                run "ifconfig vio0 inet -alias 146.59.143.231"
        }

        # everything is fine, decrease the counter
        if $carp_if_down && $external_if_up && $internal_if_up && $ping_ok {
                run "logger -p daemon.info -sit ifstated '=> remove carpdemote'"
                run "ifconfig -g carp -carpdemote" 
        }

        # this host just became master, so it is promoted
        if $carp_if_up && $external_if_up && $internal_if_up && $ping_ok {
                set-state promoted
        }
}

# print the status of all probes for every event
if $carp_if_up
        run "logger -p daemon.info -sit ifstated 'carp0 is master'"
if $carp_if_down
        run "logger -p daemon.info -sit ifstated 'carp0 is backup'"
if $external_if_up
        run "logger -p daemon.info -sit ifstated 'interface vio0 (external) is up'"
if $external_if_down
        run "logger -p daemon.info -sit ifstated 'interface vio0 (external) is down'"
if $internal_if_up
        run "logger -p daemon.info -sit ifstated 'interface vio1 (internal) is up'"
if $internal_if_down
        run "logger -p daemon.info -sit ifstated 'interface vio1 (internal) is down'"
if $ping_ok
        run "logger -p daemon.info -sit ifstated 'ping ok to external server'"
if ! $ping_ok
        run "logger -p daemon.info -sit ifstated 'could not ping external server'"

{{< /highlight >}}

You probably noticed that this script does not check if the [traefik](https://www.traefik.io) service is up and running.
Although it is totally possible to do it, it adds a degree of complexity to script that is not easy to handle if you want
to cover all cases (legitimate fail, actions by [Nomad](https://www.nomadproject.io/), manual actions by the SysAdmin, 
etc.). [ifstated](https://man.openbsd.org/ifstated.8) has not been designed for such cases.

I also like the idea that [ifstated](https://man.openbsd.org/ifstated.8), as a network daemon, only works with network
related events.

That's why, if we need to trigger this daemon and [carp](https://www.openbsd.org/faq/pf/carp.html), we'll have to do it
externally. 

{{% notice info %}}
[ifstated](https://man.openbsd.org/ifstated.8) cannot use variables in the *run* action.
{{% /notice %}}

{{% notice warning %}}
Do not forget to update the script on the second node.
{{% /notice %}}

## Check everything is working

To test the configuration is working, go on the master node and put the[carp](https://www.openbsd.org/faq/pf/carp.html) 
interface down:
{{< highlight shell >}}
ifconfig carp0 down
{{< /highlight >}}

The backup node should take the master status and update the [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/).
Go to the OVH console and check the association:

!["FailOver IP"](/images/projects/bi/ovh_failoverip.png)