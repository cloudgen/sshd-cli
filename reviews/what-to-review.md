# What to review — sshd-cli

**Living checklist** (review plan). Product: **sshd-cli** — simplify Termux to install sshd.  
**Class:** software-development · domain SSOT `requirement-domain-sshd` · online-install channel + TTY menu / non-TTY install-ensure.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-09-07  
**Ship unit VERSION:** 1.5.0  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|-------|
| P1 | Read `docs/requirements/index.md` | Class + 11 shell + domain sshd (13 Active) |
| P2 | Confirm ship unit `src/sshd-cli` / `./sshd-cli` | `APP_NAME` / `VERSION` hard-assign (**1.5.0**); same bytes |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** is `cloudgen/sshd-cli` | `SCRIPT_URL` default raw GitHub |
| P6 | Confirm trimmed verbs stay unknown | backup / restore / print-sudoers |
| P7 | Human-facing | Every REQ has §1.1; README Description is people language; help does not lead with Type 0 |
| P8 | Normal-user-only CLI | Termux / Git Bash / Windows cmd: no `sudo curl`, no `pkg` except Termux named list |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh; Termux sshd purpose; **project nature** |
| Domain | `requirement-domain-sshd.md` | status/start/stop/port/keys/menu/dns; start after install; background daemon; this-login ssh_config dns-ip |
| CLI interface | `requirement-shell-cli-interface.md` | This-login + domain commands, flags, dispatch; dual mention |
| Empty argv | `requirement-shell-cli-zero-arguments.md` | TTY **menu** / non-TTY **install-ensure** |
| Self-management | `requirement-shell-self-management.md` | install / self-update / self-uninstall |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | domain prefix **`sshd_*`** |
| Idempotency | `requirement-shell-idempotency.md` | Re-install / pipe re-run (not TTY empty argv) |
| Storage | `requirement-shell-cli-storage.md` | Isolation |
| Interactive vs non-interactive | `requirement-shell-interactive-vs-noninteractive.md` | TTY ask vs pipe never-wait |
| Script coding | `requirement-shell-script-coding.md` | `set -u`; do-not-capture-read |
| Automatic checksum | `requirement-shell-automatic-checksum.md` | Companion link/value/result; CHECKSUM not on help |
| Termux-ish | `requirement-shell-termux-ish.md` | Detect / named `pkg`; not Linux `apt`; Git Bash / Windows cmd |

**Do not review as this product’s law:** folder-archive backup, restore dest whitelist, sudoers-file emit (those remain on sibling **folder-backup**).

---

## Coverage honesty (this product)

| Claim | Truth |
|-------|--------|
| Online channel | **In scope** (`SCRIPT_URL`, `self-update`, `version-check`) |
| Empty argv | Split: TTY menu / non-TTY install-ensure |
| Checksum in Core CI | **TP-CSUM-01** (file:// link + PASS-or-warn); not TP-LC-01 |
| Domain TPs | Present for status Connect, menu, pkg, start-after-install; **todo** for full start/stop/port/keys behavior |

---

## Human-readability gate

- [ ] Each registered `requirement-*.md` has **§1.1 Human-facing** (one sentence, three boxes, includes/excludes, practice)
- [ ] Lead is not only Type 0 / Type 1 / euid / F6
- [ ] §1.1 says **project nature**, not **project class**
- [ ] Product README Description uses the same voice pack; Features/Usage do not lead with catalog codes
- [ ] README does **not** recommend `sudo curl | sh` for Termux / Git Bash / Windows cmd
