---
title: "Resizing a LVM LV"
menuTitle: "Resizing a LVM LV"
description: "Resizing a LVM Logical Volume"
---

The goal is to extend the size of a logical volume by resizing the size of the underlying disk or by adding a new one.

## If the disk has been resized (a virtual disk)

{{< highlight shell >}}
parted /dev/sdx resize N 100%
pvresize /dev/sdxN
{{< /highlight >}}

## If a disk has been added

{{< highlight shell >}}
fdisk /dev/sdy
pvcreate /dev/sdyN
vgextend myvg /dev/sdyN
{{< /highlight >}}

## Finally extend the size of the LV

{{< highlight shell >}}
lvextend -l +100%FREE /dev/mapper/myvg-mylv 
resize2fs /dev/mapper/myvg-mylv # for extX
xfs_grows /dev/mapper/myvg-mylv # for xfs
{{< /highlight >}}
