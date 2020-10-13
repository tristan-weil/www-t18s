---
title: "SSHD configuration"
menuTitle: "SSHD configuration"
description: "Configure the SSH server"
---

Here are some secure algorithms (**at the time of writing**) to add in the `/etc/ssh/sshd_config` file:

{{< highlight scala >}}
Ciphers chacha20-poly1305@openssh.com
KexAlgorithms curve25519-sha256@libssh.org
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
{{< /highlight >}}
