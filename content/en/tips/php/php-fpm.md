---
title: "PHP-FPM cache security"
menuTitle: "PHP-FPM cache security"
description: "Securing the cache of PHP-FPM"
---

{{% notice warning %}}
`PHP-FPM` **does not compartmentalize** its caches.
{{% /notice %}}

This can lead to some security problems but also some operating problems.\
{{< icon "fas fa-fire" >}} Indeed, the key used by the cache is the **path** of the PHP files. {{< icon "fas fa-fire" >}} 

A problem will occur if:
- you use the `chroot` parameter with different `pools`
- you have some paths that are identical inside the different `chroots`

Because, for the cache of PHP-FPM, the **path** used as a key is the **path** seen by a `pool` and not 
the absolute **path** on the host.

The result is that PHP-FPM will answer with the first file that has been requested, regardless the `chroot` directory. 

For example, if you have two chrooted instance of the same PHP applcation:
- if the pages of the `A-pool` are in the cache (because already requested by a suer)
- then, if the pages of the `B-pool` are requested, the pages of the `A-pool` are displayed

To fix this problem, the following parameters must be set in the `php.ini` file from `PHP-FPM`:
(for example in `/etc/php/7.0/fpm/php.ini`):

{{< highlight scala >}}
opcache.use_cwd = 1
opcache.validate_permission = 1
opcache.validate_root = 1
{{< /highlight >}}

Or they can be set in the configuration file of each `pool`:

{{< highlight scala >}}
php_admin_flag[opcache.use_cwd] = 1
php_admin_flag[opcache.validate_permission] = 1
php_admin_flag[opcache.validate_root] = 1
{{< /highlight >}}    

For more informations:
- https://ma.ttias.be/mitigating-phps-long-standing-issue-opcache-leaking-sensitive-data/ \
- https://bugs.php.net/bug.php?id=69090
