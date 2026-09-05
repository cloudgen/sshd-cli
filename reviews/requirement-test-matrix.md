# Requirement ↔ test matrix — sshd-cli

**Updated:** 2026-09-05  
**Product VERSION:** 1.0.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + posix-sh stack |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch; domain verbs in help |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type O install-ensure |
| requirement-shell-self-management | shell | TP-LC-* (incl. **09/10** mode) | install / self-uninstall; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | `sshd_*` domain prefix; `app_main` / `out_*` |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 | self-uninstall confirm |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-shell-automatic-checksum | shell | TP-LC-01 | Companion path on install (file:// in CI) |
| requirement-domain-sshd | domain | TP-CLI-04, TP-CLI-06 | help domain rows; about `sshd_platform` |
| requirement-shell-script-coding | shell | TP-CLI-01, TP-CLI-11 | `sh -n`; `set -u` with HOME unset |

**Absent by design (no TP Core):** folder-archive backup/restore, sudoers-file emit, systemd unit files.
