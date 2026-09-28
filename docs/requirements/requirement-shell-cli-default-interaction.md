**file**: docs/requirements/requirement-shell-cli-default-interaction.md
**Status**: Active (Version 1.5.0)
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **independent product law** for the sshd-cli **TTY numbered main menu**: front board **1 client-side / 2 server-side / 7 sudoers / 8 self-management / 9 Exit**, child numbers that **keep the parent prefix** and **never repeat** a parent integer, **0 Back** on every submenu, and each command row printed as **number + bold short description + italic long description**.

A **zero-cli-verb** line (no command after switches; a switch such as `--debug` is still no command) follows `requirement-shell-cli-zero-arguments.md` when the run is **non-interactive**. **Interactive** zero-cli-verb and `menu`/`main` open this tree (case 3). Domain verbs (`status`, `dns`, `ssh`, …) stay owned by `requirement-domain-sshd.md`. This file owns **the numbered tree**, not those handlers. Section 6 defines every word this file uses for that tree. The rules in section 2 are the law; section 6 is the glossary.

### 1.1 Human-facing

**In one sentence:** On a real terminal, `sshd-cli` with no command — a switch such as `--debug` is still no command — or `sshd-cli menu` shows client-side, server-side, sudoers, and self-management, each with unique numbers; **0** walks back; **9** leaves.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Picking numbered boards on a keyboard | `sshd-cli` or `sshd-cli --debug`, then `1` then `11` |
| The other role | Scripts and pipes that must not hang | `sshd-cli status` |
| Not this file | What `start` does to sshd; empty-argv install-ensure | Domain + zero-arguments peers |

