# Product review: sshd-cli (TTY download user prompt)

**Date:** 2026-09-12  
**Reviewer:** council (this session)  
**Product:** sshd-cli `VERSION=1.19.0`  
**Ship unit:** `src/sshd-cli` / `./sshd-cli`  
**Scope:** TTY `download` user walk vs `ssh`; tests **TP-DL-***; requirements coverage  
**Method:** disk read of `sshd_cmd_download` / `sshd_ssh_walk_user`; suite `tests/run.sh`  
**Baseline:** PASS=626 FAIL=0 SKIP=0 (`tests/run.sh`, 2026-09-12)

## Summary

1.18.0 asked **user [default]** on TTY `ssh` and not on TTY `download`. That is **INC-20260912-001**. 1.19.0 shares the walk, passes `-l`, and proves default / override / `""` / invalid user. Remaining review findings in the first pass (Next: still named `ssh`; help and invalid-user TPs missing) are **fixed** in the same release.

## Strengths

| Area | Notes |
|------|--------|
| Shared helper | `sshd_ssh_walk_user` is current-shell `read` (do-not-capture-read) |
| Non-interactive | Operands still required; no hang; JSON adds `user` |
| Fixtures | Minted Host/IP; fake `SSHD_CLI_SSH`; no live session |

## Findings

### SSHD-DL-01 — Severity: P2 (medium)
- **Area:** TTY download vs ssh user walk  
- **Status:** fixed  
- **Location:** `sshd_cmd_download` (1.18.0 omitted `sshd_ssh_walk_user`)  
- **Description:** Host pick then folder only; BatchMode ssh with no `-l`.  
- **Impact:** Operator could not choose remote login; fail-closed.  
- **Suggestion:** Same prompt as `ssh`; then folder.  
- **Cross-ref:** **INC-20260912-001** · `requirement-domain-sshd` §2 download User (TTY) · **TP-DL-10** · **TP-DL-11**

### SSHD-DL-02 — Severity: P2 (medium)
- **Area:** operator-readable Next  
- **Status:** fixed  
- **Location:** `sshd_ssh_validate_user`; download ssh-fail `out_die`  
- **Description:** Invalid user Next named only `ssh`. ssh-fail Next omitted `-l`.  
- **Impact:** Operator on download was sent to the wrong verb.  
- **Suggestion:** Optional Next operand; include `-l` when user was set.  
- **Cross-ref:** **TP-DL-12**

### SSHD-DL-03 — Severity: P3 (low)
- **Area:** TEST  
- **Status:** fixed  
- **Location:** `tests/test_ssh_download.sh`  
- **Description:** Help and `""` omit-`-l` were unproven after the user-walk MUST landed.  
- **Impact:** Coverage hole vs law.  
- **Suggestion:** **TP-DL-01** unique help phrase; **TP-DL-13** empty token.  
- **Cross-ref:** `requirement-shell-interactive-vs-noninteractive` DTV

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Non-interactive download hangs | No — missing folder fail-closed (**TP-DL-06**) |
| JSON starts a live ssh session | No — transfer with fake client (**TP-DL-08**) |
| Session Host/IP in suite source | No — minted (**PP-C-21**) |
| `src/sshd-cli` vs `./sshd-cli` | Same bytes after sync |

## Requirements coverage (this change)

| MUST | Evidence |
|------|----------|
| TTY download asks user [default] | **TP-DL-10** (Host User `-l`) |
| Override / `""` | **TP-DL-11** · **TP-DL-13** |
| Invalid user fail-closed + Next download | **TP-DL-12** |
| Help names user then folder | **TP-DL-01** |
| JSON `user` key | **TP-DL-08** |
| Non-interactive no prompt | **TP-DL-02** · **TP-DL-06** |
| Domain + interactive + CLI-interface dual mention | three REQs updated; RTM **TP-DL-01..13** |

## Priority remediation order

1. (done) User walk on download  
2. (done) Next hint + TPs 12/13  
3. Watch **L-DL-01** on later reviews  

## Related

| Artifact | Role |
|----------|------|
| `reviews/lessons.md` | **L-DL-01** |
| `reviews/test-plan.md` | **TP-DL-10** .. **TP-DL-13** |
| `docs/requirements/requirement-domain-sshd.md` | Download User (TTY) MUST |

**Written by:** Review + Implement (same turn as 1.19.0)  
**Review status:** Findings closed
