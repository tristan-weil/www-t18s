---
title: "ttserver"
menuTitle: "ttserver"
description: "A little and simple TCP server"
chapter: false
weight: 3
---

{{< toc >}}

## What ?

{{< icon "fab fa-github" >}}&nbsp;[**ttserver**](https://github.com/tristan-weil/ttserver) is a simple TCP server allowing to:
- serve content over custom connection handlers:
  - `finger` and `gopher` protocols' handlers included
  - a basic page renderer supporting:
    - Go templates
    - caching
    - fetching remotes contents
- define generic routes with regex
- fetch remote contents (json, html, feeds) and display them in pages
- run cron tasks to create/update pages
- server content over TLS with the support of the ACME protocol ([Let's Encrypt](https://letsencrypt.org/))
- gather stats about the server on a
[Prometheus compatible endpoint](https://prometheus.io/docs/instrumenting/exposition_formats/), /metrics
- handle [PROXY protocol](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt)

## Why ?

I really like the idea to be able to have a [Gopher](https://en.wikipedia.org/wiki/Gopher_%28protocol%29)
and a [finger](https://en.wikipedia.org/wiki/Finger_protocol) spaces to serve contents.

If you want to know more about my motivations:
- `lynx gopher://gopher.t18s.fr/1/about/server`
- `finger about/server@finger.t18s.fr`

I tried to have both running for some times now but it's not easy to find tools that support all the above features.

So I wrote **ttserver**.

## What have I learned ?

My skills in Go improved a lot (Go routines, templates, etc.).

And I've started to use
 - [super-linter](https://github.com/github/super-linter)
 - [golangci-lint](https://golangci-lint.run/)
 - [GitHub Actions](https://golangci-lint.run/)

I also wrote a GitHub Actions to handle checksums and signatures:
[ghaction-checksum-sign-artifact](https://github.com/tristan-weil/ghaction-checksum-sign-artifact/).
