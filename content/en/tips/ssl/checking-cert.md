---
title: "Checking Cert"
menuTitle: "Checking Cert"
description: "Checking SSL Certificate"
weight: 2
---

## Check a **CSR**

{{< highlight shell >}}
openssl req -text -noout -verify -in CSR.csr
{{< /highlight >}}

## Check a **private key**

{{< highlight shell >}}
openssl rsa -in privateKey.key -check
{{< /highlight >}}

## Check a **certificate**

{{< highlight shell >}}
openssl x509 -in certificate.crt -text -noout
{{< /highlight >}}

## Check a **PKCS#12 file (.pfx or .p12)**

{{< highlight shell >}}
openssl pkcs12 -info -in keyStore.p12
{{< /highlight >}}
