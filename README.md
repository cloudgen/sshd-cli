# sshd-cli - Simplify Termux to install sshd

![Version](https://img.shields.io/badge/Version-1.13.2-blue?style=flat-square)
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

Runtime version SSOT: `VERSION="1.13.2"` in `./sshd-cli`. Install channel SSOT: `SCRIPT_URL` default `https://raw.githubusercontent.com/cloudgen/sshd-cli/main/sshd-cli`. Philosophy: **[CIAO](https://github.com/cloudgen/ciao) v2.10.2** with [CIAO-Lite](https://github.com/cloudgen/ciao-lite). Specialized from bootstrap origin **selfmanaged** (A → B only).

## Features

- One file you can run or install with `curl | sh` / `wget`
- Places itself for this login (`~/.local/bin`) or, on a **root login**, under `/usr/local/bin` (Termux: `$PREFIX/bin`)
- On a **terminal**, no arguments opens a numbered **menu**; under a **pipe** (`curl | sh`, quiet, json) it **installs itself** (not help)
- Purpose: **simplify Termux to install sshd** (`status`, `start`, `stop`, `restart`, `port`, `config`, `host-keys`, `auth-keys`)
- On POSIX Linux (not Termux / Git Bash / Windows cmd), the TTY menu shows **start / stop / restart** (rows **2** / **3** / **4**) **only as root**. A non-root login sees an INFO line naming this OS, then rows **1**, **5**, **9**. Typed `start` / `stop` / `restart` still fail closed without wrapping `sudo`
- `start` launches OpenSSH sshd as a **background daemon** (`sshd -f`) on Termux and on Linux with **no** distro unit. On POSIX Linux with a loaded `ssh.service` / `sshd.service`, `start` / `stop` / `restart` call **`systemctl`** as a **root login** (no in-tool `sudo`; no `sshd-cli systemctl` verb)
- On Termux, `start` also acquires an **Android wake lock** so sshd can keep listening with the screen off. Acquire again with `sshd-cli wake-lock` if Android dropped it. `wake-unlock` is optional and does **not** run on `stop`
- After a reboot on Termux, run `sshd-cli start` again. Listen-after-reboot on Termux is **Termux:Boot** (you own `~/.termux/boot/`) — not a `sshd-cli` verb. On POSIX Linux, listen-after-reboot is the distro sshd unit
- This login’s `~/.ssh/config` **Host** list (`dns`, TTY menu row **5**): action menu **Edit / Add / Delete**, then a Host pick; TTY **as Termux (Y/n)** (Port 8022, simpler Ciphers/MACs, keep-alives — some Termux sshd versions otherwise **corrupt** the session), **identity-file** / **identities-only**, **Old OpenSSH (Y/n)** (`ssh-rsa` / `ssh-dss`); `""` means empty; `--json` / pipes list or `set` / `delete` without hanging
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

On Termux, `install` also ensures OpenSSH and `termux-auth` (`pkg install -y openssh termux-auth`), creates `~/.bashrc` if missing (PATH), and creates `~/.profile` if missing so an SSH login sources `~/.bashrc`. If you will use a password to SSH in, set one with `passwd`. Tests/CI may set `BASHRC` to a file path (default `~/.bashrc`) so PATH ensure does not touch this login's real interactive rc. The test-purpose verb `sshd-cli rc-test --root <dir> --file bashrc --case create` proves the same helpers against a throw-away folder.

After install, on a terminal (no arguments opens the menu):

```text
$ sshd-cli
[INFO] **sshd-cli**(*1.13.2*)
1. Show sshd status: running, port, and paths
2. Start sshd: launch the OpenSSH daemon (background, not a boot service)
3. Stop sshd: end the running daemon
4. Restart sshd: stop then start
5. SSH names (dns): this login ~/.ssh/config Host list
9. Exit
Choose a number, or type the command name:
```

On POSIX Linux as a **non-root** login, rows **2** / **3** / **4** are omitted (the OS name comes from this host):

```text
$ sshd-cli
[INFO] **sshd-cli**(*1.13.2*)
[INFO] start/stop/restart sshd features are not available for non-root in Ubuntu
1. Show sshd status: running, port, and paths
5. SSH names (dns): this login ~/.ssh/config Host list
9. Exit
Choose a number, or type the command name:
```

Choose a number, or type the command name. `5` opens this login’s `~/.ssh/config` Host list, then **Edit / Add / Delete**. `9` exits. Re-run as root on Linux to see start/stop/restart.

## Usage

```sh
sshd-cli help
sshd-cli version
sshd-cli about
sshd-cli status
sshd-cli start
sshd-cli wake-lock
sshd-cli wake-unlock
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
sshd-cli dns add dns phone ip 192.168.1.10 termux yes old-openssh yes
sshd-cli dns delete 1
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

# If Android dropped the wake lock (screen off killed Termux), acquire again
sshd-cli wake-lock

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
sshd-cli dns add dns phone ip 192.168.1.10 termux yes old-openssh yes identity-file '~/.ssh/phone' identities-only yes
sshd-cli dns delete 1
```

`--json` prints machine objects (`sshd-cli --json status`).

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Termux (Android, OpenSSH via `pkg install openssh`) | Primary target — this login only; no `sudo curl` |
| POSIX Linux with OpenSSH server | Supported; system sshd start/stop/port/host-keys need a **root login** |
| Git Bash / Windows cmd | Same “this login only” class as Termux: no `pkg`, no in-tool `sudo` |
| Other UNIX with `/bin/sh`, `sha256sum`, `mktemp` | CLI install as this login should work; sshd paths follow POSIX defaults |

On **Termux**, `sshd-cli start` is a **background daemon for this session** (OpenSSH forks itself). Leaving the shell is fine. A reboot, or Android killing Termux, ends the daemon — run `start` again. `start` also acquires an Android wake lock so the CPU can stay awake with the screen off; if Android dropped it, run `sshd-cli wake-lock`. Listen-after-reboot is **Termux:Boot** (operator hook).

On a **Linux** server with a loaded distro unit (`ssh.service` or `sshd.service`), `sshd-cli start` / `stop` / `restart` as **root** call `systemctl` on that unit. Listen-after-reboot is the distro unit. There is no `sshd-cli systemctl` command and no in-tool `sudo`. Non-root logins fail closed: re-run as root.

## Related Projects

- [selfmanaged](https://github.com/cloudgen/selfmanaged) — bootstrap origin (install / self-update / self-uninstall as this login)
- [CIAO](https://github.com/cloudgen/ciao) — defensive programming philosophy
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite) — agent contract

## Contributing

Keep CIAO Protection Zones. Do not reverse-copy this product onto `selfmanaged`. Run `./tests/run.sh` before claiming a change done. Product law lives under `docs/requirements/`.

## License

MIT. See [`LICENSE.md`](./LICENSE.md). Copyright (c) 2026 Cloudgen Wong.

## Last Update

2026-09-09 — 1.13.2: dns tests mint Host/IP (do not copy this-login LAN identity). 1.13.1: `self-update` is CLI-only (does not fail on `/etc/ssh/sshd_config` / `/run/sshd`). 1.13.0: `rc-test` proves PATH/profile ensure in a temp folder; uninstall keeps a shared PATH while other tools remain.
