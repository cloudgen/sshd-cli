**file**: docs/requirements/requirement-sshd-config-backup.md  
**Status**: Active (Version 1.0.0)  
**Area**: backup  
**Key**: `requirement-sshd-config-backup`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the operations Single Source of Truth for depositing this login’s `~/.ssh/config` into `/var/sshd-cli` (`backup-config`) and copying that store back into this login’s `~/.ssh/config` (`sync-config`) with mode `600`. It is the sshd-cli analog of grok-cli auth deposit (`backup` / `sync-auth`), not folder-archive tar.gz.

### 1.1 Human-facing

**In one sentence:** on a POSIX Linux host, `sshd-cli backup-config` copies this login’s SSH client config into `/var/sshd-cli/config` as root after a passwordless grant; `sshd-cli sync-config` copies that file back into `~/.ssh/config` as you, mode 600, with no sudo.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Push or pull the SSH client config | `sshd-cli backup-config` · `sshd-cli sync-config` |
| The other role | sudoer-adm approves passwordless `sudo sshd-cli backup-config` | JSON grant inbound |
| Not this file | Host list edit; sudoers JSON schema | `requirement-domain-sshd` · `requirement-sudoer-json-file` |

| Includes | Excludes |
|----------|----------|
| Source `~/.ssh/config`; dest `/var/sshd-cli/config`; SUDO_USER home when elevated; dest mode 600 on sync | Whole `~/.ssh` including private keys; folder-archive `backup`/`restore`; Termux / Git Bash / Windows cmd deposit |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./sshd-cli` | ship unit | live verbs |
| `/var/sshd-cli/config` | durable store | backup dest / sync source |
| `sshd-cli backup-config` | command | elevated push |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Share this login’s SSH names | Copy `~/.ssh/config` into the host store as root | `sshd-cli backup-config` |
| Use the shared names | Copy the store into this login’s `~/.ssh/config` as 600 | `sshd-cli sync-config` |

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Source and dest

1. Source **MUST** be the invoking login’s `{{HOME}}/.ssh/config`. When the process is root via sudo, invoking home **MUST** be `SUDO_USER`’s passwd home (not `/root`) unless tests set an explicit root home.  
2. Default dest directory **MUST** be `/var/sshd-cli`. Override `SSHD_CLI_ROOT` (tests / non-production). Store file **MUST** be `{{SSHD_CLI_ROOT}}/config`.  
3. **MUST NOT** copy private keys, `id_*`, or the whole `~/.ssh` directory.  
4. Missing source **MUST** fail closed. Next: create this login’s SSH config (for example `sshd-cli dns add`), then `sshd-cli backup-config`.

### 2.2 backup-config (elevated deposit)

1. On Termux, Git Bash, or Windows cmd **MUST** fail closed. Next: use a POSIX Linux host.  
2. Writing the production dest (`/var/sshd-cli` or a path under it) as a non-root login **MUST** re-exec `sudo -n {{GLOBAL_BIN}}/sshd-cli backup-config` (exact grant; no extra flags on the sudo command line) through `util_sudo`.  
3. If that sudo is refused, **MUST** fail closed and tell the operator to generate/submit a JSON grant for sudoer-adm. Next: `sshd-cli generate-sudoer-request && sshd-cli submit-sudoer-request`.  
4. As root, the ship unit **MUST** `mkdir` the dest if needed, copy the file, `chown root:root`, `chmod 0644` the file and `0755` the dest.  
5. **MUST NOT** grant OS tools (`cp`, `mkdir`, `chmod`, `chown`) in sudoers; those run inside the elevated product command.  
6. A writable `SSHD_CLI_ROOT` outside `/var/sshd-cli` **MAY** accept Type 0 deposit for tests (no chown). Production dest **MUST NOT** skip elev just because it happens to be writable.  
7. Re-running backup-config **MUST** overwrite the same basename (idempotent snapshot, no dated tar).

### 2.3 sync-config (no sudo)

1. `sync-config` **MUST NOT** call `sudo`.  
2. Source is `{{SSHD_CLI_ROOT}}/config`. Dest is this login’s `{{HOME}}/.ssh/config`.  
3. **MUST** fail closed if the store is missing or unreadable without sudo. Next: someone with an approved `sudo sshd-cli backup-config` must push first.  
4. **MUST** create dest `~/.ssh` if needed (dir mode `700` when possible).  
5. Dest `config` **MUST** be mode `600` after copy. Owner is this login.

### 2.4 Invocation samples

```text
sshd-cli backup-config
sshd-cli sync-config
sshd-cli generate-sudoer-request
sshd-cli submit-sudoer-request
```

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Store | `/var/sshd-cli/config` (`SSHD_CLI_ROOT` default `/var/sshd-cli`) |
| Source | `$(sshd_invoking_home)/.ssh/config` |
| Elev argv | `sudo -n /usr/local/bin/sshd-cli backup-config` |
| Handlers | `sshd_cmd_backup_config` · `sshd_cmd_sync_config` · `util_sudo` |
| Tests | `tests/test_config_backup.sh` **TP-CFG-01..09** |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least privilege** (https://github.com/cloudgen/ciao): elev is the product command only.  
- **CIAO Principle 12 – Right backup** (https://github.com/cloudgen/ciao): durable host store is not the dns pre-edit `.bak`.  
- **CIAO Principle 22 – File modes** (https://github.com/cloudgen/ciao): store 0644; dest 600.

## Under command line for normal user only

When the ship unit detects Termux, Git Bash, Windows cmd, or the same class: **MUST NOT** deposit into `/var/sshd-cli` or wrap `sudo`. Direct `backup-config` / `sync-config` **MUST** fail closed. TTY menu **MUST** print `[INFO] backup-config and sync-config not available for termux` / `gitbash` / `windows-cmd` **before** the numbered list and **MUST** omit those rows (and sudoers).

**This requirement:** deposit and pull are POSIX Linux host features; this-login-only shells keep Type 1 unused.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: SUDO_USER home; no private keys.  
- **Intentional**: `backup-config` vs `sync-config` vs dns `util_backup`.  
- **Anti-fragile**: `SSHD_CLI_ROOT` for tests; overwrite same leaf.  
- **Over-protect**: fail closed on this-login-only hosts.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Tar the whole `~/.ssh` or copy private keys.  
2. Name the pull verb `restore` / `restore-config` (folder-archive retired; pull is `sync-config`).  
3. Grant `cp`/`mkdir`/`chmod` in sudoers.  
4. Enable deposit on Termux / Git Bash / Windows cmd.  
5. Use `/root/.ssh/config` when `SUDO_USER` is set.

## 5. Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CFG-01** | `tests/test_config_backup.sh` | have |
| **TP-CFG-02** | `tests/test_config_backup.sh` | have |
| **TP-CFG-03** | `tests/test_config_backup.sh` | have |
| **TP-CFG-04** | `tests/test_config_backup.sh` | have |
| **TP-CFG-05** | `tests/test_config_backup.sh` | have |
| **TP-CFG-08** | `tests/test_config_backup.sh` | have |
| **TP-CFG-09** | `tests/test_config_backup.sh` | have |

**Matrix:** `docs/reviews/requirement-test-matrix.md`  
**Map:** `docs/reviews/test-plan.md`.

## 6. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-domain-sshd.md` | Dual mention catalog |
| `docs/requirements/requirement-sudoer-json-file.md` | JSON grant body |
| `docs/requirements/requirement-three-layer-privilege-model.md` | sudoers workflow |
| `docs/requirements/requirement-shell-sudo-command.md` | `util_sudo` |
| `./sshd-cli` | Ship unit |

**Last Updated**: 2026-09-11  
**Owner**: sshd-cli project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
