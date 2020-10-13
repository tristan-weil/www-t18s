---
title: "fqdn/domain/nodename"
menuTitle: "fqdn/domain/nodename"
description: "The ansible_facts' nodename value"
---

Ansible is using the Python lib [socket](https://docs.python.org/3/library/socket.html) to fill 
the **fqdn** and **domain** value in the facts (**ansible_facts**).

But for the hostname, it uses the lib [platform](https://docs.python.org/3/library/platform.html).

And of course, as their names suggest it, they are retrieving the data with different approach:
- [socket](https://docs.python.org/3/library/socket.html) uses sockets {{< icon "fas fa-thumb-up" >}} and thus the network (in this cas: DNS resolution)
- [platform](https://docs.python.org/3/library/platform.html) only works locally

{{% notice warning %}}
The lib **socket** can sometimes be weird!
{{% /notice %}}  

In a corner case I encountered (see also https://bugs.python.org/issue5004\):
- OpenBSD
- no DNS records
- an entry in /etc/hosts (12.7.0.0.1 my.host.localdomain)

the **domain** value in **ansible_facts** was empty {{< icon "fas fa-bomb" >}} and thus unexpected behaviours occured.
The lib [socket](https://docs.python.org/3/library/socket.html) was obviously lost...

To avoid such problem, the solution is to rely only on the lib [platform](https://docs.python.org/3/library/platform.html).

So replace your `ansible_facts['domain]` with:
{{< highlight python >}}
ansible_facts['nodename'].split('.')[1:] | join('.')
{{< /highlight >}}

And your `ansible_facts['fqdn]` with:
{{< highlight python >}}
ansible_facts['nodename']
{{< /highlight >}}

