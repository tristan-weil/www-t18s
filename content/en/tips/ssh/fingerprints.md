---
title: "Fingerprints"
menuTitle: "Fingerprints"
description: "Manage SSH fingerprints"
---

## Generate a public key from a private key

To **generate a public key** from a private key:

{{< highlight shell >}}
 ssh-keygen -y -f ~/.ssh/<private key>
{{< /highlight >}}

## Gather the SSH fingerprints of a machine

To **gather the SSH fingerprints** of a machine and add them in the `known_hosts` file:

{{< highlight shell >}}
ssh-keyscan -H <host or ip> >> ~/.ssh/known_hosts
{{< /highlight >}}

## Delete the fingerprints SSH of a machine

To **delete the SSH fingerprint** of a machine and remove them from the `known_hosts` file:

{{< highlight shell >}}
ssh-keygen -R <host or ip> -f ~/.ssh/known_hosts
{{< /highlight >}}
