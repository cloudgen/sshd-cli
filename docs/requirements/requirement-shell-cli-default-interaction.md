**file**: docs/requirements/requirement-shell-cli-default-interaction.md
**Status**: Active (Version 1.10.0)
**Area**: shell
**Key**: `requirement-shell-cli-default-interaction`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **independent product law** for the sshd-cli **TTY numbered main menu**: front board **1 client-side / 2 server-side / 7 sudoers / 8 self-management / 9 Exit**, child numbers that **keep the parent prefix** and **never repeat** a parent integer, **0 Back** on every submenu, and each command row printed as **number + bold short description + italic long description**.

A **zero-cli-verb** line (no command after switches; a switch such as `--debug` is still no command) follows `requirement-shell-cli-zero-arguments.md` when the run is **non-interactive**. **Interactive** zero-cli-verb and `menu`/`main` open this tree. When a layer hides rows, each cause prints a **menu-hidden message** before that layer’s numbered items. The choice on every layer is a current-shell `read` (**do not capture `read`**). Domain verbs (`status`, `dns`, `ssh`, …) stay owned by `requirement-domain-sshd.md`. This file owns **the numbered tree**, not those handlers. The board functions are `app_cmd_menu`, `app_cmd_menu_client`, `app_cmd_menu_server`, and `app_cmd_menu_self` (`app_*`, so another project keeps the same names). The Terminology section defines every word this file uses for that tree. The rules in section 2 are the law. §2.11 quotes the live functions from `./sshd-cli`.

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
| Read why backup or daemon rows are missing | The reason is printed above the numbers on that board | Termux client board; non-root server board |

## 2. Core Rules / Requirements (Mandatory)

**Claimed:** yes. A zero-arguments requirement already exists, so this file owns the numbered tree and does not replace that requirement’s non-interactive path. An **interactive zero-cli-verb** (no verb after switch parse; switches allowed; real terminal and not quiet/json) and `menu`/`main` draw this tree. A **non-interactive** zero-cli-verb (`--quiet`, `--json`, or no TTY, even with other switches and no verb) is CLI self-install (`requirement-shell-cli-self-install`). `menu` off-TTY fails closed (`menu needs a terminal`). Interactive `menu --json` still draws the tree.

### 2.1 Front board

| Number | Short | Long | Runs |
|--------|-------|------|------|
| **1** | client-side | this login OpenSSH client (`~/.ssh/config`, ssh, folders) | Client submenu |
| **2** | server-side | this host OpenSSH sshd (listen, keys, port) | Server submenu |
| **7** | sudoers | grant and drafts for passwordless sudo | Sudoers submenu (POSIX Linux only; hidden on Termux / Git Bash / Windows cmd) |
| **8** | self-management | this CLI install, version, update, uninstall | Self-management submenu |
| **9** | Exit | leave the program | Return 0 |

**MUST NOT** list install, version, about, self-update, self-uninstall, help, menu, or `rc-test` on this board.

**Menu-hidden message** for hiding **7** on Termux / Git Bash / Windows cmd belongs on this board, before the numbered items (§2.2.3). The ship unit omits **7** and prints no such line (**Gap**). The client-board sentence covers backup-config and sync-config only.

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

### 2.2.3 Menu-hidden message

A **menu-hidden message** is the line that names why rows of **this** menu layer are omitted. Each distinct cause prints its own message before the numbered items of the layer those rows belong to.

**MUST:**

1. Print the message on the same layer as the omitted rows, after that layer’s header and before the first numbered item.  
2. Use one message when one cause omits several rows on that same layer.  
3. Use a separate message for a different cause. A message on a child layer does not cover a hidden row on the parent.  
4. Reprint that message every time the layer is drawn, including when invalid-choice retry reprints the layer. The message still comes before the numbers.  
5. Leave the omitted numbers reserved (§2.2). A later pick of a hidden number stays invalid-choice retry (§2.2.2).

**MUST NOT** print the message after the numbered items. **MUST NOT** fold two causes into one sentence. **MUST NOT** use the invalid-choice warn as this message. **MUST NOT** give the message a command number. **MUST NOT** renumber the rows that remain.

A token that stays available by name and is absent as a number by design is not a hide cause. On POSIX Linux, **18** `sync-from-remote` is that kind of typed command, so the client board has no menu-hidden message for **18**.

**Live sentences:**

