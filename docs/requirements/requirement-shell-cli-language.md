**file**: docs/requirements/requirement-shell-cli-language.md
**Status**: Active (Version 1.0.0)
**Area**: shell
**Key**: `requirement-shell-cli-language`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the product law for **menu language** on sshd-cli: English and Traditional Chinese, the saved code, and the words the numbered menu prints.

The numbered tree (which row is **6**, which child is **61** or **62**, Back, and the current-shell `read`) stays owned by `requirement-shell-cli-default-interaction`. The persistence directory stays owned by `requirement-shell-cli-storage`. This file owns the language codes, the `language` leaf, and the menu copy.

### 1.1 Human-facing

**In one sentence:** Menu **6** chooses English or 繁體中文 for the numbered menu, and the next menu opens in that language.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Pick a language on the menu | `6` then `62` |
| The other role | A script that must not wait | `sshd-cli status` |
| Not this file | What `start` prints, help pages, dns action words | Those stay English in this version |

| Includes | Excludes |
|----------|----------|
| Codes `en` and `zh-Hant`; front **6** / **61** / **62**; menu copy on the boards named in §2.4 | A third language; translating help, about, or command output |
| File `${HOME}/.local/${APP_NAME}/language` | Putting that file in the cache folder |

## 2. Core Rules / Requirements (Mandatory)

**Claimed:** yes. Default language is English so an existing menu test keeps matching English words. Traditional Chinese is the operator’s choice, stored for the next run.

### 2.1 Languages

| Code | Name on the language board | Default |
|------|----------------------------|---------|
| `en` | English | yes |
| `zh-Hant` | 繁體中文 | no |

**MUST** accept only these two codes in this version. **MUST** treat a missing file, an empty file, or any other first line as English for this process. **MUST NOT** rewrite a file whose first line is not one of these codes. **MUST NOT** add a third code without a new revision of this file.

The short names **English** and **繁體中文** are the same words in both languages (each language’s own name).

### 2.2 Where the choice is stored

1. The leaf is `${HOME}/.local/${APP_NAME}/language`, inside the persistence directory from `requirement-shell-cli-storage`. **MUST NOT** put it in the cache folder. **MUST NOT** put it under `/var/sshd-cli`.
2. The file is one line, `en` or `zh-Hant`, then a newline. Mode **0600**. A trailing CR is ignored. Only the first line is read.
3. `app_lang_load` sets `APP_LANG` once, at the start of `app_cmd_menu`, after the terminal check and before the first row. **MUST NOT** call it again in that same process: a later call would let `SSHD_CLI_LANG` cover a pick just saved.
4. When `SSHD_CLI_LANG` is `en` or `zh-Hant`, that value wins over the file at process start. It does not write the file. A menu pick still writes the file and sets `APP_LANG` for the rest of that process.
5. `app_lang_save` writes the line and sets `APP_LANG` only after the write succeeds.

### 2.3 Menu numbers

Front **6** opens `app_cmd_menu_language`. **61** saves `en`. **62** saves `zh-Hant`. Both are valid leaves: an info line names the language, then the front board redisplays in that language. **0** / empty / EOF is Back and does not write the file. An invalid choice warns and reprints this board.

Typed `language` on the front board opens it. Typed `english`, `en`, `English`, `traditional-chinese`, `zh-Hant`, `zh-hant`, and `繁體中文` select the matching row. `language` is not an argv verb.

Row **6** is numbered on every host, including Termux, Git Bash, and Windows cmd. It is not a hide cause.

### 2.4 What follows the saved language

**MUST** follow `APP_LANG` on these boards: front, client, server, language, self-management, and sudoers. That covers the layer title, the category shorts (`client-side`, `server-side`, `self-management`, `language`), every long description, `0. Back` / `0. 返回`, `9. Exit` / `9. 離開`, the choose-prompt, the unknown-choice warn, and the two menu-hidden sentences (client backup/sync, server non-root).

