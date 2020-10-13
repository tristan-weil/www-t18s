---
title: "Masking IPs"
menuTitle: "Masking IPs"
description: "Masking IPs addresses in the Caddy logs"
---

To **mask the IPs addresses** of your visitors in Caddy, you can use the `ipmask` parameter from the `log` plugin.

It's a mask, so the "reverse" value must be supplied.

In this example, the complete IP addresses (v4 and v6) are masked:
{{< highlight python >}}
log / /path/to/logs "{common}" {
  ipmask          0.0.0.0 0000:0000:0000:0000:0000:0000:0000:0000
}
{{< /highlight >}}

In this example, only the last half of the IP addresses (v4 and v6) are masked:
{{< highlight python >}}
log / /path/to/logs "{common}" {
  ipmask          255.255.0.0 ffff:ffff:ffff:ffff::
}
{{< /highlight >}}

{{% notice note %}}
The complete IP address will be transfered to the possible proxied services.
{{% /notice %}}

{{% notice warning %}}
The data is permanently lost in the logs (here a file).\
And this is a good thing :heart:
{{% /notice %}}