| Layer | Cause | Message before the numbers | Ship unit |
|-------|--------|----------------------------|-----------|
| Client | Termux / Git Bash / Windows cmd omits **15** backup-config and **16** sync-config | `backup-config and sync-config not available for termux` / `gitbash` / `windows-cmd` | have — **TP-SSHD-04**, **TP-CFG-04**, **TP-CFG-05**, **TP-CFG-09** |
| Server | POSIX Linux and this login is not root: **22–24** omitted | `start/stop/restart sshd features are not available for non-root in <OS-Name>` | have — **TP-SSHD-03** |
| Front | Termux / Git Bash / Windows cmd omits **7** sudoers | Its own message, before the front numbered items | **Gap** — row **7** is omitted and no reason line is printed |

**OS-Name** for the server sentence is `/etc/os-release` `NAME=` with quotes stripped, else `uname -s`, else `Linux`. **MUST NOT** hardcode Ubuntu. **MUST NOT** wrap `sudo` to unhide **22–24**. The functions that print these sentences, and the front board that still omits the **7** reason, are quoted in §2.11.

### 2.2.4 Do not capture `read`

**Do not capture `read`** is the call shape for every choice on this tree: the front board, each submenu, each nested action board, each data picker (Host, folder, extra settings), and a yes/no approval question opened from a valid pick.

**MUST:**

1. Read the board choice with `read` in the **current shell**, into the choice variable. The same shape on every layer, including the reprint after invalid-choice retry.  
2. Call any helper whose body contains `read` in the current shell. That includes `prompt_ask`, `prompt_yes_no`, and a future menu-choice reader.  
3. Take a yes/no from `prompt_yes_no` by its exit status (`if prompt_yes_no; then`). Empty on that question still means no (§2.8).  
4. Leave `$()` for pure-data helpers that never `read` (a user name, a path, a label).

**MUST NOT** wrap `read`, or a function whose body contains `read`, in `$()` or backticks. **MUST NOT** treat a prompt on stderr, or `read` from `/dev/tty` inside the helper, as permission to keep that capture. The assignment inside the child shell does not become the parent’s choice.

**This ship unit:** each menu loop uses `read -r` in the current shell (`app_cmd_menu` and the child boards). `prompt_yes_no` is called in the current shell. `prompt_ask` still prints its answer on stdout and these boards do not call it. New menu and picker choice code stays on the current-shell `read`. **MUST NOT** add `_choice=$(prompt_ask …)`. Those menu functions are quoted in §2.11. `prompt_ask` and `prompt_yes_no` are quoted in `requirement-shell-interactive-vs-noninteractive`. Coding home for the same ban outside this tree: `requirement-shell-script-coding`.

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

**Menu-hidden message** for this cause (§2.2.3), before the numbered items: `backup-config and sync-config not available for termux` / `gitbash` / `windows-cmd`. One cause covers **15** and **16**.

### 2.5 Server submenu (parent **2**)

| Number | Short | Who |
|--------|-------|-----|
| **21** status | Always |
| **22** start | Termux class always; POSIX Linux root only (reserved hidden otherwise) |
| **23** stop | Same as **22** |
| **24** restart | Same as **22** |
| **0** Back | Always |

**Menu-hidden message** for this cause (§2.2.3), before the numbered items: `start/stop/restart sshd features are not available for non-root in <OS-Name>`. **MUST NOT** wrap `sudo` to unhide **22–24**.

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

Each of these boards is its own menu layer. Typed verb names still dispatch. An invalid choice warns, reprints **this** layer, and reads again. A finished action on either board is a valid leaf: the front board redisplays. **0** on the dns board returns to the client board (its parent). **0** on the sudoers board returns to the front board (its parent). The choice follows **do not capture `read`** (§2.2.4): a current-shell `read` into the choice variable.

### 2.8 Menu layer

**Layered menu design** is this stack of boards. A **menu layer** is the one numbered list that owns the current `read`. The front board is a layer. Client, server, sudoers, self-management, dns actions, and each data picker (Host, folder, extra settings) are layers. Each of those lists is a numbered list of CLI verbs, except a category row, which opens the next layer.

| This layer | Leave / back tokens | Where you land |
|------------|---------------------|----------------|
| Front board | **9**, **99**, **999**, `exit`, empty line, EOF | Leave the program (return 0) |
| Client, server, self-management | **0**, `q`, empty line, EOF | Parent (the front board) |
| Sudoers, dns actions | **0**, `q`, `exit`, empty line, EOF | Parent (front board for sudoers; client board for dns) |
| Data picker | **0** plus that picker’s leave token | The board that opened the picker |

