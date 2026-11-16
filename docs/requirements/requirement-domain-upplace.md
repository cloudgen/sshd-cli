**file**: docs/requirements/requirement-domain-upplace.md
**Status**: Active (Version 1.2.0)
**Area**: domain
**Key**: `requirement-domain-upplace`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This file owns the **upplace** verb: upload a local folder and replace the remote folder that has the same name. The one domain SSOT stays `requirement-domain-sshd`. That file names the verb and points here. It does not restate this law.

The operator answers the same opening questions as **upload** (Host, then user, then the local folder). The remote target folder is the **last** question. The operator may type the same-named folder (`~/sites/app` when the local folder is `app`) or that folder's parent (`~/sites`). A parent is joined with the local basename before anything is renamed. The program checks the resolved folder on the remote host before it renames or copies anything. A missing folder, the remote home, or an existing backup stops the rest of the task, prints the error, and returns to the main menu. A match renames the remote folder to `XXXX.yyyyMMdd.bak`, then sends a `tar.gz` to remote `/tmp`, expands it there, and `cp -rP` into the original parent. The typed parent itself is not renamed. Temp files on both sides are removed.

### 1.1 Human-facing

**In one sentence:** You replace a remote folder that already has the same name as your local folder, after the old remote folder is renamed with today’s date.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The person who has the new folder on this machine | `sshd-cli upplace phone ./app ~/sites/app` |
| The other role | The ssh user on the named Host, and the folder that already sits at the target | Host `phone`, target `~/sites/app` |
| Not this file | First-time copy into the remote home (`upload`), or pulling a folder here (`download`) | `requirement-domain-sshd` |

