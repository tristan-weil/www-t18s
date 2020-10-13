---
title: "Dynamic Array"
menuTitle: "Dynamic Array"
description: "Creating a dynamic array in Ansible"
---

It can be sometime useful to **generate dynamically some variables that are arrays**.

The `Jinja2` templating features allows to achieve this directly when defined a variable.\
Here is an example: 

{{< highlight python >}}
cgit_stack_git_repos: >-
  {% set result = [] -%}
  {% for h in cgit_stack_repos -%}
  {% if h.src is not defined -%}
  {% set dummy = result.append({'name': h.name, 'desc': h.desc, 'parent_dir': cgit_stack_repos_dir + '/' + h.parent_dir}) -%}
  {% endif -%}
  {% endfor -%}
  {{ result }}
{{< /highlight >}}

The important part are:

* the initialisation of the array: it must be empty `[]`
* the use of the `append` function and its return in an unused variable
* the return of the array as a normal variable

{{% notice info %}}
You should avoid new lines as it won't be interpreted as a variable.
{{% /notice %}}
  
{{% notice warning %}}
This tip could be deprecated in new version of Ansible.
{{% /notice %}}