The `read` on every row of that table follows **do not capture `read`** (§2.2.4). A wrong pick stays on this layer (§2.2.2). A one-shot yes/no after a valid pick is an approval question. It is not a numbered layer, it has no menu number, and empty means no. Who may run a verb (Type 0, Type 1, Type 2) is three-layer privilege. That classification is not a menu layer.

### 2.9 When the tree is drawn

This tree is the numbered main menu. An **interactive zero-cli-verb** draws it: no command token after switches are parsed, on a real terminal, and not quiet and not json. `sshd-cli`, `sshd-cli --debug`, and `sshd-cli --force` with no command are that line when the terminal is real and quiet/json are off. `menu` / `main` draw the same tree. Interactive `menu --json` still draws it. A switch is not a command. Off a terminal, under quiet, or under `--json`, a zero-cli-verb line is **non-interactive** and does not draw this tree. That path is Type O empty argv (CLI self-install), owned by `requirement-shell-cli-zero-arguments` and `requirement-shell-cli-self-install`. This file does not replace that path. `menu` / `main` off a terminal fails closed with a named-command hint and does not wait. That split is interactive vs noninteractive. Type O is the letter **O**. Privilege Type 0 is the digit **0**.

### 2.10 Implementation Notes (this project)

| Field | Value |
|-------|--------|
| Claimed | yes |
| When drawn | Interactive zero-cli-verb and `menu` / `main` on a terminal |
| Handler | `app_cmd_menu` · `app_cmd_menu_client` · `app_cmd_menu_server` · `app_cmd_menu_self` (`app_*`; **MUST NOT** use the domain prefix for these boards) |
| Printer | `out_menu_choice` |
| Ship unit | `./sshd-cli` |
| Zero-cli-verb gate | After switches, no verb left. Interactive (a real terminal, not quiet, not json) → this tree (`sshd-cli`, `sshd-cli --debug`, `sshd-cli --force`). Non-interactive → Type O CLI self-install. The no-token line uses the same split before flag parse. **TP-CLI-14** proves the no-token line. **TP-CLI-23** proves `--debug` / `--force` on a terminal, and `--quiet` / `--json` / non-TTY `--debug` with no verb. |
| Menu-hidden message | Client and server sentences above are have. Front **7** on Termux / Git Bash / Windows cmd is **Gap** (row omitted, no reason line). |
| Choice read | Current-shell `read -r` in each menu loop. `prompt_yes_no` is called in the current shell. `prompt_ask` still prints its answer on stdout and is not used for these boards. |
| Functions | §2.11 quotes `sshd_os_name`, `sshd_menu_show_daemon_rows`, `sshd_host_normal_user_only_label`, `app_cmd_menu_client`, `app_cmd_menu_server`, `app_cmd_menu_self`, and `app_cmd_menu` from `./sshd-cli` |
| Proof | `tests/test_cli.sh` **TP-CLI-14** · **TP-CLI-21** · **TP-CLI-22** · **TP-CLI-23** · **TP-SSHD-03..05** · **TP-SSHD-16**; `tests/test_dns.sh` **TP-DNS-13** · **TP-DNS-20** · **TP-DNS-21** · **TP-DNS-47**; `tests/test_config_backup.sh` **TP-CFG-04** · **TP-CFG-05** · **TP-CFG-09** · **TP-CFG-17**; `tests/test_ssh_download.sh` **TP-UL-18** |
| Map | `reviews/test-plan.md` |

### 2.11 Ship-unit functions

These bodies are the current text of `./sshd-cli` (the same bytes as `src/sshd-cli`). They show the menu-hidden message and the current-shell `read`. Section 2 is the law. A note under a heading records a Gap the function shows. Comment lines inside a fence are copied as the ship unit writes them.

**Front board (`app_cmd_menu`).** On Termux / Git Bash / Windows cmd the function omits row **7** and prints no menu-hidden message. §2.2.3 requires that message. The sentence is Gap. The same function calls `out_die` when `JSON` is 1, when `QUIET` is 1, or when `TTY` is not 1. §2.9 still says interactive `menu --json` draws the tree. That §2.9 sentence stays the known gap. The sample is the function the ship unit runs.

**Client board (`app_cmd_menu_client`).** Choice `11` / `dns` calls `sshd_cmd_dns` and then `return 0`. Back from the dns action board lands on the front board. §2.7 says **0** on the dns board returns to the client board.

**Server helper comment.** The comment on `sshd_menu_show_daemon_rows` says "Numbered menu rows 2/3/4". The live numbers are **22–24**.

**`$()` in the helpers.** `sshd_os_name` and `sshd_menu_show_daemon_rows` use `$()` to read a name or a uid. Those helpers do not `read` a choice (§2.2.4).

