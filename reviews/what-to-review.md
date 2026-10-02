# What to review — sshd-cli

**Living checklist** (review plan). Product: **sshd-cli** — simplify Termux to install sshd.  
**Class:** software-development · domain SSOT `requirement-domain-sshd` · online-install channel + TTY menu / non-TTY CLI self-install.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-10-02  
**Ship unit VERSION:** 1.32.0  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|-------|
| P1 | Read `docs/requirements/index.md` | Class + 17 shell + domain sshd + 3 pointers (22 Active, including `requirement-shell-cli-self-install`) |
| P2 | Confirm ship unit `src/sshd-cli` / `./sshd-cli` | `APP_NAME` / `VERSION` hard-assign (**1.32.0**); same bytes |
| P2a | Language menu numbers | Front **5** language. Block **50–69** is at most 20 languages. Assigned **51–63**. **50** and **64–69** are not printed. Front **6** is not a row. **TP-CLI-24** |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** is `cloudgen/sshd-cli` | `SCRIPT_URL` default raw GitHub |
| P6 | Confirm retired verbs stay unknown | `backup` / `restore` (not `backup-config`). `print-sudoers` is live (menu **73**) |
| P7 | Human-facing | Every REQ has §1.1; README Description is people language; help does not lead with Type 0 |
| P8 | Normal-user-only CLI | Termux / Git Bash / Windows cmd: no `sudo curl`, no `pkg` except Termux named list |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh; Termux sshd purpose; **project nature** |
| Domain | `requirement-domain-sshd.md` | status/start/stop/port/keys/menu/dns; `fix-config` comments unsupported OpenSSH client keywords by OS and runs on every start against `~/.ssh/config`; Termux daemonize; POSIX Linux systemd `systemctl` unit path; this-login ssh_config dns-ip; non-root server hides **22–24**; Termux Old OpenSSH comments + `ssh -o`; TTY unknown choice redisplay; **upload** client **14** (**TP-UL-01..18**); sudoers front **7** |
| CLI interface | `requirement-shell-cli-interface.md` | This-login + domain commands, flags, dispatch; dual mention |
| Empty argv | `requirement-shell-cli-zero-arguments.md` · `requirement-shell-cli-self-install.md` | TTY **menu** / non-TTY **CLI self-install** (not payload) |
| Self-management | `requirement-shell-self-management.md` | install / self-update / self-uninstall; companion **call site** |
| Path / shell-rc | `requirement-shell-path-and-shell-support.md` | PATH + profile; sibling unify; **TP-LC-20..22**; `rc-test` ship Gap |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | domain prefix **`sshd_*`** |
| Idempotency | `requirement-shell-idempotency.md` | Re-install / pipe re-run (not TTY empty argv); bashrc exact-PATH no-op |
| Storage | `requirement-shell-cli-storage.md` | Per-login per-process cache (Linux shm → tmp → `~/.cache`; Git Bash tmp → AppData; Mac tmp → Library/Caches → `~/cache`); silent tier miss; persistence `${HOME}/.local/${APP_NAME}` |
| Interactive vs non-interactive | `requirement-shell-interactive-vs-noninteractive.md` | TTY ask vs pipe never-wait; unknown TTY menu redisplay |
| Script coding | `requirement-shell-script-coding.md` | `set -u`; do-not-capture-read |
| Automatic checksum | `requirement-shell-automatic-checksum.md` | Companion link/value/result; CHECKSUM not on help |
| Termux-ish | `requirement-shell-termux-ish.md` | Detect / named `pkg`; Android wake lock auto-acquire + `wake-lock`; Git Bash / Windows cmd |

**Do not review as this product’s law:** folder-archive backup, restore dest whitelist, sudoers-file emit (those remain on sibling **folder-backup**).

---

## Coverage honesty (this product)

| Claim | Truth |
|-------|--------|
| Online channel | **In scope** (`SCRIPT_URL`, `self-update`, `version-check`) |
| Empty argv | Split: TTY menu / non-TTY CLI self-install |
| Checksum in Core CI | **TP-CSUM-01** (file:// link + PASS-or-warn); not TP-LC-01 |
| Domain TPs | Present for status Connect, menu, pkg, start-after-install, ssh/download/upload, TTY unknown-menu retry; full start/stop/port/keys behavior still residual |

---

## Human-readability gate

- [ ] Each registered `requirement-*.md` has **§1.1 Human-facing** (one sentence, three boxes, includes/excludes, practice)
- [ ] Lead is not only Type 0 / Type 1 / euid / F6
- [ ] §1.1 says **project nature**, not **project class**
- [ ] Product README Description uses the same voice pack; Features/Usage do not lead with catalog codes
- [ ] README does **not** recommend `sudo curl | sh` for Termux / Git Bash / Windows cmd


## Language menu numbers (2026-10-02)

- [x] Front row is **5** language on every host, including Termux / Git Bash / Windows cmd
- [x] Language rows are reserved **50–69** (twenty numbers, not more than 20 languages)
- [x] Assigned rows are **51** English, **52** 繁體中文, **53** Español, **54** Français, **55** Deutsch, **56** 简体中文, **57** 日本語, **58** 한국어
- [x] **50** and **59–69** are not printed; choosing **50**, **69**, or old **61** warns and does not write `language`
- [x] Front **6** is not a row
- [x] Requirements, review matrix, test plan, and **TP-CLI-24** name the same numbers
- [x] `src/sshd-cli` and `./sshd-cli` are the same bytes, and `sshd-cli.sha256` is the bare hex of that file
