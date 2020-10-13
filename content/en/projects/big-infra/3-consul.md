---
title: "3. Consul"
menuTitle: "3. Consul"
description: "Consul"
weight: 13
---

{{< toc >}}

## Deployment

[Consul](https://www.consul.io/) binaries are available from the main site or from many package managers.

For now, this is how we are going to configure each agent:
- no ACLs
- TLS is activated with manually generated certificates for the servers
- TLS is activated with cluster-managed certificates for the clients
- the API is only accessible locally and with no TLS

## Generate the encryption key

The encryption key is used to encrypt all communications.
Here is a simple way to generate one:
{{< highlight shell >}}
consul keygen
{{< /highlight >}}

We'll use it later in the configuration files.

## Generate the certificates

### The CA

First we need a CA:
{{< highlight shell >}}
consul tls ca create -domain consul -additional-name-constraint=my.domain -name-constraint
{{< /highlight >}}

This will give you something like:
{{< highlight text >}}
> openssl x509 -in consul-ca.pem -text -noout                                                                                                                                                                                 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            1d:ee:c7:ed:0e:67:69:7b:b6:5c:69:12:9d:32:1a:23
    Signature Algorithm: ecdsa-with-SHA256
        Issuer: C=US, ST=CA, L=San Francisco/street=101 Second Street/postalCode=94105, O=HashiCorp Inc., CN=Consul Agent CA 39787432322714861766387827631839124003
        Validity
            Not Before: Sep 16 19:35:55 2020 GMT
            Not After : Jul 26 19:35:55 2030 GMT
        Subject: C=US, ST=CA, L=San Francisco/street=101 Second Street/postalCode=94105, O=HashiCorp Inc., CN=Consul Agent CA 39787432322714861766387827631839124003
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub: 
                    04:6a:10:8d:c3:07:55:7c:f2:f7:3a:db:a0:20:d3:
                    db:bd:1c:b8:b6:8e:dc:12:69:67:08:d0:15:04:70:
                    1c:11:2e:f7:13:6c:b7:a8:8b:9d:95:d9:90:b2:0d:
                    94:66:9e:2f:08:83:cb:b0:4e:9f:b7:58:c1:61:e8:
                    6e:86:ed:45:60
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Subject Key Identifier: 
                8B:66:D6:55:FE:5E:A8:39:F1:DC:FA:C6:7D:05:55:AF:EE:6C:BC:01:56:F7:4E:AA:33:8B:76:ED:1C:45:91:07
            X509v3 Authority Key Identifier: 
                keyid:8B:66:D6:55:FE:5E:A8:39:F1:DC:FA:C6:7D:05:55:AF:EE:6C:BC:01:56:F7:4E:AA:33:8B:76:ED:1C:45:91:07

            X509v3 Name Constraints: critical
                Permitted:
                  DNS:intra.terror.ninja
                  DNS:consul
                  DNS:localhost

    Signature Algorithm: ecdsa-with-SHA256
         30:44:02:20:70:40:c4:ce:99:be:19:f2:9b:77:a1:7c:54:a1:
         27:3b:1e:f6:b3:2e:f6:37:8f:d5:3a:78:c1:9b:ee:e9:4c:76:
         02:20:36:75:3c:42:c9:7b:39:ba:43:b9:be:34:2c:04:a8:c5:
         d6:11:a2:3c:7f:a6:26:0a:50:90:68:7a:52:08:38:c8
{{< /highlight >}}

The CA certificate certificate is deployed on all servers.

### The Consul Servers' certificates

Then we need the certificates for the 3 servers:

{{< highlight shell >}}
consul tls cert create -server -domain=consul -dc=bi-sbg -additional-dnsname=bi-core-sbg-1.intra.terror.ninja -additional-ipaddress=x.x.x.x
consul tls cert create -server -domain=consul -dc=bi-sbg -additional-dnsname=bi-core-sbg-2.intra.terror.ninja -additional-ipaddress=x.x.x.x
consul tls cert create -server -domain=consul -dc=bi-sbg -additional-dnsname=bi-core-sbg-3.intra.terror.ninja -additional-ipaddress=x.x.x.x
{{< /highlight >}}

This will give you something like:
{{< highlight text >}}
> openssl x509 -in consul-server.pem -text -noout      
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            86:a5:e2:0e:ed:43:88:42:1b:f1:ec:a0:56:c0:9b:1e
    Signature Algorithm: ecdsa-with-SHA256
        Issuer: C=US, ST=CA, L=San Francisco/street=101 Second Street/postalCode=94105, O=HashiCorp Inc., CN=Consul Agent CA 39787432322714861766387827631839124003
        Validity
            Not Before: Sep 16 19:36:07 2020 GMT
            Not After : Sep  1 19:36:07 2023 GMT
        Subject: CN=server.bi-sbg.consul
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub: 
                    04:5a:ba:dc:1b:15:82:85:b5:b1:1e:f0:6d:88:1c:
                    0a:92:08:a7:58:84:67:32:61:ea:8d:97:33:b7:7c:
                    c9:f8:6f:4f:f2:11:61:00:fc:c3:ce:70:73:3b:ee:
                    24:37:38:b2:00:27:c1:02:c2:ce:ed:05:67:7c:aa:
                    c8:66:74:f7:2b
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
                9B:5D:58:32:E7:6A:18:D6:F7:93:9F:37:E4:65:F8:5B:63:DD:11:E4:E6:CC:76:12:7C:15:20:C5:99:83:97:E4
            X509v3 Authority Key Identifier: 
                keyid:8B:66:D6:55:FE:5E:A8:39:F1:DC:FA:C6:7D:05:55:AF:EE:6C:BC:01:56:F7:4E:AA:33:8B:76:ED:1C:45:91:07

            X509v3 Subject Alternative Name: 
                DNS:bi-core-sbg-1.intra.terror.ninja, DNS:server.bi-sbg.consul, DNS:localhost, IP Address:x.x.x.x, IP Address:127.0.0.1
    Signature Algorithm: ecdsa-with-SHA256
         30:44:02:20:5e:cb:a0:36:82:3e:cc:7c:ba:b3:47:7b:05:6c:
         a6:f0:13:94:4b:2b:64:c1:1b:a3:39:ee:bf:8a:37:1d:dc:a2:
         02:20:27:6e:3a:8e:aa:6a:b8:0a:2c:ad:81:aa:26:06:4b:6b:
         cc:0e:2c:cf:53:29:c5:b4:af:6e:dc:dc:41:b7:4b:75
{{< /highlight >}}

### The Consul Agents' certificates

No need!
We are using the auto-encryption feature: https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure.

## Ports to open

See https://www.consul.io/docs/install/ports.html.

The Consul Agents need at least the following ports to communicate:
- TCP: 8301, 8302, 8300
- UDP: 8301, 8302

## Server configuration

Here is a server configuration file:
{{< highlight json >}}
{
    "auto_encrypt": {
        "allow_tls": true
    },
    "bind_addr": "{{ GetInterfaceIP `vio1` }}",
    "bootstrap_expect": 3,
    "ca_path": "/etc/ssl/consul/consul-ca.pem",
    "cert_file": "/etc/ssl/consul/consul-server.pem",
    "client_addr": "127.0.0.1",
    "data_dir": "/var/consul",
    "datacenter": "bi-sbg",
    "disable_host_node_id": true,
    "disable_remote_exec": true,
    "disable_update_check": true,
    "domain": "consul.",
    "enable_local_script_checks": true,
    "enable_script_checks": false,
    "enable_syslog": true,
    "encrypt": "xxxx",
    "encrypt_verify_incoming": true,
    "encrypt_verify_outgoing": true,
    "key_file": "/etc/ssl/consul/consul-server-key.pem",
    "leave_on_terminate": true,
    "log_level": "INFO",
    "node_name": "bi-core-sbg-1",
    "retry_join": [
        "bi-core-sbg-1.intra.terror.ninja",
        "bi-core-sbg-2.intra.terror.ninja",
        "bi-core-sbg-3.intra.terror.ninja"
    ],
    "server": true,
    "skip_leave_on_interrupt": true,
    "telemetry": {
        "disable_hostname": true,
        "prometheus_retention_time": "5m"
    },
    "ui": true,
    "verify_incoming": false,
    "verify_outgoing": true,
    "verify_server_hostname": true
}
{{< /highlight >}}

## Client configuration

Here is a client configuration file:
{{< highlight json >}}
{
    "auto_encrypt": {
        "tls": true
    },
    "bind_addr": "{{ GetInterfaceIP `eth1` }}",
    "ca_path": "/etc/ssl/consul/consul-ca.pem",
    "client_addr": "127.0.0.1",
    "data_dir": "/var/lib/consul",
    "datacenter": "bi-sbg",
    "disable_host_node_id": true,
    "disable_remote_exec": true,
    "disable_update_check": true,
    "domain": "consul.",
    "enable_local_script_checks": true,
    "enable_script_checks": false,
    "enable_syslog": true,
    "encrypt": "xxxx",
    "encrypt_verify_incoming": true,
    "encrypt_verify_outgoing": true,
    "leave_on_terminate": true,
    "log_level": "INFO",
    "node_name": "bi-node-sbg-3",
    "retry_join": [
        "bi-core-sbg-1.intra.terror.ninja",
        "bi-core-sbg-2.intra.terror.ninja",
        "bi-core-sbg-3.intra.terror.ninja"
    ],
    "skip_leave_on_interrupt": true,
    "telemetry": {
        "disable_hostname": true,
        "prometheus_retention_time": "5m"
    },
    "ui": true,
    "verify_incoming": false,
    "verify_outgoing": true,
    "verify_server_hostname": true
}
{{< /highlight >}}

## Check everything is working

We can check everything is working by looking at the logs and with this simple command:
{{< highlight shell >}}
> consul members
Node              Address             Status  Type    Build  Protocol  DC      Segment
bi-core-sbg-1     x.x.x.x:8301        alive   server  1.7.2  2         bi-sbg  <all>
bi-core-sbg-2     x.x.x.x:8301        alive   server  1.7.2  2         bi-sbg  <all>
bi-core-sbg-3     x.x.x.x:8301        alive   server  1.7.2  2         bi-sbg  <all>
bi-edge-sbg-1     x.x.x.x:8301        alive   client  1.7.2  2         bi-sbg  <default>
bi-edge-sbg-2     x.x.x.x:8301        alive   client  1.7.2  2         bi-sbg  <default>
bi-node-sbg-1     x.x.x.x:8301        alive   client  1.7.2  2         bi-sbg  <default>
bi-node-sbg-2     x.x.x.x:8301        alive   client  1.7.2  2         bi-sbg  <default>
bi-node-sbg-3     x.x.x.x:8301        alive   client  1.7.2  2         bi-sbg  <default>
{{< /highlight >}}