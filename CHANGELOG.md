# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.3.0] - 2026-09-05

### Changed

- Terminal menu rows are **status**, **start**, **stop**, **restart**, then **Exit 9**. `port` / `config` / `host-keys` / `auth-keys` stay typed commands.
- `status` (and start) print a recommended connect line `ssh -p <port> <user>@<lan-ipv4>` from live `id -un` and a non-loopback IPv4.

## [1.2.0] - 2026-09-05

### Changed

- Empty argv on a **terminal** opens the numbered domain **menu** (same as `sshd-cli menu`).
- Empty argv **non-interactive** (`curl | sh`, quiet, json, no TTY) still **install-ensure**.

## [1.1.0] - 2026-09-05

### Added

- **`install` companion (always, including already-installed CLI):** create `~/.bashrc` if missing and add `USER_BIN` to PATH; create `~/.profile` if missing so a login shell sources `~/.bashrc` (never overwrite an existing `.profile` body).
- **Termux:** `install` runs `pkg install -y openssh termux-auth`. POSIX Linux does not wrap `apt`.
- Tests **TP-LC-11..16** for login rc and Termux `pkg` (mocked).

### Changed

- Help `install` row names login rc and Termux packages.
- Domain law no longer lists wrapping Termux `pkg` as a non-goal.

## [1.0.0] - 2026-09-05

### Added

- First specialized product **sshd-cli**, bootstrapped from origin **selfmanaged** 1.2.3 (A → B only).
- **Purpose:** simplify Termux to install OpenSSH sshd.
- Self-install / self-update / self-uninstall / about / help (architecture inheritance).
- Domain commands: `status`, `start`, `stop`, `restart`, `port`, `config`, `host-keys`, `auth-keys`, `menu`.
- Termux-first path resolve (`PREFIX`); Linux system sshd fails closed without a root login (no in-tool sudo).
- Product law: `requirement-class-software-dev`, shell lifecycle REQs, `requirement-shell-script-coding`, `requirement-domain-sshd`.
- GitHub home: `cloudgen/sshd-cli`.

### Notes

- Bootstrap origin **selfmanaged** is frozen as architecture reference. Do not reverse-copy this tree onto A.