**MUST** keep each leaf short as the English verb in both languages (`dns`, `ssh`, `start`, `install`, `generate-sudoer-request`, and the other leaf tokens). A leaf short is that verb. The sudoers category short stays `sudoers` in both languages.

Row **71**’s English long text is `Write a JSON grant you can read`. That sentence stays inside `sshd_cmd_sudoers_menu`, which already contains a current-shell `read`. **MUST NOT** put that sentence in `app_menu_text`: the helper’s body must stay free of those four letters in a row so a command substitution stays legal. The Traditional Chinese line for row **71** is the other branch of the same `if` in `sshd_cmd_sudoers_menu`. The other sudoers longs go through `app_menu_text`.

**Stays English in this version** (this scope, not a missing sentence): the dns action board (**111–114**), Host / folder / extra-setting pickers, `help`, `about`, `version`, operational command output, and `out_die` lines that are not the menu unknown-choice warn.

`app_menu_text` prints the chosen string on stdout for the caller. The caller passes that string to `out_menu_choice`, `out_info`, `out_warn`, `out_plain`, or `out_msg_n`. The operator sees `out_*`.

After a successful save the info line is `Menu language is English` or `選單語言是繁體中文`, printed after `APP_LANG` has changed. A failed write warns with `Could not save the menu language` or `無法儲存選單語言` in the language that was already current, leaves `APP_LANG` unchanged, and still returns to the front board.

### 2.5 Call shape

`app_lang_load`, `app_lang_save`, and `app_menu_text` do not contain `read`. A command substitution around them is allowed. `app_cmd_menu_language` contains `read -r` and **MUST** be called in the current shell (`6|language) app_cmd_menu_language`). **MUST NOT** wrap that function, or `read`, in `$()` or backticks. The same rule as `requirement-shell-cli-default-interaction` §2.2.4.

### 2.6 Ship-unit functions

These bodies are the current text of `./sshd-cli` (the same bytes as `src/sshd-cli`). Section 2 is the law.

#### `app_lang_load`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-language.md · requirement-shell-cli-storage.md
# APP_LANG is en or zh-Hant. Missing or unrecognized file stays en.
# SSHD_CLI_LANG wins over the file when it is en or zh-Hant.
# One call at the start of the front board. A later pick updates APP_LANG
# in this process; do not call this again in that process or the env value
# would cover the pick.
app_lang_load() {
    APP_LANG=en
    if [ -z "${PERSISTENT_STORAGE_DIR:-}" ]; then
        PERSISTENT_STORAGE_DIR=$(util_resolve_persistent_storage)
        export PERSISTENT_STORAGE_DIR
    fi
    _ll_path="${PERSISTENT_STORAGE_DIR}/language"
    if [ -f "${_ll_path}" ]; then
        _ll_line=$(head -n 1 "${_ll_path}" 2>/dev/null || true)
        _ll_line=$(printf '%s' "${_ll_line}" | tr -d '\r')
        case "${_ll_line}" in
            en|zh-Hant) APP_LANG="${_ll_line}" ;;
        esac
    fi
    case "${SSHD_CLI_LANG-}" in
        en|zh-Hant) APP_LANG="${SSHD_CLI_LANG}" ;;
    esac
    export APP_LANG
    unset _ll_path _ll_line
}
```

#### `app_lang_save`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-language.md · requirement-shell-cli-storage.md
# Write one line, mode 0600, under persistence. Set APP_LANG on success.
app_lang_save() {
    _ls_code=${1-}
    case "${_ls_code}" in
        en|zh-Hant) ;;
        *)
            unset _ls_code
            return 1
            ;;
    esac
    if [ -z "${PERSISTENT_STORAGE_DIR:-}" ]; then
        PERSISTENT_STORAGE_DIR=$(util_resolve_persistent_storage)
        export PERSISTENT_STORAGE_DIR
    fi
    _ls_path="${PERSISTENT_STORAGE_DIR}/language"
    if ! printf '%s\n' "${_ls_code}" > "${_ls_path}"; then
        unset _ls_code _ls_path
        return 1
    fi
    chmod 0600 "${_ls_path}" 2>/dev/null || true
    APP_LANG="${_ls_code}"
    export APP_LANG
    unset _ls_code _ls_path
    return 0
}
```