#### `sshd_os_name`

```sh
# Host OS display name for operator copy (not a platform class).
# /etc/os-release NAME= first; else uname -s; else Linux.
sshd_os_name() {
    _name=""
    if [ -r /etc/os-release ]; then
        _name=$(grep -E '^NAME=' /etc/os-release 2>/dev/null | head -n 1 || true)
        _name=${_name#NAME=}
        _name=${_name#\"}
        _name=${_name%\"}
        _name=${_name#\'}
        _name=${_name%\'}
    fi
    if [ -z "${_name}" ]; then
        _name=$(uname -s 2>/dev/null || true)
    fi
    if [ -z "${_name}" ]; then
        _name="Linux"
    fi
    printf '%s' "${_name}"
    unset _name
}
```

#### `sshd_menu_show_daemon_rows`

```sh
# Numbered menu rows 2/3/4 (start/stop/restart): this login on a
# command-line-for-normal-user-only host, or a root login on POSIX Linux.
sshd_menu_show_daemon_rows() {
    if sshd_is_normal_user_only_cli; then
        return 0
    fi
    if [ "$(id -u 2>/dev/null || echo 1)" -eq 0 ]; then
        return 0
    fi
    return 1
}
```

#### `sshd_host_normal_user_only_label`

```sh
sshd_host_normal_user_only_label() {
    if sshd_is_termux; then
        printf '%s' "termux"
        return 0
    fi
    if sshd_is_git_bash; then
        printf '%s' "gitbash"
        return 0
    fi
    if sshd_is_windows_cmd; then
        printf '%s' "windows-cmd"
        return 0
    fi
    printf '%s' ""
}
```

#### `app_cmd_menu_client`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-default-interaction
# A valid leaf (or nested action board) returns to the front board. Unknown
# choice retries this layer. 0 / empty / EOF is Back.
app_cmd_menu_client() {
    _show_cfg=1
    if sshd_is_normal_user_only_cli; then
        _show_cfg=0
    fi
    while true; do
        out_info "**${APP_NAME}**(*${VERSION}*) — client-side"
        if [ "${_show_cfg}" -eq 0 ]; then
            out_info "backup-config and sync-config not available for $(sshd_host_normal_user_only_label)"
        fi
        out_menu_choice "11" "dns" "this login ~/.ssh/config Host list"
        out_menu_choice "12" "ssh" "OpenSSH client to a Host from this login ~/.ssh/config"
        out_menu_choice "13" "download" "tar.gz a remote folder into this directory"
        out_menu_choice "14" "upload" "tar.gz a local folder onto a Host (extract under that ssh user home)"
        if [ "${_show_cfg}" -eq 1 ]; then
            out_menu_choice "15" "backup-config" "copy this login ~/.ssh/config to /var/sshd-cli"
            out_menu_choice "16" "sync-config" "copy /var/sshd-cli/config into this login ~/.ssh/config"
            out_plain "   (or type sync-from-remote [user@host]: copy /var/sshd-cli/config from another host)"
        else
            out_menu_choice "18" "sync-from-remote" "copy /var/sshd-cli/config from user@host (or host)"
        fi
        out_plain "0. Back"
        out_msg_n "Choose a number, or type the command name: "
        _choice=""
        if ! read -r _choice; then
            unset _choice _show_cfg
            return 0
        fi
        case "${_choice}" in
            11|dns)
                sshd_cmd_dns
                unset _choice _show_cfg
                return 0
                ;;
            12|ssh)
                sshd_cmd_ssh
                unset _choice _show_cfg
                return 0
                ;;
            13|download)
                sshd_cmd_download
                unset _choice _show_cfg
                return 0
                ;;
            14|upload)
                sshd_cmd_upload
                unset _choice _show_cfg
                return 0
                ;;
            15)
                if [ "${_show_cfg}" -eq 1 ]; then
                    sshd_cmd_backup_config
                    unset _choice _show_cfg
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
            16)
                if [ "${_show_cfg}" -eq 1 ]; then
                    sshd_cmd_sync_config
                    unset _choice _show_cfg
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
            18)
                if [ "${_show_cfg}" -eq 0 ]; then
                    sshd_cmd_sync_from_remote
                    unset _choice _show_cfg
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
            0|q|"")
                unset _choice _show_cfg
                return 0
                ;;
            *)
                if sshd_menu_typed_leaf; then
                    unset _choice _show_cfg
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
        esac
    done
}
```

#### `app_cmd_menu_server`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-default-interaction
# A valid leaf returns to the front board. Unknown choice retries this layer.
# 0 / empty / EOF is Back.
app_cmd_menu_server() {
    _show_daemon=0
    if sshd_menu_show_daemon_rows; then
        _show_daemon=1
    fi
    while true; do
        out_info "**${APP_NAME}**(*${VERSION}*) — server-side"
        if [ "${_show_daemon}" -eq 0 ]; then
            out_info "start/stop/restart sshd features are not available for non-root in $(sshd_os_name)"
        fi
        out_menu_choice "21" "status" "running, port, and paths"
        if [ "${_show_daemon}" -eq 1 ]; then
            out_menu_choice "22" "start" "launch the OpenSSH daemon (background, not a boot service)"
            out_menu_choice "23" "stop" "end the running daemon"
            out_menu_choice "24" "restart" "stop then start"
        fi
        out_plain "0. Back"
        out_msg_n "Choose a number, or type the command name: "
        _choice=""
        if ! read -r _choice; then
            unset _choice _show_daemon
            return 0
        fi
        case "${_choice}" in
            21|status)
                sshd_cmd_status
                unset _choice _show_daemon
                return 0
                ;;
            22)
                if [ "${_show_daemon}" -eq 1 ]; then
                    sshd_cmd_start
                    unset _choice _show_daemon
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
            23)
                if [ "${_show_daemon}" -eq 1 ]; then
                    sshd_cmd_stop
                    unset _choice _show_daemon
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
            24)
                if [ "${_show_daemon}" -eq 1 ]; then
                    sshd_cmd_restart
                    unset _choice _show_daemon
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
            0|q|"")
                unset _choice _show_daemon
                return 0
                ;;
            *)
                if sshd_menu_typed_leaf; then
                    unset _choice _show_daemon
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
        esac
    done
}
```

