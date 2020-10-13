---
title: "4. Nomad"
menuTitle: "4. Nomad"
description: "Nomad"
weight: 14
---

{{< toc >}}

## Deployment

[Nomad](https://www.nomadproject.io/) binaries are available from the main site or from many package managers.

For now, this is how we are going to configure each agent:
- no ACLs
- TLS is activated with manually generated certificates for the servers and the clients
- the API is only accessible locally and with no TLS

## Generate the encryption key

The encryption key is used to encrypt all communications between servers.
Here is a simple way to generate one:
{{< highlight shell >}}
nomad operator keygen
{{< /highlight >}}

We'll use it later in the configuration files.

## Generate the certificates

### The CA

First we need a CA:
{{< highlight shell >}}
consul tls ca create -domain nomad -additional-name-constraint=intra.terror.ninja -name-constraint 
{{< /highlight >}}

This will give you something like:
{{< highlight text >}}
> openssl x509 -in nomad-ca.pem -text -noout   
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            5f:87:33:aa:e0:b7:1a:5d:db:5f:c2:b3:73:68:57:0e
    Signature Algorithm: ecdsa-with-SHA256
        Issuer: C=US, ST=CA, L=San Francisco/street=101 Second Street/postalCode=94105, O=HashiCorp Inc., CN=Consul Agent CA 126978667616692623453696393235535517454
        Validity
            Not Before: Sep 16 19:40:18 2020 GMT
            Not After : Jul 26 19:40:18 2030 GMT
        Subject: C=US, ST=CA, L=San Francisco/street=101 Second Street/postalCode=94105, O=HashiCorp Inc., CN=Consul Agent CA 126978667616692623453696393235535517454
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub: 
                    04:4a:65:75:8b:26:72:3b:a6:ba:a8:0e:87:3e:89:
                    d0:a4:39:aa:eb:54:29:69:09:62:87:05:a6:2e:5b:
                    a9:90:eb:fc:00:ef:e6:da:18:8a:24:31:42:3a:18:
                    6b:06:89:55:39:0a:e4:ec:df:8b:16:ea:2f:a8:1d:
                    7f:5d:66:6a:f3
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Subject Key Identifier: 
                3D:B3:DA:67:16:65:C8:64:E3:1F:FB:96:81:5E:C8:9A:37:9B:CC:05:1B:93:CD:3B:28:3B:8B:03:6F:0A:E9:B5
            X509v3 Authority Key Identifier: 
                keyid:3D:B3:DA:67:16:65:C8:64:E3:1F:FB:96:81:5E:C8:9A:37:9B:CC:05:1B:93:CD:3B:28:3B:8B:03:6F:0A:E9:B5

            X509v3 Name Constraints: critical
                Permitted:
                  DNS:intra.terror.ninja
                  DNS:nomad
                  DNS:localhost

    Signature Algorithm: ecdsa-with-SHA256
         30:46:02:21:00:e7:b4:4b:cb:8d:b6:d9:49:d8:6f:9b:12:e1:
         4b:dd:26:0f:49:75:58:59:e0:25:fa:c3:60:93:af:aa:82:58:
         53:02:21:00:9a:20:da:d3:da:31:27:32:8d:48:c9:b1:34:fb:
         a8:75:5f:88:d9:ee:b2:d7:9d:42:da:88:35:58:23:47:88:ce
{{< /highlight >}}

### The Nomad Servers' certificates

Then the certificates for the 3 servers:

{{< highlight shell >}}
consul tls cert create -server -domain=nomad -dc=eu -additional-dnsname=bi-core-sbg-1.intra.terror.ninja -additional-ipaddress=x.x.x.x
consul tls cert create -server -domain=nomad -dc=eu -additional-dnsname=bi-core-sbg-2.intra.terror.ninja -additional-ipaddress=x.x.x.x
consul tls cert create -server -domain=nomad -dc=eu -additional-dnsname=bi-core-sbg-3.intra.terror.ninja -additional-ipaddress=x.x.x.x
{{< /highlight >}}

This will give you something like:
{{< highlight text >}}
> openssl x509 -in nomad-server.pem -text -noout 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            0d:9e:a5:ba:fd:e3:d0:34:25:ed:61:68:9e:74:57:0f
    Signature Algorithm: ecdsa-with-SHA256
        Issuer: C=US, ST=CA, L=San Francisco/street=101 Second Street/postalCode=94105, O=HashiCorp Inc., CN=Consul Agent CA 126978667616692623453696393235535517454
        Validity
            Not Before: Sep 16 19:40:32 2020 GMT
            Not After : Sep  1 19:40:32 2023 GMT
        Subject: CN=server.eu.nomad
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub: 
                    04:17:fa:46:1a:55:e7:95:31:1d:4d:a7:26:9e:c9:
                    b1:dd:7d:4c:f8:4f:6a:30:a2:2f:4c:bb:f7:a6:75:
                    1a:4b:ce:15:05:a5:8e:97:c9:fa:87:43:77:b0:fa:
                    a6:38:19:56:49:95:04:41:dc:dc:70:b0:1c:8e:d1:
                    fc:01:7b:f1:48
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                BE:F3:0C:BE:49:B9:11:C1:C0:0C:69:87:B8:A6:8A:2A:81:40:1F:63:D9:C8:C0:60:51:F9:3C:F6:38:EC:4C:AF
            X509v3 Authority Key Identifier: 
                keyid:3D:B3:DA:67:16:65:C8:64:E3:1F:FB:96:81:5E:C8:9A:37:9B:CC:05:1B:93:CD:3B:28:3B:8B:03:6F:0A:E9:B5

            X509v3 Subject Alternative Name: 
                DNS:bi-core-sbg-1.intra.terror.ninja, DNS:server.eu.nomad, DNS:localhost, IP Address:10.20.130.52, IP Address:127.0.0.1
    Signature Algorithm: ecdsa-with-SHA256
         30:45:02:21:00:a4:8b:c5:8c:04:11:ec:bb:16:9b:b5:62:45:
         ef:00:0f:37:90:35:bd:d0:ff:9b:93:f3:c9:a0:ce:bb:4b:d6:
         d2:02:20:36:df:b4:53:55:97:fe:f4:af:6e:2a:ef:b9:19:a9:
         36:24:f8:fc:84:3f:4c:1e:f9:6c:c0:b7:10:f1:dd:5a:d0
{{< /highlight >}}

### The Nomad Clients' certificates

Finally the certificates for the 3 clients:
{{< highlight shell >}}
consul tls cert create -client -domain=nomad -dc=eu -additional-dnsname=bi-node-sbg-1.intra.terror.ninja -additional-ipaddress=x.x.x.x
consul tls cert create -client -domain=nomad -dc=eu -additional-dnsname=bi-node-sbg-2.intra.terror.ninja -additional-ipaddress=x.x.x.x
consul tls cert create -client -domain=nomad -dc=eu -additional-dnsname=bi-node-sbg-3.intra.terror.ninja -additional-ipaddress=x.x.x.x
{{< /highlight >}}

This will give you something like:
{{< highlight text >}}
> openssl x509 -in nomad-client.pem -text -noout 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            f4:53:45:32:f2:92:bc:cc:0f:24:3d:98:47:8d:d1:0f
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = US, ST = CA, L = San Francisco, street = 101 Second Street, postalCode = 94105, O = HashiCorp Inc., CN = Consul Agent CA 126978667616692623453696393235535517454
        Validity
            Not Before: Sep 16 19:43:47 2020 GMT
            Not After : Sep  1 19:43:47 2023 GMT
        Subject: CN = client.eu.nomad
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:b4:bd:34:c3:e5:71:d7:34:8e:99:d6:bc:ea:2e:
                    8f:14:78:90:73:93:03:a0:81:eb:a2:b3:31:d8:45:
                    d6:2c:a7:8e:ce:cc:dc:e0:77:9b:dd:a8:44:29:b4:
                    ce:b1:3f:d9:a3:a2:65:7f:6d:06:fe:7a:45:66:94:
                    e2:f9:72:e0:77
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                AB:35:41:2F:89:65:4F:4C:44:48:04:41:C7:D1:D8:9F:80:C1:3A:BF:19:75:EF:AC:EE:7D:76:AE:D5:BB:A1:E3
            X509v3 Authority Key Identifier: 
                keyid:3D:B3:DA:67:16:65:C8:64:E3:1F:FB:96:81:5E:C8:9A:37:9B:CC:05:1B:93:CD:3B:28:3B:8B:03:6F:0A:E9:B5

            X509v3 Subject Alternative Name: 
                DNS:bi-node-sbg-2.intra.terror.ninja, DNS:client.eu.nomad, DNS:localhost, IP Address:10.20.131.42, IP Address:127.0.0.1
    Signature Algorithm: ecdsa-with-SHA256
         30:44:02:20:4b:66:1d:fe:29:ec:02:1a:9d:3c:22:11:15:63:
         03:d6:aa:67:ad:28:35:d5:58:6d:51:c2:87:f2:63:c9:a6:74:
         02:20:20:19:3c:67:b9:8f:bd:b4:4d:d6:cf:2d:25:9c:7e:94:
         29:ad:9f:1b:db:07:4e:b8:c6:7e:30:b0:43:a4:39:f8
{{< /highlight >}}

## Ports to open

See https://www.nomadproject.io/docs/configuration#ports.

So, you need at least:
- TCP: 4648, 4647
- UDP: 4648, 4647

## Server configuration

Here is a server configuration file:
{{< highlight text >}}
addresses {
  http = "127.0.0.1"
}
advertise {
  http = "127.0.0.1"
}
bind_addr = "{{ GetInterfaceIP `vio1` }}"
consul {
  address = "127.0.0.1:8500"
  auto_advertise = true
  client_auto_join = true
  client_service_name = "nomad-client"
  server_auto_join = true
  server_service_name = "nomad"
}
data_dir = "/var/nomad"
datacenter = "bi-sbg"
disable_anonymous_signature = true
disable_update_check = true
enable_syslog = true
leave_on_interrupt = true
leave_on_terminate = true
log_level = "INFO"
name = "bi-core-sbg-1"
region = "eu"
server {
  bootstrap_expect = 3
  enabled = true
  encrypt = "xxxx"
}
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
tls {
  ca_file = "/etc/ssl/nomad/nomad-ca.pem"
  cert_file = "/etc/ssl/nomad/nomad-server.pem"
  key_file = "/etc/ssl/nomad/nomad-server-key.pem"
  rpc = true
  verify_server_hostname = true
}
{{< /highlight >}}

## Client configuration

Here is a client configuration file:
{{< highlight text >}}
addresses {
  http = "127.0.0.1"
}
advertise {
  http = "127.0.0.1"
}
bind_addr = "{{ GetInterfaceIP `vio1` }}"
client {
  enabled = true
  network_interface = "vio1"
  node_class = "prod"
  meta {
    client_type = "edge"
  }
}
plugin "raw_exec" {
  config {
    enabled = true
  }
}
consul {
  address = "127.0.0.1:8500"
  auto_advertise = true
  client_auto_join = true
  client_service_name = "nomad-client"
  server_auto_join = true
  server_service_name = "nomad"
}
data_dir = "/var/nomad"
datacenter = "bi-sbg"
disable_anonymous_signature = true
disable_update_check = true
enable_syslog = true
leave_on_interrupt = true
leave_on_terminate = true
log_level = "INFO"
name = "bi-edge-sbg-2"
region = "eu"
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
tls {
  ca_file = "/etc/ssl/nomad/nomad-ca.pem"
  cert_file = "/etc/ssl/nomad/nomad-client.pem"
  key_file = "/etc/ssl/nomad/nomad-client-key.pem"
  rpc = true
  verify_server_hostname = true
}
{{< /highlight >}}

Note some important configuration options:
- to let Nomad execute processes (usefull on OpenBSD)
{{< highlight text >}}
plugin "raw_exec" {
  config {
    enabled = true
  }
}
{{< /highlight >}}
- the **meta** data allow to specialize nodes and let Nomad use them as constraints when starting jobs
{{< highlight text >}}
client {
  enabled = true
  network_interface = "vio1"
  node_class = "prod"
  meta {
    client_type = "edge"
  }
}
{{< /highlight >}}

{{% notice info %}}
The Nomad service needs to be run with enough privileges.\
If you only want to start Docker images, the user running the service should be in the **docker** group.\
If you want to start processes, be careful with the chosen user as they inherit from it.
{{% /notice %}}

## Check everything is working

We can check everything is working by looking at the logs and with those simple commands:
{{< highlight shell >}}
> nomad server members
Name              Address        Port  Status  Leader  Protocol  Build   Datacenter  Region
bi-core-sbg-1.eu  x.x.x.x        4648  alive   false   2         0.11.1  bi-sbg      eu
bi-core-sbg-2.eu  x.x.x.x        4648  alive   false   2         0.11.1  bi-sbg      eu
bi-core-sbg-3.eu  x.x.x.x        4648  alive   true    2         0.11.1  bi-sbg      eu
{{< /highlight >}}

and

{{< highlight shell >}}
> nomad node status
ID        DC      Name           Class  Drain  Eligibility  Status
bb61d930  bi-sbg  bi-node-sbg-2  prod   false  eligible     ready
b6af4099  bi-sbg  bi-node-sbg-1  prod   false  eligible     ready
0281f4e7  bi-sbg  bi-node-sbg-3  prod   false  eligible     ready
{{< /highlight >}}