| Includes | Excludes |
|----------|----------|
| Host, user, local folder, then the target path | Asking for the remote destination before the local folder |
| Absolute target, or `~/folder` under that ssh user’s home. A parent of the same-named folder is joined with the local basename | A relative path, `~` alone, `~/`, or `~user` |
| Resolved basename equal to the local folder, existing directory, not the remote home | Creating a new remote folder, replacing `$HOME`, or renaming the typed parent |
| Rename to `name.yyyyMMdd.bak`, then `tar.gz` via `/tmp`, then `cp -rP` | `rsync`, `sudo`, or merging into the old folder |
| Remove the temp archive and the temp folder on both hosts | Leaving `/tmp` files behind after success or after a failed copy |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./sshd-cli` | Program | Live `upplace` |
| `sshd-cli help` | Command | The `upplace` row |
| Client menu **19** | Terminal list | Same walk, target last |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Replace a site folder | The remote folder must already be named like the local folder. The old one is renamed with today’s date, then the new tree replaces it. The remote home itself is refused. | `sshd-cli upplace phone ./app ~/sites/app` |
| Type the parent | The same replace. `~/sites` and local folder `app` resolve to `~/sites/app`. A trailing slash is stripped first. The parent directory is not renamed. | `sshd-cli upplace phone ./app ~/sites` |
| Stop when the name is not there | Nothing is renamed and nothing is uploaded. The error is shown and the main menu returns. | A missing directory at the resolved path (`~/sites/app`, or `~/sites/other/app` when the typed path was `~/sites/other`) |

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Verb

| Verb | Operands | Privilege | Errors |
|------|----------|-----------|--------|
| `upplace` | optional `<n\|name>`, then optional local folder, then optional target | This login. OpenSSH client `ssh` and `scp`. No in-tool `sudo` | Missing operands, bad path, missing tools → `out_die`. Remote pre-check miss → status 1 and, on the menu, return to the front board. After the rename, a failed copy → `out_die` after cleanup and rollback |

**Routing:** operands after `upplace` are domain operands, in the same pass as `upload`. Non-interactive form is `upplace <n|name> <local-folder> <target>`. JSON mode does not prompt. A path that contains a space is outside this verb’s operand split, the same limit as `upload`.

**Guided-input field table (TTY walk and operands):**

| Field | Secret? | Prompt label | Default | Skip-if |
|-------|---------|--------------|---------|---------|
| Host | no | numbered Host pick (same list as `dns`) | none | first operand present |
| user | no | user [default] | Host `User` if set, else this login (`id -un`) | non-interactive / `--json` / quiet / no TTY |
| local folder | no | local folder (absolute, relative, or `~/folder` on this login) | numbered previous local paths for that Host | never; empty is fail-closed |
| target | no | target folder on that host (the same-named folder, or its parent; absolute or `~/folder` under that ssh user home) | none (no history list) | never; empty is fail-closed |

| Mode | MUST | MUST NOT |
|------|------|----------|
| **Order** | Host, then user, then local folder, then target. The target is last | Ask the remote destination first |
| **Host pick** | Same concrete Host list as `dns` / `ssh` / `upload`. TTY with no first operand: pick Host. `0` or empty leaves with status 0 and no error. Non-interactive: require `<n\|name>` | Follow `Include`; treat `Host *` as a concrete entry |
| **User (TTY)** | Same contract as `upload`. `-l` only when the user is non-empty. An empty saved User omits `-l` | Skip the user prompt on TTY; hang under `--json` / quiet / no TTY; `$()` a `read` helper |
| **Local folder** | Same memory file as `upload` (`{{HOME}}/.local/{{APP_NAME}}/upload-folders`). A `~/folder` prefix expands against **this login’s** `HOME` only. The path **MUST** be a directory. Out-of-range number warns and redisplays. Empty → `out_die` | Share `download-folders`; call the upload validator; treat the path as remote |
| **Target** | Absolute, or `~/` relative to the **remote ssh user’s** home. The same-named folder, or the parent of that folder. Quote with the download remote-quote so `~/folder` becomes `"$HOME"/'folder'` for the remote shell. Do not expand that `~` against this login. No target history file | Accept a relative path, `~`, `~/`, `~user`, `.`, `..`, `/` alone, or a leading `-` |
| **Parent** | When the typed target’s basename is not the local folder basename, probe that typed path first. If it is the remote home, `upplace_home` and do not join. Otherwise set the target to `<typed>/<basename>` and use that path for the info line, the second probe, the rename, the copy, and the JSON `target` and `destination`. A trailing slash is stripped before this test. The parent directory is not renamed | Join when the typed path is the remote home; join a second time; replace the parent; create `<typed>/<basename>` when it is absent |
| **Home guard** | Compare the path under test to `"$HOME"` (and `"${HOME%/}"`) **before** the basename check. On a parent input, that comparison runs on the typed path before the join, then again on the joined path. Refuse when they are the same, even if the basename equals the home directory’s name. Also refuse `/` | Rename or replace the remote home |
| **Name check** | After the parent join, the target **MUST** be an existing directory whose basename equals the local folder basename | Treat a different resolved basename as “missing”; create the folder; merge into the old tree |
| **Probe order** | String-equal home; if a directory, `pwd -P` (fallback `pwd`) compared to home; then basename versus the wanted name; then, if it is not a directory, missing | Rename or upload before this check returns success |
| **Date** | `yyyyMMdd` from **this login’s** `date +%Y%m%d`, not the remote clock | Use the remote date; continue when `date` fails |
| **Backup name** | `{{BASENAME}}.{{YYYYMMDD}}.bak` beside the target (same parent). If that name already exists, stop **before** `mv` | Clobber an existing `.bak` |
| **Transfer** | After the rename, when neither this login nor the remote probe is Windows: local `tar czf` of the basename from its parent, `gzip -t`, `scp` the archive to `user@host:/tmp/<name>` or `host:/tmp/<name>` (not the remote home), remote `mkdir` under `/tmp`, `tar xzf` into that stage, `cp -rP <stage>/<basename> <parent>/`, then remove the remote stage and the archive and the local temp directory | `rsync`; `cp -a`; `sudo`; pipe gzip the way non-Windows `upload` does; copy the archive into the remote home; leave the temps |
| **Windows transfer** | When this login is Git Bash or Windows cmd, or the remote probe is MSYS, Git Bash, or `uname` `Windows_NT`: a real zip (`zip -r`, or bsdtar `tar -a` when `tar --version` names bsdtar or libarchive). GNU tar is not a zip writer. `zip -T` (or `tar -tf` for bsdtar) before `scp`. Extract with `unzip`, or with bsdtar `tar -xf`. Still `cp -rP`. The archive is not the remote home. Local stage is `/tmp` when that directory is usable, otherwise the cache folder from `util_resolve_storage`. Remote stage is `/tmp` when that directory is usable, otherwise `"$HOME/AppData/Local/Temp"`, else `$TEMP`, else `"$HOME/.cache"`, as `cache-${APP_NAME}-$$`. A remote shell that is only `cmd.exe` is not driven. The writer check is before the probe, so a missing zip does not leave a backup. Detail: `requirement-shell-windows-git-bash-cli-coding` | Treat GNU `tar -a` as a zip writer; pipe the zip; land the archive in the remote home; skip the backup |
| **Tools** | Require `ssh`, `scp`, and `date` before the Windows decision. The Windows case then requires a zip writer. The other case requires `tar` and `gzip`. All of that is **before** the directory probe, so a missing tool does not leave a backup. A failed remote OS probe is not Windows; the later directory probe reports ssh failed | Probe first and then discover a missing tool; `out_die` on a failed OS probe by itself |
| **Failure after rename** | Remove temps this run created, move the backup back onto the target, then `out_die`. If the move-back fails, append that the target could not be restored from the backup | Leave the live name absent; delete the backup on a failed copy |
| **Menu** | Client row **19**, always, after **16** on POSIX and after **18** on Termux / Git Bash / Windows cmd. A pre-check stop returns to the front board. A direct command with that stop exits 1 | Print client **17**; `out_die` for a missing same-named folder |
| **`--json`** | One object: `type` `upplace`, `message` `ok`, `n`, `dns`, `user`, `folder`, `target`, `backup`, `destination` (the typed target). `user` may be `""`. Still performs the transfer when the operands are complete | Prompt; two JSON objects |

**Pre-check stops** (human `out_error`, JSON `out_json_error`, status 1, no rename, no upload, no temp files):

| Token | JSON code | Message |
|-------|-----------|---------|
| home | `upplace_home` | `Cannot upplace: target <target> is the remote home.` |
| name | `upplace_name` | `Cannot upplace: target <target> is not named <basename>.` |
| missing | `upplace_missing` | `Cannot upplace: <host> has no folder named <basename> at <target>.` |
| backup exists | `upplace_bak` | `Cannot upplace: backup <basename>.<yyyyMMdd>.bak already exists beside <target> on <host>.` |

A typed path whose basename differs is the parent of the local folder, unless that typed path is the remote home (`upplace_home`, no join). The joined path is then checked. A missing directory at the joined path is the **missing** stop. The **name** stop remains when the resolved path’s basename is still not the local folder name. A missing directory whose basename already matches is the **missing** stop, and that path is not joined again.

**Success text:** `Replaced <target> on <host> (previous folder saved as <basename>.<yyyyMMdd>.bak).`

**Info line before the probe:** `Replacing <folder> onto <target> on <host> as <user> (backup <basename>.<yyyyMMdd>.bak).`

**Refuse locally:** target `~`, `~/`, `/`, `.`, `..`, a leading `-`, `~user`, a relative path that does not start with `/` or `~/`, and the shell characters `; | & $` `` ` `` `\ ( ) < > * ? ! # ~` after an allowed `~/` prefix. A target whose normalized form is `~` or `~/` is refused locally.