#### `app_menu_text`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-language.md
# Menu copy for APP_LANG (en or zh-Hant). Pure data. No input builtin.
# A missing key prints the key. Call from the current shell or a command
# substitution. Keep this body free of the four letters r, e, a, d in a row.
app_menu_text() {
    _mt_key=${1-}
    _mt_extra=${2-}
    _mt_lang=${APP_LANG:-en}
    case "${_mt_lang}" in
        zh-Hant) ;;
        *) _mt_lang=en ;;
    esac
    _mt_out=""
    case "${_mt_key}" in
        cat_client)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="用戶端" ;;
                *) _mt_out="client-side" ;;
            esac
            ;;
        cat_server)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="伺服器端" ;;
                *) _mt_out="server-side" ;;
            esac
            ;;
        cat_self)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="自我管理" ;;
                *) _mt_out="self-management" ;;
            esac
            ;;
        cat_language)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="語言" ;;
                *) _mt_out="language" ;;
            esac
            ;;
        front_client_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個登入的 OpenSSH 用戶端（~/.ssh/config、ssh、資料夾）" ;;
                *) _mt_out="this login OpenSSH client (~/.ssh/config, ssh, folders)" ;;
            esac
            ;;
        front_server_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這台主機的 OpenSSH sshd（接聽、金鑰、連接埠）" ;;
                *) _mt_out="this host OpenSSH sshd (listen, keys, port)" ;;
            esac
            ;;
        front_language_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單的顯示語言" ;;
                *) _mt_out="display language for this menu" ;;
            esac
            ;;
        front_sudoers_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="免密碼 sudo 的授權與草稿" ;;
                *) _mt_out="grant and drafts for passwordless sudo" ;;
            esac
            ;;
        front_self_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個 CLI 的安裝、版本、更新、移除" ;;
                *) _mt_out="this CLI install, version, update, uninstall" ;;
            esac
            ;;
        client_11_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個登入的 ~/.ssh/config Host 清單" ;;
                *) _mt_out="this login ~/.ssh/config Host list" ;;
            esac
            ;;
        client_12_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="以這個登入的 ~/.ssh/config 連線到 Host" ;;
                *) _mt_out="OpenSSH client to a Host from this login ~/.ssh/config" ;;
            esac
            ;;
        client_13_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將遠端資料夾打包為 tar.gz 放到這個目錄" ;;
                *) _mt_out="tar.gz a remote folder into this directory" ;;
            esac
            ;;
        client_14_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將本機資料夾打包為 tar.gz 傳到 Host（在該 ssh 使用者家目錄解開）" ;;
                *) _mt_out="tar.gz a local folder onto a Host (extract under that ssh user home)" ;;
            esac
            ;;
        client_15_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="把這個登入的 ~/.ssh/config 複製到 /var/sshd-cli" ;;
                *) _mt_out="copy this login ~/.ssh/config to /var/sshd-cli" ;;
            esac
            ;;
        client_16_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="把 /var/sshd-cli/config 複製進這個登入的 ~/.ssh/config" ;;
                *) _mt_out="copy /var/sshd-cli/config into this login ~/.ssh/config" ;;
            esac
            ;;
        client_18_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="從 user@host（或 host）複製 /var/sshd-cli/config" ;;
                *) _mt_out="copy /var/sshd-cli/config from user@host (or host)" ;;
            esac
            ;;
        hint_sync_typed)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="   （或輸入 sync-from-remote [user@host]：從另一台主機複製 /var/sshd-cli/config）" ;;
                *) _mt_out="   (or type sync-from-remote [user@host]: copy /var/sshd-cli/config from another host)" ;;
            esac
            ;;
        server_21_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="執行狀態、連接埠與路徑" ;;
                *) _mt_out="running, port, and paths" ;;
            esac
            ;;
        server_22_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="啟動 OpenSSH 常駐程式（背景執行，不是開機服務）" ;;
                *) _mt_out="launch the OpenSSH daemon (background, not a boot service)" ;;
            esac
            ;;
        server_23_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="結束正在執行的常駐程式" ;;
                *) _mt_out="end the running daemon" ;;
            esac
            ;;
        server_24_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="先停止再啟動" ;;
                *) _mt_out="stop then start" ;;
            esac
            ;;
        self_81_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="放置 ${APP_NAME}；確保 rc 與 Termux 的 openssh/termux-auth；啟動 sshd" ;;
                *) _mt_out="place ${APP_NAME}; ensure rc + Termux openssh/termux-auth; start sshd" ;;
            esac
            ;;
        self_82_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示版本與詳細診斷（about）" ;;
                *) _mt_out="show version and detailed diagnostics (about)" ;;
            esac
            ;;
        self_83_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示詳細診斷" ;;
                *) _mt_out="show detailed diagnostics" ;;
            esac
            ;;
        self_84_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="比較本機與遠端版本" ;;
                *) _mt_out="compare local vs remote version" ;;
            esac
            ;;
        self_85_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將 ${APP_NAME} 更新到較新的遠端版本" ;;
                *) _mt_out="update ${APP_NAME} to a newer remote version" ;;
            esac
            ;;
        self_86_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="移除 ${APP_NAME}（安全清理 PATH）" ;;
                *) _mt_out="remove ${APP_NAME} (safe PATH cleanup)" ;;
            esac
            ;;
        self_87_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="只放置這個 CLI（複製這個檔案，或在管線輸入時下載）" ;;
                *) _mt_out="place this CLI only (copy this file, or download when piped)" ;;
            esac
            ;;
        line_back)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="0. 返回" ;;
                *) _mt_out="0. Back" ;;
            esac
            ;;
        line_exit)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="9. 離開" ;;
                *) _mt_out="9. Exit" ;;
            esac
            ;;
        line_prompt)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="請輸入編號，或輸入指令名稱： " ;;
                *) _mt_out="Choose a number, or type the command name: " ;;
            esac
            ;;
        lang_en_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用英文" ;;
                *) _mt_out="use English for this menu" ;;
            esac
            ;;
        lang_zh_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用繁體中文" ;;
                *) _mt_out="use Traditional Chinese for this menu" ;;
            esac
            ;;
        lang_saved)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="選單語言是繁體中文" ;;
                *) _mt_out="Menu language is English" ;;
            esac
            ;;
        lang_save_fail)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="無法儲存選單語言" ;;
                *) _mt_out="Could not save the menu language" ;;
            esac
            ;;
        sudoers_header)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sudoers（免密碼授權與草稿）" ;;
                *) _mt_out="sudoers (grant and drafts)" ;;
            esac
            ;;
        sudoers_72_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將 JSON 授權排入待處理佇列" ;;
                *) _mt_out="Queue the JSON grant inbound" ;;
            esac
            ;;
        sudoers_73_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="輸出 sudoers 草稿" ;;
                *) _mt_out="Emit sudoers draft" ;;
            esac
            ;;
        sudoers_74_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="寫出管理者安裝腳本" ;;
                *) _mt_out="Write admin install script" ;;
            esac
            ;;
        sudoers_75_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="只移除 sudoers 草稿" ;;
                *) _mt_out="Remove sudoers draft only" ;;
            esac
            ;;
        hidden_client)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="backup-config 與 sync-config 不適用於 ${_mt_extra}" ;;
                *) _mt_out="backup-config and sync-config not available for ${_mt_extra}" ;;
            esac
            ;;
        hidden_server)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="非 root 在 ${_mt_extra} 無法使用 start/stop/restart sshd" ;;
                *) _mt_out="start/stop/restart sshd features are not available for non-root in ${_mt_extra}" ;;
            esac
            ;;
        unknown_menu)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="未知的選單選項 '${_mt_extra}'。請從清單選擇編號，或輸入指令名稱。" ;;
                *) _mt_out="Unknown menu choice '${_mt_extra}'. Choose a number from the list, or type the command name." ;;
            esac
            ;;
        unknown_sudoers)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="未知的 sudoers 選項 '${_mt_extra}'。請從清單選擇編號，或輸入指令名稱。" ;;
                *) _mt_out="Unknown sudoers choice '${_mt_extra}'. Choose a number from the list, or type the command name." ;;
            esac
            ;;
        *)
            _mt_out="${_mt_key}"
            ;;
    esac
    printf '%s' "${_mt_out}"
    unset _mt_key _mt_extra _mt_lang _mt_out
}
```

#### `app_cmd_menu_language`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-language.md · requirement-shell-cli-default-interaction.md
# Parent 6. 61 stores en. 62 stores zh-Hant. Both return to the front board.
# 0 / empty / EOF is Back. The choice is a current-shell input builtin.
app_cmd_menu_language() {
    while true; do
        out_info "**${APP_NAME}**(*${VERSION}*) — $(app_menu_text cat_language)"
        out_menu_choice "61" "English" "$(app_menu_text lang_en_long)"
        out_menu_choice "62" "繁體中文" "$(app_menu_text lang_zh_long)"
        out_plain "$(app_menu_text line_back)"
        out_msg_n "$(app_menu_text line_prompt)"
        _choice=""
        if ! read -r _choice; then
            unset _choice
            return 0
        fi
        case "${_choice}" in
            61|english|en|English)
                if app_lang_save en; then
                    out_info "$(app_menu_text lang_saved)"
                else
                    out_warn "$(app_menu_text lang_save_fail)"
                fi
                unset _choice
                return 0
                ;;
            62|traditional-chinese|zh-hant|zh-Hant|繁體中文)
                if app_lang_save zh-Hant; then
                    out_info "$(app_menu_text lang_saved)"
                else
                    out_warn "$(app_menu_text lang_save_fail)"
                fi
                unset _choice
                return 0
                ;;
            0|q|"")
                unset _choice
                return 0
                ;;
            *)
                out_warn "$(app_menu_text unknown_menu "${_choice}")"
                continue
                ;;
        esac
    done
}
```

