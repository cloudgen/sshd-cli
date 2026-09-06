# Requirement ↔ test matrix — sshd-cli

**Updated:** 2026-09-06  
**Product VERSION:** 1.4.1  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + posix-sh stack |
| requirement-shell-cli-interface | shell | TP-CLI-* · TP-LC-18/19 | Commands, flags, dispatch; domain verbs in help; Git Bash / Windows cmd |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07, TP-CLI-14 | Non-TTY install-ensure; TTY menu |
| requirement-shell-self-management | shell | TP-LC-* (incl. **09/10** mode, **11–14** rc) · TP-CLI-10 | install / self-uninstall; **0755**; create `.bashrc` / `.profile`; channel verbs routed |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | `sshd_*` domain prefix; `app_main` / `out_*`; `inst_ensure_companion` — no dedicated prefix scan |
| requirement-shell-idempotency | shell | TP-LC-03,07,13,14 | Re-install / uninstall absent / PATH / profile |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05, TP-CLI-07, TP-CLI-14 | self-uninstall confirm; empty-argv TTY vs pipe |
| requirement-shell-cli-storage | shell | TP-CLI-12, TP-CLI-06 | Isolation; about JSON storage fields |
| requirement-shell-automatic-checksum | shell | TP-CSUM-01, TP-CLI-04, TP-CLI-06 | Companion **link** on install; CHECKSUM omitted from help/about. Not TP-LC-01. |
| requirement-domain-sshd | domain | TP-CLI-04, TP-CLI-06, TP-CLI-14, TP-CLI-15, TP-LC-16, TP-LC-17 | help rows; menu 1–4; connect IPv4; package names; install starts sshd |
| requirement-shell-termux-ish | shell | TP-LC-15, TP-LC-16, TP-LC-18, TP-LC-19 | not Termux: `pkg` not invoked; Termux mock: `pkg install -y openssh termux-auth`; Git Bash / Windows cmd mock: `pkg` not invoked |
| requirement-shell-script-coding | shell | TP-CLI-01, TP-CLI-11 | `sh -n`; `set -u` with HOME unset |

**Absent by design (no TP Core):** folder-archive backup/restore, sudoers-file emit, systemd unit files.

**Honest todo (not Core this cut):** dedicated `start`/`stop`/`port`/`config`/`host-keys`/`auth-keys` behavioral TPs; public-network curl; prefix-scan for modular-function-design.
