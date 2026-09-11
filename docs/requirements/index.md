# Requirements index

**Product:** sshd-cli — a POSIX `/bin/sh` program you run as yourself to install and run OpenSSH sshd on Termux (and ordinary Linux). Catalog: Type 0 self-install + domain SSOT.  
**Workspace state:** Specialized product law (not blank genesis); **software-development** class; bootstrap origin **selfmanaged** (A → B).  
**Updated:** 2026-09-11 (backup-config / sync-config / sudoers grant)

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, no package tool) | class | Active | `requirement-class-software-dev.md` | 2026-09-09 |
| requirement-shell-automatic-checksum | Automatic companion-digest integrity (transparent link/value/result; CHECKSUM not help/about) | shell | Active | `requirement-shell-automatic-checksum.md` | 2026-09-06 |
| requirement-shell-cli-interface | Shell CLI interface (commands, flags, dispatch, modes; `wake-lock`; `BASHRC`; `rc-test` dual mention) | shell | Active | `requirement-shell-cli-interface.md` | 2026-09-09 |
| requirement-shell-cli-storage | Scratch/cache storage resolve (per-user isolation, mkdir fail-soft, Git Bash AppData Temp) | shell | Active | `requirement-shell-cli-storage.md` | 2026-09-11 |
| requirement-shell-cli-zero-arguments | Empty argv: TTY menu / non-TTY Type O install-ensure | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-09-09 |
| requirement-shell-idempotency | Shell idempotency / re-run safety for ensure-style ops | shell | Active | `requirement-shell-idempotency.md` | 2026-09-09 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / `curl\|sh` behavior | shell | Active | `requirement-shell-interactive-vs-noninteractive.md` | 2026-09-09 |
| requirement-shell-modular-function-design | Single-file modular function design (prefixes, zones) | shell | Active | `requirement-shell-modular-function-design.md` | 2026-09-05 |
| requirement-shell-output-requirements | Central `out_*` output SSOT (stdout/stderr, modes; `@key` raw nested JSON) | shell | Active | `requirement-shell-output-requirements.md` | 2026-09-05 |
| requirement-shell-path-and-shell-support | Shell-rc PATH + profile ensure (sibling unify, scoped uninstall, heal, `rc-test`) | shell | Active | `requirement-shell-path-and-shell-support.md` | 2026-09-09 |
| requirement-shell-self-management | Self-management lifecycle (version-check, update, uninstall, about; companion **call site**) | shell | Active | `requirement-shell-self-management.md` | 2026-09-09 |
| requirement-shell-script-coding | POSIX shell coding-style home (set -u, prefixes, do-not-capture-read, mkdir fail-soft) | shell | Active | `requirement-shell-script-coding.md` | 2026-09-11 |
| requirement-shell-sudo-command | In-tool `util_sudo` wrap + studied allow table (`backup-config` only) | shell | Active | `requirement-shell-sudo-command.md` | 2026-09-11 |
| requirement-shell-termux-ish | Termux-like this-login `pkg` companion (detect/invoke/fail-closed; not Linux `apt`) + Android wake lock | shell | Active | `requirement-shell-termux-ish.md` | 2026-09-07 |
| requirement-sshd-config-backup | Deposit this-login `~/.ssh/config` to `/var/sshd-cli` (`backup-config`) and Type 0 `sync-config` | backup | Active | `requirement-sshd-config-backup.md` | 2026-09-11 |
| requirement-sudoer-json-file | JSON sudoer grant body (`sshd-cli backup-config` only) | privilege | Active | `requirement-sudoer-json-file.md` | 2026-09-11 |
| requirement-three-layer-privilege-model | Sudoers print/generate/submit/admin-script workflow | privilege | Active | `requirement-three-layer-privilege-model.md` | 2026-09-11 |
| requirement-domain-sshd | OpenSSH sshd domain (status/start/stop/port/keys/menu/dns; backup-config/sync-config; sudoers; Termux daemonize; POSIX Linux systemd `systemctl` unit path; this-login ssh_config dns-ip; menu row 5; non-root hides 2/3/4; self-update CLI-only) | domain | Active | `requirement-domain-sshd.md` | 2026-09-11 |

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for sshd-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files (or future registered ones) — never `template-*` / `skill-*` as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here (git-surface; INC-20260712-005).  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Registry discipline (summary only):** invent no paths; same-change file+row; empty registry valid at genesis; this file stays **requirement rows only** (no harness tree dumps).  
7. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
