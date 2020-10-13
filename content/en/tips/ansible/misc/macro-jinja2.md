---
title: "Jinja2 macros"
menuTitle: "Jinja2 macros"
description: "Jinja2 macros"
---

In `Ansible`, it's of course possible to use the **templating features** of Jinja2.\
Thus I really often use the Jinja2 `macros` in my **configuration files** (processed by the `template` module).\
Because in a configuration file, the data are indeed always formatted in a known format. 

Here is example to generate a `.init` file:

{{< highlight python >}}
{% macro display_dict(dict) %}
{% for (key, value) in dict|dictsort %}
{{ key }}={{ value }}
{% endfor %}
{% endmacro %}
{{< /highlight >}}

Here is another exemple to generate diffent types of value and the indentation:

{{< highlight python >}}
{% macro display_dict(dict, offset=0) -%}
{% for (key, value) in dict|dictsort %}
{% if value == 'true' or value == 'false' or value is number -%}
{{ ' ' * (2 + offset) }}{{ key }} = {{ value }}
{% elif value is string -%}
{{ ' ' * (2 + offset) }}{{ key }} = "{{ value }}"
{% elif value is mapping -%}
{{ ' ' * (2 + offset) }}[[{{ key }}]]
{{ display_dict(value, 2) }}
{% elif value is iterable -%}
{{ ' ' * (2 + offset) }}{{ key }} = ["{{ value | join('", "') }}"]
{% else -%}
{{ ' ' * (2 + offset) }}{{ key }} = "{{ value }}"
{% endif -%}
{% endfor %}
{%- endmacro %}
{{< /highlight >}}
 
To use a `macro`, you must simple call it:

{{< highlight python >}}
{{ display_dict(my_dict) }}
{{< /highlight >}}