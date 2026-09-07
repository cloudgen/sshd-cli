# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.5.1] - 2026-09-07

### Fixed

- TTY main menu numbers `dns` as row **5** (`SSH names (dns): this login ~/.ssh/config Host list`). The Host list was already in 1.5.0 as `sshd-cli dns` / typing `dns` at the prompt, but the numbered list hid it so an update-and-open of `sshd-cli` looked unchanged.
- Choosing **5** runs the same TTY Host pick as `sshd-cli dns`. Leave that pick with `0` / empty (row 9 is a Host when the list is long). `port` / `config` / `host-keys` / `auth-keys` stay typed.

### Changed

- Domain menu rows are status, start, stop, restart, **dns**, then Exit 9. Test **TP-DNS-20**.

## [1.5.0] - 2026-09-07

### Added

- `dns` — this login’s `~/.ssh/config` as an SSH name/IP list. Numbered concrete `Host` rows; `show` details (`user` empty → `empty`, empty port → `22`); TTY field-by-field edit with current values as defaults; token `""` means empty.
- Non-interactive: `dns list`, `dns show N`, `dns set N ip … user "" port …`, `dns add dns NAME ip …`. `--json dns list` emits `@items`. `dns edit` off a terminal fails closed with Next: `dns set`.
- Tests **TP-DNS-01** .. **TP-DNS-19**.

### Changed

- Domain law includes this-login ssh_config Host management (not `/etc/hosts`, not `Host *`, not session mux).
- Interactive vs non-interactive matrix covers `dns` pick/walk vs list/set.

### Fixed

- TTY `dns` pick: `9` is Host row 9 when the list has nine or more entries. Leave with `0`, `q`, `exit`, or Enter.
- `dns add` inserts the new Host **before** a trailing `Host *` / `Match` (OpenSSH first-match), via atomic replace (not `>>`).
- `dns set` / `edit` keep extra Host aliases, parse `Key=value` and `Key = value`, and rewrite those keywords in `Key value` form.

## [1.4.2] - 2026-09-06

### Added

- Human `start` (and already-running no-op) explains that sshd is a **background daemon for this session**, not a boot service; after a reboot run `sshd-cli start`. Termux names Termux:Boot as an operator-owned `~/.termux/boot/` hook. POSIX Linux names the distro sshd unit.
- Tests **TP-SSHD-01** (launch is `sshd -f`, no service-manager verbs) and **TP-SSHD-02** (Termux stub start names the daemon / reboot hint).

### Changed

- `start` stays OpenSSH daemonize (`sshd -f`; no `-D`). Product law forbids systemd / `termux-services` / `sv-enable` / `add-crontab` / `enable-service` verbs.
- Help and menu `start` rows say **background daemon**, not a boot service.
- README Features / Examples / Platform Compatibility: daemon vs reboot; Termux:Boot is optional and operator-owned.

## [1.4.1] - 2026-09-06

### Added

- Named law `requirement-shell-termux-ish` (Termux `pkg` detect/invoke; Git Bash and Windows cmd are the same this-login-only class).
- Tests **TP-LC-18** / **TP-LC-19** (Git Bash / Windows cmd mock: `pkg` not invoked) and **TP-CSUM-01** (companion link on install).

### Changed

- Help heading is “Self-management (this login)” — not a Type 0 catalog line. `menu` help names the `main` alias.
- README and requirement leads use people language. POSIX Linux root install is the same one-liner **as root**; Termux / Git Bash / Windows cmd are not told to use `sudo curl | sh`.
- Coverage maps (`reviews/test-plan.md`, `what-to-review.md`, RTM) match live tests: this product **has** an online channel; empty argv is TTY menu / non-TTY install-ensure.

### Fixed

- Idempotency practice no longer treats a second bare `sshd-cli` on a terminal as “already installed” (that path is the menu).
- Ghost citations removed (`requirement-bootstrap-chain`, `tests/test_install_lifecycle.sh`, `TP-INST-MAYBE-01`).

## [1.4.0] - 2026-09-05

### Added

- `install` (and non-interactive empty-argv ensure) **starts sshd** when it finishes. Termux fail-closed if `sshd` is still missing. POSIX Linux warns and still succeeds the CLI install when system sshd needs root.

### Fixed

- `status` Connect line used a `<this-host>` placeholder. It now reads **`ifconfig wlan0`** inet (then other ifaces). No placeholder host.

## [1.3.1] - 2026-09-05

### Fixed

- `status` Connect line used a `<this-host>` placeholder when `ip -4 -o` failed on Termux. It now reads the inet address from **`ifconfig wlan0`** (then other ifaces). No placeholder host in the ship unit.

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
