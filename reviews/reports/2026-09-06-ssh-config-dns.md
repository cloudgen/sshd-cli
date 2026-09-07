# Report: ssh-config dns-ip — sshd-cli 1.5.0

**Date:** 2026-09-06  
**Scope:** `dns` verb — this login `~/.ssh/config` Host list  
**Verdict:** superseded (2026-09-07 commit-gate review found write/pick bugs; fixed)  
**Suite:** PASS=189 FAIL=0 SKIP=0 (`tests/run.sh`) — later TP-DNS-13..19 added

## What shipped

- Numbered concrete Host list (`Host *` omitted)
- Show: dns, ip, user (`empty` if unset), port (`22` if unset)
- TTY / `INTERACTIVE=1` field walk; Enter keeps current; `""` clears
- Non-interactive `list` / `show` / `set` / `add`; `edit` fail-closed with Next: `dns set`

## Review notes

Implement-turn fixes (not left open):

1. `set -u`: helpers must not `unset _n` used by the caller.
2. After `COMMAND=dns`, a later token `dns` is a **field name**, not a second command.

Checklists: `docs/checklists/2026-09-06-*-ssh-config-dns.md` and dual-mention.
