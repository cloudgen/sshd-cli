# What to review — sshd-cli

**Living checklist** (review plan). Product: **sshd-cli** — simplify Termux to install sshd.  
**Class:** software-development · domain SSOT `requirement-domain-sshd` · online-install Type O.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-09-05  
**Ship unit VERSION:** 1.0.0  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + shell + domain sshd |
| P2 | Confirm ship unit `src/sshd-cli` / `./sshd-cli` | `APP_NAME` / `VERSION` hard-assign (**1.0.0**) |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** is `cloudgen/sshd-cli` | SCRIPT_URL default raw GitHub |
| P6 | Confirm trimmed verbs stay unknown | backup / restore / print-sudoers |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh; Termux sshd purpose |
| Domain | `requirement-domain-sshd.md` | status/start/stop/port/keys/menu |
| CLI interface | `requirement-shell-cli-interface.md` | Type 0 + domain commands, flags, dispatch |
| Empty argv Type O | `requirement-shell-cli-zero-arguments.md` | Empty = install-ensure |
| Self-management | `requirement-shell-self-management.md` | install / self-update / self-uninstall |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | no domain prefix |
| Idempotency | `requirement-shell-idempotency.md` | Re-install |
| Storage | `requirement-shell-cli-storage.md` | Isolation |

**Do not review as this product’s law:** folder-archive backup, restore dest whitelist, sudoers-file emit (those remain on sibling **folder-backup**).
