# Filled run: language menu 5 — sshd-cli 1.31.0

**Date:** 2026-10-02  
**Checklist:** `reviews/what-to-review.md` section “Language menu numbers (2026-10-02)”  
**Product:** sshd-cli (`src/sshd-cli` and `./sshd-cli`, same bytes)  
**Change type:** menu number  
**Related law:** `requirement-shell-cli-default-interaction` **1.15.0** · `requirement-shell-cli-language` **1.4.0** · `requirement-shell-cli-interface` **1.14.9** · `requirement-domain-sshd` **1.27.1**  
**Proof:** **TP-CLI-14** · **TP-CLI-24** (`tests/test_cli.sh`)  
**Suite:** PASS=1065 FAIL=0 SKIP=0 (`./tests/run.sh`, 2026-10-02). Focused CLI surface before the full suite: PASS=399 FAIL=0 SKIP=0.

## Verdict

- [x] **Pass** — front **5** language; block **50–69** holds at most 20 languages; eight assigned **51–58**
- [ ] **Revise**
- [ ] **Block**

Reviewer / role: Implement + Review (this change)  
Date: 2026-10-02

## Checklist

- [x] Front row is **5** language on every host, including Termux / Git Bash / Windows cmd
- [x] Language rows are reserved **50–69** (twenty numbers, not more than 20 languages)
- [x] Assigned rows are **51** English, **52** 繁體中文, **53** Español, **54** Français, **55** Deutsch, **56** 简体中文, **57** 日本語, **58** 한국어
- [x] **50** and **59–69** are not printed; choosing **50**, **69**, or old **61** warns and does not write `language`
- [x] Front **6** is not a row
- [x] Requirements, review matrix, test plan, and **TP-CLI-24** name the same numbers
- [x] `src/sshd-cli` and `./sshd-cli` are the same bytes, and `sshd-cli.sha256` is the bare hex of that file

## Proof

- **TP-CLI-14** front board prints `5.` and does not print `6.`
- **TP-CLI-24** language board prints **51** through **58**, does not print **50**, **59**, **60**, **61**, or **69**, and saves `en`, `zh-Hant`, `es`, `fr`, `de`, `zh-Hans`, `ja`, and `ko`
- Reserved **50** and **69**, and the old child **61**, warn and leave `~/.local/sshd-cli/language` unwritten
- Old front **6** warns and does not open the language rows

## Scope

| Field | Value |
|-------|--------|
| Script / ship unit | `src/sshd-cli` 1.31.0 |
| Digest | `08cf70b709aa35e768a03f534be66f5fbaf370d1361e89463ad77b222af7fa48` |
| Related requirements | default-interaction 1.15.0, language 1.4.0, interface 1.14.9, domain 1.27.1 |
| Change type | menu number |
