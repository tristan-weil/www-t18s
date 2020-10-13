---
title: "SOCKS proxy"
menuTitle: "SOCKS proxy"
description: "SOCKS proxy"
---

It is possible to **send all the traffic** through a remote machine by using a *SOCKS proxy* (version 5).

To start a `SOCKS proxy` on the local port 888, the following command can be used:
{{< highlight shell >}}
ssh -D 8888 user@remote_machine
{{< /highlight >}}

The `sshd` service of the remote machine must be configured with the following parameter:
{{< highlight shell >}}
AllowTcpForwarding yes
{{< /highlight >}}

With `curl`, to use the created `SOCKS proxy`, the following command can be used:

{{< highlight shell >}}
curl --preproxy socks5h://127.0.0.1:8888 www.google.fr
{{< /highlight >}}

{{% notice warning %}}
By default, the applications WILL NOT use the SOCKS proxy for their DNS requests.
You must be very careful in also encapsulating those requests (should be an option in the application).
{{% /notice %}}
