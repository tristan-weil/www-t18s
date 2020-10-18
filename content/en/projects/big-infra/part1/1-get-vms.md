---
title: "1. Get some VMs"
menuTitle: "1. Get some VMs"
description: "Get some VMs"
weight: 1
---

{{< toc >}}

## What I want?

So, I need some VMs.

In the current infrastructure, I have:
- 1 VM for the `bastion`
    - it's the only machine with an SSH access to the Internet
    - it has also a DNS server
    - of course, it runs [OpenBSD](https://www.openbsd.org) 
- 3 VMs as the `core`
    - they host the Consul Servers and the Nomad Servers
    - of course, they run [OpenBSD](https://www.openbsd.org) 
- 3 VMs acting as working `nodes`
    - they run the services, as Docker containers
    - they are Consul Clients and Nomad Clients
    - they are powered by Debian (for Docker containers)
- 2 VMs acting as `edge` nodes
    - they handle the incoming Web traffic
    - of course, they run [OpenBSD](https://www.openbsd.org)     

## How?

I simply ordered the VMs from the [OVH Public Cloud](https://www.ovhcloud.com/fr/public-cloud/) offer, using the UI:
- I took the [Debian](https://www.debian.org) distribution for all of them
- **s1-2 instances** are doing well

{{% notice info %}}
Of course, all this work (and the next chapter) could have been done with [Ansible](https://www.ansible.com), 
[Terraform](https://www.terraform.io/) and some [Packer](https://www.packer.io/)'s templates 
VMs stored on OVH's Openstack.\
I'll probably do it in a future attempt.
{{% /notice %}}

## System installation

For the VMs with [Debian](https://www.debian.org): no problem, as they are totally supported.

### Problems

But [OVH Public Cloud](https://www.ovhcloud.com/fr/public-cloud/) does not support [OpenBSD](https://www.openbsd.org)  directly.

### Solution to install OpenBSD

We have to install [OpenBSD](https://www.openbsd.org) manually!

#### Prepare the conversion to OpenBSD

Connect to the VMs that need to be reinstalled to [OpenBSD](https://www.openbsd.org) with the SSH key you put on the 
OVH console and with the **debian** user:

{{< highlight shell >}}
ssh -i ~/.ssh/ovh_provisioning debian@<ip>
{{< /highlight >}}

Then as root, download the [ramdisk kernel](https://www.openbsd.org/faq/faq4.html#bsd.rd).
{{< highlight shell >}}
sudo -u root -i
cd / && wget https://ftp.fr.openbsd.org/pub/OpenBSD/6.7/amd64/bsd.rd
{{< /highlight >}}

We will reboot the machine and ask Grub to boot on the ramdisk kernel.

So before rebooting, edit the Grub menu in `/etc/grub.d/40_custom`:
{{< highlight ini >}}
menuentry "OpenBSD" {
       set root=(hd0,msdos1)
       kopenbsd /bsd.rd
}
{{< /highlight >}}

And add some timeout by editing `/etc/default/grub`:
{{< highlight ini >}}
GRUB_TIMEOUT=600
{{< /highlight >}}

Don't forget to update the microcode and then reboot:
{{< highlight shell >}}
update-grub
reboot
{{< /highlight >}}

#### Convert to OpenBSD

Go to the OVH console and access each VM's VNC console: you can now install [OpenBSD](https://www.openbsd.org) as usual {{< icon "fas fa-glass-cheers" >}}

For the paritioning, here is mine:
{{< highlight shell >}}
sd0> p m
OpenBSD area: 128-20970240; size: 10239.3M; free: 0.0M
#                size           offset  fstype [fsize bsize   cpg]
  a:          1024.3M              128  4.2BSD   2048 16384 12960 # /
  b:           256.2M          2097920    swap                    # none
  c:         10240.0M                0  unused                    
  d:          1024.4M          2622720  4.2BSD   2048 16384 12960 # /tmp
  e:          3072.5M          4720640  4.2BSD   2048 16384 12960 # /usr
  f:          4861.9M         11013120  4.2BSD   2048 16384 12947 # /var
{{< /highlight >}}

## Network

### Create a private network

In the OVH console, put all VMs in a **private network**: this will allow to configure the secondary interface.

!["Vrack"](/images/projects/bi/ovh_vrack.png)

You could already create a second **private network**: it will be used for the carp communication between the edge nodes.

### Configure the VMs

#### Problems with DHCP and OpenBSD

I experienced some issues with [OpenBSD](https://www.openbsd.org) and DHCP, so I will configure everything as static.

#### Solutions
 
On both [Debian](https://www.debian.org) and [OpenBSD](https://www.openbsd.org) hosts, configure the network interfaces 
as static interfaces:

On OpenBSD:
{{< highlight shell >}}
vi /etc/hostname.vio1
sh /etc/netstart vio1
vi /etc/hostname.vio0
sh /etc/netstart vio0
{{< /highlight >}}

On Debian:
{{< highlight shell >}}
vi /etc/network/interfaces
systemctl restart networking
{{< /highlight >}}
