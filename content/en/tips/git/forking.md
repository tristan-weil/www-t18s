---
title: "Forking"
menuTitle: "Forking"
description: "Forking"
---

If you fork a repository from GitHub, Gitlab or any other places, you will probably need to rebase from time to
time to the upstream project.

So just add another **remote**:
{{< highlight shell >}}
git remote add upstream https://github.com/matcornic/hugo-theme-learn.git
{{< /highlight >}}

And when needed, update your branch:
{{< highlight shell >}}
git fetch upstream
git checkout master # or any other branch
git rebase upstream/master
git push
{{< /highlight >}}