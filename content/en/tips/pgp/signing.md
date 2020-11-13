---
title: "Signing"
menuTitle: "Signing"
description: "Signing"
---

{{< toc >}}

GnuPG is used in this tip.

## Non-interactive commands

### Importing your key before signing

The private key will be imported in one GnuPG store and the public key in another store.

This will allow you to sign and verify the signature with isolated stores and thus be sure of the verification.

{{< highlight shell >}}
echo "your_password" | gpg --quiet --no-tty --batch --pinentry-mode loopback --passphrase-fd 0 \
   --homedir /home/me/gpg_sign --import private_subkey
{{< /highlight >}}

{{< highlight shell >}}
gpg --quiet --no-tty --batch --pinentry-mode loopback \
   --homedir /home/me/gpg_verify --keyserver keys.openpgp.org --recv-keys the_fingerprint_of_your_master_key
{{< /highlight >}}

### Sign with a detached signature file

If you want to sign `your_file`:
{{< highlight shell >}}
echo "your_password" | gpg --quiet --no-tty --batch --pinentry-mode loopback --passphrase-fd 0 \
   --homedir /home/me/gpg_sign \
   --armor --detach-sign your_file
{{< /highlight >}}

A `your_file.asc` will be created with the signature.

### Sign

If you want to sign `your_file`:
{{< highlight shell >}}
echo "your_password" | gpg --quiet --no-tty --batch --pinentry-mode loopback --passphrase-fd 0 \
   --homedir /home/me/gpg_sign \
   --armor --clear-sign your_file
{{< /highlight >}}

A `your_file.asc` will be created with the content of the file and the signature.

### Check signature with a detached signature file

If you want to verify the signature of `your_file` with `your_file.asc`:
{{< highlight shell >}}
gpg --quiet --no-tty --batch --pinentry-mode loopback --passphrase-fd 0 \
   --homedir /home/me/gpg_verify \
   --verify your_file.asc your_file
{{< /highlight >}}

### Check signature

If you want to verify the file and the signature of `your_file.asc`:
{{< highlight shell >}}
gpg --quiet --no-tty --batch --pinentry-mode loopback --passphrase-fd 0 \
   --homedir /home/me/gpg_verify \
   --verify your_file.asc
{{< /highlight >}}

## Interactive commands

### Importing your key before signing

The private key will be imported in one GnuPG store and the public key in another store.

This will allow you to sign and verify the signature with isolated stores and thus be sure of the verification.

{{< highlight shell >}}
gpg --homedir /home/me/gpg_sign --import private_subkey
{{< /highlight >}}

{{< highlight shell >}}
gpg --homedir /home/me/gpg_verify --keyserver keys.openpgp.org --recv-keys the_fingerprint_of_your_master_key
{{< /highlight >}}

### Sign with a detached signature file

If you want to sign `your_file`:
{{< highlight shell >}}
gpg --homedir /home/me/gpg_sign --armor --detach-sign your_file
{{< /highlight >}}

A `your_file.asc` will be created with the signature.

### Sign

If you want to sign `your_file`:
{{< highlight shell >}}
gpg --homedir /home/me/gpg_sign --armor --clear-sign your_file
{{< /highlight >}}

A `your_file.asc` will be created with the content of the file and the signature.

### Check signature with a detached signature file

If you want to verify the signature of `your_file` with `your_file.asc`:
{{< highlight shell >}}
gpg --homedir /home/me/gpg_verify --verify your_file.asc your_file
{{< /highlight >}}

### Check signature

If you want to verify the file and the signature of `your_file.asc`:
{{< highlight shell >}}
gpg --homedir /home/me/gpg_verify --verify your_file.asc
{{< /highlight >}}