**Sudoers row 71** (inside `sshd_cmd_sudoers_menu`, not inside `app_menu_text`):

```sh
        if [ "${APP_LANG:-en}" = "zh-Hant" ]; then
            out_menu_choice "71" "generate-sudoer-request" "寫一份可閱讀的 JSON 授權"
        else
            out_menu_choice "71" "generate-sudoer-request" "Write a JSON grant you can read"
        fi
```

### 2.7 Implementation Notes (this project)

| Field | Value |
|-------|--------|
| Claimed | yes |
| Codes | `en` (default), `zh-Hant` |
| File | `${HOME}/.local/sshd-cli/language`, mode 0600 |
| Env override | `SSHD_CLI_LANG=en` or `SSHD_CLI_LANG=zh-Hant` at process start |
| Handlers | `app_lang_load`, `app_lang_save`, `app_menu_text`, `app_cmd_menu_language` (`app_*`) |
| Proof | `tests/test_cli.sh` **TP-CLI-24** · **TP-CLI-14** (English front still lists `language`) · **TP-SSHD-04** (Termux front still lists `language`) |
| Map | `reviews/test-plan.md` |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: one owner for the language codes and the menu copy.
- **CIAO Principle 5 – SSOT of output**: the operator still sees `out_*`. `app_menu_text` only returns the string.
- **CIAO Principle 16 – Interactive**: the language board is part of the terminal menu. A non-interactive run does not open it.

