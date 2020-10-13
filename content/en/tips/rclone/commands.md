---
title: "Some commands"
menuTitle: "Some commands"
description: "Some commands"
weight: 3
---

## Sync

If you want to sync one remote (probably a local path) to another:

{{< highlight shell >}}
rclone -v sync -P --filter-from .config/rclone/filter --delete-excluded /your/local/path <remote>:
{{< /highlight >}}

{{% notice info %}}
See https://rclone.org/commands/rclone_sync/
{{% /notice %}}

## Sync and backup modified files

If you want to sync one remote (probably a local path) to another.

And if you want to keep modified files (deleted, updated) in a backup directory:

{{< highlight shell >}}
rclone -v sync -P --filter-from .config/rclone/filter --backup-dir <remote>:/$(date +'%Y-%m-%d-%H-%M-%S') --delete-excluded /your/local/path <remote>:
{{< /highlight >}}

{{% notice info %}}
See https://rclone.org/commands/rclone_sync/
{{% /notice %}}

## Check two remotes

To check the consistency of two remotes (probably your local path and a remote):

{{< highlight shell >}}
rclone -v check -P --filter-from .config/rclone/filter /your/local/path <remote>:
{{< /highlight >}}

{{% notice info %}}
It will use underlying features of the providers to do the check.\
For example, for S3 compatible providers this means comparing the MD5 sum of your local files and the MD5 sum registered
after the transfer.\
But for [Mega.nz](https://www.mega.nz), the check will only be based on the size of the files.
{{% /notice %}}

{{% notice warning %}}
For encrypted remotes, use **cryptcheck**
{{% /notice %}}

{{% notice info %}}
See https://rclone.org/commands/rclone_check/
{{% /notice %}}

## Check two remotes, at least one in encrypted

If you have an encrypted remote, you **MUST** use this command:

{{< highlight shell >}}
rclone -v cryptcheck -P --filter-from .config/rclone/filter /your/local/path <remote>:
{{< /highlight >}}

{{% notice info %}}
See https://rclone.org/commands/rclone_cryptcheck/
{{% /notice %}}

## ncdu

[ncdu](https://dev.yorhel.nl/ncdu) is a really usefull tool {{< icon "fas fa-trophy" >}}

And it has been implemented in [Rclone](https://rclone.org/) {{< icon "fas fa-heart" >}} {{< icon "fas fa-heart" >}} {{< icon "fas fa-heart" >}}

{{< highlight shell >}}
rclone -v ncdu <remote>:
{{< /highlight >}}

![Rclone ncdu](/images/tips/rclone_ncdu.png)

{{% notice info %}}
See https://rclone.org/commands/rclone_ncdu/
{{% /notice %}}