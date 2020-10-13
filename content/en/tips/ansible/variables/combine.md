---
title: "Combining dictionaries"
menuTitle: "Combining dictionaries"
description: "Combining dictionaries"
---

If you need to **override a precise value in a dictionnary**, you have to combine 2 dictionnaries.

Here a 2 dictionnaries:
{{< highlight yaml >}}
dict_orig:
    orig_key1: 'value'
    orig_key2:
        orig_subkey1: 'value'
        orig_subkey2:
            orig_subsubkey2: 'value'

dict_override:
    orig_key2:
        orig_subkey2:
            orig_subsubkey2: 'new_value'
{{< /highlight >}}

And to combine them:
{{< highlight yaml >}}
dict_new: "{{ dict_orig | combine(dict_override, recursive=True) }}"
{{< /highlight >}}
