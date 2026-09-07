# sshd-cli - Simplify Termux to install sshd

![Version](https://img.shields.io/badge/Version-1.5.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/sshd-cli?style=flat-square)](https://github.com/cloudgen/sshd-cli)

**sshd-cli** makes it simple on **Termux** to install and run OpenSSH **sshd**. One program, one login, no systemd.

| You | The other role | Not this |
|-----|----------------|----------|
| A Termux login that wants SSH *into* this phone | OpenSSH `sshd` and its files under `$PREFIX/etc/ssh` | A systemd unit editor, a `termux-services` wrapper, a `sudo` wrapper, or an SSH *client* session helper |

| Includes | Excludes |
|----------|----------|
| Install this helper, then start sshd as a **background daemon** (Termux often listens on **8022**) | Wrapping `sudo` inside the CLI; systemd / termux-services / cron-as-service |
| Host keys and this login’s `authorized_keys` | Dropbear-only hosts; wrapping `apt` on Linux; firewall changes; a Termux:Boot installer |
| This login’s `~/.ssh/config` Host list (`dns`) as numbered dns-ip rows | `/etc/hosts`; `Host *`; SSH session mux |

| Step | What it means | What you type |
|------|---------------|---------------|
| Install the helper | Puts `sshd-cli` on your PATH so later sshd steps are one command. | `curl -fsSL https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli \| sh` |
| Install OpenSSH on Termux | Termux does not ship `sshd` until you ask. | `sshd-cli install` (runs `pkg install openssh termux-auth`) |
| Start sshd | OpenSSH **forks itself** so a laptop can connect. Default Termux port is often **8022**. This is not a boot service. | `sshd-cli start` then `ssh -p 8022 user@host` |
| After a reboot | The daemon is gone. Start again. Termux:Boot is **your** hook if you want listen-after-reboot. | `sshd-cli start` |

Runtime version SSOT: `VERSION="1.5.0"` in `./sshd-cli`. Install channel SSOT: `SCRIPT_URL` default `https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli`. Philosophy: **[CIAO](https://github.com/cloudgen/ciao) v2.10.2** with [CIAO-Lite](https://github.com/cloudgen/ciao-lite). Specialized from bootstrap origin **selfmanaged** (A → B only).

## Features

- One file you can run or install with `curl | sh` / `wget`
- Places itself for this login (`~/.local/bin`) or, on a **root login**, under `/usr/local/bin` (Termux: `$PREFIX/bin`)
- On a **terminal**, no arguments opens a numbered **menu**; under a **pipe** (`curl | sh`, quiet, json) it **installs itself** (not help)
- Purpose: **simplify Termux to install sshd** (`status`, `start`, `stop`, `restart`, `port`, `config`, `host-keys`, `auth-keys`)
- `start` launches OpenSSH sshd as a **background daemon** (`sshd -f`; OpenSSH forks itself). This CLI is **not** a systemd, termux-services, or cron service manager
- After a reboot, run `sshd-cli start` again. On Termux, listen-after-reboot is **Termux:Boot** (you own `~/.termux/boot/`) — not a `sshd-cli` verb
- This login’s `~/.ssh/config` **Host** list (`dns`): numbered dns-ip rows, details, field-by-field edit; `""` means empty; `--json` / pipes list or `set` without hanging
- Termux-first paths (`PREFIX`); Linux system sshd is a second home and asks for a **root login** instead of wrapping `sudo`
- Online install / self-update fetches a SHA-256 sidecar (`${SCRIPT_URL}.sha256`) and tells you link, value, and result
- Built under **[CIAO](https://github.com/cloudgen/ciao) v2.10.*** (fail closed; one printer family for messages)

## Quick Installation

### Online (recommended)

**Per-user (non-root):**

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli | sh
```

**POSIX Linux, already a root login** (not Termux, Git Bash, or Windows cmd). Same one-liner **as root** — do **not** use `sudo curl | sh` on Termux:

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli | sh
```

Then verify:

```sh
sshd-cli about
sshd-cli status
```

### Integrity (automatic checksum)

The program downloads the companion digest **itself**. You do **not** set `CHECKSUM` for normal online install or self-update.

| Mode | When | Algorithm | What happens |
|------|------|-----------|--------------|
| **Automatic (default)** | `CHECKSUM` **unset** | **SHA-256** via `sha256sum` | Fetch `${SCRIPT_URL}.sha256`. Human mode shows companion **link**, expected **value**, and **result**. **Match** → continue. **Mismatch** → **abort**. **Sidecar missing** → **warning**, continue. |
| **Strict pin (optional)** | `CHECKSUM` set to an out-of-band hex digest | **SHA-256** | Must match the pin; mismatch aborts. CI / freeze only. |

Default companion:

```text
https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli.sha256
```

In this repository the companion file is **`sshd-cli.sha256`**. Same-channel SHA-256 proves **consistency** of the two files on that channel; it is not a substitute for signed releases.

### From a local checkout

```sh
chmod +x ./sshd-cli
./sshd-cli install
sshd-cli about
```

On Termux, `install` also ensures OpenSSH and `termux-auth` (`pkg install -y openssh termux-auth`), creates `~/.bashrc` if missing (PATH), and creates `~/.profile` if missing so an SSH login sources `~/.bashrc`. If you will use a password to SSH in, set one with `passwd`.

After install, on a terminal (no arguments opens the menu):

```text
$ sshd-cli
[INFO] **sshd-cli**(*1.5.0*)
1. Show sshd status: running, port, and paths
2. Start sshd: launch the OpenSSH daemon (background, not a boot service)
3. Stop sshd: end the running daemon
4. Restart sshd: stop then start
9. Exit
Choose a number, or type the command name:
```

Choose a number, or type the command name. `9` exits.

## Usage

```sh
sshd-cli help
sshd-cli version
sshd-cli about
sshd-cli status
sshd-cli start
sshd-cli stop
sshd-cli restart
sshd-cli port
sshd-cli port 8022
sshd-cli config
sshd-cli host-keys generate
sshd-cli auth-keys add ./laptop.pub
sshd-cli dns
sshd-cli dns list
sshd-cli dns show 1
sshd-cli dns set 1 ip 192.168.1.10 user "" port 8022
sshd-cli menu
```

Self-management (this login, no OS package manager): `install`, `version-check`, `self-update`, `self-uninstall`.

Global flags: `--quiet` / `-q`, `--json`, `--debug`, `--force`.

## Examples

```sh
# See whether sshd is running (Termux often listens on 8022)
sshd-cli status

# Start it (OpenSSH forks into the background), then connect from a laptop
sshd-cli start
ssh -p 8022 "$(id -un)"@192.0.2.10

# Allow a laptop public key
sshd-cli auth-keys add ./laptop.pub

# After a reboot, start the daemon again (this CLI is not a boot service)
sshd-cli start

# Optional: Termux:Boot — you own ~/.termux/boot/; this CLI has no enable-service verb
mkdir -p ~/.termux/boot
printf '%s\n' 'sshd-cli start' > ~/.termux/boot/start-sshd
chmod +x ~/.termux/boot/start-sshd

# This login's SSH names (OpenSSH client ~/.ssh/config)
sshd-cli dns list
sshd-cli dns show 1
sshd-cli dns set 1 ip 192.168.1.10 user "" port 8022
sshd-cli dns add dns phone ip 192.168.1.10
```

`--json` prints machine objects (`sshd-cli --json status`).

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Termux (Android, OpenSSH via `pkg install openssh`) | Primary target — this login only; no `sudo curl` |
| POSIX Linux with OpenSSH server | Supported; system sshd start/stop/port/host-keys need a **root login** |
| Git Bash / Windows cmd | Same “this login only” class as Termux: no `pkg`, no in-tool `sudo` |
| Other UNIX with `/bin/sh`, `sha256sum`, `mktemp` | CLI install as this login should work; sshd paths follow POSIX defaults |

`sshd-cli start` is a **background daemon for this session**, not a boot service. Leaving the shell is fine (OpenSSH already forked). A reboot, or Android killing Termux, ends the daemon — run `start` again. Listen-after-reboot on Termux is **Termux:Boot** (operator hook). On a Linux server, the distro `sshd` unit is the boot service; this CLI does not wrap systemd.

## Related Projects

- [selfmanaged](https://github.com/cloudgen/selfmanaged) — bootstrap origin (install / self-update / self-uninstall as this login)
- [CIAO](https://github.com/cloudgen/ciao) — defensive programming philosophy
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite) — agent contract

## Contributing

Keep CIAO Protection Zones. Do not reverse-copy this product onto `selfmanaged`. Run `./tests/run.sh` before claiming a change done. Product law lives under `docs/requirements/`.

## License

MIT. See [`LICENSE.md`](./LICENSE.md). Copyright (c) 2026 Cloudgen Wong.

## Last Update

2026-09-07 — 1.5.0: `dns` lists this login’s `~/.ssh/config` Host entries as numbered dns-ip rows; show/edit field-by-field; `""` is empty; non-interactive `set`/`add`/`list`. Pick `9` is a Host when the list is long; add inserts before `Host *`.
