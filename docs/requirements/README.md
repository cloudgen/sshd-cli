# Requirements

Authoritative product and engineering requirements for this project live here.

**Current state (2026-09-12 — sshd-cli 1.18.0):** sshd-cli is a Termux-first helper that installs and runs OpenSSH sshd. Termux: background daemon (`sshd -f`) plus Android wake lock. POSIX Linux with a loaded distro unit: `start` / `stop` / `restart` use `systemctl` (root login; no in-tool `sudo`; no routed `systemctl` verb). This login’s `~/.ssh/config` Host list (`dns`) includes **`unset`** (drop extra keys without deleting the Host). **`ssh`** opens an OpenSSH client session using a named Host; **`download`** tar.gz a remote folder into cwd (remembers paths per Host). `backup-config` / `sync-config` / `sync-from-remote` and sudoers grant live on **`requirement-shell-config-backup`** / **`requirement-shell-sudoer`**. `install` PATH ensure honors `BASHRC` (default `~/.bashrc`). Scratch/cache resolve mkdir is fail-soft (Git Bash AppData Local Temp/`cache` when `/dev/shm` cannot be created). Shell-rc law (path-ensure, profile-ensure, sibling unify, `rc-test`) lives on **`requirement-shell-path-and-shell-support`**. **dns** as-Termux Host writes simpler Ciphers/MACs so slow Termux sshd does not abort with Connection corrupted. Law lives in **one** class file (`requirement-class-software-dev`), **fifteen** shell files (including **script-coding**, **termux-ish**, **path-and-shell-support**, **sudoer**, and **config-backup**), **three** pointer files (`requirement-sshd-config-backup`, `requirement-sudoer-json-file`, `requirement-three-layer-privilege-model`), and **one** domain file (`requirement-domain-sshd`). Registry: `index.md`. Specialized from bootstrap origin **selfmanaged** (A → B). You run as yourself (catalog: Type 0). Product version SSOT: `VERSION="1.18.0"`. TTY menu numbers **`ssh` (6)** / **`download` (7)**; TTY `ssh` prompts user with default. Do **not** invent additional requirement paths without a real ownership gap — verify on disk and register new files in `index.md` in the same change.

## Purpose

- **Plan mode** designs work by reading and **updating** these docs — not only the session `plan.md`.
- **Implement** delivers code and docs that **trace** to requirement IDs.
- **Review** verifies delivery against requirements **and** defensive (CIAO) checklists.

## Layout

| Path | Role |
|------|------|
| `docs/requirements/index.md` | Registry of all requirements (IDs, status, owners) — keep in sync with files |
| `docs/requirements/requirement-*.md` | CIAO-style project requirements (flat; primary live convention) |
| `docs/requirements/<area>/<REQ-ID>.md` | Optional council-style `REQ-<AREA>-<NNN>` files |

Suggested areas (if using subdirs): `product/`, `platform/`, `security/`, `ops/` — create as needed.

## ID scheme

- **Primary live convention:** `requirement-<topic>.md` or `requirement-<language>-<topic>.md` (e.g. `requirement-shell-cli-interface.md`, `requirement-class-software-dev.md`).
- Optional council-style: `REQ-<AREA>-<NNN>` (example: `REQ-PLAT-001`) if using area subdirs.
- IDs/keys are stable. Prefer status/`supersedes` over renumbering.
- Record every key in `index.md` when created or status changes.

## Status values

Live product law on this project uses the **file header Status** (and matching registry **Status** column):

| Status | Meaning |
|--------|---------|
| `Active` | Normative product law — implement and review against it |
| `Draft` | Proposed; not yet approved as binding law |
| `Deprecated` | No longer active; keep file for history |
| `Superseded` | Replaced by another requirement key (link it) |

Legacy/council synonyms sometimes seen in older docs (`approved`, `in-progress`, `done`) map to **Active** when the file is registered and binding. Prefer **Active** for this registry.

## Plan-mode rules (mandatory)

When planning non-trivial work:

1. Search `docs/requirements/` (and `index.md`) for related requirements.
2. Decide: **new requirement**, **update existing**, or **no requirements impact** (state why).
3. Apply requirement file changes **before** or as part of finishing the plan.
4. Session plan (`plan.md`) must list affected REQ-IDs and whether each is create / update / no-change.
5. Do not implement against unstated intent — if behavior is required, it belongs in a requirement file.

## Implementation rules

- Every non-trivial PR/change set cites one or more REQ-IDs in commit/PR/summary when requirements exist.
- Do not invent requirements only in code comments; promote durable intent here.
- **No placeholders** in requirement files: no `TBD`/`TODO` acceptance criteria, hollow sections, or stub “later” text. See `AGENTS.md` → **No-placeholder policy**.
- Product source comments cite only **live** `requirement-*.md` files (never invent basenames).

## Review rules

- Requirements changes and code/docs delivery use the project’s plan/implement/code-review/security checklist process.
- Empty registry is valid for genesis; do not invent requirements to “fill” the index.
- Software-development class requires Active `requirement-class-software-dev.md` in the registry.
