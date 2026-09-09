# Requirement ↔ test matrix — sshd-cli

**Updated:** 2026-09-09  
**Product VERSION:** 1.13.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + posix-sh stack |
| requirement-shell-cli-interface | shell | TP-CLI-* · TP-LC-18/19 · TP-TX-10/11/12/15 | Commands, flags, dispatch; domain verbs + `wake-lock` in help; Git Bash / Windows cmd |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07, TP-CLI-14 | Non-TTY install-ensure; TTY menu |
| requirement-shell-self-management | shell | TP-LC-* (incl. **09/10** mode) · TP-CLI-10 | install / self-uninstall; **0755**; companion **call site**; channel verbs routed. Rc bodies: `requirement-shell-path-and-shell-support` |
| requirement-shell-path-and-shell-support | shell | TP-LC-11–14 · TP-LC-20–22 · TP-LC-27–31 · TP-CLI-18 | PATH / profile; sibling; scoped uninstall; heal; `rc-test` routed |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | `sshd_*` domain prefix; `app_main` / `out_*`; `inst_ensure_companion` — no dedicated prefix scan |
| requirement-shell-idempotency | shell | TP-LC-03,07,13,14,20,21,22 | Re-install / uninstall absent / PATH / profile; `BASHRC` create / dongle modify / VERSION+PATH no-op |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05, TP-CLI-07, TP-CLI-14, TP-DNS-05, TP-DNS-08, TP-DNS-11, TP-DNS-13 | self-uninstall confirm; empty-argv TTY vs pipe; dns walk vs list/set; pick 9 is a Host |
| requirement-shell-cli-storage | shell | TP-CLI-12, TP-CLI-06 | Isolation; about JSON storage fields |
| requirement-shell-automatic-checksum | shell | TP-CSUM-01, TP-CLI-04, TP-CLI-06 | Companion **link** on install; CHECKSUM omitted from help/about. Not TP-LC-01. |
| requirement-domain-sshd | domain | TP-CLI-04, TP-CLI-06, TP-CLI-14, TP-CLI-15, TP-LC-16, TP-LC-17, **TP-SSHD-01**, **TP-SSHD-02**, **TP-SSHD-03..08**, **TP-SSHD-09..14**, **TP-DNS-01..38**, **TP-TX-09**, **TP-TX-13**, **TP-TX-16** | help rows; menu 1–5; POSIX Linux non-root hides 2/3/4; host-local Linux errors; systemd unit path law 1.10.0 (ship Gap); Termux daemonize; dns Edit/Add/Delete; minted Host/IP fixtures |
| requirement-shell-termux-ish | shell | TP-LC-15, TP-LC-16, TP-LC-18, TP-LC-19, **TP-TX-08..16** | not Termux: `pkg` / `termux-wake-lock` not invoked; Termux mock: `pkg install -y openssh termux-auth`; auto-acquire + `wake-lock` verb; Git Bash / Windows cmd skip |
| requirement-shell-script-coding | shell | TP-CLI-01, TP-CLI-11 | `sh -n`; `set -u` with HOME unset |

**Absent by design (no TP Core):** folder-archive backup/restore, sudoers-file emit, systemd unit files.

**Honest todo (not Core this cut):** dedicated `stop`/`port`/`config`/`host-keys`/`auth-keys` behavioral TPs; public-network curl; prefix-scan for modular-function-design.
