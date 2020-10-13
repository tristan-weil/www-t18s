---
title: "Connect to the instance"
menuTitle: "Connect to the instance"
description: "Connect to the instance"
---

As you know, it's possible to keep the instance alive after the end of the test.

You just have to use:
{{< highlight shell >}}
molecule test -s docker --destroy=never
{{< /highlight >}}

## Docker

When dealing with a Docker instance, it really easy to connect to it and debug the role or the test.

You just have to identify the container and connect to it:
{{< highlight shell >}}
docker ps
docker exec -it <container id> sh
{{< /highlight >}}

## Vagrant

But if you are using Vagrant as a provider, it's a bit more complicated because Molecule use generated SSH key
to connect to it.

Hopefully, Molecule keeps everything in its cache folder.

So, print it's inventory file.
It is located here: `cat $HOME/.cache/molecule/<role>/<the instance name>/inventory/ansible_inventory.yml`

Identify the following 3 lines:
{{< highlight yaml >}}
ansible_host: 127.0.0.1
ansible_port: '2222'
ansible_private_key_file: $HOME/.cache/molecule/<role>/<the instance name>/.vagrant/machines/<the instance name>/virtualbox/private_key
{{< /highlight >}}

You just have now to connect with the user *vagrant*:
{{< highlight shell >}}
ssh -o Port=2222 -i $HOME/.cache/molecule/<role>/<the instance name>/.vagrant/machines/<the instance name>/virtualbox/private_key vagrant@127.0.0.1
sudo su -
{{< /highlight >}}
