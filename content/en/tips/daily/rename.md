---
title: "Renaming files"
menuTitle: "Renaming files"
description: "Renaming files in masse"
---

In order to **mass rename** files, you can use the `rename` command.

Unfortunately there are different versions:
- one without regex (like on Fedora)
- one with regex (like on Debian)

{{% notice info %}}
The `rename` command supporting regexp is written in Perl, and thus 
support [regular expressions from Perl](https://perldoc.perl.org/perlre.html)
{{% /notice %}}

## To modify the extension (with regex)

{{< highlight shell >}}
rename -v 's/\.jpeg$/.jpg/' *
rename -v 's/\.bak$//' *
{{< /highlight >}}

## To modify the case (with regex)

{{< highlight shell >}}
rename -v 'y/A-Z/a-z/' *
{{< /highlight >}}

## To modify the extension (without regex)

{{< highlight shell >}}
rename .htm .html *.htm
{{< /highlight >}}

## To dry-run

{{< highlight shell >}}
rename -nv "chanson-de-la-semaine" "song-of-the-week" *
{{< /highlight >}}
