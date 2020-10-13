---
title: "Start a process as a nologin user"
menuTitle: "Start a process as a nologin user"
description: "Start a process as a nologin user"
---

If you want to start a command or a process with a user that don't have a shell, launch (as root):
{{< highlight shell >}}
su -s /bin/sh <user> -c "/path/to/command args" 
{{< /highlight >}}
