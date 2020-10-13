---
title: "tee"
menuTitle: "tee"
description: "Output duplication with tee"
---

The `tee` command is really useful when you start some verbose treatments and you need to keep the logs on the screen
and on a file. 

{{< highlight shell >}}
/path/of/the/app 2>&1 | tee -a /path/of/the/log_$(date '+%Y%m%d-%H%M%S').log
{{< /highlight >}}

The `-a` option allows to append new logs at the end of file instead of creating a new file.
