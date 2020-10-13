---
title: "Molecule and Docker"
menuTitle: "Molecule and Docker"
description: "Molecule and Docker"
---

In order to have an almost complete and useable system to test your roles and playbook with Docker, add the following
lines in your `molecule/docker/molecule.yml`:

{{< highlight yaml >}}
platforms:
  - name: 'target'
    image: '${MOLECULE_LINUX_DISTRIBUTION:-geerlingguy/docker-debian10-ansible:latest}'
    command: ""
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    privileged: True
    pre_build_image: True
{{< /highlight >}}

Explanations:
- *image*: the name of the Docker image to use, in this case, this one has been built for Ansible/Molecule testing
- *volumes*, *privileged*: needed to use systemd commands
- *pre_build_image*: it tells molecule to use directly this image instead of creating a custom one
