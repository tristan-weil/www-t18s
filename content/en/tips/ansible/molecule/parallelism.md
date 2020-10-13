---
title: "Parallel tests"
menuTitle: "Parallel tests"
description: "Launching multiple tests in parallel"
---

{{% notice warning %}}
Molecule does not randomize the instance name
{{% /notice %}}

It's of course possible to launch multiple tests in parallel but if you use the same instance name in all
your ` molecule.yml` file, they will collide and fail.

To avoid this potential problem, it's possible a find a unique name by using the **environment variable** 
expansion feature.

## Update molecule.yml

In the platform block, where the instance name is defined, just include a variable:
{{< highlight yaml >}}
platforms:
  - name: 'target-debian-${MOLECULE_INSTANCE_NAME_ID:-1}'
{{< /highlight >}}

## On your computer

Before a run, just export the *MOLECULE_INSTANCE_NAME_ID* variable with a random content.

## On a CI/CD platform

It's the same mechanism: just export the *MOLECULE_INSTANCE_NAME_ID*.

For [GitHub Actions](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#github-context), use the `github.run_id` variable:
{{< highlight yaml >}}
- name: Test with molecule
  env:
    MOLECULE_INSTANCE_NAME_ID: '${{ github.run_id }}'
  run: |
    molecule test -s docker_${{ matrix.distribution }}
{{< /highlight >}}

For [Gitlab CI](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html), use the `CI_JOB_ID` variable:
{{< highlight yaml >}}
variables:
    MOLECULE_INSTANCE_NAME_ID: "$CI_JOB_ID"
{{< /highlight >}}
