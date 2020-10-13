---
title: "Generating a fullchain"
menuTitle: "Generating a fullchain"
description: "Generating a file containing the full chain and the private key for Certbot"
---

Some tools like [HAProxy](http://www.haproxy.org) need a file that contains the full chain of certificate (the 
certificate and the intermediates ones) and the private key in order to configure the SSL parameters.
 
But `certbot` does not do this.
We must so add a `hook` that will do it for every update or creation:

{{< highlight shell >}}
#!/bin/bash

cat "$RENEWED_LINEAGE/fullchain.pem" "$RENEWED_LINEAGE/privkey.pem" > "$RENEWED_LINEAGE/fullchainprivkey.pem"
{{< /highlight >}}

The script must be placed in `/etc/certbot/renewal-hooks/deploy/fullchainprivkey.sh`.

To use it, the option `--deploy-hook` of `certbot` must be used.
