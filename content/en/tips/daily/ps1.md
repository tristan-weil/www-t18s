---
title: "Custom prompt shell"
menuTitle: "Custom prompt shell"
description: "Custom prompt shell"
---

The **PS1 variable** could to be overrided (probably in ~/.profile):

- for `bash`:
{{< highlight shell >}}
if [[ $(id -u) == "0" ]]; then
    umask 022
    PS1="\n\[\e[1;33m\]\t ${venv_prompt}\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;31m\]\h \[\e[0;31m\]\w ${git_prompt}\[\e[0;33m\][$EXIT]\n\[\e[1;31m\]> \[\e[0m\]"
else
    umask 027
    PS1="\n\[\e[1;33m\]\t ${venv_prompt}\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;35m\]\h \[\e[1;36m\]\w ${git_prompt}\[\e[0;33m\][$EXIT]\[\e[0m\]\n\[\e[1;32m\]$ \[\e[0m\]"
fi
{{< /highlight >}}

- pour `ksh`:
{{< highlight shell >}}
if [[ $(id -u) == "0" ]]; then
    umask 022
    if echo $KSH_VERSION | grep -q "PD KSH" >/dev/null 2>&1; then
        PS1="\n\e[1;33m\]\$(date +"%H:%M:%S") ${venv_prompt}\e[1;31m\]\$(logname)\e[0m\]@\e[1;31m\]\$(hostname -s) \e[0;31m\]\$PWD ${git_prompt}\n\e[0;31m\]> \e[0m\]"
    else
        PS1=$'\n\E[1;33m\$(date +"%H:%M:%S") ${venv_prompt}\E[1;31m\$(logname)\E[0m@\E[1;31m\$(hostname -s) \E[0;31m\$PWD '${git_prompt}$'\n\E[0;31m> \E[0m'
    fi
else
    umask 027
    if echo $KSH_VERSION | grep -q "PD KSH" >/dev/null 2>&1; then
        PS1="\n\e[1;33m\]\$(date +"%H:%M:%S") ${venv_prompt}\e[1;32m\]\$(logname)\e[0m\]@\e[1;35m\]\$(hostname -s) \e[0;36m\]\$PWD ${git_prompt}\n\e[0;32m\]> \e[0m\]"
    else
        PS1=$'\n\E[1;33m\$(date +"%H:%M:%S") ${venv_prompt}\E[1;32m\$(logname)\E[0m@\E[1;35m\$(hostname -s) \E[1;36m\$PWD '${git_prompt}$'\n\E[1;32m$ \E[0m'
    fi
fi
{{< /highlight >}}

The result:\
!["ps1"](/images/tips/ps1_user_root.png?classes=inline)