#### `app_cmd_menu_self`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-default-interaction
# A valid leaf returns to the front board. Unknown choice retries this layer.
# 0 / empty / EOF is Back.
app_cmd_menu_self() {
    while true; do
        out_info "**${APP_NAME}**(*${VERSION}*) — self-management"
        out_menu_choice "81" "install" "place ${APP_NAME}; ensure rc + Termux openssh/termux-auth; start sshd"
        out_menu_choice "82" "version" "show version and detailed diagnostics (about)"
        out_menu_choice "83" "about" "show detailed diagnostics"
        out_menu_choice "84" "version-check" "compare local vs remote version"
        out_menu_choice "85" "self-update" "update ${APP_NAME} to a newer remote version"
        out_menu_choice "86" "self-uninstall" "remove ${APP_NAME} (safe PATH cleanup)"
        out_menu_choice "87" "self-install" "place this CLI only (copy this file, or download when piped)"
        out_plain "0. Back"
        out_msg_n "Choose a number, or type the command name: "
        _choice=""
        if ! read -r _choice; then
            unset _choice
            return 0
        fi
        case "${_choice}" in
            81|install)
                inst_perform_install
                unset _choice
                return 0
                ;;
            82|version)
                app_about
                unset _choice
                return 0
                ;;
            83|about)
                app_about
                unset _choice
                return 0
                ;;
            84|version-check)
                ver_check
                unset _choice
                return 0
                ;;
            85|self-update)
                inst_self_update
                unset _choice
                return 0
                ;;
            86|self-uninstall)
                inst_self_uninstall
                unset _choice
                return 0
                ;;
            87|self-install)
                inst_self_install
                unset _choice
                return 0
                ;;
            0|q|"")
                unset _choice
                return 0
                ;;
            *)
                if sshd_menu_typed_leaf; then
                    unset _choice
                    return 0
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
        esac
    done
}
```

#### `app_cmd_menu`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-default-interaction · requirement-shell-cli-zero-arguments
# Front board loops until Exit. Category rows open a submenu. POSIX Linux
# row 7 opens sudoers (71-75). A finished leaf redisplays this board.
# Unknown choice retries this layer. Row 7 stays reserved when hidden.
app_cmd_menu() {
    if [ "${JSON}" -eq 1 ] || [ "${QUIET}" -eq 1 ] || [ "${TTY}" -ne 1 ]; then
        out_die "menu needs a terminal. Run a named command instead, for example: ${APP_NAME} status"
    fi
    _show_sudoers=1
    if sshd_is_normal_user_only_cli; then
        _show_sudoers=0
    fi
    while true; do
        out_info "**${APP_NAME}**(*${VERSION}*)"
        out_menu_choice "1" "client-side" "this login OpenSSH client (~/.ssh/config, ssh, folders)"
        out_menu_choice "2" "server-side" "this host OpenSSH sshd (listen, keys, port)"
        if [ "${_show_sudoers}" -eq 1 ]; then
            out_menu_choice "7" "sudoers" "grant and drafts for passwordless sudo"
        fi
        out_menu_choice "8" "self-management" "this CLI install, version, update, uninstall"
        out_plain "9. Exit"
        out_msg_n "Choose a number, or type the command name: "
        _choice=""
        if ! read -r _choice; then
            unset _choice _show_sudoers
            return 0
        fi
        case "${_choice}" in
            1|client-side) app_cmd_menu_client; continue ;;
            2|server-side) app_cmd_menu_server; continue ;;
            7)
                if [ "${_show_sudoers}" -eq 1 ]; then
                    sshd_cmd_sudoers_menu
                    continue
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
            8|self-management) app_cmd_menu_self; continue ;;
            9|99|999|exit|"")
                unset _choice _show_sudoers
                return 0
                ;;
            *)
                if sshd_menu_typed_leaf; then
                    continue
                fi
                out_warn "Unknown menu choice '${_choice}'. Choose a number from the list, or type the command name."
                continue
                ;;
        esac
    done
}
```

