---
title: "Why?"
menuTitle: "Why?"
description: "Why?"
weight: 1
---

## From simple solutions...

There a dozens of tools allowing you to backup your data in the way you want.
You can also easily write one with some shell scripts (but don't please) or use some cloud-based solution.

I personally used [rsnapshot](https://rsnapshot.org/) for quite a long time as my backup solution:
- it's based on [rsync](https://rsync.samba.org/) from [Andrew Tridgell](https://en.wikipedia.org/wiki/Andrew_Tridgell)
- it can work transparently with local storage or remote (SSH)
- it's easy to use and deploy
- it's easy to validate the source code and the backuped data (no meta-data, no hidden parameters, etc.)
- it uses hard link to reduce the disk space usage between two backups (the number of backups can be configured)

It's rock-solid, fast and will never disappoint you {{< icon "fas fa-trophy" >}}

But of course:
- it lacks encryption (it's up to you to add it by another way, like LUKS volume)
- it only works with local storage or SSH

## To cloud-aware swiss-army knives tools

Today's dedicated hosts' offers are too expensive (especially if you want multiple backup sites).
And I don't see the point to have a lot of RAM or CPU when you only need storage. 

On the other side, there are a lot of cloud-based storage solutions:
- that are cheap (and with multiple layers of redundancy)
- but come with complex and dedicated tools (and sometimes closed source) that you need to use to backup your data {{< icon "fas fa-sad-cry" >}}
- hopefully they are mainly based on well-known APIs (like S3 or OpenShift)

And thus enters [Rclone](https://rclone.org/).

## Rclone

[Rclone](https://rclone.org/) has a nice list of features:
- it's multi-vendors (S3, SFTP, Box.net, Webdav, etc.)
- it can encrypt/decrypt files on-the-fly
- it has a simple and clean code design
- some providers (encryption, chunking, etc.) can be stacked with other providers
- it's fast and it comes with a nice list of tools (ncdu, dry-run, filters, ls, rm, etc.)
- and it's of course open-source

It's probably not the fastest and it doesn't implement the current state-of-the-art of the best backup solutions
(have a look at [Borg](https://www.borgbackup.org/)):
- chunking
- deduplication
- security by default

But its simplicity of use, its versatility and its unshakeability makes it the perfect tool 
{{< icon "fas fa-award" >}}&nbsp;(from my point of view).
