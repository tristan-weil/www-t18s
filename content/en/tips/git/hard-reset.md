---
title: "Hard Reset"
menuTitle: "Hard Reset"
description: "git reset --hard"
---

After a rebase on a remote branch (`force update`) from someone else, the local branch is desynchronized: a
resynchronization must be done.

{{< highlight bash >}}
git fetch
git reset --hard origin/branch_name
{{< /highlight >}}