### 2.x Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): one owner for the numbered tree so domain law does not keep a second integer map.  
- **CIAO Principle 5 – SSOT of output**: `out_menu_choice` is the row printer.  
- **CIAO Principle 16 – Interactive**: no hang off-TTY; invalid choice retries this layer.

## Under command line for normal user only

Who may run a verb is **three-layer privilege** (Type 0 normal user, Type 1 admin, Type 2 dedicated system user). It does not change menu numbers.

When Termux, Git Bash, or Windows cmd is detected: Type 1/2 unused; no in-tool sudo. **This requirement:** front **7** sudoers stays hidden; client **15–16** stay hidden; server **22–24** stay visible for this login; self-management **81–87** stay Type 0. Each of those hides is its own menu-hidden message, printed before that layer’s numbers (§2.2.3). The client sentence is have. The front-board sentence for **7** is still a Gap. Git Bash and Windows cmd do not invoke Termux `pkg`.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: unique numbers so a typed integer cannot mean two boards.  
- **Intentional**: independent file; domain points here.  
- **Anti-fragile**: reserved hidden numbers; each hide cause announced before that layer’s numbers; retry on this layer.  
- **Over-protect**: **0** Back on every submenu; do not capture `read`.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

- Restart a submenu at **1** or reuse **1 / 2 / 7 / 8** on a child list.  
- Put install / version / about on the **front** board.  
- Treat TTY **82 version** as done when it only reprints the board header; TTY **82** and typed `version` on a numbered board **MUST** run `about`. Argv `version` stays thin.  
- Own this tree only inside `requirement-domain-sshd.md`.  
- `out_die` on an unknown TTY menu number.  
- `$()` or backticks around the menu `read`, or around `prompt_ask`, `prompt_yes_no`, or any helper whose body contains `read`. A prompt on stderr, or `read` from `/dev/tty`, does not allow that capture.  
- Print short unstyled or long unstyled on a TTY.  
- After a valid leaf command, stay on the submenu that launched it — **MUST** redisplay the **front board**.
- Treat **0** on the dns board as a jump to the front board. **0** returns to the client board.
- Replace the Terminology section with file paths. The glossary names the word and gives the definition.
- Drop a design piece from §2: the catalog, the shared numbers, the integer grammar, the look, the menu layer, the menu-hidden message, do not capture `read`, invalid-choice retry, the command-finished front board, when the tree is drawn, or who-may-run.
- Print a hide reason after the numbered items, or let one layer’s message cover a hidden row on another layer.
- Invent a front-board sudoers sentence the ship unit does not print. The rule requires that message. The sentence stays a Gap until the ship unit has one.
- Replace the §2.11 fences with a shortened or invented menu. Those fences stay the current `./sshd-cli` functions.
- Name these boards with the domain prefix. The handlers are `app_cmd_menu`, `app_cmd_menu_client`, `app_cmd_menu_server`, and `app_cmd_menu_self`.
- Treat a switch (`--debug`, `--quiet`, `--json`, `--force`) as a command verb.
- Send an interactive zero-cli-verb to help or to install-ensure.
- Draw this tree for a non-interactive zero-cli-verb (no TTY, quiet, or `--json` with no command).

## 5. Definition of done

This requirement is satisfied when all of the following hold:

