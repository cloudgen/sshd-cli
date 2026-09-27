# Filled run: CL-TEMP-FILE-SYSTEM — sshd-cli 1.27.0 cache folder

**Date:** 2026-09-27  
**Blank form:** `docs/templates/checklists/checklist-temp-file-system.md`  
**Product:** sshd-cli (`src/sshd-cli`)  
**Change type:** fix  
**Related law:** `requirement-shell-cli-storage` **1.3.0**  
**Proof:** **TP-CLI-06** · **TP-CLI-12** · **TP-CLI-19** · **TP-CLI-20** (`tests/test_cli.sh`)  
**Suite:** PASS=817 FAIL=22 SKIP=0 (`./tests/run.sh`, 2026-09-27). The 22 failures are pre-existing TP-DL-* archive cases.

## Verdict

- [x] **Pass** — per-login per-process cache directory; mktemp files; silent tier miss
- [ ] **Revise**
- [ ] **Block**

Reviewer / role: Implement + Review (this change)  
Date: 2026-09-27

## 1. Leaves (blocking)

- [x] Scratch created with `mktemp -t` under `${TMPDIR}` after storage resolve (self-install staging is `${APP_NAME}-XXXXXX`, then move to bin)
- [x] `mkdir` of one cache tier is fail-soft and silent (**TP-CLI-12** skip of preferred: no `fallback` text on stderr, no `Cannot create cache`, live path is the 1st fallback). **TP-CLI-19**: Git Bash preferred `/tmp/cache` mkdir failure uses the AppData leaf and prints no `[ERROR]` / `[WARN]`
- [x] Linux: `/dev/shm/cache/cache-${APP_NAME}-${login}-$$`, then `/tmp/cache/...`, then `${HOME}/.cache/cache-${APP_NAME}-$$` (**TP-CLI-12**)
- [x] Git Bash: `/tmp/cache/cache-${APP_NAME}-${login}-$$`, then `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$`. No 2nd fallback line (**TP-CLI-12** · **TP-CLI-19**)
- [x] Mac: `/tmp/cache/...`, then `${HOME}/Library/Caches/cache-${APP_NAME}-$$`, then `${HOME}/cache/cache-${APP_NAME}-$$` (**TP-CLI-12**)
- [x] Cache directory may end in `-$$`. Scratch files stay `mktemp` (`XXXXXX`, not `${APP_NAME}.$$`)
- [x] `ps -p $$` is a shell-name probe in `util_get_current_shell`, not a cache path
- [x] `mktemp` failure stays fail-closed at the call site (`out_die` / `out_error`). The resolver dies only when every cache tier failed (`Cannot create cache folder`)
- [x] Chosen leaf mode **0700** (**TP-CLI-12**). Live path is not `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${login}`

## 2. Cleanup

- [x] Self-install removes the staged file on copy/move failure (`rm -f` of the mktemp path)
- [x] Fatal helpers still `exit 1` only when every cache tier failed
- [x] Re-run does not reuse another process’s leaf (`$$` is this process)

## 3. Root vs leaf

- [x] Root still from `util_resolve_storage`. No second chain
- [x] `TMPDIR` exported to the chosen cache directory (`app_main`)

## 4. Proof

- [x] **TP-CLI-06** human labels: Cache folder used, preferred, 1st fallback, 2nd fallback, Persistence storage
- [x] **TP-CLI-12** Linux, Git Bash, and Mac chains; silent skip; mode 0700; persistence `${HOME}/.local/${APP_NAME}`
- [x] **TP-CLI-19** Git Bash `/tmp/cache` mkdir miss lands on the AppData leaf
- [x] **TP-CLI-20** static names for the three host chains; old `util_try_mkdir_storage` helper is gone

## Scope

| Field | Value |
|-------|--------|
| Script / ship unit | `src/sshd-cli` 1.27.0 |
| Related requirement | `requirement-shell-cli-storage` 1.3.0 |
| Change type | fix |
