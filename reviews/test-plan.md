# Test plan — sshd-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/sshd-cli`  
**Product VERSION:** 1.13.1  
**Last plan update:** 2026-09-09  
**Last suite run:** PASS=439 FAIL=0 SKIP=0 (2026-09-09)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Empty argv: non-TTY install-ensure / TTY menu | have | TP-CLI-07, TP-CLI-14, TP-SSHD-03..05 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| Channel verbs routed (`self-update`, `version-check`); no public network in CI | have | TP-CLI-04, TP-CLI-10 |
| Trimmed parent verbs fail closed | have | TP-CLI-13 |
| Local install / idempotent / uninstall / mode 0755 / login rc / Termux pkg | have | TP-LC-01..19 |
| Android wake lock (auto on start + `wake-lock` verb) | have | TP-TX-08..16 |
| sshd start is a background daemon (not a service manager) | have | TP-SSHD-01, TP-SSHD-02 |
| POSIX Linux systemd unit path (`systemctl` start/stop/restart) | have | TP-SSHD-09..14 |
| this-login `~/.ssh/config` dns-ip list / show / set / add / delete | have | TP-DNS-01..36 |
| Automatic companion link on install (file://) | have | TP-CSUM-01 |
| Backup / restore / sudoers emit | n/a | Absent by design (not a backup product) |
| Online curl against public GitHub | n/a | Core suite stays offline; channel is `file://` in CI |

This product **is** online-installable (`SCRIPT_URL`, `self-update`, `version-check`, companion `.sha256`). Core CI does **not** hit the public network.

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help lists this-login + domain verbs; no backup/restore/sudoers; no CHECKSUM | test_cli | requirement-shell-cli-interface · requirement-domain-sshd · requirement-shell-automatic-checksum | **have** |
| TP-CLI-18 | help lists `rc-test` under testers heading apart from operational verbs | test_cli | requirement-shell-cli-interface · requirement-shell-path-and-shell-support | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON storage + `sshd_platform`; no CHECKSUM | test_cli | requirement-shell-cli-storage · requirement-domain-sshd | **have** |
| TP-CLI-07 | empty argv non-interactive install-ensure | test_cli | requirement-shell-cli-zero-arguments · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | `self-update` / `version-check` are **known** commands (no network) | test_cli | requirement-shell-cli-interface · requirement-shell-self-management | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / requirement-shell-script-coding | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | backup/restore/sudoers verbs unknown | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-14 | empty argv interactive → domain menu (no install); status + dns row 5 + Exit 9 | test_cli | requirement-shell-cli-zero-arguments · requirement-domain-sshd · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-CLI-15 | status Connect: live ssh -p user@ipv4; no `<this-host>` | test_cli | requirement-domain-sshd | **have** |

### TP-SSHD (domain start: Termux daemonize / Linux systemd unit)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-SSHD-01 | Start launch is `sshd -f`; help/dispatcher have no systemd / termux-services / sv-enable / add-crontab / enable-service | `tests/test_cli.sh` | requirement-domain-sshd · requirement-shell-cli-interface | **have** |
| TP-SSHD-02 | Termux stub install/start names background daemon, reboot re-start, Termux:Boot operator hook | `tests/test_local_lifecycle.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-03 | POSIX Linux non-root TTY menu hides rows 2/3/4; INFO names OS; dns stays 5 | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-04 | Termux mock TTY menu still shows rows 2/3/4; no non-root INFO | `tests/test_cli.sh` | requirement-domain-sshd · requirement-shell-termux-ish | **have** |
| TP-SSHD-05 | POSIX Linux non-root: numbered **2** is unknown (does not start) | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-06 | POSIX Linux non-root `stop` error names re-run as root; no Termux | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-07 | Ship-unit start/stop/writable die copy is host-local (no “use Termux”) | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-08 | POSIX Linux `start` already-running does not deny systemd / session-daemon | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-09 | systemd host detect: `/run/systemd/system` + `systemctl`; Termux class never true | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-10 | Unit name: `ssh.service` before `sshd.service`; skip LoadState not-found | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-11 | Source unit path invokes `systemctl start` | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-12 | Source unit path invokes `systemctl stop` / `restart` | `tests/test_cli.sh` | requirement-domain-sshd | **have** |
| TP-SSHD-13 | Termux mock `start` never invokes `systemctl` | `tests/test_cli.sh` | requirement-domain-sshd · requirement-shell-termux-ish | **have** |
| TP-SSHD-14 | Dispatcher has no routed verb `systemctl` / `enable-service` | `tests/test_cli.sh` | requirement-domain-sshd · requirement-shell-cli-interface | **have** |
| TP-SSHD-15 | `self-update --force` still exit 0 when stub `sshd -t` would fail; no sshd_config ERROR | `tests/test_local_lifecycle.sh` | requirement-domain-sshd · requirement-shell-self-management | **have** |

### TP-DNS (this login ~/.ssh/config Host list)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-DNS-01 | help lists `dns` | `tests/test_dns.sh` | requirement-domain-sshd · requirement-shell-cli-interface | **have** |
| TP-DNS-02 | numbered list; `Host *` omitted | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-03 | show: user empty → `empty`; port set | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-04 | show by name; empty port displays 22 | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-05 | non-interactive `set` ip | test_dns | requirement-domain-sshd · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-06 | `""` clears user; omit User line | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-07 | JSON list `@items` | test_dns | requirement-domain-sshd · requirement-shell-output-requirements | **have** |
| TP-DNS-08 | `edit` without TTY fail-closed Next `dns set` | test_dns | requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-09 | missing n fail-closed | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-10 | non-interactive `add` | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-11 | bare `dns` non-TTY lists (no hang) | test_dns | requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-12 | INTERACTIVE field walk; `""` clears ip | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-13 | action Edit then pick `9` is Host row 9 (not action Exit) | test_dns | requirement-domain-sshd · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-14 | add inserts before trailing `Host *` | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-15 | extra Host aliases kept on set | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-16 | `Key=value` / `Key = value` parse; set does not corrupt User | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-17 | Match / Include skipped on list | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-18 | after `COMMAND=dns`, token `dns` is a field name | test_dns | requirement-domain-sshd · requirement-shell-cli-interface | **have** |
| TP-DNS-19 | add without dns name Next mentions add | test_dns | requirement-domain-sshd · requirement-shell-cli-interface | **have** |
| TP-DNS-20 | TTY menu row 5 opens Edit/Add/Delete action menu | test_dns | requirement-domain-sshd · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-21 | TTY Edit then Host 1 | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-22 | non-interactive `delete`; `Host *` kept | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-23 | TTY delete cancel | test_dns | requirement-domain-sshd · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-24 | TTY delete yes | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-25 | delete without n fail-closed | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-26 | JSON delete one object; other stanzas kept | test_dns | requirement-domain-sshd · requirement-shell-output-requirements | **have** |
| TP-DNS-27 | non-interactive `add termux yes` writes Port 8022 + keep-alive / IPQoS + Ciphers/MACs bundle | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-28 | `old-openssh yes` writes HostKeyAlgorithms / PubkeyAcceptedAlgorithms +ssh-rsa,ssh-dss | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-29 | `identity-file` + `identities-only` written and shown | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-30 | INTERACTIVE add default as Termux (Y) + Old OpenSSH (Y) | test_dns | requirement-domain-sshd · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-31 | INTERACTIVE add Termux n prompts Port; Old OpenSSH n omits algorithms | test_dns | requirement-domain-sshd · requirement-shell-interactive-vs-noninteractive | **have** |
| TP-DNS-32 | `set termux no` strips keep-alives and Ciphers/MACs; Port kept | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-33 | `set old-openssh no` strips algorithm lines | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-34 | show names identity-file / termux / old-openssh | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-35 | unknown field fail-closed names identity-file / termux / old-openssh | test_dns | requirement-domain-sshd | **have** |
| TP-DNS-36 | keep-alive-only stanza is termux no; `set termux yes` writes Ciphers/MACs | test_dns | requirement-domain-sshd | **have** |

### TP-LC (local lifecycle)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01 | install → USER_BIN | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-02 | installed binary version | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-03 | reinstall already-installed | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-04 | about installed path | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-05 | uninstall JSON no force fail-closed | test_local_lifecycle | requirement-shell-interactive-vs-noninteractive | **have** |
| TP-LC-06 | uninstall --force removes | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-07 | uninstall absent no-op | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-08 | about shows installed | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-09 | installed mode is `0755` | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-10 | `--force` reinstall heals `0711` → `0755` | test_local_lifecycle | requirement-shell-self-management | **have** |
| TP-LC-11 | install creates `~/.bashrc` with USER_BIN PATH | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-12 | install creates `~/.profile` sourcing bashrc | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-13 | reinstall does not duplicate PATH | test_local_lifecycle | requirement-shell-path-and-shell-support · requirement-shell-idempotency | **have** |
| TP-LC-14 | existing `~/.profile` body kept | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-15 | not Termux: `pkg` not invoked | test_local_lifecycle | requirement-shell-termux-ish | **have** |
| TP-LC-16 | Termux mock: `pkg install -y openssh termux-auth` | test_local_lifecycle | requirement-shell-termux-ish · requirement-domain-sshd | **have** |
| TP-LC-17 | install ends by starting sshd (Termux stub) | test_local_lifecycle | requirement-domain-sshd | **have** |
| TP-LC-18 | Git Bash mock: `pkg` not invoked (normal-user-only CLI) | test_local_lifecycle | requirement-shell-cli-interface · requirement-shell-termux-ish | **have** |
| TP-LC-19 | Windows cmd mock: `pkg` not invoked (normal-user-only CLI) | test_local_lifecycle | requirement-shell-cli-interface · requirement-shell-termux-ish | **have** |
| TP-LC-20 | `BASHRC` env: create rc in a random temp folder when missing | test_local_lifecycle | requirement-shell-path-and-shell-support · requirement-shell-idempotency | **have** |
| TP-LC-21 | `BASHRC` env: modify a dongle `.bashrc` in that temp folder | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-22 | `BASHRC` env: already-correct VERSION + exact `export PATH=` is a no-op | test_local_lifecycle | requirement-shell-path-and-shell-support · requirement-shell-idempotency | **have** |
| TP-LC-27 | sibling exact PATH already present: no second export; sibling comment kept | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-28 | uninstall keeps shared PATH while USER_BIN still has files | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-29 | already installed + PATH missing: install heals exact export | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-30 | uninstall does not delete `.profile` | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-31 | `rc-test --root` create / modify / noop; real HOME bashrc untouched | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |

### TP-TX (Termux android-wake-lock)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-TX-08 | not Termux: `termux-wake-lock` not invoked | test_local_lifecycle | requirement-shell-termux-ish | **have** |
| TP-TX-09 | Termux mock start (and already-running) invokes `termux-wake-lock` | test_local_lifecycle | requirement-shell-termux-ish · requirement-domain-sshd | **have** |
| TP-TX-10 | Termux mock `wake-lock` verb; idempotent | test_local_lifecycle | requirement-shell-termux-ish · requirement-shell-cli-interface | **have** |
| TP-TX-11 | Git Bash mock: helper not invoked | test_local_lifecycle | requirement-shell-termux-ish · requirement-shell-cli-interface | **have** |
| TP-TX-12 | Windows cmd mock: helper not invoked | test_local_lifecycle | requirement-shell-termux-ish · requirement-shell-cli-interface | **have** |
| TP-TX-13 | Termux start, helper missing: start succeeds; Next names `wake-lock` | test_local_lifecycle | requirement-shell-termux-ish · requirement-domain-sshd | **have** |
| TP-TX-14 | Termux `wake-lock` verb, helper missing: fail closed + Next `pkg install termux-tools` | test_local_lifecycle | requirement-shell-termux-ish | **have** |
| TP-TX-15 | help lists `wake-lock` / `wake-unlock` | test_cli (TP-CLI-04) | requirement-shell-cli-interface · requirement-shell-termux-ish | **have** |
| TP-TX-16 | `stop` does not invoke `termux-wake-unlock` | test_local_lifecycle | requirement-shell-termux-ish · requirement-domain-sshd | **have** |

### TP-CSUM (companion digest)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CSUM-01 | First install prints companion **link**; PASS or missing-sidecar warn; no mismatch abort | test_local_lifecycle | requirement-shell-automatic-checksum | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce folder-backup / sudoers-emit as Core without a product-mode change.  
4. Domain TPs **are** Core for this product (`status` Connect, menu rows, Termux pkg, start-after-install, daemon vs service). Broader `stop`/`port`/`config`/`host-keys`/`auth-keys` behavioral TPs remain **todo** until added.  
5. There is **no** `requirement-bootstrap-chain` on this product. Trimmed parent verbs are owned by `requirement-shell-cli-interface`.