**Remote cleanup** removes only the temp names this run created under `/tmp`, or under the cache leaf this run created (`cache-${APP_NAME}-` plus a child name). A path that is `/tmp`, `/tmp/`, the cache root, the remote home, or contains `..` is not removed. **Local cleanup** removes only this run’s stage under `/tmp`, `/var/tmp`, `TMPDIR`, or `cache-${APP_NAME}-*/${APP_NAME}.upplace.*` (and the upload stage `*.upload.*`), and never `{{HOME}}`, `/`, or the cache root.

**Filename grammar:**

```text
{{BASENAME}}.{{YYYYMMDD}}.bak
```

Worked sample basename: `app.20261116.bak` (local folder `app`, this login’s date 2026-11-16).

**Success JSON sample:**

```json
{"type":"upplace","message":"ok","n":"1","dns":"phone","user":"","folder":"./app","target":"~/sites/app","backup":"app.20261116.bak","destination":"~/sites/app"}
```

**Help:** one operational row, `upplace [N|name] [folder] [target]`, in the domain section of `help`. This verb is not a test-purpose verb. Test-purpose verbs stay under their own heading.

**About:** Type 0 only. This verb adds no about field.

### 2.2 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Product | `sshd-cli` |
| Version | `1.36.2` (`VERSION="1.36.2"`) |
| Handler | `sshd_cmd_upplace` |
| Menu | client **19**, short `upplace` |
| Typed leaf | `upplace` runs the handler and returns 0 so the front board returns |
| Menu case | The client case for 19 or the word upplace runs the handler and ignores its status, then returns 0, so a leaf status 1 still redisplays the front board |
| Local walk | `sshd_upplace_walk_folder` (reuses `sshd_upload_folders_list` / `sshd_upload_folders_save`) |
| Target walk | `sshd_upplace_walk_target` (no history) |
| Local check | `sshd_upplace_validate_local` |
| Target check | `sshd_upplace_validate_target` |
| Remote quote | `sshd_download_remote_quote` |
| Remote scripts | quoted `printf` lines only. No unquoted heredoc. `"$HOME"` stays for the remote shell |
| ssh | `sshd_upplace_ssh`: BatchMode, ConnectTimeout 15, `-l` only when the TTY user is non-empty. Returns 0 when the client ran. The caller reads the first stdout token |
| Archive name | Non-Windows: `sshd_xfer_new_name` (`.tar.gz`) under a local `mktemp` directory. Windows: `sshd_xfer_new_zip_name` (`.zip`) under `/tmp` when usable, otherwise the cache folder |
| Remote stage | Non-Windows: `/tmp/` plus `sshd-cli.upstage.`. Windows: `/tmp` when usable, otherwise the cache leaf `cache-${APP_NAME}-$$`, plus that stage leaf |
| Copy | exactly `cp -rP` |
| Parent after rename | remote `dirname` of the original target |
| Date | this login `date +%Y%m%d` |
| Memory | `{{HOME}}/.local/sshd-cli/upload-folders` mode 0600. No `upplace-targets` file |
| English menu long | `upload a local folder and replace the same-named remote folder (backup, then tar.gz)` |
| English help | `tar.gz a local folder, back up the same-named remote folder, and replace it; on Windows, zip, and a cache folder when /tmp is missing (TTY: Host, user, local folder, then target ~/folder or absolute; never the remote home)` |
| Local prompt | `Local folder to upplace (absolute, relative, or ~/folder on this login):` |
| Target prompt | `Target folder on that host (the same-named folder, or its parent; absolute or ~/folder under that ssh user home):` |
| Proof | **TP-UP-01** .. **TP-UP-20** in `tests/test_upplace.sh`. **TP-UP-20** is the parent join (`~/sites` → `~/sites/app`). **TP-CLI-14** and **TP-SSHD-04** assert row **19** |

