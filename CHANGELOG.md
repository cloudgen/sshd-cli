# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
