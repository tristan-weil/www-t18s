---
title: "6. Traefik"
menuTitle: "6. Traefik"
description: "Traefik"
weight: 16
---

{{< toc >}}

## Deployment

[Traefik](https://www.traefik.io/) binaries are available from the main site or from many package managers.

## Configuration

Nothing deployed, everything will be done by a Nomad job.

It will configure **traefik**:
- to use Consul as a provider for source services
- generate [Let's Encrypt](https://letsencrypt.org/) certificates for backends asking for them
- prepare some middlewares for the backends that want to use them
