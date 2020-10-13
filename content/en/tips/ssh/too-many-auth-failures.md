---
title: "Too Many Authentication Failures"
menuTitle: "Too Many Authentication Failures"
description: "Too Many Authentication Failures"
---

By default, the **ssh** client will try all keys it found in the ~/.ssh directory.

So if you have a lot of them, it can be problematic because it will failed a lot of time and eventually be kicked
by the SSH server with this error:
{{< highlight shell >}}
Too Many Authentication Failures
{{< /highlight >}} 

To avoid this behaviour, add the following option to the command line (or directly in the ssh configuration file)
{{< highlight shell >}}
IdentitiesOnly=yes
{{< /highlight >}}

And then specify the method you want to use
{{< highlight shell >}}
ssh -o IdentitiesOnly=yes -o PreferredAuthentication=pubkey -i ~/.ssh/my_new_key root@<ip>
{{< /highlight >}}