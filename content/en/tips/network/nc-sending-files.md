---
title: "Sending files with nc"
menuTitle: "Sending files with nc"
description: "Sending files with nc"
---

Sometime, you need to **send a file** from a remote machine, the `source`, to another remote machine, the `destination`. \
The SSH access to the machines is allowed from your computer, but not between them.

We can hence use the `nc` command if the firewall rules allow it.

On the machine `destination`:
{{< highlight shell >}}
nc -l -p 1234 | uncompress -c | tar xvfp -
{{< /highlight >}}  

On the machine `source`:
{{< highlight shell >}}
tar cfp - /a/path | compress -c | nc machine_destination 1234
{{< /highlight >}}

{{% notice warning %}}
The `nc` command doesn't provide any mechanism to check the quality of the transferred data (no re-transfer nor retry):
**do checksums**.
{{% /notice %}}