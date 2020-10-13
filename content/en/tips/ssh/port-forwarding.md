---
title: "Port forwarding"
menuTitle: "Port forwarding"
description: "Port forwarding"
---

It is possible to make port forwarding between a local port and a distant port.

For example, to send the flows from the **local port 9999** to the **distant port 80**, the following command can be used:
{{< highlight shell >}}
ssh  -L 9999:127.0.0.1:80 user@remote_machine
{{< /highlight >}}

The `sshd` service of the remote machine must be configured with the following parameter:
{{< highlight shell >}}
AllowTcpForwarding yes
{{< /highlight >}}

With `curl`, to use the created port, the following command can be used:
{{< highlight shell >}}
curl http://127.0.0.1:9999
{{< /highlight >}}

{{% notice warning %}}
In the case of the HTTP protocol (and others), the domain name can be part of the configuration of the web server: 
the HTTP HEADERS must be set accordingly.
{{% /notice %}}