## Under command line for normal user only

The language file lives under this login’s `$HOME`. No sudo, no root path. Row **6** stays numbered when Termux, Git Bash, or Windows cmd hides sudoers. Changing language does not change who may run a verb.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: an unrecognized file stays on disk and the menu stays English.
- **Intentional**: two codes, one file, one helper for the strings.
- **Anti-fragile**: `SSHD_CLI_LANG` can force a language for one process without deleting the file.
- **Over-protect**: `app_menu_text` stays free of a current-shell `read`, and the language board’s `read` stays in the current shell.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

- Default the menu to Traditional Chinese.
- Hide row **6**, or number the language children **1** and **2**.
- Put `read` inside `app_menu_text`, `app_lang_load`, or `app_lang_save`, including inside a catalog sentence.
- Capture `app_cmd_menu_language` with `$()` or backticks.
- Call `app_lang_load` again after a pick in the same process.
- Add `language` as an argv verb without a revision of this file and of `requirement-shell-cli-interface`.
- Translate help, about, or command output in the same edit that only claims the menu boards in §2.4, then pretend those surfaces follow `APP_LANG`.
- Store the language file in the cache folder or under `/var/sshd-cli`.
- Rewrite an unrecognized language file on load.
- Replace the §2.6 fences with a shortened catalog. Those fences stay the current `./sshd-cli` functions.

