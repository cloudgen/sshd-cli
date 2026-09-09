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
| `test_cli.sh` | CLI surface, empty argv, domain help, systemd unit path, POSIX Linux non-root menu hide | **TP-CLI-*** · **TP-SSHD-01** · **TP-SSHD-03..14** |
| `test_local_lifecycle.sh` | install / self-uninstall / about / login rc / `BASHRC` fixture / sibling / scoped uninstall / heal / `rc-test` / Termux pkg mock / companion link / daemon hint / Android wake lock | **TP-LC-*** · **TP-CSUM-01** · **TP-SSHD-02** · **TP-TX-08..16** |
| `test_dns.sh` | this-login `~/.ssh/config` Host list (dns-ip; edit/add/delete; as Termux / identity / Old OpenSSH; simpler Ciphers/MACs) | **TP-DNS-01..36** |

## Isolation

- Temp `HOME` + `USER_BIN` + redirected `GLOBAL_BIN` for install tests  
- **`BASHRC`** redirected to a random temp folder for **TP-LC-20..22** (create / modify dongle / no-op)  
- **No** public network  
- **No** write to `/etc` or `/var/backup`

## Ship unit under test

`src/sshd-cli` (channel copy `./sshd-cli`)

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
