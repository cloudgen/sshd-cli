#!/bin/sh
# Git Bash launcher for setup-windows-ssh-server.ps1
# Host OpenSSH setup still needs Administrator (UAC). This file only starts PowerShell.

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
ps1="${here}/setup-windows-ssh-server.ps1"
if [ ! -f "${ps1}" ]; then
    printf '%s\n' "setup-windows-ssh-server.ps1 was not found next to this launcher." >&2
    exit 1
fi
win="${ps1}"
if command -v cygpath >/dev/null 2>&1; then
    win=$(cygpath -w "${ps1}")
fi
exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${win}" "$@"
