---
title: "Redirecting with a regex"
menuTitle: "Redirecting with a regex"
description: "Redirecting with a regex"
---

I have a simple use-case: I want to redirect all pages from https://www.t18s.fr/en/path to 
https://www.t18s.fr/path.

The goal is thus to redirect all pages found by a regexp.

Found here: https://caddy.community/t/regex-on-redir-solved/5215/7, the trick is to use a **rewrite** rule 
then a **redir** rule in order to trigger the **rewrite_uri** placeholder.

{{< highlight python >}}
rewrite {
  r ^/en/(.*)
  to /{1}
}

redir {
  if {uri} not {rewrite_uri}
  / https://www.t18s.fr{rewrite_uri} 301
}
{{< /highlight >}}