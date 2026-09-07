**file**: docs/requirements/requirement-domain-sshd.md  
**Status**: Active (Version 1.5.0)  
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
| Not this file | Installing *this CLI* binary (`self-update`, checksum) | `requirement-shell-self-management.md` |

| Includes | Excludes |
|----------|----------|
| status / start / stop / restart / port / config / host-keys / auth-keys / menu / **dns** | Wrapping `sudo` inside this CLI; systemd unit files; `termux-services` / `sv-enable`; cron-as-service; SSH *client* session mux / ProxyJump |
| OpenSSH sshd as a **background daemon** (`sshd -f`); pidfile stop | Foreground `-D`; `&` / `nohup` wrappers; a `enable-service` verb |
| This login’s `~/.ssh/config` **Host** entries as a numbered **dns-ip** list (alias → HostName) | Editing `/etc/hosts`; wrapping `systemd-resolved`; following `Include`; listing `Host *` / `?` wildcards |
| Termux `pkg install openssh termux-auth` as a companion of `install` (names + start after; invoke contract on `requirement-shell-termux-ish`) | Wrapping `apt` / `dnf` on POSIX Linux; owning Termux:Boot as a CLI verb |
| Termux user-level sshd and Linux system sshd with a root login | Inventing a dedicated `sshd-adm` account; auto-running `passwd` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./sshd-cli` | Program | Live domain verbs |
| `sshd-cli help` | Command | Domain rows after Type 0 |
| `sshd-cli` (no args, terminal) or `sshd-cli menu` | Terminal list | Numbered domain choices |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Prepare Termux for sshd | `install` places this program, creates `~/.bashrc` / `~/.profile` if needed, and on Termux runs `pkg install -y openssh termux-auth` | `sshd-cli install` |
| See if sshd is up | Paths, port, pid, and a copy-paste `ssh -p …` line | `sshd-cli status` |
| Listen on Termux | Default port is often 8022. OpenSSH **forks itself** into the background. This is not a boot service. | `sshd-cli start` then the Connect line from `status` |
| After a reboot | The daemon is gone with the old session. Start again. Termux:Boot (if you use it) is **your** hook, not a `sshd-cli` verb. | `sshd-cli start` — or put that command in `~/.termux/boot/` yourself |
| Allow a laptop key | Append one public-key file | `sshd-cli auth-keys add ./laptop.pub` |
| Name a phone for `ssh` | This login’s `~/.ssh/config` Host list: number, details, then edit fields | `sshd-cli dns` · `sshd-cli dns list` · `sshd-cli dns set 1 ip 192.168.1.10` |

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
| `dns` | `list` (default non-TTY) · `show <n\|name>` · `edit <n\|name>` · `set <n\|name> …` · `add …` · empty (TTY walk) | `sshd_cmd_dns` | This login’s `~/.ssh/config` | Missing n / empty dns name / bad port → `out_die` |
| `menu` / `main` | none | `sshd_cmd_menu` | TTY only | `--json` / quiet / non-TTY → `out_die` with named-command hint |

**Routing:** `app_main` parses these verbs in the same pass as Type 0. Operands after `port` / `host-keys` / `auth-keys` / **`dns`** are domain operands, not unknown flags. **MUST NOT** number `dns` as a main-menu row 5–8 (typed command; its **own** numbered Host list is separate).

**MUST:** Each verb above is also named on `requirement-shell-cli-interface` (dual mention).  
**MUST:** Interactive empty argv (`TTY=1`, not quiet/json) **MUST** call `sshd_cmd_menu` (same handler as `menu`). Dual mention: `requirement-shell-cli-zero-arguments`.  
**MUST NOT:** Open this menu on **non-interactive** empty argv (`curl \| sh`, quiet, json, no TTY) — that path stays install-ensure.

### 2.1.1 Install companion packages (Termux)

`install` and **non-interactive** empty-argv install-ensure **MUST** call domain helper `sshd_pkg_ensure` (via `inst_ensure_companion`) **before** the already-installed binary no-op. After the CLI binary is placed **or** the already-installed no-op, **MUST** start sshd (`sshd_start_after_install` → `sshd_cmd_start`). Dual mention: `requirement-shell-termux-ish` (detect / invoke contract), `requirement-shell-cli-interface` (`install` row), and `requirement-shell-self-management` (orchestrator). Interactive empty argv is the menu and **MUST NOT** run package ensure or auto-start as a side effect.

| After CLI place | MUST | MUST NOT |
|-----------------|------|----------|
| **Termux** | Start sshd (idempotent if already running). Fail closed if `sshd` is still missing after `pkg`. | Leave sshd stopped after a successful Termux `install` |
| **POSIX Linux** | Start when this login can (root / writable config). If not, **warn** and still succeed the CLI install | Fail the CLI install solely because system sshd needs root |
| **JSON `install`** | Start the daemon; **MUST NOT** emit a second JSON object from `start` | Mix two JSON objects on stdout |

| Host | MUST | MUST NOT |
|------|------|----------|
| **Termux** | `pkg install -y openssh termux-auth` (non-interactive `-y`; quiet/json suppress pkg stdout) | Hang on `pkg` prompts; skip packages because the CLI binary is already placed |
| **POSIX Linux** | No-op (operator uses the distro package manager) | Wrap `apt` / `dnf` / `yum` inside this CLI |
| **Termux, `pkg` missing** | Fail closed with operator-readable Next | Pretend sshd is ready |
| **Termux, pkg fail** | Fail closed: “Could not install openssh and termux-auth. Next: run: pkg install openssh termux-auth” | Continue as success |

**MUST NOT** run `passwd` automatically (secret; interactive). Human mode **MAY** hint: set a password with `passwd` if the operator will use password SSH.

**Invocation sample (same verb as CLI lifecycle):**

```sh
sshd-cli install
```

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
sshd-cli dns
sshd-cli dns list
sshd-cli --json dns list
sshd-cli dns show 1
sshd-cli dns edit 1
sshd-cli dns set 1 ip 192.168.1.10 user "" port 8022
sshd-cli dns add dns phone ip 192.168.1.10
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

1. **status** is read-only. Missing sshd is a warning, not a crash. Human mode **MUST** end with a recommended connect line `ssh -p <port> <user>@<lan-ipv4>` when a live IPv4 exists. **User** is `id -un`. **IPv4 SSOT:** `ifconfig wlan0` inet (Termux Wi-Fi). Then `wlan1`, then any `ifconfig` inet, then `ip` fallbacks. **MUST NOT** print a placeholder host (`<this-host>`, `<LAN-IPv4>`, `example.com`). If no usable IPv4: warn and say Next (turn on Wi-Fi, then `status`) — do not invent an address. JSON `connect` is that live string, or empty. **MUST NOT** freeze a session login or a sample home IP into product law.  
1b. **menu** numbered rows are **only** `status`, `start`, `stop`, `restart`, then **Exit 9**. `port` / `config` / `host-keys` / `auth-keys` stay typed commands (and may be typed at the menu prompt) but **MUST NOT** appear as numbered rows 5–8.  
2. **start** is idempotent: already running → success no-op. Missing host keys → generate when the host-key dir is writable. `sshd -t` must pass before launch. Launch **MUST** be `"${SSHD_BIN}" -f "${SSHD_CONFIG}"` so OpenSSH **daemonizes itself** (pidfile). **MUST NOT** pass `-D` (foreground). **MUST NOT** wrap the launch in `&` / `nohup` / a service manager. Human mode (not quiet/json) **MUST** say this is a **background daemon for this session**, not a boot service, and name `${APP_NAME} start` after a reboot. On Termux, human mode **MUST** name Termux:Boot as an **operator-owned** hook (`~/.termux/boot/`), not a CLI verb. On POSIX Linux, human mode **MUST** say listen-after-reboot is the distro sshd unit, not this CLI.  
3. **stop** is idempotent: already stopped → success no-op.  
4. **port set** rewrites the `Port` line (or appends one). Does not auto-restart; human mode tells the operator to `restart` when sshd is up.  
5. **host-keys generate** creates ed25519 if missing; tries rsa 4096 and warns if declined. Never overwrite existing private host keys.  
6. **auth-keys add** appends one `ssh-ed25519` / `ssh-rsa` / ecdsa / sk- line from a **file**. Duplicate line → success no-op. Creates `~/.ssh` mode `700` and `authorized_keys` mode `600` when possible.  
7. **No in-tool sudo.** If a Linux system path is not writable, fail closed and tell the operator to re-run as root or use Termux.  
8. **No service manager.** Start is `sshd -f <config>` (OpenSSH daemonizes). Stop is signal the sshd pid (pidfile, then process match). On Termux, **MUST NOT** treat a host `pgrep -x sshd` as this login’s daemon — pidfile / `${PREFIX}/bin/sshd` only. **MUST NOT** add verbs or install units for systemd / `systemctl` / `termux-services` / `sv-enable` / `add-crontab` / `enable-service`. Termux:Boot and a Linux distro `sshd.service` stay **outside** this CLI (operator or distro).  
9. **dns** (this login’s `~/.ssh/config` as an SSH name/IP list):

| Mode | MUST | MUST NOT |
|------|------|----------|
| **List** | Numbered **concrete** `Host` entries (`Host` first pattern has no `*` / `?`). Human row: `N. <dns>  <ip-or-(empty)>`. Missing file → empty list (success), not a crash. Skip `Host *`, `Match`, and `Include` (do not follow). | Treat `Host *` as a dns-ip row; rewrite `/etc/hosts` |
| **Show** | Fields **dns**, **ip** (`HostName`), **user**, **port**. Human: **user** empty → print `empty`. **port** empty → print `22`. JSON: raw `user`/`port` may be `""`; also `user_display` / `port_display`. | Invent a user or port; print a live Unix login as a sample |
| **Interactive pick** (`dns` with no subcommand, TTY or `INTERACTIVE=1`, not quiet/json) | Print the numbered list; `read` a number in the **current shell** (not `$()` of `prompt_ask`); show details; then **field-by-field** edit (dns, ip, user, port) with **current values as defaults**. Enter keeps current. Token `""` (two quotes) **or** an empty operand **means empty**. Leave with `0` / `q` / `exit` / empty — **not** `9` (row 9 is a Host when the list is long). | Hang under `--json` / `--quiet` / no TTY (those paths **list** only); `$()` a `read` helper; treat `9` as Exit when `9` is a Host row |
| **edit N** | Same field walk as after pick. Non-interactive / quiet / json: **fail closed** with Next: `dns set …` | Hang waiting for fields in CI |
| **set N** / **add** non-interactive | Operands `dns`/`ip`/`user`/`port` values, or `--dns` / `--ip` / `--user` / `--port`. Omitted fields on **set** stay unchanged. **add** requires a dns name. `""` or empty value clears that field. Port empty or `22` → omit `Port` line (OpenSSH default 22). Empty user → omit `User`. Empty ip → omit `HostName`. Empty dns name after normalize → `out_die`. Port if set must be 1–65535. | Prompt; follow `Include`; change other keys besides HostName / User / Port |
| **Write** | Backup via `util_backup` then **atomic replace** (mktemp + `mv`) for **set and add**. Create `~/.ssh` mode `700` and `config` mode `600` when missing. Keep unrelated stanzas, extra keys, and extra Host aliases after the first pattern. Read `Key value`, `Key=value`, and `Key = value`. **add** inserts the new Host **before** the first wildcard `Host` / `Match` (OpenSSH first-match). Duplicate dns name on rename/add → `out_die`. | Overwrite the whole file from a stub; print private keys; `>>` after trailing `Host *`; drop extra aliases on an IP-only set |

**Guided-input field table (Choice C — TTY walk and operands):**

| Field | Secret? | Prompt label | Default | Skip-if |
|-------|---------|--------------|---------|---------|
| dns | no | dns (SSH Host name you type) | current Host | never; empty after `""` is fail-closed |
| ip | no | ip (HostName to connect to) | current HostName | never |
| user | no | user | current User (display `empty` when unset) | never |
| port | no | port | current Port (display `22` when unset) | never |

Intention: the operator is not forced to assemble a long flag list from memory. Dual mention: `requirement-shell-interactive-vs-noninteractive` · `requirement-shell-cli-interface`.

**Non-goals:** SSH client `ProxyJump` recipes, ControlMaster session mux, Dropbear-only hosts, changing Linux firewall, wrapping `apt`/`dnf` on POSIX Linux, password-auth policy as a verb (shown on `config` only), auto-running `passwd`, systemd unit files, `termux-services` / runit supervision, cron-as-service, a Termux:Boot installer, `/etc/hosts` editing. Termux `pkg install openssh termux-auth` **is** in scope as the install companion (§2.1.1). This login `~/.ssh/config` Host list **is** in scope as **dns**.

**Filename grammar (when this domain allocates files):** host keys use OpenSSH names, not a dated JSON grant.

```text
{{HOSTKEY_DIR}}/ssh_host_ed25519_key
{{HOSTKEY_DIR}}/ssh_host_ed25519_key.pub
```

Example on Termux: `$PREFIX/etc/ssh/ssh_host_ed25519_key`

**ssh_config Host sample (dns-ip; this login `~/.ssh/config`):**

```text
Host phone
    HostName 192.168.1.10
    User termux
    Port 8022