1. Interactive zero-cli-verb on a terminal (`sshd-cli`, `sshd-cli --debug`, `sshd-cli --force`, quiet and json off) draws front **1 / 2 / 7 / 8 / 9** and does not place the binary.  
2. `menu` / `main` on a terminal draw the same tree. `menu` / `main` off a terminal fails closed and does not wait.  
3. A non-interactive zero-cli-verb does not draw this tree. That path stays on `requirement-shell-cli-zero-arguments` and `requirement-shell-cli-self-install`.  
4. Child numbers keep the parent prefix. **0** on a submenu returns to the parent. Front **9** leaves.  
5. An invalid choice warns, names the token, and reprints that layer.  
6. After a valid leaf, the front board is shown again.  
7. TTY **82** and a typed `version` on a numbered board run `about`.  
8. The proof rows below are **have**.  
9. Each distinct hide cause prints its own menu-hidden message before that layer’s numbered items. The client and server sentences in §2.2.3 are have. The front-board sudoers hide on Termux / Git Bash / Windows cmd still has no message (Gap).  
10. Every menu layer, data picker, and yes/no from this tree reads in the current shell. `$()` and backticks are absent around any helper whose body contains `read`.  
11. Changes cite `requirement-shell-cli-default-interaction`.
12. §2.11 quotes the current `./sshd-cli` functions named there.

### Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-14** interactive empty argv → front 1/2/7/8/9 | `tests/test_cli.sh` | have |
| **TP-CLI-21** TTY **82** / typed `version` run about | `tests/test_cli.sh` | have |
| **TP-CLI-22** finished leaf redisplays the front board | `tests/test_cli.sh` | have |
| **TP-CLI-23** TTY `--debug` / `--force` menu; `--quiet` / `--json` / non-TTY `--debug` do not draw the tree | `tests/test_cli.sh` | have |
| **TP-SSHD-03..05** · **TP-SSHD-16** server rows and invalid-choice retry | `tests/test_cli.sh` | have |
| **TP-SSHD-03** server menu-hidden message before the server numbers | `tests/test_cli.sh` | have |
| **TP-SSHD-04** · **TP-CFG-04** · **TP-CFG-05** · **TP-CFG-09** client menu-hidden message before the client numbers | `tests/test_cli.sh` · `tests/test_config_backup.sh` | have |
| Front **7** hide on Termux / Git Bash / Windows cmd | `./sshd-cli` | Gap (row omitted; no message before the front numbers) |
| **TP-DNS-13** · **TP-DNS-20** · **TP-DNS-21** · **TP-DNS-47** dns board | `tests/test_dns.sh` | have |
| **TP-CFG-17** sudoers **71–75** | `tests/test_config_backup.sh` | have |
| **TP-UL-18** upload row on the client board | `tests/test_ssh_download.sh` | have |

**Map:** `reviews/test-plan.md`

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Zero-cli-verb shape; non-interactive Type O owner |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention `menu`/`main` |
| `docs/requirements/requirement-domain-sshd.md` | Domain handlers; points here for numbers |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | No hang; retry |
| `docs/requirements/requirement-shell-script-coding.md` | Coding home for do not capture `read` outside this tree |
| `docs/requirements/requirement-shell-self-management.md` | install / self-update handlers |
| `./sshd-cli` | Implementation |
| `tests/test_cli.sh`, `tests/test_dns.sh`, `tests/test_config_backup.sh`, `tests/test_ssh_download.sh` | Regression coverage |

## 7. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-09-14 | v1.0.0: independent numbered TTY menu; front **1 / 2 / 8 / 9** | Grok (Release 1.20.0) |
| 2026-09-14 | v1.0.1: TTY **82** runs about | Grok (Release 1.21.0) |
| 2026-09-27 | v1.2.0: sudoers is front **7** (children **71–75**) | Grok (Release 1.26.0) |
| 2026-09-28 | v1.5.0: interactive zero-cli-verb draws this tree; terminology lives in this file | Grok (Release 1.28.0) |
| 2026-09-28 | v1.6.0: same section shape as the other product requirements (definition of done, related artifacts, revision history). The numbered tree stays the law in this file. | Grok (owner request) |
| 2026-09-28 | v1.7.0: each hide cause prints its own menu-hidden message before that layer’s numbered items. Client and server sentences are have. Front **7** on Termux / Git Bash / Windows cmd is Gap. | Grok (owner request) |
| 2026-09-28 | v1.8.0: do not capture `read` is a core rule for every layer, picker, and yes/no on this tree. The choice is a current-shell `read`. | Grok (owner request) |
| 2026-09-28 | v1.9.0: §2.11 quotes the live `./sshd-cli` functions for the menu-hidden message and the current-shell `read`. | Grok (owner request) |
| 2026-09-28 | v1.10.0: menu handlers are `app_cmd_menu`, `app_cmd_menu_client`, `app_cmd_menu_server`, and `app_cmd_menu_self` (`app_*` CLI surface). | Grok (owner request) |

