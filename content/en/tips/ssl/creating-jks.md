---
title: "Creating JKS file"
menuTitle: "Creating JKS file"
description: "Creating a JKS store"
weight: 5
---

## Generate a Java keystore and key pair

{{< highlight shell >}}
keytool -genkey -alias mydomain -keyalg RSA -keystore keystore.jks -keysize 2048
{{< /highlight >}}

## Generate a CSR for an existing Java keystore

{{< highlight shell >}}
keytool -certreq -alias mydomain -keystore keystore.jks -file CSR.csr
{{< /highlight >}}

## Import a root or intermediate CA certificate

{{< highlight shell >}}
keytool -import -trustcacerts -alias root -file CA.crt -keystore keystore.jks
{{< /highlight >}}

## Import a signed certificate

{{< highlight shell >}}
keytool -import -trustcacerts -alias mydomain -file mydomain.crt -keystore keystore.jks
{{< /highlight >}}

##  Generate a keystore and self-signed certificate

{{< highlight shell >}}
keytool -genkey -keyalg RSA -alias selfsigned -keystore keystore.jks -storepass password -validity 360
{{< /highlight >}}
