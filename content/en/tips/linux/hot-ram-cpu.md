---
title: "Adding RAM and CPU"
menuTitle: "Adding RAM and CPU"
description: "Hot-adding RAM and CPU in Linux"
---

It is possible to hot-add RAM and CPU (useful in virtual environment) without rebooting the machine.

The following commands can be used.

For the RAM (as root):
{{< highlight shell >}}
for i in $(grep -l offline /sys/devices/system/memory/*/state); do echo online > $i; done
{{< /highlight >}}

For the CPU (as root):
{{< highlight shell >}}
for i in $(grep -l 0 /sys/devices/system/cpu/*/online); do echo 1 > $i; done
{{< /highlight >}}

{{% notice warning %}}
If the RAM or CPU amounts are reduced, it is of course advised to do it after shutting down the machine.
{{% /notice %}}