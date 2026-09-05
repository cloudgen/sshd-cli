# sshd-cli - Simplify Termux to install sshd

![Version](https://img.shields.io/badge/Version-1.4.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/sshd-cli?style=flat-square)](https://github.com/cloudgen/sshd-cli)

**sshd-cli** makes it simple on **Termux** to install and run OpenSSH **sshd**. One program, one login, no systemd.

| You | The other role | Not this |
|-----|----------------|----------|
| A Termux login that wants SSH *into* this phone | OpenSSH `sshd` and its files under `$PREFIX/etc/ssh` | A systemd unit editor, a `sudo` wrapper, or an SSH *client* session helper |

| Includes | Excludes |
|----------|----------|
| Install this helper, then start sshd (Termux often listens on **8022**) | Wrapping `sudo` inside the CLI |
| Host keys and this login’s `authorized_keys` | Dropbear-only hosts; wrapping `apt` on Linux; firewall changes |

| Step | What it means | What you type |
|------|---------------|---------------|
| Install the helper | Puts `sshd-cli` on your PATH so later sshd steps are one command. | `curl -fsSL https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli \| sh` |
| Install OpenSSH on Termux | Termux does not ship `sshd` until you ask. | `sshd-cli install` (runs `pkg install openssh termux-auth`) |
| Start sshd | Listens so a laptop can connect. Default Termux port is often **8022**. | `sshd-cli start` then `ssh -p 8022 user@host` |

Runtime version SSOT: `VERSION="1.4.0"` in `./sshd-cli`. Install channel SSOT: `SCRIPT_URL` default `https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli`. Philosophy: **[CIAO](https://github.com/cloudgen/ciao) v2.10.2** with [CIAO-Lite](https://github.com/cloudgen/ciao-lite). Specialized from bootstrap origin **selfmanaged** (A → B only).

## Features

- Defensive design under **CIAO v2.10.*** — Protection Zones, centralized `out_*`, fail-closed install integrity
- Single-file script for direct execution and online install (`curl | sh` / `wget`)
- User vs global install (`~/.local/bin`; `/usr/local/bin` or Termux `$PREFIX/bin`)
- Empty argv on a **terminal** = numbered **menu**; empty argv **non-interactive** (`curl | sh`, quiet, json) = **install-ensure** (not help)
- Purpose: **simplify Termux to install sshd** (`status`, `start`, `stop`, `restart`, `port`, `config`, `host-keys`, `auth-keys`)
- Termux-first paths (`PREFIX`); Linux system sshd is a second home and asks for a **root login** instead of wrapping `sudo`
- Numbered **menu** of domain commands on a terminal (`sshd-cli` with no args, or `sshd-cli menu`)
- Automatic SHA-256 companion `${SCRIPT_URL}.sha256` on online install / self-update

## Quick Installation

### Online (recommended)

**Per-user (non-root):**

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli | sh
```

**System-wide (root / elevated):**

```sh
sudo curl -fsSL https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli | sudo sh
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
[INFO] **sshd-cli**(*1.4.0*)
1. Show sshd status: running, port, and paths
2. Start sshd: launch the OpenSSH daemon
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
sshd-cli port
sshd-cli port 8022
sshd-cli host-keys generate
sshd-cli auth-keys add ./laptop.pub
sshd-cli menu
```

Self-management (inherited Type 0): `install`, `version-check`, `self-update`, `self-uninstall`.

Global flags: `--quiet` / `-q`, `--json`, `--debug`, `--force`.

## Examples

```sh
# See whether sshd is running (Termux often listens on 8022)
sshd-cli status

# Start it, then connect from a laptop
sshd-cli start
ssh -p 8022 "$(id -un)"@192.0.2.10

# Allow a laptop public key
sshd-cli auth-keys add ./laptop.pub
```

`--json` prints machine objects (`sshd-cli --json status`).

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Termux (Android, OpenSSH via `pkg install openssh`) | Primary target |
| POSIX Linux with OpenSSH server | Supported; system sshd start/stop/port/host-keys need a **root login** |
| Other UNIX with `/bin/sh`, `sha256sum`, `mktemp` | Type 0 install should work; sshd paths follow POSIX defaults |

## Related Projects

- [selfmanaged](https://github.com/cloudgen/selfmanaged) — bootstrap origin (Type 0 install/self-maintenance)
- [CIAO](https://github.com/cloudgen/ciao) — defensive programming philosophy
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite) — agent contract

## Contributing

Keep CIAO Protection Zones. Do not reverse-copy this product onto `selfmanaged`. Run `./tests/run.sh` before claiming a change done. Product law lives under `docs/requirements/`.

## License

MIT. See [`LICENSE.md`](./LICENSE.md). Copyright (c) 2026 Cloudgen Wong.

## Last Update

2026-09-05 — 1.4.0: `install` starts sshd at the end; `status` Connect line uses `ifconfig wlan0` (no placeholder host).
