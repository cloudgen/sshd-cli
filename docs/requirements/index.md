# Requirements index

**Product:** sshd-cli — a POSIX `/bin/sh` program you run as yourself to install and run OpenSSH sshd on Termux (and ordinary Linux). Catalog: Type 0 self-install + domain SSOT.  
**Workspace state:** Specialized product law (not blank genesis); **software-development** class; bootstrap origin **selfmanaged** (A → B).  
**Updated:** 2026-09-28 (1.28.0: interactive no-command, including a switch such as `--debug`, opens the menu; `--quiet` / `--json` with no command places the CLI. 2026-09-27: 1.27.0 per-login per-process cache folder; 1.26.0 Termux Old OpenSSH comments + `ssh -o`; sudoers front **7** / **71–75**)

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, no package tool) | class | Active | `requirement-class-software-dev.md` | 2026-09-09 |
| requirement-shell-automatic-checksum | Automatic companion-digest integrity (transparent link/value/result; CHECKSUM not help/about) | shell | Active | `requirement-shell-automatic-checksum.md` | 2026-09-06 |
| requirement-shell-cli-default-interaction | TTY numbered main menu (interactive zero-cli-verb → this menu; switches allowed; default menu style; non-repeating number prefix; numbered lists of CLI verbs; layered menu; back to the top menu after a command; front 1/2/7/8; sudoers **71–75**; **82** runs about; §6 term definitions) | shell | Active | `requirement-shell-cli-default-interaction.md` | 2026-09-28 |
| requirement-shell-cli-interface | Shell CLI interface (commands, flags, dispatch, modes; zero-cli-verb split; `self-install`; `wake-lock`; `BASHRC`; `rc-test` dual mention; `dns unset`; `ssh`; `download` / `upload` TTY user default; `download` `~/folder`; menu dual mention; TTY unknown choice redisplay; TTY **82** about; about cache lines) | shell | Active | `requirement-shell-cli-interface.md` | 2026-09-28 |
| requirement-shell-cli-self-install | CLI self-place: non-interactive zero-cli-verb + `self-install`; copy when `$0` is a script; dest 0700 local / 0755 global; not payload | shell | Active | `requirement-shell-cli-self-install.md` | 2026-09-28 |
| requirement-shell-cli-storage | Per-login per-process cache folder (Linux shm → tmp → `~/.cache`; Git Bash tmp → AppData; Mac tmp → Library/Caches → `~/cache`) and persistence `${HOME}/.local/${APP_NAME}` | shell | Active (1.3.0) | `requirement-shell-cli-storage.md` | 2026-09-27 |
| requirement-shell-cli-zero-arguments | Zero-cli-verb (no verb; switches allowed): interactive → main menu; non-interactive → Type O CLI self-install (not help, not payload) | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-09-28 |
| requirement-shell-idempotency | Shell idempotency / re-run safety for ensure-style ops | shell | Active | `requirement-shell-idempotency.md` | 2026-09-09 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / `curl\|sh` behavior (`download` / `upload` `~/folder`; TTY unknown menu redisplay; finished leaf → front board) | shell | Active | `requirement-shell-interactive-vs-noninteractive.md` | 2026-09-16 |
| requirement-shell-modular-function-design | Single-file modular function design (prefixes, zones) | shell | Active | `requirement-shell-modular-function-design.md` | 2026-09-27 |
| requirement-shell-output-requirements | Central `out_*` output SSOT (stdout/stderr, modes; `@key` raw nested JSON) | shell | Active | `requirement-shell-output-requirements.md` | 2026-09-05 |
| requirement-shell-path-and-shell-support | Shell-rc PATH + profile ensure (sibling unify, scoped uninstall, heal, `rc-test`) | shell | Active | `requirement-shell-path-and-shell-support.md` | 2026-09-09 |
| requirement-shell-self-management | Self-management lifecycle (version-check, update, uninstall, about; companion **call site**) | shell | Active | `requirement-shell-self-management.md` | 2026-09-09 |
| requirement-shell-script-coding | POSIX shell coding-style home (set -u, prefixes, do-not-capture-read, mkdir fail-soft) | shell | Active | `requirement-shell-script-coding.md` | 2026-09-11 |
| requirement-shell-sudo-command | Points at `requirement-shell-sudoer` (`util_sudo` wrap slice) | shell | Active | `requirement-shell-sudo-command.md` | 2026-09-12 |
| requirement-shell-sudoer | All sudoer features: JSON grant, print/generate/submit, `util_sudo` | shell | Active | `requirement-shell-sudoer.md` | 2026-09-12 |
| requirement-shell-config-backup | `backup-config` / `sync-config` / `sync-from-remote` (depends on shell-sudoer) | shell | Active | `requirement-shell-config-backup.md` | 2026-09-12 |
| requirement-shell-termux-ish | Termux-like this-login `pkg` companion (detect/invoke/fail-closed; not Linux `apt`) + Android wake lock | shell | Active | `requirement-shell-termux-ish.md` | 2026-09-07 |
| requirement-sshd-config-backup | Points at `requirement-shell-config-backup` (product store names) | backup | Active | `requirement-sshd-config-backup.md` | 2026-09-12 |
| requirement-sudoer-json-file | Points at `requirement-shell-sudoer` (JSON slice) | privilege | Active | `requirement-sudoer-json-file.md` | 2026-09-12 |
| requirement-three-layer-privilege-model | Type 0/1/2 map; sudoer verbs point at `requirement-shell-sudoer` | privilege | Active | `requirement-three-layer-privilege-model.md` | 2026-09-12 |
| requirement-domain-sshd | OpenSSH sshd domain (status/start/stop/port/keys/menu/dns; `dns unset`; `ssh` **12** + user default; `download` **13** + user default + `~/folder`; `upload` **14** + user default + local `tar.gz` into remote home; TTY unknown menu redisplay; finished leaf → front board; backup-config/sync-config; sudoers front **7** / **71–75**; Termux daemonize; POSIX Linux systemd `systemctl` unit path; this-login ssh_config dns-ip; non-root hides 22–24; self-update CLI-only) | domain | Active | `requirement-domain-sshd.md` | 2026-09-27 |

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for sshd-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files (or future registered ones) — never `template-*` / `skill-*` as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here (git-surface; INC-20260712-005).  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Registry discipline (summary only):** invent no paths; same-change file+row; empty registry valid at genesis; this file stays **requirement rows only** (no harness tree dumps).  
7. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
