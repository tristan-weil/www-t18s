---
title: "Creating Cert"
menuTitle: "Creating Cert"
description: "Creating a SSL Certificate"
weight: 5
---

## Generate a new private key (RSA)

{{< highlight shell >}}
openssl genrsa -out privateKey.key 4096
openssl ecparam -genkey -name secp384r1 -out privateKey.key
{{< /highlight >}}

## Generate a new private key (ECC)

{{< highlight shell >}}
openssl ecparam -genkey -name secp384r1 -out privateKey.key
{{< /highlight >}}

## Generate a self-signed certificate

{{< highlight shell >}}
openssl req -x509 -sha256 -nodes -days 365 -key privateKey.key -out certificate.crt
{{< /highlight >}}

## Generate a CSR for an existing private key

{{< highlight shell >}}
openssl req -out CSR.csr -key privateKey.key -new
{{< /highlight >}}

## Generate a CSR based on an existing certificate

{{< highlight shell >}}
openssl x509 -x509toreq -in certificate.crt -out CSR.csr -signkey privateKey.key
{{< /highlight >}}

## Remove a passphrase from a private key

{{< highlight shell >}}
openssl rsa -in privateKey.pem -out newPrivateKey.pem
{{< /highlight >}}
