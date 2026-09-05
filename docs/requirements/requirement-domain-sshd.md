**file**: docs/requirements/requirement-domain-sshd.md  
**Status**: Active (Version 1.0.0)  
**Area**: domain  
**Key**: `requirement-domain-sshd`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This is the **one Active domain SSOT** for **sshd-cli**. The product **purpose** is to **simplify Termux to install sshd**. OpenSSH **sshd** (the SSH server) plus this login’s **authorized_keys** are the domain; Termux is the first home and ordinary POSIX Linux is the second. Type 0 install/self-update/self-uninstall stay on the shell lifecycle requirements. This file owns specialized subcommands, features, help rows, and about fields.

Bootstrap origin is **selfmanaged** (A → B only). Domain law lives here on B, never on A.

### 1.1 Human-facing

**In one sentence:** You use `sshd-cli` so installing and running OpenSSH sshd on Termux is simple — one program, not a pile of path, port, and key steps.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The person who wants SSH into this device | `sshd-cli status` · `sshd-cli start` |
| The other role | OpenSSH `sshd` + `sshd_config` + host keys | Termux `$PREFIX/etc/ssh` or Linux `/etc/ssh` |
| Not this file | Installing *this CLI* (`install`, empty argv, `self-update`) | `requirement-shell-cli-zero-arguments.md` |

| Includes | Excludes |
|----------|----------|
| status / start / stop / restart / port / config / host-keys / auth-keys / menu | Wrapping `sudo` inside this CLI; systemd unit files; SSH *client* session mux |
| Termux user-level sshd and Linux system sshd with a root login | Inventing a dedicated `sshd-adm` account |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./sshd-cli` | Program | Live domain verbs |
| `sshd-cli help` | Command | Domain rows after Type 0 |
| `sshd-cli menu` | Terminal list | Numbered domain choices (not empty argv) |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See if sshd is up | Paths, port, pid | `sshd-cli status` |
| Listen on Termux | Default port is often 8022 | `sshd-cli start` then `ssh -p 8022 user@host` |
| Allow a laptop key | Append one public-key file | `sshd-cli auth-keys add ./laptop.pub` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Specialized CLI subcommands

| Verb | Operands | Handler | Privilege | Errors |
|------|----------|---------|-----------|--------|
| `status` | none | `sshd_cmd_status` | This login | Missing sshd → warn, still print paths |
| `start` | none | `sshd_cmd_start` | Termux: this login. Linux system sshd: **root login** (no in-tool sudo) | No binary / bad config / not writable → `out_die` |
| `stop` | none | `sshd_cmd_stop` | Same as start | Cannot signal pid → `out_die` |
| `restart` | none | `sshd_cmd_restart` | Same as start | Same as stop then start |
| `port` | optional `N` | `sshd_cmd_port` | Show: this login if config readable. Set: writable config | Non-numeric / out of 1–65535 → `out_die` |
| `config` | none | `sshd_cmd_config` | This login | Unreadable config → warn |
| `host-keys` | `list` (default) or `generate` | `sshd_cmd_host_keys` | generate needs a writable host-key dir | Unknown action → `out_die` |
| `auth-keys` | `list` (default) or `add <pubkey-file>` | `sshd_cmd_auth_keys` | This login’s `~/.ssh` | Missing file / no key line → `out_die` |
| `menu` / `main` | none | `sshd_cmd_menu` | TTY only | `--json` / quiet / non-TTY → `out_die` with named-command hint |

**Routing:** `app_main` parses these verbs in the same pass as Type 0. Operands after `port` / `host-keys` / `auth-keys` are domain operands, not unknown flags.

**MUST:** Each verb above is also named on `requirement-shell-cli-interface` (dual mention).  
**MUST NOT:** Replace empty argv with this menu. Empty argv stays Type O install-ensure.

**Invocation samples:**

```sh
sshd-cli status
sshd-cli --json status
sshd-cli start
sshd-cli stop
sshd-cli restart
sshd-cli port
sshd-cli port 8022
sshd-cli config
sshd-cli host-keys
sshd-cli host-keys generate
sshd-cli auth-keys
sshd-cli auth-keys add ./laptop.pub
sshd-cli menu
```

### 2.2 Specialized features

**Path resolve (SSOT `sshd_resolve`):**

| Field | Termux | POSIX Linux |
|-------|--------|-------------|
| Platform id | `termux` | `posix` |
| sshd binary | `${PREFIX}/bin/sshd` or `command -v sshd` | `command -v sshd` or `/usr/sbin/sshd` |
| Config | `${PREFIX}/etc/ssh/sshd_config` | `/etc/ssh/sshd_config` |
| Host keys | `${PREFIX}/etc/ssh` | `/etc/ssh` |
| Pid file | `${PREFIX}/var/run/sshd.pid` | `/run/sshd.pid` or `/var/run/sshd.pid` |
| Default Port | `8022` if config has no Port | `22` if config has no Port |
| Login keys | `${HOME}/.ssh/authorized_keys` | same |

Termux detect: `PREFIX` contains `com.termux`, or `TERMUX_VERSION` set, or `/data/data/com.termux/files/usr` exists.

**Semantics:**

1. **status** is read-only. Missing sshd is a warning, not a crash.  
2. **start** is idempotent: already running → success no-op. Missing host keys → generate when the host-key dir is writable. `sshd -t` must pass before launch.  
3. **stop** is idempotent: already stopped → success no-op.  
4. **port set** rewrites the `Port` line (or appends one). Does not auto-restart; human mode tells the operator to `restart` when sshd is up.  
5. **host-keys generate** creates ed25519 if missing; tries rsa 4096 and warns if declined. Never overwrite existing private host keys.  
6. **auth-keys add** appends one `ssh-ed25519` / `ssh-rsa` / ecdsa / sk- line from a **file**. Duplicate line → success no-op. Creates `~/.ssh` mode `700` and `authorized_keys` mode `600` when possible.  
7. **No in-tool sudo.** If a Linux system path is not writable, fail closed and tell the operator to re-run as root or use Termux.  
8. **No systemd.** Start is `sshd -f <config>`. Stop is signal the sshd pid (pidfile, then `pgrep -x sshd`).

**Non-goals:** SSH client `ProxyJump` recipes, Dropbear-only hosts, changing Linux firewall, wrapping `pkg`/`apt` inside the CLI, password-auth policy as a verb (shown on `config` only).

**Filename grammar (when this domain allocates files):** host keys use OpenSSH names, not a dated JSON grant.

```text
{{HOSTKEY_DIR}}/ssh_host_ed25519_key
{{HOSTKEY_DIR}}/ssh_host_ed25519_key.pub
```

Example on Termux: `$PREFIX/etc/ssh/ssh_host_ed25519_key`

**authorized_keys sample line:**

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKeyMaterialOnly laptop-user
```

