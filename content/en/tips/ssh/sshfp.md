---
title: "SSHFP"
menuTitle: "SSHFP"
description: "SSHFP"
---

## What is SSHFP ?

[SSHFP](https://en.wikipedia.org/wiki/SSHFP_record) is a **really** nice feature of OpenSSH.

It lets you put the fingerprint of a SSH key in your DNS records:
- OpenSSH will automatically accept to connect to the host without asking you to check the fingerprint
- no need to auto-accept or auto-discard all fingerprints
- no MITM possible

But you will need:
- a DNSSEC protected domain (so no internal domains or AWS/Google Cloud/etc domains)
- a DNS resolver/cache that is able to verify DNSSEC and supports [EDNS](https://en.wikipedia.org/wiki/Extension_mechanisms_for_DNS)
- your machine resolver must also supports EDNS. You can check that your the `/etc/resolv.conf` file contains:
{{< highlight ini >}}
options edns0
{{< /highlight >}}

## How to generate a SSHFP record ?

{{< highlight shell >}}
ssh-keygen -r "host.domain.tld." -f "/path/to/the/key.pub"
{{< /highlight >}}

You can see that this command outputs different lines.
For example:
{{< highlight ini >}}
/path/to/the/key.pub IN SSHFP 1 1 f58274d47186d69c03a6bc4a6059e9f753d22de6
/path/to/the/key.pub IN SSHFP 1 2 768467fe009909ecb6679b1bed0ecac675fbf720907c93cf9494ef11a2907a6c
/path/to/the/key.pub IN SSHFP 3 1 cd3943b7e23430bd2d80a51a4a70ae0c41d88e4c
/path/to/the/key.pub IN SSHFP 3 2 d13779e474296a49c33bbbfd860ce3d7b398d540fde8c20a8a3409d067b7806c
/path/to/the/key.pub IN SSHFP 4 1 aeb0b1eb3f151aa466301dd7aefa180fe55b4313
/path/to/the/key.pub IN SSHFP 4 2 4b0dfa56796eeb8c24bd2f42e79a43fcd4981dd168cc8fbf23a584eed31ecb5b
{{< /highlight >}}

Explanations:
- 1st: the path to your key
- 2nd: the class (IN obviously)
- 3rd: the type (SSHFP obviously)
- 4th: the algorithm:
    - rsa = 1
    - dss = 2
    - ecdsa = 3
    - ed25519 =  4
- 5th: the algorithm used to hash the public key
    - sha1 = 1
    - sha256 = 2


If you want to only take one of these:
{{< highlight shell >}}
ssh-keygen -r "host.domain.tld." -f "/path/to/the/key.pub" | \
    awk '$4==4 && $5==2 {print $4" "$5" "$6}'
{{< /highlight >}}

Finally, put it in your DNS records.

## Check the record

To check the record, you can use dig:
{{< highlight shell >}}
dig +dnssec SSHFP host.domain.tld
{{< /highlight >}}

Check that you find the **do** flag in the response.

For example:
{{< highlight text >}}
dig +dnssec SSHFP bi-bastion-sbg-1.terror.ninja

; <<>> DiG 9.11.22-RedHat-9.11.22-1.fc32 <<>> +dnssec SSHFP bi-bastion-sbg-1.terror.ninja
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19322
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 65494
; OPT=5: 05 07 08 0a 0d 0e 0f (".......")
; OPT=6: 01 02 04 ("...")
; OPT=7: 01 (".")
;; QUESTION SECTION:
;bi-bastion-sbg-1.terror.ninja.	IN	SSHFP

;; ANSWER SECTION:
bi-bastion-sbg-1.terror.ninja. 3590 IN	SSHFP	4 2 A308E2EE29D5A6B91B22B1968DD6E426E09B2098880D87088A634E1C A9E20FC7
{{< /highlight >}}

## Try to connect

Now, you can try to connect. Use the debug output to find that everything is OK:
{{< highlight shell >}}
ssh -v -o VerifyHostKeyDNS=yes host.domain.tld
[...]
debug1: found 1 secure fingerprints in DNS
debug1: matching host key fingerprint found in DNS
[...]
{{< /highlight >}}
