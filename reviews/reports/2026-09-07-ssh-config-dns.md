# Report: ssh-config dns-ip commit gate — sshd-cli 1.5.0

**Date:** 2026-09-07  
**Scope:** `dns` verb — this login `~/.ssh/config` Host list (write/pick fidelity)  
**Verdict:** closed  
**Suite:** PASS=218 FAIL=0 SKIP=0 (`tests/run.sh`)

## What shipped

- Numbered concrete Host list (`Host *` / `Match` / `Include` omitted)
- Show: dns, ip, user (`empty` if unset), port (`22` if unset)
- TTY pick: leave with `0` / `q` / `exit` / Enter — `9` is Host row 9
- TTY / `INTERACTIVE=1` field walk; Enter keeps current; `""` clears
- Non-interactive `list` / `show` / `set` / `add`; `edit` fail-closed with Next: `dns set`
- `add` inserts before the first wildcard `Host` / `Match` (atomic replace)
- `set`/`edit` keep extra Host aliases; parse `Key=value` and `Key = value`

## Review notes

Commit-gate findings (fixed this turn):

1. TTY pick treated `9` as Exit when row 9 was a Host (L-DNS-01, TP-DNS-13).
2. `add` appended after trailing `Host *` so OpenSSH first-match ignored new User/Port (L-DNS-02, TP-DNS-14).
3. Rewrite dropped extra Host aliases (L-DNS-03, TP-DNS-15).
4. `Key=value` / `Key = value` mis-parse; later set corrupted User (L-DNS-03, TP-DNS-16).
5. `add` was `>>` rather than atomic replace (folded into TP-DNS-14).

Suggestions closed in the same turn: Next hint for empty `dns add` (TP-DNS-19); Match/Include skip and `dns` field-token TPs (TP-DNS-17, TP-DNS-18).

## Issues

None open.
