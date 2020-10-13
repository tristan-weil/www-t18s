---
title: "debconf"
menuTitle: "debconf"
description: "Packages pre-configuration with debconf"
---

`debconf` is a tool to **pre-configure some packages in `Debian`**.

It allows to prepare the configuration of a package before installing it (when supported) and thus allows to answer to
some questions that are usually displayed in the terminal during the installation process.

The major difficulty is obviously to find the right syntax and the questions a package can answer...

For example, for MariaDB:
{{< highlight shell >}}
debconf-set-selections <<< 'mysql-server/root_password password xXXXx'
debconf-set-selections <<< 'mysql-server/root_password_again password xXXXx'
{{< /highlight >}}

Bonus, for Ansible:
{{< highlight yaml >}}
- name: answering some default questions
  debconf:
    name: mysql-server
    question: "{{ item.question }}"
    value: "{{ item.value }}"
    vtype: password
  loop:
    - question: mysql-server/root_password
      value: xXXXx
    - question: mysql-server/root_password_again
      value: xXXXx
  no_log: True
{{< /highlight >}}