## 5. Definition of done

This requirement is satisfied when all of the following hold:

1. Front **6** is `language` in English and `語言` in Traditional Chinese, on every host.
2. **61** stores `en` and **62** stores `zh-Hant`, mode 0600, and the front board redisplays in that language.
3. **0** on the language board does not write the file.
4. A later interactive run with the same `$HOME` opens in the saved language. An unrecognized file still opens in English and is left as written.
5. `SSHD_CLI_LANG=zh-Hant` shows Traditional Chinese even when the file says `en`.
6. English menu tests still match the English catalog (default).
7. §2.6 quotes the current helpers from `./sshd-cli`.
8. **TP-CLI-24** is **have**.

### Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-24** **6** / **61** / **62**, file, unrecognized line, `SSHD_CLI_LANG` | `tests/test_cli.sh` | have |
| **TP-CLI-14** English front lists `language` | `tests/test_cli.sh` | have |
| **TP-SSHD-04** Termux front still lists `language` | `tests/test_cli.sh` | have |

**Map:** `reviews/test-plan.md`

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Numbered tree, row **6** / **61** / **62**, current-shell `read` |
| `docs/requirements/requirement-shell-cli-storage.md` | Persistence directory that holds the `language` leaf |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of front **6** |
| `docs/requirements/requirement-shell-output-requirements.md` | Operator text goes through `out_*` |
| `./sshd-cli` | Implementation |
| `tests/test_cli.sh` | **TP-CLI-24** |
| `reviews/test-plan.md` | TP map |

## 7. Revision history

| Date | Change | Author / agent |
|------|--------|----------------|
| 2026-09-28 | v1.0.0: English and Traditional Chinese for the numbered menu. Front **6**, **61** / **62**, file `language`. | Grok (owner request) |

## 8. Terminology

Words this requirement uses. Each row is the term and the definition this file means by it. No glossary file paths.

| Term | Definition |
|------|------------|
| **Menu language** | The saved choice for the words on the numbered boards named in §2.4. English is the default. Traditional Chinese is the other choice. The numbers do not change. |
| **Language code** | `en` or `zh-Hant`. The first line of the language file, or `SSHD_CLI_LANG` when that variable is one of those two codes. Anything else is English for this process. |
| **Menu copy** | The layer titles, category shorts, long descriptions, Back, Exit, choose-prompt, unknown-choice warn, and menu-hidden sentences that follow the language code. Leaf shorts stay the English verb. |
| **English catalog** | The menu words printed when the language code is `en`. The tables in the menu requirement are this catalog. |
| **Do not capture `read`** | A `read`, and any helper whose body contains `read`, runs in the current shell. `app_cmd_menu_language` is that kind of helper. `app_menu_text` is not, and its body must stay free of those letters so a command substitution stays legal. |

**Last Updated**: 2026-09-28
**Owner**: sshd-cli project maintainers
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
