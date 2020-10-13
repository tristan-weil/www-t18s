---
title: "Masking IPs"
menuTitle: "Masking IPs"
description: "Masking IPs addresses in the Caddy logs"
---

To **mask the IPs addresses** of your visitors in HAProxy, you can use the `ipmask` parameter.

It's a mask, so the "reverse" value must be supplied.

In this example, the complete IP addresses (v4 and v6) are masked:
{{< highlight python >}}
log-format '%[src,ipmask(16,64)]\ [%t]\ %ft\ %b/%s\ %Tw/%Tc/%Tt\ %B\ %ts\ %ac/%fc/%bc/%sc/%rc\ %sq/%bq'
{{< /highlight >}}

In this example, only the last half of the IP addresses (v4 and v6) are masked:
{{< highlight python >}}
log-format '%[src,ipmask(8,32)]\ [%t]\ %ft\ %b/%s\ %Tw/%Tc/%Tt\ %B\ %ts\ %ac/%fc/%bc/%sc/%rc\ %sq/%bq'
{{< /highlight >}}

{{% notice info %}}
The IPV6 support appeared in the `ipmask` function appeared in HAProxy 1.9.
{{% /notice %}}

{{% notice note %}}
The complete IP address will be transfered to the possible proxied services.
{{% /notice %}}

{{% notice warning %}}
The data is permanently lost in the logs (here a file).\
And this is a good thing :heart:
{{% /notice %}}