```

**authorized_keys sample line:**

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKeyMaterialOnly laptop-user
```

### 2.3 Specialized project help items

`help` **MUST** keep Type 0 rows, then a **Domain commands (OpenSSH sshd):** section:

- `status` — Show whether sshd is running, and the port/paths  
- `start` — Start sshd as a background daemon (not a boot service)  
- `stop` / `restart`  
- `port [N]`  
- `config`  
- `host-keys [list|generate]`  
- `auth-keys [list|add <file>]`  
- `dns [list|show N|edit N|set N …|add …]` — This login `~/.ssh/config` Host list (numbered dns-ip)  
- `menu` — Numbered list: status, start, stop, restart, Exit 9 (terminal only)

`help` Type 0 `install` row **MUST** mention Termux `pkg install openssh termux-auth` and `~/.bashrc` / `~/.profile` ensure (dual mention with the CLI-interface file).

**MUST NOT** list install / self-update / version / about inside `menu`.  
This product has **no test-purpose verbs**. Help has no tester heading.

Interactive empty argv **MUST** show this same list (zero-arguments dual mention).

### 2.4 Specialized project about items

Human `about` **MUST** add after storage lines: sshd platform, binary, port, running yes/no.  
JSON `about` **MUST** add fields: `sshd_platform`, `sshd_bin`, `sshd_port`, `sshd_running`.  
**MUST NOT** put `CHECKSUM` on about.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Product | `sshd-cli` 1.5.0 |
| Bootstrap origin | `selfmanaged` 1.2.3 (architecture + Type 0 only; A untouched) |
| Domain prefix | `sshd_*` |
| Channel | `https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli` |
| Install companion | `sshd_pkg_ensure` then `sshd_start_after_install` |
| Login rc companion | Owned by `path_*` / `inst_ensure_companion` (`requirement-shell-self-management`) |
| In-tool sudo | **none** — no `requirement-shell-sudo-command` |
| Dest / fence | **none** (class residual: considered — no dest fence conditions) |
| Menu | Verb `menu`/`main`; also interactive empty argv. Rows: 1 status, 2 start, 3 stop, 4 restart, 9 Exit |
| Status connect hint | `ifconfig wlan0` via `sshd_ifconfig_ipv4` / `sshd_lan_ipv4`; live `Connect:` line; **no** placeholder host |
| Start launch | `"${SSHD_BIN}" -f "${SSHD_CONFIG}"` (OpenSSH daemonizes). **No** `-D`. **No** systemd / termux-services / cron verbs. Termux:Boot is operator-owned. |
| dns file | `${HOME}/.ssh/config` (OpenSSH client config; this login) |
| dns fields | dns=`Host` · ip=`HostName` · user=`User` · port=`Port` (display 22 if empty) |
| dns empty token | `""` or empty operand → empty field |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Termux vs Linux paths are named, not guessed per call.  
- **CIAO Principle 9 – Type 0/1/2** (https://github.com/cloudgen/ciao): Domain start/stop stay invoker Type 0; Linux root is a **login**, not a hidden sudo wrap.  
- **CIAO Principle 10 – Least privilege** (https://github.com/cloudgen/ciao): No dedicated system user; no sudoers fragment.  
- **CIAO Principle 5 – SSOT of output** (https://github.com/cloudgen/ciao): Domain messages use `out_*`.  
- **CIAO Principle 16 – Interactive vs non-interactive** (https://github.com/cloudgen/ciao): `dns` TTY field walk; `--json` / pipe **list** or **set** without hanging.  
- **CIAO Principle 21 – Dual policies** (https://github.com/cloudgen/ciao): Portable core; filled notes.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail closed on missing sshd, bad port, unreadable pubkey file.  
- **Intentional**: One domain SSOT; dual mention on the CLI-interface file.  
- **Anti-fragile**: Works when systemd is absent (Termux). Start is OpenSSH’s own daemonize, not a service manager.  
- **Over-protect**: Never overwrite host private keys; never `$()` a `read` helper for `menu`.

## Under command line for normal user only

When the ship unit detects a **command line for normal user only** (Termux, Git Bash, Windows cmd, or the same class):

| MUST | MUST NOT |
|------|----------|
| Keep **normal user privilege** (Type 0) only | Implement or enable **admin privilege** (Type 1) or **dedicated system user privilege** (Type 2) |
| Document Type 1 **unused** and Type 2 **unused** | In-tool `sudo`; wrap `apt` / `dnf` / `yum`; create a dedicated system user |
| Termux: named `pkg` as this login remains Type 0 | Recommend `sudo curl \| sh` as the install path |
| Git Bash / Windows cmd: same privilege ceiling | Invoke Termux `pkg` because Git Bash or Windows cmd was detected |

Helpers (this product): `sshd_is_termux`, `sshd_is_git_bash`, `sshd_is_windows_cmd`, `sshd_is_normal_user_only_cli`. Dual mention: `requirement-shell-cli-interface` · `requirement-shell-termux-ish`.

**This requirement:** `start` / `stop` / `restart` run as this login as OpenSSH’s own background daemon (not a service manager). **dns** reads and writes **this login’s** `~/.ssh/config` (Type 0). Linux **root login** for system sshd is **not** this class (Termux / Git Bash / Windows cmd have no in-tool sudo). **MUST NOT** invent a dedicated `sshd-adm` account. **MUST NOT** add systemd / `termux-services` / cron-as-service verbs on that class.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Drop Type 0 routes while adding domain verbs.  
2. Open the menu on **non-interactive** empty argv (`curl \| sh` / quiet / json). Interactive empty argv **MUST** open the menu.  
3. Wrap `sudo` without a studied sudo-command requirement.  
4. Overwrite existing host private keys on `generate`.  
5. Put domain law only on the bootstrap origin.  
6. Lead help/about with Type 0/Type 1 jargon as the only words.  
7. Echo secret key **private** material (public key lines on `auth-keys list` are intended).  
8. Skip Termux `pkg install -y openssh termux-auth` on `install` / empty-argv ensure, or wrap `apt` on Linux in its place.  
8b. List wrapping Termux `pkg` as a domain **non-goal**, or empty a stated Termux sshd purpose with a portable “do not wrap package managers” habit.  
9. Auto-run `passwd` or print a password.  
10. Number `port` / `config` / `host-keys` / `auth-keys` as menu rows 5–8.  
11. Freeze a session Unix login or a literal LAN IP into product law as the connect example.  
12. Print `<this-host>` or any other placeholder as the ssh host on `status` / `start`.  
13. Finish Termux `install` without starting sshd, or fail POSIX CLI install only because system sshd needs root.  
14. Strip the **Under command line for normal user only** section, or wrap `sudo` / create `sshd-adm` on that class.  
15. Pass `-D` on start, wrap start in `&` / `nohup`, or add systemd / `systemctl` / `termux-services` / `sv-enable` / `add-crontab` / `enable-service` verbs.  
16. Treat Termux:Boot or a Linux distro sshd unit as a verb this CLI owns.  
17. Hang `dns` / `dns edit` under `--json` / quiet / no TTY, or `$()` a `read` helper for the numbered pick or field walk.  
18. Follow `Include`, list `Host *`, or rewrite `/etc/hosts` as dns.  
19. Number `dns` as main-menu rows 5–8.  
20. Treat `9` as Exit on the dns Host pick when row 9 is a Host.  
21. Append a new Host after a trailing `Host *` / `Match`.  
22. Drop extra Host aliases, or fail to parse `Key=value` / `Key = value`, on set/edit.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-termux-ish.md` | Detect / `pkg` invoke contract; not Type 1 |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of domain verbs and `install` companion |
| `docs/requirements/requirement-shell-self-management.md` | `inst_ensure_companion` orchestrator; login rc |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Interactive empty argv = this menu; non-interactive = install-ensure |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` |
| `docs/requirements/requirement-class-software-dev.md` | Class residual points here |
| `./sshd-cli` | Implementation |

## 6. Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-04**, **TP-CLI-06**, **TP-CLI-14**, **TP-CLI-15** | `tests/test_cli.sh` | have |
| **TP-SSHD-01** | `tests/test_cli.sh` | have |
| **TP-LC-16**, **TP-LC-17**, **TP-SSHD-02** | `tests/test_local_lifecycle.sh` | have |
| **TP-DNS-01** .. **TP-DNS-19** | `tests/test_dns.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

**Last Updated**: 2026-09-07  
**Owner**: Cloudgen Wong  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
