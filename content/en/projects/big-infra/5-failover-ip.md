---
title: "5. FailOver IP"
menuTitle: "5. FailOver IP"
description: "FailOver IP"
weight: 15
---

{{< toc >}}

## Why ?

In the current infrastructure, there is only one edge node that handle all the incoming Web traffic.\
The second one is a backup and is activated only in case of failure of the other.

This is achieved by using a [FailOver IP](https://www.ovhcloud.com/en/bare-metal/ip/) from OVH.

Because this IP can only be attached to one instance at a time and must be moved only with the [OVH API](https://api.ovh.com)
we will need some configurations.

We'll use OpenBSD's [carp](https://www.openbsd.org/faq/pf/carp.html) and [ifstated](https://man.openbsd.org/ifstated.8) 
features.

{{% notice note %}}
OVH does not offer an ELB like feature like Amazon Web Services.
You are on your own to implement redundancy.
{{% /notice %}}

## Prepare the network

### Get a FailOver IP

In the OVH console, buy a FailOver IP and attach it to one of the node.

### Create a private network

In the OVH console, put the 2 edge VMs in a second **private network**: this will allow to configure a third interface.

!["Vrack"](/images/projects/bi/ovh_vrack.png)

## carp and ifstated ?

Usually, **carp** is configured directly in the same subnet as the IP address(es) it manages.
It is in charge to handle the IP address(es) and the trafic through the underlying network interface.

Because we are on the OVH Public Cloud offer, we cannot (and don't want) to have our **carp interfaces** communicate 
their states on a public network.
That's why we created a second **private network**: the communication will only take place on this VLAN. \
But of course, the **carp interfaces** won't be able to handle the **FailOver IP** anymore.

Tha't why we also need the **ifstated** daemon: it will detect the change on the **carp interface** and manage the
**FailOver IP** accordingly but on another interface. 

## carp configuration

**carp** is configured on the interface that is present in the new **private network**.

### Choose a password

Carp communication can be authenticated with a password: choose one (stay with the range [a-Z0_9-_]).

### On the Master

Pick one node as the master and apply these configurations:

On `/etc/hostname.vio2`:
{{< highlight text >}}
up
{{< /highlight >}}

On `/etc/hostname.carp0`:
{{< highlight text >}}
inet 10.25.0.10 255.255.0.0 10.25.255.255 vhid 1 carpdev vio2 pass xxx advskew 1
up
{{< /highlight >}}

### On the Backup

On `/etc/hostname.vio2`:
{{< highlight text >}}
up
{{< /highlight >}}

On `/etc/hostname.carp0`:
{{< highlight text >}}
inet 10.25.0.10 255.255.0.0 10.25.255.255 vhid 1 carpdev vio2 pass xxx advskew 50
up
{{< /highlight >}}

### The firewall

Edit `/etc/pf.conf` to add:
{{< highlight text >}}
pass on vio2 proto carp
{{< /highlight >}}

and reload it:
{{< highlight shell >}}
pfctl -f /etc/pf.conf
{{< /highlight >}}

### Apply the configurations

On both VMs:
{{< highlight shell >}}
sh /etc/netstart carp0
{{< /highlight >}}

### Result

On the master node, you should see:
{{< highlight text >}}
carp0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	lladdr 00:00:5e:00:01:01
	index 6 priority 15 llprio 3
	carp: MASTER carpdev vio2 vhid 1 advbase 1 advskew 50
	groups: carp
	status: master
	inet 10.25.0.10 netmask 0xffff0000 broadcast 10.25.255.255
{{< /highlight >}}

On the backup node, you should see:
{{< highlight shell >}}
carp0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	lladdr 00:00:5e:00:01:01
	index 6 priority 15 llprio 3
	carp: BACKUP carpdev vio2 vhid 1 advbase 1 advskew 1
	groups: carp
	status: backup
	inet 10.25.0.10 netmask 0xffff0000 broadcast 10.25.255.255
{{< /highlight >}}

## ifstated

**ifstated** is able:
- to detect the modification of the status of an interface but also check the execution of a command
- execute commands in reaction of this changes

### The script

**ifstated** is started on both edge nodes of course.

Here is a example configuration:

{{< highlight shell >}}
    external_if_up = 'vio0.link.up'
    external_if_down = 'vio0.link.down'
    
    internal_if_up = 'vio1.link.up'
    internal_if_down = 'vio1.link.down'
    
    carp_if_up = 'carp0.link.up'
    carp_if_down = 'carp0.link.down'
    
    ping_ok = '"ping -q -c 1 -w 1 8.8.8.8 >/dev/null 2>&1" every 10'
    
    # the first state defined is the initial state
    state neutral {
            if $external_if_down {
                    run "logger -p daemon.info -sit ifstated 'interface vio0 (external) is down'"
                    set-state demoted
            }
            if $internal_if_down {
                    run "logger -p daemon.info -sit ifstated 'interface vio1 (internal) is down'"
                    set-state demoted
            }
            if $carp_if_down {
                    run "logger -p daemon.info -sit ifstated 'carp0 is backup'"
                    set-state demoted
            }
            if ! $ping_ok {
                    run "logger -p daemon.info -sit ifstated 'could not ping external server'"
                    set-state demoted
            }
            if $carp_if_up && $external_if_up && $internal_if_up && $ping_ok {
                    run "logger -p daemon.info -sit ifstated 'configure an alias for the failover public ip'"
                    run "ifconfig vio0 inet alias 146.59.143.231 netmask 255.255.255.255 2>&1 | logger -p daemon.info -sit ifstated"
                    run "logger -p daemon.info -sit ifstated 'claim failover public ip'"
                    run "/usr/local/bin/ipmoveOvh -project t18s -ip 146.59.143.231 -instance bi-edge-sbg-2 2>&1 | logger -p daemon.info -sit ifstated"
            }
    }
    
    state demoted {
            # initial command when entering this state
            init {
                    if $carp_if_up {
                            run "ifconfig -g carp carpdemote"
                    }
                    run "logger -p daemon.info -sit ifstated 'remove the alias of the failover public ip'"
                    run "ifconfig vio0 inet -alias 146.59.143.231"
            }
            if $external_if_up && $internal_if_up && $ping_ok {
                    run "logger -p daemon.info -sit ifstated 'all interfaces are up and ping is ok'"
                    run "ifconfig -g carp -carpdemote"
            }
            if $carp_if_up && $external_if_up && $internal_if_up && $ping_ok {
                    run "logger -p daemon.info -sit ifstated 'carp0 is master'"
                    set-state neutral
            }
    }
    
    # commands in the global scope are always run
    if carp0.link.up
            run "logger -p daemon.info -sit ifstated 'carp0 is master'"
    if carp0.link.down
            run "logger -p daemon.info -sit ifstated 'carp0 is backup'"
{{< /highlight >}}

{{% notice info %}}
**ifstated** cannot use variables in the *run* action: be carefull to update the script on the other node
{{% /notice %}}

### ipmoveOvh

Because the **FailOver IP** can only be moved using the [OVH API](https://api.ovh.com), we must use an external tool to
do it: [ipmoveOvh]({{< relref "/projects/ipmoveOvh" >}})

## Check everything is working

To test the configuration is working, go on the master node and put the **carp** interface down:
{{< highlight shell >}}
ifconfig carp0 down
{{< /highlight >}}

The backup node should take the master status and update the **FailOver IP**.
Go to the OVH console and check the association:

!["FailOver IP"](/images/projects/bi/ovh_failoverip.png)