### 2.3 Specialized project help items

`help` **MUST** keep Type 0 rows, then a **Domain commands (OpenSSH sshd):** section:

- `status` — Show whether sshd is running, and the port/paths  
- `start` / `stop` / `restart`  
- `port [N]`  
- `config`  
- `host-keys [list|generate]`  
- `auth-keys [list|add <file>]`  
- `menu` — Numbered list of domain commands (terminal only)

**MUST NOT** list install / self-update / version / about inside `menu`.  
This product has **no test-purpose verbs**. Help has no tester heading.

### 2.4 Specialized project about items

Human `about` **MUST** add after storage lines: sshd platform, binary, port, running yes/no.  
JSON `about` **MUST** add fields: `sshd_platform`, `sshd_bin`, `sshd_port`, `sshd_running`.  
**MUST NOT** put `CHECKSUM` on about.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Product | `sshd-cli` 1.0.0 |
| Bootstrap origin | `selfmanaged` 1.2.3 (architecture + Type 0 only; A untouched) |
| Domain prefix | `sshd_*` |
| Channel | `https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli` |
| In-tool sudo | **none** — no `requirement-shell-sudo-command` |
| Dest / fence | **none** |
| Menu | Verb `menu`/`main` (Type O owns empty argv) |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Termux vs Linux paths are named, not guessed per call.  
- **CIAO Principle 9 – Type 0/1/2** (https://github.com/cloudgen/ciao): Domain start/stop stay invoker Type 0; Linux root is a **login**, not a hidden sudo wrap.  
- **CIAO Principle 10 – Least privilege** (https://github.com/cloudgen/ciao): No dedicated system user; no sudoers fragment.  
- **CIAO Principle 5 – SSOT of output** (https://github.com/cloudgen/ciao): Domain messages use `out_*`.  
- **CIAO Principle 21 – Dual policies** (https://github.com/cloudgen/ciao): Portable core; filled notes.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail closed on missing sshd, bad port, unreadable pubkey file.  
- **Intentional**: One domain SSOT; dual mention on the CLI-interface file.  
- **Anti-fragile**: Works when systemd is absent (Termux).  
- **Over-protect**: Never overwrite host private keys; never `$()` a `read` helper for `menu`.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Drop Type 0 routes while adding domain verbs.  
2. Make empty argv open `menu` (Type O install-ensure stays).  
3. Wrap `sudo` without a studied sudo-command requirement.  
4. Overwrite existing host private keys on `generate`.  
5. Put domain law only on the bootstrap origin.  
6. Lead help/about with Type 0/Type 1 jargon as the only words.  
7. Echo secret key **private** material (public key lines on `auth-keys list` are intended).

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of domain verbs |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv is not menu |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` |
| `docs/requirements/requirement-class-software-dev.md` | Class residual points here |
| `./sshd-cli` | Implementation |

**Last Updated**: 2026-09-04  
**Owner**: Cloudgen Wong  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
