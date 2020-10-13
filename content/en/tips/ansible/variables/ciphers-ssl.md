---
title: "Handling SSL ciphers"
menuTitle: "Handling SSL ciphers"
description: "Handling SSL ciphers for different apps"
---

Using the [SSL ciphers list]({{< relref "/tips/ssl/ciphers" >}}), you can generate different application
configurations:

{{< highlight python >}}
ssl_ciphers:
- ECDHE-ECDSA-WITH-CHACHA20-POLY1305
- ECDHE-RSA-WITH-CHACHA20-POLY1305
- ECDHE-ECDSA-AES256-GCM-SHA384
- ECDHE-RSA-AES256-GCM-SHA384
- ECDHE-ECDSA-AES128-GCM-SHA256
- ECDHE-RSA-AES128-GCM-SHA256

ssl_ciphers_caddy: "{{ ssl_ciphers | join(' ') }}"
ssl_ciphers_haproxy: "{{ ssl_ciphers | join(':') }}"
ssl_ciphers_influxdb: "{{ ssl_ciphers | map('regex_replace', '-', '_') | map('regex_replace', '^', 'TLS_') | list }}"
{{< /highlight >}}
