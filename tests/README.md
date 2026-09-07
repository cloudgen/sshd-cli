# Tests — sshd-cli

## Run

```sh
./tests/run.sh
# or
sh tests/run.sh
```

Exit **0** when all assertions pass; **1** on failure; **2** if ship unit missing.

## Layout

| File | Focus | TP families |
|------|--------|-------------|
| `run.sh` | Entrypoint | — |
| `helpers.sh` | Asserts + isolated HOME | — |
| `test_cli.sh` | CLI surface, empty argv (TTY menu / pipe install-ensure), domain help, trimmed-verb reject, daemon vs service | **TP-CLI-*** · **TP-SSHD-01** |
| `test_local_lifecycle.sh` | install / self-uninstall / about / login rc / Termux pkg mock / companion link / daemon hint | **TP-LC-*** · **TP-CSUM-01** · **TP-SSHD-02** |
| `test_dns.sh` | this-login `~/.ssh/config` Host list (dns-ip) | **TP-DNS-01..19** |

## Isolation

- Temp `HOME` + `USER_BIN` + redirected `GLOBAL_BIN` for install tests  
- **No** public network  
- **No** write to `/etc` or `/var/backup`

## Ship unit under test

`src/sshd-cli` (channel copy `./sshd-cli`)

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
