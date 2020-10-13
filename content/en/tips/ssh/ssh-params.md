---
title: "SSH configuration"
menuTitle: "SSH configuration"
description: "Configure the SSH client"
---

It is possible to configure some **connection options** in the `~/.ssh/config` file.\
It is also allowed to **filter** the parameters by machines and thus have differents rules.

cf [man ssh_config](http://man.openbsd.org/ssh_config) 

An example:
{{< highlight scala >}}
Host *
    User my_user
    Port 2222
    IdentityFile ~/.ssh/custom.private_key
    ControlMaster auto
    ControlPath ~/.ssh/control/%r@%h:%p
    ControlPersist 10m
{{< /highlight >}}
