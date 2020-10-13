---
title: "Rate-limit"
menuTitle: "Rate-limit"
description: "Rate-limiting the requests in HAProxy"
---

It is possible to **limit the number of request** in HAProxy by using almost any gathered data.

This topic is huge and complexe as it is possible to make everything, depending the needs.\
A good introduction can be found on the blog of 
[haproxy.com](https://www.haproxy.com/fr/blog/introduction-to-haproxy-stick-tables/).

I have a simple cas where I only want to block an IP if the number of requests if too hight.

In a `frontend`:
{{< highlight python >}}
stick-table type ip size 1m expire 10s store conn_rate(10s)

tcp-request inspect-delay 10s
tcp-request content track-sc0 src

tcp-request content reject if { sc_conn_rate(0) gt 10 }
{{< /highlight >}}

Explications:

* 1st line: the **table definition** linked to this fronted (here with a time to live of 10 seconds)
* 2nd line: we must be sure to **gather enough data** (in the case of the IP, I think the delay can be lowered)
* 3rd line: a **counter** `sc0` to follow the source IP (the counter is automatically linked to the previous table as
it is in the same frontend)
* 4th line: the rule that allows to **reject a request** is the counter overrun the threshold (here 10 requests in 10 
seconds)   
