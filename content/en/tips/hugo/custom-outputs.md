---
title: "Custom outputs"
menuTitle: "Custom outputs"
description: "Custom outputs within hugo"
---

## Activating outputs

To configure custom *outputs*, add the folowing to your `config.toml`:
{{< highlight toml >}}
[outputs]
home = [ "HTML", "RSS", "JSON"]
{{< /highlight >}}

## Adding a link of an output in the \<head\> block

Add in the `layouts/partials/custom-header.html` file:
{{< highlight go >}}
{{ with .OutputFormats.Get "rss" -}}
    {{ printf `<link rel="%s" type="%s" href="%s" title="%s" />` .Rel .MediaType.Type .Permalink $.Site.Title | safeHTML }}
{{ end -}}
{{< /highlight >}}

{{% notice warning %}}
The previous code will add a link in each page of your project
{{% /notice %}}

If you want to limit the link to specific page, add in the `layouts/partials/custom-header.html` file:
{{< highlight go >}}
{{ if .Params.rssLink -}}
    {{ $title := (.Params.rssLinkTitle | default (printf "%s :: %s " $.Site.Title $.Title)) -}}
    {{ with .OutputFormats.Get "rss" -}}
        {{ printf `<link rel="%s" type="%s" href="%s" title="%s" />` .Rel .MediaType.Type .Permalink $title | safeHTML }}
    {{ end -}}
{{ end -}}
{{< /highlight >}}

And then in each page, you can configure the following parameters in the **front-matter**:
{{< highlight yaml >}}
---
rssLink: true
rssLinkTitle: "(╯°□°）╯︵ t18s.fr"
---
{{< /highlight >}}
