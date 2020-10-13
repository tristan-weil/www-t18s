---
title: "Virtual Envs"
menuTitle: "Virtual Envs"
description: "Choosing the right Virtual Env"
---

Python comes with an impressive list of freely available libraries that can be used to build an app.

There are different ways to handle how and where they are installed.

## System

You can use your packages manager to install libraries.

It's the simpliest method but you will often end with old or deprecated packages.

## Virtualenv

You can use Virtualenv: it will create a custom folder with an almost complete Python environment where you can
use `pip` to install the needed libraries.

It's a better solution than using your system packages manager and a simplier than using Pyenv.

The main problem is that it only copies a subset of the `core` modules: you will still rely on your system Python
packages for the others (and for the version of Python if your distribution cannot handle different ones).

To create a Virtualenv:
{{< highlight shell >}}
python3 -m venv /path/to/new/virtual/environment
{{< /highlight >}}

## Pyenv

You can use [pyenv](https://github.com/pyenv/pyenv).
It allows to build every version of Python in any directory and thus it also allows to use `pip` to install 
the needed libraries.\
It's also a good candidate if you need to chroot your app as the whole Python env is stored in the Pyenv.

The main problem is that you need to compile Python and thus update it if needed.

To create a Pyenv for Python 2.7.8:
{{< highlight shell >}}
pyenv install 2.7.8
{{< /highlight >}}