### 2.3 Why this requirement exists

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): the remote home is checked before any rename.
- **CIAO Principle 2 – Intentional**: the target is a separate last question, not a reuse of the upload destination.
- **CIAO Principle 3 – Anti-fragile**: a failed copy after the rename moves the backup back and removes temps.
- **CIAO Principle 11 – Temporary files**: archives and stages live under `/tmp` when that directory is usable, otherwise under the cache folder, and are removed on both hosts.
- **CIAO Principle 12 – Risk-class backup**: the previous folder is `name.yyyyMMdd.bak` and an existing backup is not overwritten.
- **CIAO Principle 16 – Interactive**: the TTY walk is one field at a time; JSON and a pipe do not prompt.

## Under command line for normal user only

When the ship unit detects Termux, Git Bash, or Windows cmd, Type 1 and Type 2 stay unused. **This requirement:** `upplace` stays a normal-user verb. It does not wrap `sudo`, `apt`, `dnf`, or `pkg`. Git Bash and Windows cmd do not invoke Termux `pkg` for this verb. On those logins, and when the remote probe is Windows, the archive is a zip and the stage is the cache folder when `/tmp` is missing. A non-Windows pair still builds `tar.gz`, sends it to remote `/tmp`, and expands that file. The archive is never the remote home.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution** (Principle 1): refuse the remote home before the basename check.
- **Intentional** (Principle 2): stop when the same-named directory is absent. Do not create it.
- **Anti-fragile** (Principle 3): rollback the rename when the copy fails.
- **Over-protect** (Principle 4 / CIAO-Lite O · Principle 20): refuse metacharacters, `~user`, and `/`.
- **Principle 5**: one JSON object through `out_json`.
- **Principle 10**: this login only. No privilege raise.
- **Principle 11**: temp names are created by `mktemp` and removed by this run only.
- **Principle 22**: the local stage is mode 0700. The upload-folders file stays mode 0600.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Ask for the remote target before the local folder.
2. Replace, rename, or `cp` onto the remote `$HOME` or `/`.
3. Continue after a missing same-named directory or an existing `.bak`. A typed basename that differs is the parent of the same-named folder. Do not rename that parent. Do not join when the typed path is the remote home.
4. Use `out_die` for those pre-check stops. They return 1 so the menu can show the front board again.
5. Use `rsync`, `cp -a`, or `sudo` for this verb.
6. Send the archive to the remote home. The destination is `/tmp` when that directory is usable, otherwise the cache folder named above.
7. Leave the temp archive or the temp folder on either host after success or after a handled failure.
8. Clobber `name.yyyyMMdd.bak` when it already exists.
9. Expand a remote `~/` against this login’s home.
10. Store a separate target history, or share `download-folders` as this verb’s local memory.
11. Number client **17**, or hide row **19** on Termux, Git Bash, or Windows cmd.
12. Pipe gzip into `tar` for this verb, or change `upload`’s pipe to match this file.
13. Freeze a live Host alias, a live login name, or a LAN address into this file, the tests, or the README.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-domain-sshd.md` | Domain SSOT; points here |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of `upplace` |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Client row **19** |
| `docs/requirements/requirement-shell-cli-language.md` | `client_19_long` and `help_upplace` |
| `docs/requirements/requirement-shell-exit-condition.md` | `out_die` and pre-check status 1 rows |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY walk versus operands |
| `docs/requirements/requirement-shell-windows-git-bash-cli-coding.md` | Windows zip for `upload` and `upplace`; `download` stays the finished tar.gz |
| `./sshd-cli` | Implementation |

## Terminologies

Copied substance for the words this requirement uses. No harness paths.

### Operational verb

**Definition:** An operational verb is a CLI routed-verb that runs the product: lifecycle (install, help), domain convert/submit/list/show, dest emit, admin setup/review, or other live host work. It is not a test-purpose verb. Normal-user, admin, and dedicated-system-user privilege still apply. Normal-user operational verbs remain distinct from normal-user unit testers.

**Human daily-life explanation:** An operational verb is a command that actually does product work: install, help, convert, submit, list. It is not a unit-test-only verb.

**Daily-life example:** “Please bake the cake” is operational; “please run the kitchen’s practice quiz about baking” is a test verb.

### Command line for normal user only

**Definition:** A command line for normal user only is a POSIX-like shell environment whose privilege ceiling is normal user privilege. Typical instances are Termux, Git Bash, and Windows cmd. There is no usable root or `sudo` host change and no dedicated system account for this login. When the ship unit detects this class, it must not implement or enable admin privilege or dedicated system user privilege: no in-tool `sudo`, no `apt` or `dnf` wrap, no `/etc` destination, no `useradd`, and no switch to a dedicated account.

**Human daily-life explanation:** A command line for normal user only is a keyboard that only has your keys. Termux on a phone, Git Bash on Windows, and Windows cmd are this kind of room: you can tidy your own drawer; you cannot borrow the building site key or put on a dedicated-operator badge.

**Daily-life example:** On Termux you run `pkg` as yourself. On Git Bash you run `git` as yourself. On Windows cmd you type as yourself. None of those rooms should grow a `sudo apt` or a hidden system-user switch for this verb.

## 6. Status history

| Date | Status | Notes |
|------|--------|-------|
| 2026-11-16 | Active 1.2.0 | A target whose basename is not the local folder is that folder’s parent (`~/sites` and local `app` resolve to `~/sites/app`). The remote home is refused before the join. The parent is not renamed. Product `1.36.2`. **TP-UP-05** is the missing child. **TP-UP-20** is the parent replace |
| 2026-11-16 | Active 1.1.0 | Windows `upload` and `upplace` use a zip. When `/tmp` is missing, the stage is the cache folder. A non-Windows pair stays `tar.gz` to `/tmp`. Product `1.36.1`. **TP-UP-15** .. **TP-UP-19** |
| 2026-11-16 | Active 1.0.0 | `upplace` on client **19**. Product `1.36.0`. Pre-check stops return to the menu. Backup `name.yyyyMMdd.bak`, then `tar.gz` to `/tmp`, `cp -rP`, cleanup both sides. **TP-UP-01** .. **TP-UP-14** |

**Last Updated**: 2026-11-16 (1.2.0 parent target joins the local basename. 1.1.0 Windows zip and cache folder when `/tmp` is missing. 1.0.0 client **19**)
**Owner**: Cloudgen Wong
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
