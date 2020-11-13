---
title: "Initialize your Keys"
menuTitle: "Initialize your Keys"
description: "Initialize your Keys"
---

{{< toc >}}

It is recommanded to have one master key to create subkeys that will eventually be used to sign or encrypt.
Of course the master key need to be safely stored offline to avoid loss or theft/impersonation.

GnuPG is used in this tip.

## Create the master key

The master key will only be able to create other keys.

{{< highlight shell >}}
gpg --expert --full-generate-key
{{< /highlight >}}

Then answer some questions:

{{< highlight shell >}}
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
-> (8) RSA (set your own capabilities)
   (9) ECC and ECC
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (13) Existing key
  (14) Existing key from card
Your selection? 8

Possible actions for a RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Sign Certify Encrypt

-> (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? S

Possible actions for a RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Certify Encrypt

   (S) Toggle the sign capability
-> (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? E

Possible actions for a RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Certify

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
-> (Q) Finished

Your selection? Q
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
-> Requested keysize is 4096 bits

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
-> Key is valid for? (0) 5y

Key expires at Wed Nov 12 10:26:22 2025 CET
-> Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.
-> Real name: Your Name
-> Email address: your@mail.local
Comment:
You selected this USER-ID:
    "Your Name <your@mail.local>"

-> Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o

We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key 9581D2989F065B44 marked as ultimately trusted
gpg: revocation certificate stored as '/home/xxxx/.gnupg/openpgp-revocs.d/E938C880E3CA54814E1C93629581D2989F065B44.rev'
public and secret key created and signed.

pub   rsa4096 2020-11-13 [C] [expires: 2025-11-12]
      E938C880E3CA54814E1C93629581D2989F065B44
uid                      Your Name <your@mail.local>
{{< /highlight >}}

## Create a subkey

The subkey will only be able to sign/encrypt.

{{< highlight shell >}}
gpg --expert --edit-key your@mail.local
{{< /highlight >}}

Then add a key:

{{< highlight shell >}}
addkey
{{< /highlight >}}

And answer some questions: the same as above except that:
- you need to only allow "Sign" and "Encrypt" actions
- as we are going to share the public key of the master key, the expiration date is not relevant

## Exports the keys

Export the master key:
{{< highlight shell >}}
gpg --armor --export-secret-key $MASTERKEYID > masterkey_$MASTERKEYID.sec
{{< /highlight >}}

And its public key:
{{< highlight shell >}}
gpg --armor --export $MASTERKEYID > masterkey_$MASTERKEYID.asc
{{< /highlight >}}

And the revocation key:
{{< highlight shell >}}
gpg --gen-revoke $MASTERKEYID > masterkey_$MASTERKEYID.rev
{{< /highlight >}}

or simply
{{< highlight shell >}}
/home/xxxx/.gnupg/openpgp-revocs.d/$MASTERKEYID.rev masterkey_$MASTERKEYID.rev
{{< /highlight >}}

Export the subkey:
{{< highlight shell >}}
gpg --armor --export-secret-subkeys $SUBKEYID > subkey_$SUBKEYID.sec
{{< /highlight >}}

## Backups

The master key needs to be backuped on an offline storage.
So put masterkey_$MASTERKEYID.sec somewhere secure.

The revocation key of the master key needs to be stored somewhere else.
It's probably better to store it offline too.

## Securing

Now that we have backuped the master key, it can be deleted from your GnuPG store.
It's indeed a security risk to keep it online.

### Remove the master key
{{< highlight shell >}}
gpg --delete-secret-keys $MASTERKEYID
gpg --delete-keys $MASTERKEYID
{{< /highlight >}}

Your GnuPG store should be empty:
{{< highlight shell >}}
gpg --list-keys
{{< /highlight >}}

### Reimport the subkey

#### Reimport
The previous commands removed everything, we need to reimport the subkey:
{{< highlight shell >}}
gpg --import < $SUBKEYID.sec
{{< /highlight >}}

#### Trust
You'll need to trust it:
{{< highlight shell >}}
gpg --expert --edit-key your@mail.local
{{< /highlight >}}

Then enter:
{{< highlight shell >}}
> trust
> ultimate
{{< /highlight >}}

#### Check it's ok
To check it's ok:
{{< highlight shell >}}
gpg -K
{{< /highlight >}}

You should see a "#" next to the master key:
{{< highlight shell >}}
11:00:10 titou@trooper ~/gpg$ gpg -K
sec#  rsa4096 2020-11-13 [C] [expire : 2025-11-12]
      E938C880E3CA54814E1C93629581D2989F065B44
uid          [  ultime ] Your Name <your@mail.local>
ssb   rsa4096 2020-11-13 [SE] [expire : 2025-11-12]
{{< /highlight >}}

This means that there is a known chain but the content are not available.

### Update the password (optional)

The password can be updated and be different from the one stored with the master key:
{{< highlight shell >}}
gpg --expert --edit-key your@mail.local
{{< /highlight >}}

Then enter:
{{< highlight shell >}}
> password
{{< /highlight >}}

## Usage

### Publishing the public key

Now you can public your master public key to a PKI server like https://keys.openpgp.org/.

### Sign / Encrypt

And you can sign / encrypt documents.

## Cleaning

Remove files you won't need:
{{< highlight shell >}}
rm -f \
   masterkey_$MASTERKEYID.sec \
   /home/xxxx/.gnupg/openpgp-revocs.d/$MASTERKEYID.rev masterkey_$MASTERKEYID.rev \
{{< /highlight >}}