| Includes | Excludes |
|----------|----------|
| Front **1 / 2 / 7 / 8 / 9**; client **11…**; server **21…**; self-management **81…**; dns **111…**; sudoers **71…**; **0** Back | Restarting a submenu at **1**; `help` / `rc-test` as numbered rows |
| Bold short + italic long on every command row | Help pages; JSON catalogs |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./sshd-cli` | ship unit | live menu |
| `sshd-cli menu` | command | same tree |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the front board | Client, server, sudoers, self-management, plus Exit | `sshd-cli` or `sshd-cli --debug` on a terminal |
| Open SSH names | Client board then dns | `1` then `11` (or type `dns`) |
| Leave a side board | Back to the parent list | `0` |
| Finish a command on a side board | Front board again (not that submenu) | `8` then `85`, then 1/2/7/8/9 |
| Leave the program | Front Exit | `9` |

## 2. Core Rules / Requirements (Mandatory)

**Claimed:** yes. **Case:** 3 (zero-argument requirement exists). An **interactive zero-cli-verb** (no verb after switch parse; switches allowed; real terminal and not quiet/json) and `menu`/`main` draw this tree. A **non-interactive** zero-cli-verb (`--quiet`, `--json`, or no TTY, even with other switches and no verb) is CLI self-install (`requirement-shell-cli-self-install`). `menu` off-TTY fails closed (`menu needs a terminal`). Interactive `menu --json` still draws the tree.

### 2.1 Front board

| Number | Short | Long | Runs |
|--------|-------|------|------|
| **1** | client-side | this login OpenSSH client (`~/.ssh/config`, ssh, folders) | Client submenu |
| **2** | server-side | this host OpenSSH sshd (listen, keys, port) | Server submenu |
| **7** | sudoers | grant and drafts for passwordless sudo | Sudoers submenu (POSIX Linux only; hidden on Termux / Git Bash / Windows cmd) |
| **8** | self-management | this CLI install, version, update, uninstall | Self-management submenu |
| **9** | Exit | leave the program | Return 0 |

**MUST NOT** list install, version, about, self-update, self-uninstall, help, menu, or `rc-test` on this board.

**Layered menu design (CLI main menu hierarchy table).** The tables in §2.1 and §2.4–§2.7 are the single catalog of every numbered board. The design is a stack of menu layers, not one flat list. Each row records **number**, **parent**, **short description**, **long description**, **what it runs**, and **who sees it**. Category rows (`client-side`, `server-side`, `sudoers`, `self-management`) open the child board. A category row is not a live command token. A leaf row runs an operational verb: the short text is that verb, and the long text is the one-line explain. README capture shows **every** layer in this catalog (front, client, server, sudoers, self-management, dns actions), as markdown bold and italic, with no raw CSI.

**Shared numbers (well-known menu).** This product keeps the shared card: front **1** client-side, **2** server-side, **8** self-management, **9** Exit, and under **8** the rows **81–87**. **81** `install` is payload or local place. **87** `self-install` places this CLI only. Front **7** / **71–75**, client **11–18**, server **21–24**, and dns **111–114** are this product’s extra rows on the same catalog. Shared command words on submenu **8** are `install`, `version`, `about`, `version-check`, `self-update`, `self-uninstall`, and `self-install`. `menu` and `main` open this tree and are not rows. `help` is not a row. Domain words (`dns`, `ssh`, `start`, and the other leaf tokens in §2.4–§2.7) are live commands and are not that shared card. A gap name (a word the law names that the dispatcher does not accept yet) and every test-purpose verb stay off every numbered list.

**Numbered lists of CLI verbs.** Every menu layer is a numbered list. A leaf row is a CLI verb (an operational verb the dispatcher accepts). A category row is not a verb; it opens the next numbered list. `menu` and `main` open the tree and are not rows on any list.

### 2.2 Numbering

These rules are **CLI main menu numbering**, the non-repeating number prefix for this menu. A command number appears once in the whole tree. A child number starts with its parent’s digits as the prefix.

**MUST:**

1. Command numbers are **unique** in the whole tree.  
2. Child command numbers **start with the parent’s digits** (**11…** under **1**, **21…** under **2**, **71…** under **7**, **81…** under **8**, **111…** under **11**).  
3. Every submenu and data picker prints **0** Back (return to parent). Empty on a submenu **MUST** mean Back.  
4. Hidden rows keep their number (reserved). A hidden number is an unknown choice: warn and reprint **that** list. **MUST NOT** `out_die`.  
5. Host / folder / extra-setting pickers stay **1…N** plus **0** (item indexes).

**MUST NOT** restart a submenu at **1**. **MUST NOT** use **9** as submenu Exit. **0** is not a command. Front Exit stays **9** while the front board has at most eight command rows. A verb token typed at any numbered prompt still runs that handler.

### 2.2.1 After a finished command

This return is the **command-finished front board**: the default is to go back to the top menu after a command runs.

**MUST:** after a **valid leaf** (numbered command, typed verb, or nested action board such as dns / sudoers) finishes, redisplay the **front board** (1 / 2 / 7 / 8 / 9). **MUST NOT** redisplay the submenu that launched that command. People-facing: after a command finishes, the top numbered list comes back.

**MUST NOT** treat this as invalid-choice retry. Unknown / hidden-row numbers still warn and reprint **that** layer. **0** / empty / EOF on a submenu still means Back (parent). Front **9** / empty still leaves. A typed leaf on the front board itself also redisplays the front board (does not exit).

### 2.2.2 Invalid choice

An invalid choice is any input that is not a listed number, not a listed name, and not this layer’s leave or back token. A hidden reserved number is an invalid choice on that layer. Unused integers count.

**MUST:** print a warn that names the token and tells the operator to choose a listed number or command name (`out_warn`), reprint **this** layer, and read again in the current shell.

**MUST NOT** `out_die` for that pick. **MUST NOT** exit non-zero solely for that pick. **MUST NOT** treat the pick as an unknown command-line verb. EOF / a failed `read` leaves this layer without spinning.

### 2.3 Style

**Default CLI main menu style** (default menu style) applies to every numbered layer.

Every command row **MUST** print **number**, **bold** short description, *italic* long description (`out_menu_choice`). On a TTY the short name is bold (SGR 1) and the long description is italic and light gray (SGR 3;37). The header on every layer **MUST** be the identity token `**sshd-cli**(*VERSION*)`: bold name, italic version, no space between them. A bare `sshd-cli` on that header is not enough. The Exit row is plain `9. Exit` (no gray explain). Off-TTY / JSON: plain text, no CSI. README transcribes markdown bold/italic and shows every layer; **MUST NOT** paste raw CSI.

### 2.4 Client submenu (parent **1**)

| Number | Short | Who |
|--------|-------|-----|
| **11** dns | Host list | Always |
| **12** ssh | OpenSSH client | Always |
| **13** download | remote tar.gz | Always |
| **14** upload | local tar.gz | Always |
| **15** backup-config | | POSIX Linux only |
| **16** sync-config | | POSIX Linux only |
| **18** sync-from-remote | | Termux / Git Bash / Windows cmd numbered; POSIX Linux typed |
| **0** Back | | Always |

INFO before this list on Termux class: `backup-config and sync-config not available for …`.

### 2.5 Server submenu (parent **2**)

| Number | Short | Who |
|--------|-------|-----|
| **21** status | Always |
| **22** start | Termux class always; POSIX Linux root only (reserved hidden otherwise) |
| **23** stop | Same as **22** |
| **24** restart | Same as **22** |
| **0** Back | Always |

When **22–24** are hidden: INFO `start/stop/restart sshd features are not available for non-root in <OS-Name>` **before this list**. **MUST NOT** wrap `sudo` to unhide them.

### 2.6 Self-management submenu (parent **8**)

| Number | Short | TTY |
|--------|-------|-----|
| **81** | install | Place / ensure |
| **82** | version | Runs **about** (diagnostics). Argv `version` stays a one-liner. **INC-20260914-001**. |
| **83** | about | Same diagnostics as **82** on TTY |
| **84** | version-check | Local vs remote |
| **85** | self-update | Channel replace |
| **86** | self-uninstall | Remove |
| **87** | self-install | Place this CLI only (copy or download) |
| **0** | Back | Return to front |

### 2.7 Nested action boards

Dns (under **11**): **111** Edit, **112** Add, **113** Delete, **114** Unset, **0** Back.  
Sudoers (under **7**): **71** generate-sudoer-request, **72** submit-sudoer-request, **73** print-sudoers, **74** print-sudoers-install-script, **75** remove-project-sudoers, **0** Back.

Each of these boards is its own menu layer. Typed verb names still dispatch. An invalid choice warns, reprints **this** layer, and reads again. A finished action on either board is a valid leaf: the front board redisplays. **0** on the dns board returns to the client board (its parent). **0** on the sudoers board returns to the front board (its parent). The choice is a current-shell `read` into the choice variable. **MUST NOT** wrap that `read` in `$()` or backticks.

### 2.8 Menu layer

**Layered menu design** is this stack of boards. A **menu layer** is the one numbered list that owns the current `read`. The front board is a layer. Client, server, sudoers, self-management, dns actions, and each data picker (Host, folder, extra settings) are layers. Each of those lists is a numbered list of CLI verbs, except a category row, which opens the next layer.

| This layer | Leave / back tokens | Where you land |
|------------|---------------------|----------------|
| Front board | **9**, **99**, **999**, `exit`, empty line, EOF | Leave the program (return 0) |
| Client, server, self-management | **0**, `q`, empty line, EOF | Parent (the front board) |
| Sudoers, dns actions | **0**, `q`, `exit`, empty line, EOF | Parent (front board for sudoers; client board for dns) |
| Data picker | **0** plus that picker’s leave token | The board that opened the picker |

A wrong pick stays on this layer (§2.2.2). A one-shot yes/no after a valid pick is an approval question. It is not a numbered layer, it has no menu number, and empty means no. Who may run a verb (Type 0, Type 1, Type 2) is three-layer privilege. That classification is not a menu layer.

### 2.9 When the tree is drawn

This tree is the CLI default interaction, **case 3**. An **interactive zero-cli-verb** draws it: no command token after switches are parsed, on a real terminal, and not quiet and not json. `sshd-cli`, `sshd-cli --debug`, and `sshd-cli --force` with no command are that line when the terminal is real and quiet/json are off. `menu` / `main` draw the same tree. Interactive `menu --json` still draws it. A switch is not a command. Off a terminal, under quiet, or under `--json`, a zero-cli-verb line is **non-interactive** and does not draw this tree. That path is Type O empty argv (CLI self-install), owned by `requirement-shell-cli-zero-arguments` and `requirement-shell-cli-self-install`. This file does not replace that path. `menu` / `main` off a terminal fails closed with a named-command hint and does not wait. That split is interactive vs noninteractive. Type O is the letter **O**. Privilege Type 0 is the digit **0**.

### 2.10 Implementation Notes (this project)

| Field | Value |
|-------|--------|
| Claimed | yes |
| Case | 3 |
| Handler | `sshd_cmd_menu` · `sshd_cmd_menu_client` · `sshd_cmd_menu_server` · `sshd_cmd_menu_self` |
| Printer | `out_menu_choice` |
| Ship unit | `./sshd-cli` |
| Zero-cli-verb gate | After switches, no verb left. Interactive (a real terminal, not quiet, not json) → this tree (`sshd-cli`, `sshd-cli --debug`, `sshd-cli --force`). Non-interactive → Type O CLI self-install. The no-token line uses the same split before flag parse. **TP-CLI-14** proves the no-token line. **TP-CLI-23** proves `--debug` / `--force` on a terminal, and `--quiet` / `--json` / non-TTY `--debug` with no verb. |
| Proof | `tests/test_cli.sh` **TP-CLI-14** · **TP-CLI-21** · **TP-CLI-22** · **TP-CLI-23** · **TP-SSHD-03..05** · **TP-SSHD-16**; `tests/test_dns.sh` **TP-DNS-13** · **TP-DNS-20** · **TP-DNS-21** · **TP-DNS-47**; `tests/test_config_backup.sh` **TP-CFG-17**; `tests/test_ssh_download.sh` **TP-UL-18** |
| Map | `reviews/test-plan.md` |

### 2.x Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): one owner for the numbered tree so domain law does not keep a second integer map.  
- **CIAO Principle 5 – SSOT of output**: `out_menu_choice` is the row printer.  
- **CIAO Principle 16 – Interactive**: no hang off-TTY; invalid choice retries this layer.

## Under command line for normal user only

Who may run a verb is **three-layer privilege** (Type 0 normal user, Type 1 admin, Type 2 dedicated system user). It does not change menu numbers.

When Termux, Git Bash, or Windows cmd is detected: Type 1/2 unused; no in-tool sudo. **This requirement:** front **7** sudoers stays hidden; client **15–16** stay hidden; server **22–24** stay visible for this login; self-management **81–87** stay Type 0. Git Bash and Windows cmd do not invoke Termux `pkg`.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: unique numbers so a typed integer cannot mean two boards.  
- **Intentional**: independent file; domain points here.  
- **Anti-fragile**: reserved hidden numbers; retry on this layer.  
- **Over-protect**: **0** Back on every submenu; do-not-capture-read.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

- Restart a submenu at **1** or reuse **1 / 2 / 7 / 8** on a child list.  
- Put install / version / about on the **front** board.  
- Treat TTY **82 version** as done when it only reprints the board header; TTY **82** and typed `version` on a numbered board **MUST** run `about`. Argv `version` stays thin.  
- Own this tree only inside `requirement-domain-sshd.md`.  
- `out_die` on an unknown TTY menu number.  
- `$()` a `read` helper for the choice.  
- Print short unstyled or long unstyled on a TTY.  
- After a valid leaf command, stay on the submenu that launched it — **MUST** redisplay the **front board**.
- Treat **0** on the dns board as a jump to the front board. **0** returns to the client board.
- Replace §6 with file paths. The glossary names the word and gives the definition.
- Drop a design piece from §2: the catalog, the shared numbers, the integer grammar, the look, the menu layer, invalid-choice retry, the command-finished front board, when the tree is drawn, or who-may-run.
- Treat a switch (`--debug`, `--quiet`, `--json`, `--force`) as a command verb.
- Send an interactive zero-cli-verb to help or to install-ensure.
- Draw this tree for a non-interactive zero-cli-verb (no TTY, quiet, or `--json` with no command).

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Zero-cli-verb shape; non-interactive Type O owner |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention `menu`/`main` |
| `docs/requirements/requirement-domain-sshd.md` | Domain handlers; points here for numbers |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | No hang; retry |
| `docs/requirements/requirement-shell-self-management.md` | install / self-update handlers |
| `./sshd-cli` | Implementation |

## 6. Terminology

Words this requirement uses. Each row is the term and the definition this file means by it. No glossary file paths.

| Term | Definition |
|------|------------|
| **Zero-cli-verb** | No command token after switches are read. Switches (`--debug`, `--quiet`, `--json`, `--force`, and the other global flags) are allowed and are not a command. Interactive (a real terminal, not quiet, not json) routes to this main menu. Non-interactive (no terminal, quiet, or json) is Type O CLI self-install, owned by the zero-arguments requirement. A named command such as `menu` or `status` is not this shape. |
| **CLI default interaction** | The numbered list of CLI verbs this product claims on a real terminal. Case 3: an interactive zero-cli-verb, and `menu` / `main`, draw it. Off a terminal the same verb fails closed. It is the behavior, not the ink and not the integer grammar. |
| **CLI main menu hierarchy table** | The layered menu design: the single catalog of every numbered board. Each row records number, parent, short description, long description, what it runs, and who sees it. The tables in §2.1 and §2.4–§2.7 are that catalog. |
| **CLI main menu numbering** | The non-repeating number prefix. Each command number is unique in the whole tree. A child number starts with its parent’s digits. **0** on a submenu goes back to the parent. **9** on the front board leaves. A hidden row keeps its number. Host, folder, and extra-setting pickers stay item indexes **1…N** plus **0**. |
| **Default CLI main menu style** | The default menu style. How every numbered layer is drawn: identity token on the header, then number, bold short name, italic light-gray long description. Off a terminal the same row is plain text. This term is the ink, not which rows exist. |
| **App-name-version-display** | The header identity token: bold program name, italic version, no space, written `**sshd-cli**(*VERSION*)`. It is not a path, not a `Next:` command line, and not the JSON `app` / `version` keys. |
| **Menu layer** | The one numbered list that owns the current `read`. The front board is one layer. Each submenu and each data picker is another. Exit or back leaves only that layer. |
| **Front board** | The top menu layer: **1** client-side, **2** server-side, **7** sudoers, **8** self-management, **9** Exit. **0** is not on this layer. |
| **Well-known menu** | The shared numbers this product keeps: front **1 / 2 / 8 / 9** and self-management **81–87**. Front **7** and the domain children are this product’s rows on the hierarchy table, not part of the shared card. |
| **Well-known CLI verb** | A shared command word (`install`, `version`, `about`, `version-check`, `self-update`, `self-uninstall`, `self-install`, `menu`, `main`, `help`). Each is either an operational verb or a test-purpose verb. Domain words such as `dns` and `start` are live commands and are not this shared card. |
| **CLI routed-verb** | A command token the dispatcher accepts and hands to a handler. Inventory is the dispatcher, not the help text. |
| **CLI routed-verb table** | The kept report of those live tokens. A leaf row’s short description is the token. The long description is the one-line explain. Category rows are on the hierarchy table and are not rows of this report. |
| **CLI gap name** | A command word registered law already names while the dispatcher still rejects it. It fails closed as unknown. It is not a numbered row, and help does not list it. |
| **Operational verb** | A live command that does product work (install, status, dns, ssh, and the other leaves). It is not a test-purpose verb. |
| **Test-purpose verb** | A live command whose only job is a unit test against a local test folder (`rc-test`). It stays off every numbered list. |
| **Invalid-choice retry** | A pick that is not listed and is not this layer’s leave or back token. The program warns, names the token, reprints this layer, and reads again. It does not exit and does not treat the pick as an unknown command-line verb. |
| **Command-finished front board** | The default back to the top menu after a command runs. After a valid leaf finishes, the front board is shown again. **0** Back still returns to the parent layer. A bad pick still reprints the current layer. |
| **Three-layer privilege** | Who may run a verb: Type 0 normal user, Type 1 admin, or Type 2 dedicated system user. A menu layer is a numbered list, not one of these privilege types. |
| **Approval question** | A one-shot yes or no after a valid pick. Yes accepts. No rejects. Empty means no. It is not a numbered menu layer. |
| **Do not capture `read`** | The choice `read` runs in the current shell. Wrapping it in `$()` or backticks is forbidden: the typed line never becomes the choice. |
| **Command-substitution subshell** | `$()` or backticks start a child shell. A `read` in that child does not set the parent’s choice variable. That is why the menu choice stays in the current shell. |
| **Prompt-ask-value** | A value prompt that calls `prompt_ask` stores the text in `PROMPT_ASK_VALUE` in the current shell. This menu’s board choice is a current-shell `read` into the choice variable. The same ban on `$()` applies. |
| **Interactive vs noninteractive** | Interactive means a person at a terminal, and not quiet, and not json. Non-interactive means a pipe, a script, quiet, or json, with nobody to answer. The numbered tree is drawn only for an interactive zero-cli-verb (and for `menu` / `main` on a terminal). Non-interactive mode must not wait on a board. |
| **Type O empty argv** | The non-interactive zero-cli-verb path: no command token means place/ensure this CLI. Switches with no command are still that path when the run is non-interactive (`--quiet`, `--json`, or no terminal). The letter **O** is this path. The digit **0** is privilege Type 0. An interactive zero-cli-verb is the main menu, not this path. |
| **Operator-readable error** | A line a person at the prompt can act on: what happened, in plain words, and what to do next. The invalid-choice warn is this kind of line. It names the token and tells the operator to choose a listed number or command name. |

**Last Updated**: 2026-09-28  
**Owner**: {{OWNER}}  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
- **`PO-STAY-IN-PROJECT-SSOT`** — no silent sibling-project write without this-turn named root + notify-before-write (**`E-BLAST-09`**)
