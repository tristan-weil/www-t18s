---
title: "Facts and limit"
menuTitle: "Facts and limit"
description: "Gather facts for host excluded by the --limit"
---

## Use-case

It's a common practice to loop over a group of hosts to retrieve some data (like IP address) and concatenate 
them in a variable that you then inject into a configuration file: you've probably already done this 
to configure a cluster.

For example, you can build a yaml configuration file with:
{{< highlight yaml >}}
servers:
{% for s in groups['cluster_server'] %}
  - {{ hostvars[s]['ansible_default_ivp4']['address'] }}
{% endfor %}
{{< /highlight >}}

## Problem

Using the magic `hostvars` variable implies that facts has been gathered on all hosts.

{{< notice warning >}}
But the --limit option will **only** gather facts on the listed hosts. 
{{< /notice >}}

This could lead to some `undefined variable` errors or, even worse, you could end with strange values in your
configuration files.

For example:
{{< highlight yaml >}}
servers: [AnsibleUndefined, AnsibleUndefined, AnsibleUndefined]
{{< /highlight >}}

## Solution

The solution is to force the gathering of the facts of all the hosts you need:

{{< highlight yaml >}}
- name: update facts
  setup:
  delegate_to: "{{ item }}"
  delegate_facts: True
  when: hostvars[item]['ansible_default_ivp4']['address'] is not defined # to speed up the process
  loop: "{{ groups['cluster_server'] }}"
  tags:
    - always
{{< /highlight >}}
