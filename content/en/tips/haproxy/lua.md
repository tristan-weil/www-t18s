---
title: "LUA"
menuTitle: "LUA"
description: "Using LUA with HAProrxy"
---

HAProxy is able to use LUA scripts to handle requests.

To test this functionality, I will add a LUA script that will check the status of a TCP echo server and return
a HTML status (200 for OK)

It was really simple and straight-forward. \
I used the really good (as usual) blog post from the [HAProxy blog](https://www.haproxy.com/fr/blog) team: 
https://www.haproxy.com/fr/blog/5-ways-to-extend-haproxy-with-lua/

1. Declare in the **global** block the Lua scripts:
    
    {{< highlight python >}}
global
    lua-load /etc/haproxy/checktcp.lua
{{< /highlight >}}


2. Identify the kind of script you need (there are 5): check the blog post to find the one you need.

    For my use-case, I need the **service** kind. \
    This one is really interesting for me as it allows to generates HTML page.


3. Write the rules in the frontends/backends: it depends of what kind of script you wrote.

    For my use-case, the script will handle requests in the backend:

    {{< highlight python >}}
frontend fe_main
    bind *:80
    default_backend checktcp
    
backed checktcp
  mode http
  http-request use-service lua.checktcp
{{< /highlight >}}

    Of course, you cadd all kind of ACL and rules.

4. Write the script.

    Probably the most difficult part.
    
    But you have access to all Lua libraries found on your system and the inner API from
HAProxy (http://www.arpalert.org/haproxy-api.html).

    Mine is really simple:
        - it connects to the TCP server and send a message: 'check'
        - it removes the first line of the response (I used a custom TCP echo server that adds a header with some 
        information like IPs)
        - it check the next line to see if it sees the word 'check'
        - if so, it creates a HTML page with an 'OK' text and return the code 200
        - otherwise, it creates a HTML page with a 'KO' text and return the code 503

    {{< highlight lua >}}
local function checktcp(applet)
  local addr = '127.0.0.1'
  local port = 8080

  local code = 503
  local response = "KO\r\n"

  -- Use core.tcp to get an instance of the Socket class
  local socket = core.tcp()
  socket:settimeout(1)

  -- Connect to the service and send the request
  if socket:connect(addr, port) then
    if socket:send("check\n") then
      -- Skip response headers
      socket:receive('*l')
      -- Get the content
      local content = socket:receive('*l')
      if content and content == "check" then
        code = 200
        response = "OK\r\n"
      end
    end
    socket:close()
  end

  applet:set_status(code)
  applet:add_header("content-length", string.len(response))
  applet:add_header("content-type", "text/html")
  applet:start_response()
  applet:send(response)
end

core.register_service("checktcp", "http", checktcp)
{{< /highlight >}}

5. And that's all: just restart HAProxy now.