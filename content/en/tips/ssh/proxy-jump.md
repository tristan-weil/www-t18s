---
title: "ProxyJump"
menuTitle: "ProxyJump"
description: "ProxyJump"
---

ProxyJump allows a SSH connection to be used as a proxy for another SSH connection.\
It is thus possible to use a host as a bastion before reaching other hosts.

For example, to reach the host `remote.restricted-domain.local` using `bastion.domain.local` as a proxy:
{{< highlight shell >}}
ssh -J user@bastion.domain.local user@192.168.0.10
{{< /highlight >}}

{{% notice info %}}
If you have an internal DNS server, you can use the DNS name of your host.\
It's the proxy machine that will resolves it for you!
{{% /notice %}}

It is also possible to use multiple proxies:
{{< highlight shell >}}
ssh -J user@bastion1.domain.local,user@bastion2.domain.local user@remote.restricted-domain.local
{{< /highlight >}}

The `sshd` service on the proxy machine must be configured with the following parameter:
{{< highlight ini >}}
AllowTcpForwarding yes
{{< /highlight >}}

{{< icon "far fa-lightbulb" >}}&nbsp;You can also restrict the port reachable by the SSH connection jumping the proxy machine:

{{< highlight ini >}}
PermitOpen *:22
{{< /highlight >}}
