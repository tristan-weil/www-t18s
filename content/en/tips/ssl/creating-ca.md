---
title: "Managing a CA"
menuTitle: "Managing a CA"
description: "Creating a SSL Certificate Authority"
weight: 7
---

## Create the CA

### 1. Generate a new private key (RSA)

{{< highlight shell >}}
openssl genrsa -out privateKey.key 4096
openssl ecparam -genkey -name secp384r1 -out myCA.key
{{< /highlight >}}

### 1bis. Generate a new private key (ECC)

{{< highlight shell >}}
openssl ecparam -genkey -name secp384r1 -out myCA.key
{{< /highlight >}}

### 2. Create a new CA cert

{{< highlight shell >}}
openssl req -x509  -sha256 -nodes -days 1825 -key privateKey.key -out myCA.pem
{{< /highlight >}}

## Create a CSR

### 1. Generate a new private key (RSA)
{{< highlight shell >}}
openssl genrsa -out privateKey.key 4096
openssl ecparam -genkey -name secp384r1 -out privateKey.key
{{< /highlight >}}

### 1bis. Generate a new private key (ECC)
{{< highlight shell >}}
openssl ecparam -genkey -name secp384r1 -out privateKey.key
{{< /highlight >}}

### 2. Generate a CSR for an existing private key
{{< highlight shell >}}
openssl req -out CSR.csr -key privateKey.key -new
{{< /highlight >}}

### 3. Create an extension file

In a file named `extensions.ext`:

{{< highlight ini >}}
basicConstraints=CA:FALSE
subjectAltName=@my_subject_alt_names
subjectKeyIdentifier = hash

[ my_subject_alt_names ]
DNS.1 = *.domain.local
DNS.2 = *.domain2.local
{{< /highlight >}}

## Sign the CSR

{{< highlight shell >}}
openssl x509 -req -in CSR.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out certificate.crt -days 825 -sha256 -extfile extensions.ext
{{< /highlight >}}