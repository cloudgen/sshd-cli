# Test plan — sshd-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/sshd-cli`  
**Product VERSION:** 1.4.0  
**Last plan update:** 2026-09-05  
**Last suite run:** PASS=114 FAIL=0 SKIP=0 (2026-09-05)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Empty argv: non-TTY install-ensure / TTY menu | have | TP-CLI-07, TP-CLI-14 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| No online verbs / no SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Trimmed parent verbs fail closed | have | TP-CLI-13 |
| Local install / idempotent / uninstall / mode 0755 / login rc / Termux pkg | have | TP-LC-01..16 |
| Backup / restore / sudoers emit | n/a | Absent by design (Type 0 template; not a backup product) |
| Online curl / companion checksum | n/a | Local-only product |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help local verbs; no online; no backup/restore/sudoers | test_cli | requirement-shell-cli-interface · bootstrap-chain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON storage; no domain fields | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-07 | empty argv non-interactive install-ensure | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | backup/restore/sudoers verbs unknown | test_cli | requirement-bootstrap-chain · interface | **have** |
| TP-CLI-14 | empty argv interactive → domain menu (no install); rows 1–4 + Exit 9 | test_cli | requirement-shell-cli-zero-arguments · requirement-domain-sshd | **have** |
| TP-CLI-15 | status Connect: live ssh -p user@ipv4; no `<this-host>` | test_cli | requirement-domain-sshd | **have** |

### TP-LC (local lifecycle)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01 | install → USER_BIN | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-02 | installed binary version | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-03 | reinstall already-installed | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-04 | about installed path | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-05 | uninstall JSON no force fail-closed | test_local_lifecycle | requirement-shell-interactive-vs-noninteractive | **have** |
| TP-LC-06 | uninstall --force removes | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-07 | uninstall absent no-op | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-08 | about shows installed | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-09 | installed mode is `0755` | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-10 | `--force` reinstall heals `0711` → `0755` | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-11 | install creates `~/.bashrc` with USER_BIN PATH | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-12 | install creates `~/.profile` sourcing bashrc | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-13 | reinstall does not duplicate PATH | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-14 | existing `~/.profile` body kept | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-15 | not Termux: `pkg` not invoked | test_local_lifecycle | requirement-domain-sshd | **have** |
| TP-LC-16 | Termux mock: `pkg install -y openssh termux-auth` | test_local_lifecycle | requirement-domain-sshd | **have** |
| TP-LC-17 | install ends by starting sshd (Termux stub) | test_local_lifecycle | requirement-domain-sshd | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM or TP-FOLDER-BACKUP as Core without product-mode change.  
4. Do not add domain TP families or a `setup` verb — this product is Type 0 only.
