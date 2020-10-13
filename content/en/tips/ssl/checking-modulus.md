---
title: "Checking the Modulus"
menuTitle: "Checking the Modulus"
description: "Checking SSL Certificate Modulus"
weight: 4
---

The modulus is an element found in the CSR, the private key and the certificate. \
It is **always** the same value.
So it is really useful when you need to prove that a certificate has not been generated from a CSR.

{{< highlight shell >}}
openssl x509 -noout -modulus -in certificate.crt | openssl md5
openssl rsa -noout -modulus -in privateKey.key | openssl md5
openssl req -noout -modulus -in CSR.csr | openssl md5
{{< /highlight >}}
