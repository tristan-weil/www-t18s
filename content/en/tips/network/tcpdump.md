---
title: "tcpdump"
menuTitle: "tcpdump"
description: "Packet inspection with tcpdump"
---

We can get **basic network informations** (to start an analysis) with the following command (as root):
{{< highlight shell >}}
tcpdump -nntttte -i <interface> -A -s0
{{< /highlight >}}

The option:
- -nn: unactivates the name and port resolution
- -tttt: displays the date and the hour in a readable format
- -e: adds the MAC address
- -i: selects the network interface
- -A: displays the data in ASCII format
- -s0: forces the display of all the contents (otherwise there could be some truncatures)


