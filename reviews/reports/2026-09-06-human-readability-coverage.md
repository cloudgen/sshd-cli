# Report: human-readability + coverage — sshd-cli 1.4.1

**Date:** 2026-09-06  
**Mode:** review + authorized implement  
**Status:** closed (fixes landed this change)

## Summary

Reviewed every registered requirement §1.1 and the product README voice pack, then mapped the 13 Active requirements to `reviews/test-plan.md`, the suite, and `reviews/what-to-review.md`. Findings were implemented: people-language leads, honest coverage maps (this product **has** an online channel), Git Bash / Windows cmd `pkg` fence, companion-link TP, and version **1.4.1**.

## Issues

### Issue 1 -- Severity: bug
- File: reviews/what-to-review.md:8
- Description: Living checklist still said ship unit **1.0.0**, empty argv = Type O only, and omitted termux-ish / script-coding / automatic-checksum / interactive.
- Suggestion: Refresh to 1.4.1 and the TTY-menu / non-TTY install-ensure split.
- Lesson: L-TYPE-N-01
- Test: TP-CLI-07, TP-CLI-14
- Status: closed

### Issue 2 -- Severity: bug
- File: reviews/test-plan.md:23
- Description: Baseline claimed “local-only / no online verbs / no SCRIPT_URL UX” and owned TP-CLI-10 with ghost `requirement-bootstrap-chain`. Suite already required `self-update` / `version-check` as known commands.
- Suggestion: Rewrite baseline; TP-CLI-10 = routed channel verbs, no network.
- Test: TP-CLI-04, TP-CLI-10
- Status: closed

### Issue 3 -- Severity: bug
- File: docs/requirements/requirement-shell-idempotency.md:37
- Description: Practice told operators that a second bare `sshd-cli` on a terminal is “already installed”. After 1.2.0 that path is the numbered menu.
- Suggestion: Re-run story is `curl | sh` or `sshd-cli install`.
- Test: TP-CLI-14, TP-LC-03
- Status: closed

### Issue 4 -- Severity: suggestion
- File: README.md:48
- Description: README recommended `sudo curl | sh` as the system-wide path on a Termux-first product whose related REQs forbid that recommendation on a command line for normal user only.
- Suggestion: Same one-liner as a **root login** on POSIX Linux; not for Termux / Git Bash / Windows cmd.
- Status: closed

### Issue 5 -- Severity: suggestion
- File: reviews/requirement-test-matrix.md:18
- Description: Automatic-checksum was mapped to TP-LC-01 (binary placed). That assert never checked companion link/value/result.
- Suggestion: Add TP-CSUM-01; keep TP-CLI-04/06 for CHECKSUM omitted from help/about.
- Test: TP-CSUM-01
- Status: closed

## Coverage verdict

**Sufficient with Gaps** for C-full-product: every registered REQ has a matrix row; checksum and empty-argv are honestly owned; domain start/stop/port/keys behavioral TPs remain **todo**. No filled `docs/checklists/` product run is git-tracked (`docs/**` except `docs/requirements/` is ignored); the living product checklist is `reviews/what-to-review.md`.
