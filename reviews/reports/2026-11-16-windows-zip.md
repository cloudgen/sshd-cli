# Filled run: Windows zip for upload and upplace — sshd-cli 1.36.1

**Date:** 2026-11-16  
**Checklist:** `docs/checklists/2026-11-16-implementation-windows-zip.md` (**CL-IMPLEMENTATION-CIAO**)  
**Product:** sshd-cli (`src/sshd-cli` and `./sshd-cli`, same bytes)  
**Change type:** Windows transfer for two existing verbs  
**Related law:** `requirement-domain-upplace` **1.1.0** · `requirement-domain-sshd` **1.29.0** · `requirement-shell-windows-git-bash-cli-coding` **1.3.0** · `requirement-shell-windows-cmd-cli-coding` **1.1.0** · `requirement-shell-cli-interface` **1.14.18** · `requirement-shell-cli-language` **1.7.4** · `requirement-shell-exit-condition` **1.0.3**  
**Proof:** **TP-OS-GB-01** .. **TP-OS-GB-04** · **TP-OS-CMD-01** · **TP-OS-CMD-02** · **TP-UP-15** .. **TP-UP-19**  
**Suite:** PASS=1269 FAIL=0 SKIP=0 (`./tests/run.sh`, 2026-11-16, product 1.36.1).

## Verdict

- [x] **Pass** — when this login is Git Bash or Windows cmd, or the remote probe is Windows, `upload` and `upplace` build a real zip. The stage is `/tmp` when that directory is usable, otherwise the cache folder. `upplace` does not put the archive in the remote home. `download` on Git Bash stays the finished tar.gz. A non-Windows pair keeps the upload pipe and the upplace tar.gz to `/tmp`
- [ ] **Revise**
- [ ] **Block**

Reviewer / role: Implement + Review (this change)  
Date: 2026-11-16

## Checklist

- [x] The zip writer is `zip -r`, or bsdtar `tar -a` only when `tar --version` names bsdtar or libarchive
- [x] GNU tar is not used as a zip writer
- [x] Local stage is `/tmp` when usable. Otherwise it is `util_resolve_storage`. `SSHD_CLI_NO_TMP=1` is the test hook that skips `/tmp`
- [x] Upload still extracts under the remote `"$HOME"`
- [x] Upplace zip goes to remote `/tmp` when usable, otherwise AppData Local Temp, `$TEMP`, or `$HOME/.cache`, as `cache-${APP_NAME}-$$`, then `cp -rP`
- [x] A missing zip is named before the upplace rename. The live folder is not renamed
- [x] A remote unzip failure names zip. It does not say only that ssh failed
- [x] `download` when this login is Git Bash still finishes a tar.gz, copies it with `scp`, extracts the file, and removes the archive
- [x] A remote shell that is only `cmd.exe` is not driven
- [x] README boards show `(*1.36.1*)`. `screenshots/sudoers.png` has no version token. `screenshots/client.png` still shows row **19**
- [x] `src/sshd-cli` and `./sshd-cli` are the same bytes, and `sshd-cli.sha256` is the bare hex of that file

## Proof

- **TP-OS-GB-01** upload to an MSYS reader uses `unzip`, not `tar xzf -`
- **TP-OS-GB-02** Git Bash download stays the finished tar.gz
- **TP-OS-GB-03** a missing zip names zip; a remote unzip failure names zip
- **TP-OS-GB-04** local Git Bash uploads a zip even when the reader is Linux
- **TP-OS-CMD-01** remote `Windows_NT` upload uses a zip
- **TP-OS-CMD-02** local `OS=Windows_NT` uploads a zip even when the reader is Linux
- **TP-UP-15** Windows cmd upplace uses a zip and `scp` to `/tmp`
- **TP-UP-16** Git Bash upplace uses a zip and `scp` to `/tmp`
- **TP-UP-17** a missing local `/tmp` builds the zip under the cache folder
- **TP-UP-18** a missing remote `/tmp` lands the zip in the remote cache folder
- **TP-UP-19** a missing zip stops before the rename
- **TP-UP-01** .. **TP-UP-14** still cover the non-Windows tar.gz path
- Full suite PASS=1269 FAIL=0 SKIP=0

## Scope

| Field | Value |
|-------|--------|
| Script / ship unit | `src/sshd-cli` 1.36.1 |
| Digest | `e14556326c5d44de6dc0a49cbd1eb39dd05c6323843ba1018a0592ab2f08229a` |
| Related requirements | domain-upplace 1.1.0, domain-sshd 1.29.0, git-bash 1.3.0, windows-cmd 1.1.0, interface 1.14.18, language 1.7.4, exit 1.0.3 |
| Change type | Windows zip and cache folder for `upload` and `upplace` |
| Screens | `screenshots/` recaptured from this ship unit. Status line **1.36.1**. Sudoers has no version |
| Commit | this release |
