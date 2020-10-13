---
title: "Checking JKS file"
menuTitle: "Checking JKS file"
description: "Checking JKS store"
weight: 3
---

## List all certificates in a JKS

{{< highlight shell >}}
keytool -list -v -keystore keystore.jks
{{< /highlight >}}

## Check a particular certificate using an alias

{{< highlight shell >}}
keytool -list -v -keystore keystore.jks -alias mydomain
{{< /highlight >}}