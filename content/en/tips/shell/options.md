---
title: "Options"
menuTitle: "Options"
description: "Options"
weight: 3
---

Here are some useful and common options you can pass to your script or directly in the shebang.

{{% notice info %}}
They are supported by both **bash** and **ksh**.
{{% /notice %}}

## Exit when a command fails

{{< highlight shell >}}
set -e
{{< /highlight >}}

## Exit if a variable is not set

{{< highlight shell >}}
set -u
{{< /highlight >}}

## Print every line and returned values

{{< highlight shell >}}
set -x
{{< /highlight >}}

## Fail if a piped command fails

{{< highlight shell >}}
set -o pipefail
{{< /highlight >}}

You can check with this simple example:
{{< highlight shell >}}
grep something /non/existent/file | sort
{{< /highlight >}}
