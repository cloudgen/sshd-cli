**file**: docs/requirements/requirement-shell-windows-cmd-cli-coding.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-shell-windows-cmd-cli-coding`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This file owns Windows cmd CLI coding for sshd-cli: how this login is recognized after Git Bash, Cygwin, and WSL are excluded. `download` keeps the streamed pipe. `upload` and `upplace` use a zip when this login is Windows cmd or the remote probe is Windows.

### 1.1 Human-facing

**In one sentence:** On Windows cmd, `download` keeps the `tar.gz` pipe. `upload` and `upplace` use a zip, and a cache folder when `/tmp` is missing. `Windows_NT` is not the MSYS gzip-stdin ban.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Someone in Windows cmd changing `./sshd-cli` | `OS=Windows_NT` and `ComSpec` names `cmd.exe` |
| The other role | Git Bash / MSYS2 | `requirement-shell-windows-git-bash-cli-coding` |
| Not this file | Termux `pkg`; the cache path table | `requirement-shell-termux-ish` · `requirement-shell-cli-storage` |

| Includes | Excludes |
|----------|----------|
| `sshd_is_windows_cmd`, the download pipe, and the zip used by `upload` and `upplace` | Treating `Windows_NT` as the MSYS2 gzip-stdin ban |
| The missing-sshd sentence this shell already prints | Running `apt`, `dnf`, or `pkg` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Upload from Windows cmd | The folder is a zip. The stage is `/tmp` when that directory is usable, otherwise the cache folder | `sshd-cli upload phone ./box` |
| Start with no sshd | The next step says Windows cmd does not provide sshd | `sshd-cli start` |

---

## 2. Core Rules / Requirements (Mandatory)

1. **MUST** detect Windows cmd only after Git Bash, Cygwin (`uname -s` `CYGWIN*`), and WSL are excluded. The predicate is `OS=Windows_NT` or `ComSpec` naming `cmd.exe`. **MUST NOT** treat `Windows_NT` as the MSYS2 ban.  
2. `download` **MUST** keep the streamed pipe. `upload` and `upplace` **MUST** use the zip case in `requirement-shell-windows-git-bash-cli-coding` when this login is Windows cmd or the remote probe is Windows (`uname` `Windows_NT`, or an MSYS / Git Bash reader). They **MUST NOT** keep the streamed pipe for that case, and they **MUST NOT** use the MSYS finished `tar.gz` file for that case. `Windows_NT` is still not the MSYS gzip-stdin ban. A remote shell that is only `cmd.exe` is not driven.  
3. When sshd is missing, `sshd_openssh_server_hint` **MUST** say Windows cmd does not provide sshd and **MUST** tell the operator to install OpenSSH for Windows. **MUST NOT** name `apt` or `dnf`. **MUST NOT** run a package tool.  
4. This file **MUST NOT** call `sudo`, `apt`, `dnf`, `brew`, or Termux `pkg`.  
5. Hide sentences use the token `windows-cmd`. Menu numbers stay on `requirement-shell-cli-default-interaction`.

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Detect | `sshd_is_windows_cmd` |
| Transfer | `download` stays the streamed pipe. `upload` and `upplace` use the zip case |
| Missing sshd | `Windows cmd does not provide sshd. Install OpenSSH for Windows, then retry ${APP_NAME} start.` |
| Proof | **TP-OS-CMD-01** and **TP-OS-CMD-02** have. **TP-LC-19** and **TP-CFG-09** already cover hide and `pkg` |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Win32 `tar` is not MSYS `tar`. Download stays a pipe. Upload and upplace use a zip.  
- **CIAO Principle 5 – SSOT** (https://github.com/cloudgen/ciao): The MSYS ban has the Git Bash file. This file does not copy it.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: `Windows_NT` is not the Git Bash reader.  
- **Intentional**: Download stays a pipe. Upload and upplace use a zip.  
- **Anti-fragile**: A missing sshd names this shell and does not run a package tool.  
- **Over-protect**: Do not apply the MSYS finished `tar.gz` transfer to upload. Use a zip.

## 4. Protection Rules

**Future AI assistants or maintainers MUST NOT**:

1. Treat `Windows_NT` as the MSYS2 gzip-stdin ban.  
2. Switch `download` to the finished-file transfer, or keep `upload` / `upplace` on the streamed pipe when this login or the remote host is Windows.  
3. Tell Windows cmd to run `apt` or `dnf`.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-windows-git-bash-cli-coding.md` | MSYS2 stdin ban |
| `docs/requirements/requirement-domain-sshd.md` | Pipe contract |
| `docs/requirements/index.md` | Registry |

## 6. Design-time verification

| TP family / ID | What it shows | Status |
|----------------|---------------|--------|
| **TP-OS-CMD-01** | Remote `Windows_NT` upload uses a zip, not `tar xzf -` | have |
| **TP-OS-CMD-02** | This login `OS=Windows_NT` upload uses a zip even when the reader is Linux | have |
| **TP-CFG-09** | Hide token `windows-cmd` | have |
| **TP-LC-19** | `install` does not call `pkg` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

**Last Updated**: 2026-11-16 (1.1.0 `upload` and `upplace` use a zip on Windows cmd and on a remote `Windows_NT` reader. `download` stays the pipe. 1.0.1 **TP-OS-CMD-01** have. 1.0.0 Windows cmd keeps the streamed pipe)  
**Owner**: sshd-cli project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
