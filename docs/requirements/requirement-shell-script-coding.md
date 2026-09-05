**file**: docs/requirements/requirement-shell-script-coding.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-script-coding`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This is the **coding-style related requirement** for sshd-cli (POSIX `/bin/sh`). **Without this file, portable learned lessons arrive raw** and agents treat coding skills as product law. It is the specialize-in home for shell coding rules that are not already owned by modular-function-design, output, or interactive-vs-noninteractive peers.

### 1.1 Human-facing

**In one sentence:** This file says how the `./sshd-cli` script must be written: prefixes, `set -u`, no capturing a `read` prompt with `$()`, and keep the Protection Zones.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Someone changing `./sshd-cli` | Add a function, keep `Last updated` |
| The other role | Peer files that already own output / prefixes catalog / TTY vs pipe | `requirement-shell-output-requirements.md` |
| Not this file | Which sshd verbs exist | `requirement-domain-sshd.md` |

| Includes | Excludes |
|----------|----------|
| `set -u`, prefix map pointer, do-not-capture-read, function `Last updated` | Re-owning the full `out_*` catalog |
| Domain prefix `sshd_*` | Python / Node style |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./sshd-cli` | Ship unit | Live style |
| `sh -n ./sshd-cli` | Syntax check | Must pass |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Add a helper | New name uses the right prefix; do not `$()` `prompt_ask` | Edit `./sshd-cli`; `sh -n ./sshd-cli` |
| Change a fatal | Human what-happened / next-step | Keep `out_die` |

---

## 2. Core Rules / Requirements (Mandatory)

1. **MUST** keep `set -u` at the top of `./sshd-cli`. **MUST NOT** add global `set -e`.  
2. **MUST** use the prefix families owned by `requirement-shell-modular-function-design` plus domain **`sshd_*`**.  
3. **MUST** send product user messages through `out_*` (`requirement-shell-output-requirements`).  
4. **MUST NOT** capture a `read` helper with `$()` / command substitution (**do-not-capture-read**). `prompt_ask` returns via stdout for class-B data; **new** TTY choice code (including `menu`) **MUST** `read` in the current shell, not `_x=$(prompt_ask …)`.  
5. **MUST** keep a `Last updated:` (or `Last reviewed:`) line on every function header that is edited.  
6. **MUST NOT** strip CIAO Protection Zones / `DO NOT MODIFY` dispatcher comments for brevity.  
7. **MUST** initialize variables used under `set -u` (`: "${VAR:=…}"` or a prior assign).  
8. **MUST NOT** use this file as a second copy of install or checksum tables.  
9. **SHOULD** keep `sh -n ./sshd-cli` passing in `tests/test_cli.sh`.  
10. In-tool sudo wrappers: **none** on this product. If sudo is added later, a dedicated sudo-command requirement **MUST** own the wrap (class residual points).

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Ship unit | `./sshd-cli` POSIX `/bin/sh` |
| Prefixes in use | `out_` `inst_` `path_` `ver_` `util_` `prompt_` `app_` `sshd_` |
| `set -u` | yes (file top) |
| Menu read | `sshd_cmd_menu` calls `read -r` in-function (not `$()` of `prompt_ask`) |
| Sudo wrap | none |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Style home is named so lessons do not arrive raw.  
- **CIAO Principle 4 / 20 – Over-protect** (https://github.com/cloudgen/ciao): Protection Zones stay.  
- **CIAO Principle 21 – Dual policies** (https://github.com/cloudgen/ciao): Portable core; filled notes.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: `set -u` catches missing assigns.  
- **Intentional**: Prefixes encode job.  
- **Anti-fragile**: No global `set -e`.  
- **Over-protect**: Do not capture `read` in `$()`.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Delete this file while the workspace is software-development.  
2. Treat coding skills as product law because this file is missing.  
3. `$()` a `prompt_*` helper for new TTY choice code.  
4. Duplicate the full output or install tables here.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-modular-function-design.md` | Prefix catalog |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` |
| `docs/requirements/requirement-class-software-dev.md` | Residual points here |
| `./sshd-cli` | Implementation |

**Last Updated**: 2026-09-04  
**Owner**: Cloudgen Wong  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