## 8. Terminology

Words this requirement uses. Each row is the term and the definition this file means by it. No glossary file paths.

| Term | Definition |
|------|------------|
| **Zero-cli-verb** | No command token after switches are read. Switches (`--debug`, `--quiet`, `--json`, `--force`, and the other global flags) are allowed and are not a command. Interactive (a real terminal, not quiet, not json) routes to this main menu. Non-interactive (no terminal, quiet, or json) is Type O CLI self-install, owned by the zero-arguments requirement. A named command such as `menu` or `status` is not this shape. |
| **CLI default interaction** | The numbered list of CLI verbs this product claims on a real terminal. An interactive zero-cli-verb, and `menu` / `main`, draw it. Off a terminal the same verb fails closed. It is the behavior, not the ink and not the integer grammar. |
| **CLI main menu hierarchy table** | The layered menu design: the single catalog of every numbered board. Each row records number, parent, short description, long description, what it runs, and who sees it. The tables in §2.1 and §2.4–§2.7 are that catalog. |
| **CLI main menu numbering** | The non-repeating number prefix. Each command number is unique in the whole tree. A child number starts with its parent’s digits. **0** on a submenu goes back to the parent. **9** on the front board leaves. A hidden row keeps its number. Host, folder, and extra-setting pickers stay item indexes **1…N** plus **0**. |
| **Default CLI main menu style** | The default menu style. How every numbered layer is drawn: identity token on the header, then number, bold short name, italic light-gray long description. Off a terminal the same row is plain text. This term is the ink, not which rows exist. |
| **App-name-version-display** | The header identity token: bold program name, italic version, no space, written `**sshd-cli**(*VERSION*)`. It is not a path, not a `Next:` command line, and not the JSON `app` / `version` keys. |
| **Menu layer** | The one numbered list that owns the current `read`. The front board is one layer. Each submenu and each data picker is another. Exit or back leaves only that layer. |
| **Menu-hidden message** | The line that names why rows of this menu layer are omitted. Each distinct cause prints its own message before the numbered items of that layer. One cause that omits several rows on the same layer uses one message. The message is not a numbered row. A later pick of a hidden number is still invalid-choice retry. On this product the client Termux-class sentence and the POSIX non-root server sentence are have. Front **7** hidden on Termux / Git Bash / Windows cmd still has no message (Gap). |
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
| **Do not capture `read`** | The rule that a `read`, and any helper whose body contains `read`, runs in the current shell. `$()` and backticks are forbidden around it: the typed line stays in the child shell. A prompt on stderr, or `read` from `/dev/tty`, does not allow that capture. Pure-data helpers that never `read` may still use `$()`. On this tree the board choice is `read` into the choice variable. A yes/no uses `prompt_yes_no` by its exit status. |
| **Command-substitution subshell** | `$()` or backticks start a child shell. A `read` in that child does not set the parent’s choice variable. That is why the menu choice stays in the current shell. |
| **Prompt-ask-value** | The portable channel for a value prompt: the text lands in `PROMPT_ASK_VALUE` in the current shell. This product’s `prompt_ask` still prints the answer on stdout, and these menu boards do not call it. The board choice stays a current-shell `read`. The ban on `$()` is the same either way. |
| **Interactive vs noninteractive** | Interactive means a person at a terminal, and not quiet, and not json. Non-interactive means a pipe, a script, quiet, or json, with nobody to answer. The numbered tree is drawn only for an interactive zero-cli-verb (and for `menu` / `main` on a terminal). Non-interactive mode must not wait on a board. |
| **Type O empty argv** | The non-interactive zero-cli-verb path: no command token means place/ensure this CLI. Switches with no command are still that path when the run is non-interactive (`--quiet`, `--json`, or no terminal). The letter **O** is this path. The digit **0** is privilege Type 0. An interactive zero-cli-verb is the main menu, not this path. |
| **Operator-readable error** | A line a person at the prompt can act on: what happened, in plain words, and what to do next. The invalid-choice warn is this kind of line. It names the token and tells the operator to choose a listed number or command name. |

**Last Updated**: 2026-09-28  
**Owner**: sshd-cli project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
