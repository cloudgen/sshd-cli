**file**: docs/requirements/requirement-shell-cli-language.md
**Status**: Active (Version 1.3.1)
**Area**: shell
**Key**: `requirement-shell-cli-language`
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the product law for **menu language** on sshd-cli: English, Traditional Chinese, Spanish, French, German, Simplified Chinese, Japanese, and Korean, the saved code, the words the numbered menu prints, the human text of `help` and `about`, the worked samples of those boards, and the translation tables for the lines the samples do not show in every language.

The numbered tree (which row is **6**, which child is **61** through **68**, Back, and the current-shell `read`) stays owned by `requirement-shell-cli-default-interaction`. The persistence directory stays owned by `requirement-shell-cli-storage`. This file owns the language codes, the `language` leaf, and the menu copy.

### 1.1 Human-facing

**In one sentence:** Menu **6** chooses English, 繁體中文, Español, Français, Deutsch, 简体中文, 日本語, or 한국어 for the numbered menu, for `help`, and for `about`, and the next run opens in that language.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Pick a language on the menu | `6` then `62`, `63`, `64`, `65`, `66`, `67`, or `68` |
| The other role | A script that must not wait | `sshd-cli status` |
| Not this file | What `start` prints, the dns action board, the version one-liner | Those stay English |

| Includes | Excludes |
|----------|----------|
| Codes `en`, `zh-Hant`, `es`, `fr`, `de`, `zh-Hans`, `ja`, and `ko`; front **6** / **61–68**; menu copy on the boards named in §2.4; human `help` and human `about` | Translating command output, the dns action board, Host and folder pickers, argv `version`, or JSON about fields |
| File `${HOME}/.local/${APP_NAME}/language` | Putting that file in the cache folder |

## 2. Core Rules / Requirements (Mandatory)

**Claimed:** yes. Default language is English so an existing menu test keeps matching English words. Traditional Chinese, Spanish, French, German, Simplified Chinese, Japanese, and Korean are the operator’s choice, stored for the next run.

### 2.1 Languages

| Code | Name on the language board | Number | Default |
|------|----------------------------|--------|---------|
| `en` | English | **61** | yes |
| `zh-Hant` | 繁體中文 | **62** | no |
| `es` | Español | **63** | no |
| `fr` | Français | **64** | no |
| `de` | Deutsch | **65** | no |
| `zh-Hans` | 简体中文 | **66** | no |
| `ja` | 日本語 | **67** | no |
| `ko` | 한국어 | **68** | no |

**MUST** accept only these eight codes in this version. **MUST** treat a missing file, an empty file, or any other first line as English for this process. **MUST NOT** rewrite a file whose first line is not one of these codes. **MUST NOT** add a ninth code without a new revision of this file.

The short names **English**, **繁體中文**, **Español**, **Français**, **Deutsch**, **简体中文**, **日本語**, and **한국어** are the same words in every language (each language’s own name).

### 2.2 Where the choice is stored

1. The leaf is `${HOME}/.local/${APP_NAME}/language`, inside the persistence directory from `requirement-shell-cli-storage`. **MUST NOT** put it in the cache folder. **MUST NOT** put it under `/var/sshd-cli`.
2. The file is one line, one of `en`, `zh-Hant`, `es`, `fr`, `de`, `zh-Hans`, `ja`, or `ko`, then a newline. Mode **0600**. A trailing CR is ignored. Only the first line is read.
3. `app_lang_load` sets `APP_LANG` once, at the start of `app_main`, after persistence is resolved and before the zero-cli-verb split. Human `help`, human `about`, and the menu all see that value. **MUST NOT** call it again in that same process: a later call would let `SSHD_CLI_LANG` cover a pick just saved. `app_cmd_menu` does not call it.
4. When `SSHD_CLI_LANG` is one of those eight codes, that value wins over the file at process start. It does not write the file. A menu pick still writes the file and sets `APP_LANG` for the rest of that process.
5. `app_lang_save` writes the line and sets `APP_LANG` only after the write succeeds. A code outside the eight returns failure and leaves `APP_LANG` unchanged.

### 2.3 Menu numbers

Front **6** opens `app_cmd_menu_language`. **61** saves `en`. **62** saves `zh-Hant`. **63** saves `es`. **64** saves `fr`. **65** saves `de`. **66** saves `zh-Hans`. **67** saves `ja`. **68** saves `ko`. Each is a valid leaf: an info line names the language, then the front board redisplays in that language. **0** / empty / EOF is Back and does not write the file. An invalid choice warns and reprints this board.

Typed `language`, `語言`, `语言`, `idioma`, `langue`, `Sprache`, `sprache`, `言語`, and `언어` on the front board open it. The language board accepts:

| Row | Typed tokens |
|-----|----------------|
| **61** | `english`, `en`, `English` |
| **62** | `traditional-chinese`, `zh-hant`, `zh-Hant`, `繁體中文` |
| **63** | `spanish`, `es`, `Español`, `español` |
| **64** | `french`, `fr`, `Français`, `français` |
| **65** | `german`, `de`, `Deutsch`, `deutsch` |
| **66** | `simplified-chinese`, `zh-hans`, `zh-Hans`, `简体中文` |
| **67** | `japanese`, `ja`, `日本語` |
| **68** | `korean`, `ko`, `한국어` |

`language` is not an argv verb.

The front board also accepts the displayed category short: `client-side`, `用戶端`, `客户端`, `cliente`, `client`, `Client`, `クライアント`, `클라이언트`; `server-side`, `伺服器端`, `服务器端`, `servidor`, `serveur`, `Server`, `server`, `サーバー`, `서버`; `self-management`, `自我管理`, `autogestión`, `autogestion`, `Selbstverwaltung`, `selbstverwaltung`, `自己管理`, `자기관리`. The sudoers short stays `sudoers` in every language.

Row **6** is numbered on every host, including Termux, Git Bash, and Windows cmd. It is not a hide cause.

### 2.4 What follows the saved language

**MUST** follow `APP_LANG` on these boards: front, client, server, language, self-management, and sudoers. That covers the layer title, the category shorts, every long description, Back, Exit, the choose-prompt, the unknown-choice warn, and the two menu-hidden sentences (client backup/sync, server non-root).

**MUST** keep each leaf short as the English verb in every language (`dns`, `ssh`, `start`, `install`, `generate-sudoer-request`, and the other leaf tokens). A leaf short is that verb. The sudoers category short stays `sudoers` in every language.

Row **71**’s English long text is `Write a JSON grant you can read`. That sentence stays inside `sshd_cmd_sudoers_menu`, which contains a current-shell `read`. **MUST NOT** put that sentence, or any row **71** long, in `app_menu_text`: the helper’s body must stay free of those four letters in a row so a command substitution stays legal. Each accepted code has its own arm of the `case` in `sshd_cmd_sudoers_menu` (§2.6). The other sudoers longs go through `app_menu_text`.

**MUST** follow `APP_LANG` on human `help` and human `about`. Section headings and the words after each command token follow the code. The command token, the flag, the path, and the env name stay the Latin spelling in every language (`install`, `status`, `self-install`, `--json`, `SCRIPT_URL`, `~/.ssh/config`). English `help` still prints `Usage:` and `Tests (local folder; not install):`. The English menu sentence in `help` names **67** Japanese and **68** Korean. The other codes use their own heading: `用法：`, `Uso:`, `Utilisation :`, `Verwendung:`, `使い方:`, `사용법:`. English `about` still prints `About / Diagnostics`, `Cache folder used:`, and `Useful commands:`. Japanese about prints `概要 / 診断` and `使用中のキャッシュフォルダ:`. Korean about prints `개요 / 진단` and `사용 중인 캐시 폴더:`.

Three sentences contain the letters r, e, a, d in a row. They stay as `case` arms inside `app_help` and `app_about`, not inside `app_menu_text`. The English arms stay `Help text available in human-readable mode. Run without --json.`, `Machine-readable JSON (implies --quiet)`, and `Machine-readable output`. The help note `Use --json with version, about, version-check, install, self-install, self-update, self-uninstall, rc-test.` does not contain those letters and goes through `app_menu_text`.

**Stays English in this version** (this scope, not a missing sentence): the dns action board (**111–114**), Host / folder / extra-setting pickers, argv `version` (`app_version`), operational command output, JSON about keys and JSON values, and `out_die` lines that are not the menu unknown-choice warn.

`app_menu_text` prints the chosen string on stdout for the caller. The caller passes that string to `out_menu_choice`, `out_info`, `out_warn`, `out_plain`, or `out_msg_n`. The operator sees `out_*`.

After a successful save the info line is printed after `APP_LANG` has changed:

| Code | Saved |
|------|--------|
| `en` | `Menu language is English` |
| `zh-Hant` | `選單語言是繁體中文` |
| `es` | `El idioma del menú es español` |
| `fr` | `La langue du menu est le français` |
| `de` | `Die Menüsprache ist Deutsch` |
| `zh-Hans` | `菜单语言是简体中文` |
| `ja` | `メニューの言語は日本語` |
| `ko` | `메뉴 언어는 한국어` |

A failed write warns in the language that was current before the failed write, leaves `APP_LANG` unchanged, and still returns to the front board:

| Code | Failed write |
|------|----------------|
| `en` | `Could not save the menu language` |
| `zh-Hant` | `無法儲存選單語言` |
| `es` | `No se pudo guardar el idioma del menú` |
| `fr` | `Impossible d'enregistrer la langue du menu` |
| `de` | `Die Menüsprache konnte nicht gespeichert werden` |
| `zh-Hans` | `无法保存菜单语言` |
| `ja` | `メニューの言語を保存できませんでした` |
| `ko` | `메뉴 언어를 저장하지 못했습니다` |

Back and Exit on these boards:

| Code | Back | Exit |
|------|------|------|
| `en` | `0. Back` | `9. Exit` |
| `zh-Hant` | `0. 返回` | `9. 離開` |
| `zh-Hans` | `0. 返回` | `9. 离开` |
| `es` | `0. Atrás` | `9. Salir` |
| `fr` | `0. Retour` | `9. Quitter` |
| `de` | `0. Zurück` | `9. Beenden` |
| `ja` | `0. 戻る` | `9. 終了` |
| `ko` | `0. 뒤로` | `9. 종료` |

### 2.4.1 Worked samples

These fences are a live run with the terminal ink written as markdown: **bold** short, *italic* long. The version token is the live `VERSION`. These fences show `1.30.0`. The choose-prompt in the source ends with one space. These fences omit that space. **MUST** print the front board, and the opening of human `help` and human `about`, for each code as these samples say. **MUST NOT** invent a line the ship unit does not print. Deeper boards keep the English verb as the leaf short (§2.4). The language-board longs in a language other than English are §2.4.2. The §2.6 fences stay the full functions.

English (`en`), front board, then the language board, then the opening of `help` and `about`:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **client-side**: *this login OpenSSH client (~/.ssh/config, ssh, folders)*
2. **server-side**: *this host OpenSSH sshd (listen, keys, port)*
6. **language**: *display language for this menu*
7. **sudoers**: *grant and drafts for passwordless sudo*
8. **self-management**: *this CLI install, version, update, uninstall*
9. Exit
Choose a number, or type the command name:
```

```text
[INFO] **sshd-cli**(*1.30.0*) — language
61. **English**: *use English for this menu*
62. **繁體中文**: *use Traditional Chinese for this menu*
63. **Español**: *use Spanish for this menu*
64. **Français**: *use French for this menu*
65. **Deutsch**: *use German for this menu*
66. **简体中文**: *use Simplified Chinese for this menu*
67. **日本語**: *use Japanese for this menu*
68. **한국어**: *use Korean for this menu*
0. Back
Choose a number, or type the command name:
```

```text
[INFO] sshd-cli — Simplify Termux to install sshd
[INFO] Usage:
  sshd-cli [command] [options]
[INFO] === sshd-cli 1.30.0 - About / Diagnostics ===
[OK] sshd-cli is properly installed.
```

Traditional Chinese (`zh-Hant`), after **62**:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **用戶端**: *這個登入的 OpenSSH 用戶端（~/.ssh/config、ssh、資料夾）*
2. **伺服器端**: *這台主機的 OpenSSH sshd（接聽、金鑰、連接埠）*
6. **語言**: *這個選單的顯示語言*
7. **sudoers**: *免密碼 sudo 的授權與草稿*
8. **自我管理**: *這個 CLI 的安裝、版本、更新、移除*
9. 離開
請輸入編號，或輸入指令名稱：
```

```text
[INFO] sshd-cli — 簡化 Termux 安裝 sshd
[INFO] 用法：
  sshd-cli [命令] [選項]
[INFO] === sshd-cli 1.30.0 - 關於 / 診斷 ===
[OK] sshd-cli 已正確安裝。
```

Spanish (`es`), after **63**:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **cliente**: *cliente OpenSSH de este inicio (~/.ssh/config, ssh, carpetas)*
2. **servidor**: *sshd OpenSSH de este equipo (escucha, claves, puerto)*
6. **idioma**: *idioma de este menú*
7. **sudoers**: *concesión y borradores de sudo sin contraseña*
8. **autogestión**: *instalación, versión, actualización y desinstalación de este CLI*
9. Salir
Elija un número, o escriba el nombre del comando:
```

```text
[INFO] sshd-cli — simplificar la instalación de sshd en Termux
[INFO] Uso:
  sshd-cli [comando] [opciones]
[INFO] === sshd-cli 1.30.0 - Acerca de / diagnóstico ===
[OK] sshd-cli está instalado correctamente.
```

French (`fr`), after **64**:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **client**: *client OpenSSH de cette session (~/.ssh/config, ssh, dossiers)*
2. **serveur**: *sshd OpenSSH de cet hôte (écoute, clés, port)*
6. **langue**: *langue d'affichage de ce menu*
7. **sudoers**: *autorisation et brouillons pour sudo sans mot de passe*
8. **autogestion**: *installation, version, mise à jour et retrait de ce CLI*
9. Quitter
Choisissez un numéro, ou saisissez le nom de la commande :
```

```text
[INFO] sshd-cli — simplifier l'installation de sshd sur Termux
[INFO] Utilisation :
  sshd-cli [commande] [options]
[INFO] === sshd-cli 1.30.0 - À propos / diagnostic ===
[OK] sshd-cli est correctement installé.
```

German (`de`), after **65**:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **Client**: *OpenSSH-Client dieser Anmeldung (~/.ssh/config, ssh, Ordner)*
2. **Server**: *OpenSSH-sshd dieses Rechners (wartet, Schlüssel, Port)*
6. **Sprache**: *Anzeigesprache dieses Menüs*
7. **sudoers**: *Freigabe und Entwürfe für sudo ohne Passwort*
8. **Selbstverwaltung**: *Installation, Version, Aktualisierung und Entfernen dieses CLI*
9. Beenden
Wählen Sie eine Nummer, oder geben Sie den Befehlsnamen ein:
```

```text
[INFO] sshd-cli — sshd auf Termux einfach installieren
[INFO] Verwendung:
  sshd-cli [Befehl] [Optionen]
[INFO] === sshd-cli 1.30.0 - Über / Diagnose ===
[OK] sshd-cli ist ordnungsgemäß installiert.
```

Simplified Chinese (`zh-Hans`), after **66**:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **客户端**: *这个登录的 OpenSSH 客户端（~/.ssh/config、ssh、文件夹）*
2. **服务器端**: *这台主机的 OpenSSH sshd（监听、密钥、端口）*
6. **语言**: *这个菜单的显示语言*
7. **sudoers**: *免密码 sudo 的授权与草稿*
8. **自我管理**: *这个 CLI 的安装、版本、更新、移除*
9. 离开
请输入编号，或输入指令名称：
```

```text
[INFO] sshd-cli — 简化 Termux 安装 sshd
[INFO] 用法：
  sshd-cli [命令] [选项]
[INFO] === sshd-cli 1.30.0 - 关于 / 诊断 ===
[OK] sshd-cli 已正确安装。
```

Japanese (`ja`), after **67**:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **クライアント**: *このログインの OpenSSH クライアント（~/.ssh/config、ssh、フォルダ）*
2. **サーバー**: *このホストの OpenSSH sshd（待ち受け、鍵、ポート）*
6. **言語**: *このメニューの表示言語*
7. **sudoers**: *パスワードなし sudo の認可と下書き*
8. **自己管理**: *この CLI のインストール、バージョン、更新、削除*
9. 終了
番号を入力するか、コマンド名を入力してください:
```

```text
[INFO] sshd-cli — Termux で sshd を簡単に導入する
[INFO] 使い方:
  sshd-cli [コマンド] [オプション]
[INFO] === sshd-cli 1.30.0 - 概要 / 診断 ===
[OK] sshd-cli は正しく配置されています。
```

Korean (`ko`), after **68**:

```text
[INFO] **sshd-cli**(*1.30.0*)
1. **클라이언트**: *이 로그인의 OpenSSH 클라이언트(~/.ssh/config, ssh, 폴더)*
2. **서버**: *이 호스트의 OpenSSH sshd(대기, 키, 포트)*
6. **언어**: *이 메뉴의 표시 언어*
7. **sudoers**: *비밀번호 없는 sudo의 허가와 초안*
8. **자기관리**: *이 CLI의 설치, 버전, 업데이트, 제거*
9. 종료
번호를 입력하거나 명령 이름을 입력하세요:
```

```text
[INFO] sshd-cli — Termux에서 sshd 설치를 단순하게
[INFO] 사용법:
  sshd-cli [명령] [옵션]
[INFO] === sshd-cli 1.30.0 - 개요 / 진단 ===
[OK] sshd-cli가 올바르게 설치되어 있습니다.
```

Row **7** is on the POSIX Linux front board. Termux, Git Bash, and Windows cmd omit that row and print no reason line (Gap on the menu requirement). The samples above include row **7** because that is the POSIX Linux board.

### 2.4.2 Translation detail

The shorts on the language board stay the endonyms in every UI language. The long follows the UI language. `${_mt_extra}` is the host label or the OS name the caller passes. A failed-write line and the saved-language line stay in the tables above this section.

Language-board longs:

| UI | Row | Long |
|----|-----|------|
| `en` | **61** | `use English for this menu` |
| `en` | **62** | `use Traditional Chinese for this menu` |
| `en` | **63** | `use Spanish for this menu` |
| `en` | **64** | `use French for this menu` |
| `en` | **65** | `use German for this menu` |
| `en` | **66** | `use Simplified Chinese for this menu` |
| `en` | **67** | `use Japanese for this menu` |
| `en` | **68** | `use Korean for this menu` |
| `zh-Hant` | **61** | `這個選單改用英文` |
| `zh-Hant` | **62** | `這個選單改用繁體中文` |
| `zh-Hant` | **63** | `這個選單改用西班牙文` |
| `zh-Hant` | **64** | `這個選單改用法文` |
| `zh-Hant` | **65** | `這個選單改用德文` |
| `zh-Hant` | **66** | `這個選單改用簡體中文` |
| `zh-Hant` | **67** | `這個選單改用日文` |
| `zh-Hant` | **68** | `這個選單改用韓文` |
| `es` | **61** | `usar inglés en este menú` |
| `es` | **62** | `usar chino tradicional en este menú` |
| `es` | **63** | `usar español en este menú` |
| `es` | **64** | `usar francés en este menú` |
| `es` | **65** | `usar alemán en este menú` |
| `es` | **66** | `usar chino simplificado en este menú` |
| `es` | **67** | `usar japonés en este menú` |
| `es` | **68** | `usar coreano en este menú` |
| `fr` | **61** | `utiliser l'anglais pour ce menu` |
| `fr` | **62** | `utiliser le chinois traditionnel pour ce menu` |
| `fr` | **63** | `utiliser l'espagnol pour ce menu` |
| `fr` | **64** | `utiliser le français pour ce menu` |
| `fr` | **65** | `utiliser l'allemand pour ce menu` |
| `fr` | **66** | `utiliser le chinois simplifié pour ce menu` |
| `fr` | **67** | `utiliser le japonais pour ce menu` |
| `fr` | **68** | `utiliser le coréen pour ce menu` |
| `de` | **61** | `Englisch für dieses Menü verwenden` |
| `de` | **62** | `Traditionelles Chinesisch für dieses Menü verwenden` |
| `de` | **63** | `Spanisch für dieses Menü verwenden` |
| `de` | **64** | `Französisch für dieses Menü verwenden` |
| `de` | **65** | `Deutsch für dieses Menü verwenden` |
| `de` | **66** | `Vereinfachtes Chinesisch für dieses Menü verwenden` |
| `de` | **67** | `Japanisch für dieses Menü verwenden` |
| `de` | **68** | `Koreanisch für dieses Menü verwenden` |
| `zh-Hans` | **61** | `这个菜单改用英文` |
| `zh-Hans` | **62** | `这个菜单改用繁体中文` |
| `zh-Hans` | **63** | `这个菜单改用西班牙文` |
| `zh-Hans` | **64** | `这个菜单改用法文` |
| `zh-Hans` | **65** | `这个菜单改用德文` |
| `zh-Hans` | **66** | `这个菜单改用简体中文` |
| `zh-Hans` | **67** | `这个菜单改用日文` |
| `zh-Hans` | **68** | `这个菜单改用韩文` |
| `ja` | **61** | `このメニューを英語にする` |
| `ja` | **62** | `このメニューを繁体字中国語にする` |
| `ja` | **63** | `このメニューをスペイン語にする` |
| `ja` | **64** | `このメニューをフランス語にする` |
| `ja` | **65** | `このメニューをドイツ語にする` |
| `ja` | **66** | `このメニューを簡体字中国語にする` |
| `ja` | **67** | `このメニューを日本語にする` |
| `ja` | **68** | `このメニューを韓国語にする` |
| `ko` | **61** | `이 메뉴를 영어로` |
| `ko` | **62** | `이 메뉴를 번체 중국어로` |
| `ko` | **63** | `이 메뉴를 스페인어로` |
| `ko` | **64** | `이 메뉴를 프랑스어로` |
| `ko` | **65** | `이 메뉴를 독일어로` |
| `ko` | **66** | `이 메뉴를 간체 중국어로` |
| `ko` | **67** | `이 메뉴를 일본어로` |
| `ko` | **68** | `이 메뉴를 한국어로` |

Choose-prompt. Every source string ends with one space. The samples omit it.

| Code | Source string |
|------|----------------|
| `en` | `Choose a number, or type the command name: ` |
| `zh-Hant` | `請輸入編號，或輸入指令名稱： ` |
| `es` | `Elija un número, o escriba el nombre del comando: ` |
| `fr` | `Choisissez un numéro, ou saisissez le nom de la commande : ` |
| `de` | `Wählen Sie eine Nummer, oder geben Sie den Befehlsnamen ein: ` |
| `zh-Hans` | `请输入编号，或输入指令名称： ` |
| `ja` | `番号を入力するか、コマンド名を入力してください: ` |
| `ko` | `번호를 입력하거나 명령 이름을 입력하세요: ` |

Menu-hidden sentences. The client line is the Termux / Git Bash / Windows cmd cause on the client board. The server line is the POSIX Linux non-root cause on the server board. Front **7** still has no sentence.

| Code | Client hide | Server hide |
|------|-------------|-------------|
| `en` | `backup-config and sync-config not available for ${_mt_extra}` | `start/stop/restart sshd features are not available for non-root in ${_mt_extra}` |
| `zh-Hant` | `backup-config 與 sync-config 不適用於 ${_mt_extra}` | `非 root 在 ${_mt_extra} 無法使用 start/stop/restart sshd` |
| `es` | `backup-config y sync-config no están disponibles para ${_mt_extra}` | `las funciones start/stop/restart sshd no están disponibles sin root en ${_mt_extra}` |
| `fr` | `backup-config et sync-config ne sont pas disponibles pour ${_mt_extra}` | `les fonctions start/stop/restart sshd ne sont pas disponibles hors root sur ${_mt_extra}` |
| `de` | `backup-config und sync-config sind nicht verfügbar für ${_mt_extra}` | `start/stop/restart sshd ist ohne root auf ${_mt_extra} nicht verfügbar` |
| `zh-Hans` | `backup-config 与 sync-config 不适用于 ${_mt_extra}` | `非 root 在 ${_mt_extra} 无法使用 start/stop/restart sshd` |
| `ja` | `backup-config と sync-config は ${_mt_extra} では使えません` | `root 以外は ${_mt_extra} で start/stop/restart sshd を使えません` |
| `ko` | `backup-config 와 sync-config 는 ${_mt_extra} 에서 사용할 수 없습니다` | `root가 아니면 ${_mt_extra} 에서 start/stop/restart sshd 를 사용할 수 없습니다` |

Unknown-choice warn. `${_mt_extra}` is the typed token, inside single quotes in the sentence.

| Code | Menu | Sudoers |
|------|------|---------|
| `en` | `Unknown menu choice '${_mt_extra}'. Choose a number from the list, or type the command name.` | `Unknown sudoers choice '${_mt_extra}'. Choose a number from the list, or type the command name.` |
| `zh-Hant` | `未知的選單選項 '${_mt_extra}'。請從清單選擇編號，或輸入指令名稱。` | `未知的 sudoers 選項 '${_mt_extra}'。請從清單選擇編號，或輸入指令名稱。` |
| `es` | `Opción de menú desconocida '${_mt_extra}'. Elija un número de la lista, o escriba el nombre del comando.` | `Opción de sudoers desconocida '${_mt_extra}'. Elija un número de la lista, o escriba el nombre del comando.` |
| `fr` | `Choix de menu inconnu '${_mt_extra}'. Choisissez un numéro dans la liste, ou saisissez le nom de la commande.` | `Choix sudoers inconnu '${_mt_extra}'. Choisissez un numéro dans la liste, ou saisissez le nom de la commande.` |
| `de` | `Unbekannte Menüauswahl '${_mt_extra}'. Wählen Sie eine Nummer aus der Liste, oder geben Sie den Befehlsnamen ein.` | `Unbekannte sudoers-Auswahl '${_mt_extra}'. Wählen Sie eine Nummer aus der Liste, oder geben Sie den Befehlsnamen ein.` |
| `zh-Hans` | `未知的菜单选项 '${_mt_extra}'。请从清单选择编号，或输入指令名称。` | `未知的 sudoers 选项 '${_mt_extra}'。请从清单选择编号，或输入指令名称。` |
| `ja` | `未知のメニュー選択 '${_mt_extra}'。一覧の番号を選ぶか、コマンド名を入力してください。` | `未知の sudoers 選択 '${_mt_extra}'。一覧の番号を選ぶか、コマンド名を入力してください。` |
| `ko` | `알 수 없는 메뉴 선택 '${_mt_extra}'. 목록의 번호를 고르거나 명령 이름을 입력하세요.` | `알 수 없는 sudoers 선택 '${_mt_extra}'. 목록의 번호를 고르거나 명령 이름을 입력하세요.` |

Sudoers header after the program name, and row **71** long. The short stays `generate-sudoer-request`. Row **71** stays a `case` arm inside `sshd_cmd_sudoers_menu`, not inside `app_menu_text`.

| Code | Header | Row **71** long |
|------|--------|-----------------|
| `en` | `sudoers (grant and drafts)` | `Write a JSON grant you can read` |
| `zh-Hant` | `sudoers（免密碼授權與草稿）` | `寫一份可閱讀的 JSON 授權` |
| `es` | `sudoers (concesión y borradores)` | `Escribe una concesión JSON que se puede leer` |
| `fr` | `sudoers (autorisation et brouillons)` | `Écrire une autorisation JSON lisible` |
| `de` | `sudoers (Freigabe und Entwürfe)` | `Eine lesbare JSON-Freigabe schreiben` |
| `zh-Hans` | `sudoers（免密码授权与草稿）` | `写一份可阅读的 JSON 授权` |
| `ja` | `sudoers（パスワードなしの認可と下書き）` | `読める JSON 認可を書く` |
| `ko` | `sudoers(비밀번호 없는 허가와 초안)` | `읽을 수 있는 JSON 허가를 작성` |

Help and about lines that stay `case` arms because the English sentence contains the letters r, e, a, d in a row. The `--json` note does not, and it goes through `app_menu_text`.

| Code | Help when `--json` | `--json` flag line | About `--json` line |
|------|--------------------|--------------------|---------------------|
| `en` | `Help text available in human-readable mode. Run without --json.` | `Machine-readable JSON (implies --quiet)` | `Machine-readable output` |
| `zh-Hant` | `說明文字在人類可讀模式。請不要加 --json。` | `機器可處理的 JSON（同時視為 --quiet）` | `機器可處理的輸出` |
| `es` | `El texto de ayuda está en el modo para personas. Ejecute sin --json.` | `JSON para máquinas (implica --quiet)` | `salida para máquinas` |
| `fr` | `Le texte d'aide est dans le mode pour les personnes. Lancez sans --json.` | `JSON pour les machines (implique --quiet)` | `sortie pour les machines` |
| `de` | `Der Hilfetext steht im Modus für Menschen. Starten Sie ohne --json.` | `JSON für Maschinen (schließt --quiet ein)` | `Ausgabe für Maschinen` |
| `zh-Hans` | `说明文字在人可读模式。请不要加 --json。` | `机器可处理的 JSON（同时视为 --quiet）` | `机器可处理的输出` |
| `ja` | `説明は人が読むモードにあります。--json を付けずに実行してください。` | `機械向け JSON（--quiet を含む）` | `機械向けの出力` |
| `ko` | `도움말 문장은 사람이 읽는 모드에 있습니다. --json 없이 실행하세요.` | `기계용 JSON(--quiet 포함)` | `기계용 출력` |

The `--json` note and the cache label. English, Spanish, French, German, Japanese, and Korean cache labels end with a space. The two Chinese labels end on the fullwidth colon.

| Code | `--json` note | Cache label |
|------|----------------|-------------|
| `en` | `Use --json with version, about, version-check, install, self-install, self-update, self-uninstall, rc-test.` | `Cache folder used: ` |
| `zh-Hant` | `請把 --json 用在 version、about、version-check、install、self-install、self-update、self-uninstall、rc-test。` | `使用的快取資料夾：` |
| `es` | `Use --json con version, about, version-check, install, self-install, self-update, self-uninstall, rc-test.` | `Carpeta de caché en uso: ` |
| `fr` | `Utilisez --json avec version, about, version-check, install, self-install, self-update, self-uninstall, rc-test.` | `Dossier de cache utilisé : ` |
| `de` | `--json mit version, about, version-check, install, self-install, self-update, self-uninstall, rc-test verwenden.` | `Verwendeter Cache-Ordner: ` |
| `zh-Hans` | `请把 --json 用在 version、about、version-check、install、self-install、self-update、self-uninstall、rc-test。` | `使用的缓存文件夹：` |
| `ja` | `--json は version、about、version-check、install、self-install、self-update、self-uninstall、rc-test と一緒に使う。` | `使用中のキャッシュフォルダ: ` |
| `ko` | `--json 은 version, about, version-check, install, self-install, self-update, self-uninstall, rc-test 와 함께 쓴다.` | `사용 중인 캐시 폴더: ` |

Every other human `help` and `about` sentence is the matching arm in the §2.6 `app_menu_text` fence. A change to a string listed in this section, or shown in §2.4.1, updates the fence and this section in the same revision. Command tokens, flags, paths, and env names stay the Latin spelling in every language.

### 2.5 Call shape

`app_lang_load`, `app_lang_save`, and `app_menu_text` do not contain `read`. A command substitution around them is allowed. `app_cmd_menu_language` contains `read -r` and **MUST** be called in the current shell from the front board’s language arm. **MUST NOT** wrap that function, or `read`, in `$()` or backticks. The same rule as `requirement-shell-cli-default-interaction` §2.2.4.

### 2.6 Ship-unit functions

These bodies are the current text of `./sshd-cli` (the same bytes as `src/sshd-cli`). Section 2 is the law.

#### `app_lang_load`

```sh
# Last updated: 2026-09-28
# ALIGNMENT: requirement-shell-cli-language.md · requirement-shell-cli-storage.md
# APP_LANG is en, zh-Hant, es, fr, de, zh-Hans, ja, or ko. Missing or unrecognized file stays en.
# SSHD_CLI_LANG wins over the file when it is one of those codes.
# One call at the start of app_main, after persistence is resolved.
# A later pick updates APP_LANG in this process; do not call this again
# in that process or the env value would cover the pick.
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
            en|zh-Hant|es|fr|de|zh-Hans|ja|ko) APP_LANG="${_ll_line}" ;;
        esac
    fi
    case "${SSHD_CLI_LANG-}" in
        en|zh-Hant|es|fr|de|zh-Hans|ja|ko) APP_LANG="${SSHD_CLI_LANG}" ;;
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
        en|zh-Hant|es|fr|de|zh-Hans|ja|ko) ;;
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
# Menu copy for APP_LANG (en, zh-Hant, es, fr, de, zh-Hans, ja, ko). Pure data. No input builtin.
# A missing key prints the key. Call from the current shell or a command
# substitution. Keep this body free of the four letters r, e, a, d in a row.
app_menu_text() {
    _mt_key=${1-}
    _mt_extra=${2-}
    _mt_lang=${APP_LANG:-en}
    case "${_mt_lang}" in
        zh-Hant|es|fr|de|zh-Hans|ja|ko) ;;
        *) _mt_lang=en ;;
    esac
    _mt_out=""
    case "${_mt_key}" in
        cat_client)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="用戶端" ;;
                es) _mt_out="cliente" ;;
                fr) _mt_out="client" ;;
                de) _mt_out="Client" ;;
                zh-Hans) _mt_out="客户端" ;;
                ja) _mt_out="クライアント" ;;
                ko) _mt_out="클라이언트" ;;
                *) _mt_out="client-side" ;;
            esac
            ;;
        cat_server)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="伺服器端" ;;
                es) _mt_out="servidor" ;;
                fr) _mt_out="serveur" ;;
                de) _mt_out="Server" ;;
                zh-Hans) _mt_out="服务器端" ;;
                ja) _mt_out="サーバー" ;;
                ko) _mt_out="서버" ;;
                *) _mt_out="server-side" ;;
            esac
            ;;
        cat_self)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="自我管理" ;;
                es) _mt_out="autogestión" ;;
                fr) _mt_out="autogestion" ;;
                de) _mt_out="Selbstverwaltung" ;;
                zh-Hans) _mt_out="自我管理" ;;
                ja) _mt_out="自己管理" ;;
                ko) _mt_out="자기관리" ;;
                *) _mt_out="self-management" ;;
            esac
            ;;
        cat_language)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="語言" ;;
                es) _mt_out="idioma" ;;
                fr) _mt_out="langue" ;;
                de) _mt_out="Sprache" ;;
                zh-Hans) _mt_out="语言" ;;
                ja) _mt_out="言語" ;;
                ko) _mt_out="언어" ;;
                *) _mt_out="language" ;;
            esac
            ;;
        front_client_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個登入的 OpenSSH 用戶端（~/.ssh/config、ssh、資料夾）" ;;
                es) _mt_out="cliente OpenSSH de este inicio (~/.ssh/config, ssh, carpetas)" ;;
                fr) _mt_out="client OpenSSH de cette session (~/.ssh/config, ssh, dossiers)" ;;
                de) _mt_out="OpenSSH-Client dieser Anmeldung (~/.ssh/config, ssh, Ordner)" ;;
                zh-Hans) _mt_out="这个登录的 OpenSSH 客户端（~/.ssh/config、ssh、文件夹）" ;;
                ja) _mt_out="このログインの OpenSSH クライアント（~/.ssh/config、ssh、フォルダ）" ;;
                ko) _mt_out="이 로그인의 OpenSSH 클라이언트(~/.ssh/config, ssh, 폴더)" ;;
                *) _mt_out="this login OpenSSH client (~/.ssh/config, ssh, folders)" ;;
            esac
            ;;
        front_server_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這台主機的 OpenSSH sshd（接聽、金鑰、連接埠）" ;;
                es) _mt_out="sshd OpenSSH de este equipo (escucha, claves, puerto)" ;;
                fr) _mt_out="sshd OpenSSH de cet hôte (écoute, clés, port)" ;;
                de) _mt_out="OpenSSH-sshd dieses Rechners (wartet, Schlüssel, Port)" ;;
                zh-Hans) _mt_out="这台主机的 OpenSSH sshd（监听、密钥、端口）" ;;
                ja) _mt_out="このホストの OpenSSH sshd（待ち受け、鍵、ポート）" ;;
                ko) _mt_out="이 호스트의 OpenSSH sshd(대기, 키, 포트)" ;;
                *) _mt_out="this host OpenSSH sshd (listen, keys, port)" ;;
            esac
            ;;
        front_language_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單的顯示語言" ;;
                es) _mt_out="idioma de este menú" ;;
                fr) _mt_out="langue d'affichage de ce menu" ;;
                de) _mt_out="Anzeigesprache dieses Menüs" ;;
                zh-Hans) _mt_out="这个菜单的显示语言" ;;
                ja) _mt_out="このメニューの表示言語" ;;
                ko) _mt_out="이 메뉴의 표시 언어" ;;
                *) _mt_out="display language for this menu" ;;
            esac
            ;;
        front_sudoers_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="免密碼 sudo 的授權與草稿" ;;
                es) _mt_out="concesión y borradores de sudo sin contraseña" ;;
                fr) _mt_out="autorisation et brouillons pour sudo sans mot de passe" ;;
                de) _mt_out="Freigabe und Entwürfe für sudo ohne Passwort" ;;
                zh-Hans) _mt_out="免密码 sudo 的授权与草稿" ;;
                ja) _mt_out="パスワードなし sudo の認可と下書き" ;;
                ko) _mt_out="비밀번호 없는 sudo의 허가와 초안" ;;
                *) _mt_out="grant and drafts for passwordless sudo" ;;
            esac
            ;;
        front_self_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個 CLI 的安裝、版本、更新、移除" ;;
                es) _mt_out="instalación, versión, actualización y desinstalación de este CLI" ;;
                fr) _mt_out="installation, version, mise à jour et retrait de ce CLI" ;;
                de) _mt_out="Installation, Version, Aktualisierung und Entfernen dieses CLI" ;;
                zh-Hans) _mt_out="这个 CLI 的安装、版本、更新、移除" ;;
                ja) _mt_out="この CLI のインストール、バージョン、更新、削除" ;;
                ko) _mt_out="이 CLI의 설치, 버전, 업데이트, 제거" ;;
                *) _mt_out="this CLI install, version, update, uninstall" ;;
            esac
            ;;
        client_11_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個登入的 ~/.ssh/config Host 清單" ;;
                es) _mt_out="lista Host de ~/.ssh/config de este inicio" ;;
                fr) _mt_out="liste Host de ~/.ssh/config pour cette session" ;;
                de) _mt_out="Host-Liste in ~/.ssh/config dieser Anmeldung" ;;
                zh-Hans) _mt_out="这个登录的 ~/.ssh/config Host 清单" ;;
                ja) _mt_out="このログインの ~/.ssh/config の Host 一覧" ;;
                ko) _mt_out="이 로그인의 ~/.ssh/config Host 목록" ;;
                *) _mt_out="this login ~/.ssh/config Host list" ;;
            esac
            ;;
        client_12_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="以這個登入的 ~/.ssh/config 連線到 Host" ;;
                es) _mt_out="cliente OpenSSH hacia un Host de ~/.ssh/config de este inicio" ;;
                fr) _mt_out="client OpenSSH vers un Host du ~/.ssh/config de cette session" ;;
                de) _mt_out="OpenSSH-Client zu einem Host aus ~/.ssh/config dieser Anmeldung" ;;
                zh-Hans) _mt_out="用这个登录的 ~/.ssh/config 连接到 Host" ;;
                ja) _mt_out="このログインの ~/.ssh/config の Host へ接続する OpenSSH クライアント" ;;
                ko) _mt_out="이 로그인의 ~/.ssh/config Host로 접속하는 OpenSSH 클라이언트" ;;
                *) _mt_out="OpenSSH client to a Host from this login ~/.ssh/config" ;;
            esac
            ;;
        client_13_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將遠端資料夾打包為 tar.gz 放到這個目錄" ;;
                es) _mt_out="empaquetar una carpeta remota en tar.gz en este directorio" ;;
                fr) _mt_out="placer un dossier distant en tar.gz dans ce répertoire" ;;
                de) _mt_out="einen fernen Ordner als tar.gz in dieses Verzeichnis holen" ;;
                zh-Hans) _mt_out="将远程文件夹打包为 tar.gz 放到这个目录" ;;
                ja) _mt_out="遠隔フォルダを tar.gz にしてこのディレクトリへ置く" ;;
                ko) _mt_out="원격 폴더를 tar.gz로 이 디렉터리에 받기" ;;
                *) _mt_out="tar.gz a remote folder into this directory" ;;
            esac
            ;;
        client_14_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將本機資料夾打包為 tar.gz 傳到 Host（在該 ssh 使用者家目錄解開）" ;;
                es) _mt_out="empaquetar una carpeta local en tar.gz hacia un Host (extraer en el home de ese usuario ssh)" ;;
                fr) _mt_out="envoyer un dossier local en tar.gz vers un Host (extraire dans le home de cet utilisateur ssh)" ;;
                de) _mt_out="einen lokalen Ordner als tar.gz auf einen Host legen (entpacken im Home dieses ssh-Benutzers)" ;;
                zh-Hans) _mt_out="将本机文件夹打包为 tar.gz 传到 Host（在该 ssh 用户主目录解开）" ;;
                ja) _mt_out="ローカルフォルダを tar.gz にして Host へ送る（その ssh ユーザーのホームで展開）" ;;
                ko) _mt_out="로컬 폴더를 tar.gz로 Host에 보내기(그 ssh 사용자 홈에서 풀기)" ;;
                *) _mt_out="tar.gz a local folder onto a Host (extract under that ssh user home)" ;;
            esac
            ;;
        client_15_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="把這個登入的 ~/.ssh/config 複製到 /var/sshd-cli" ;;
                es) _mt_out="copiar ~/.ssh/config de este inicio a /var/sshd-cli" ;;
                fr) _mt_out="copier le ~/.ssh/config de cette session vers /var/sshd-cli" ;;
                de) _mt_out="~/.ssh/config dieser Anmeldung nach /var/sshd-cli kopieren" ;;
                zh-Hans) _mt_out="把这个登录的 ~/.ssh/config 复制到 /var/sshd-cli" ;;
                ja) _mt_out="このログインの ~/.ssh/config を /var/sshd-cli へコピー" ;;
                ko) _mt_out="이 로그인의 ~/.ssh/config를 /var/sshd-cli로 복사" ;;
                *) _mt_out="copy this login ~/.ssh/config to /var/sshd-cli" ;;
            esac
            ;;
        client_16_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="把 /var/sshd-cli/config 複製進這個登入的 ~/.ssh/config" ;;
                es) _mt_out="copiar /var/sshd-cli/config en ~/.ssh/config de este inicio" ;;
                fr) _mt_out="copier /var/sshd-cli/config dans le ~/.ssh/config de cette session" ;;
                de) _mt_out="/var/sshd-cli/config in ~/.ssh/config dieser Anmeldung kopieren" ;;
                zh-Hans) _mt_out="把 /var/sshd-cli/config 复制进这个登录的 ~/.ssh/config" ;;
                ja) _mt_out="/var/sshd-cli/config をこのログインの ~/.ssh/config へコピー" ;;
                ko) _mt_out="/var/sshd-cli/config를 이 로그인의 ~/.ssh/config로 복사" ;;
                *) _mt_out="copy /var/sshd-cli/config into this login ~/.ssh/config" ;;
            esac
            ;;
        client_18_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="從 user@host（或 host）複製 /var/sshd-cli/config" ;;
                es) _mt_out="copiar /var/sshd-cli/config desde user@host (o host)" ;;
                fr) _mt_out="copier /var/sshd-cli/config depuis user@host (ou host)" ;;
                de) _mt_out="/var/sshd-cli/config von user@host (oder host) kopieren" ;;
                zh-Hans) _mt_out="从 user@host（或 host）复制 /var/sshd-cli/config" ;;
                ja) _mt_out="user@host（または host）から /var/sshd-cli/config をコピー" ;;
                ko) _mt_out="user@host(또는 host)에서 /var/sshd-cli/config 복사" ;;
                *) _mt_out="copy /var/sshd-cli/config from user@host (or host)" ;;
            esac
            ;;
        hint_sync_typed)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="   （或輸入 sync-from-remote [user@host]：從另一台主機複製 /var/sshd-cli/config）" ;;
                es) _mt_out="   (o escriba sync-from-remote [user@host]: copiar /var/sshd-cli/config desde otro equipo)" ;;
                fr) _mt_out="   (ou saisissez sync-from-remote [user@host] : copier /var/sshd-cli/config depuis un autre hôte)" ;;
                de) _mt_out="   (oder sync-from-remote [user@host] eingeben: /var/sshd-cli/config von einem anderen Rechner kopieren)" ;;
                zh-Hans) _mt_out="   （或输入 sync-from-remote [user@host]：从另一台主机复制 /var/sshd-cli/config）" ;;
                ja) _mt_out="   （または sync-from-remote [user@host] と入力: 別のホストから /var/sshd-cli/config をコピー）" ;;
                ko) _mt_out="   (또는 sync-from-remote [user@host] 입력: 다른 호스트에서 /var/sshd-cli/config 복사)" ;;
                *) _mt_out="   (or type sync-from-remote [user@host]: copy /var/sshd-cli/config from another host)" ;;
            esac
            ;;
        server_21_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="執行狀態、連接埠與路徑" ;;
                es) _mt_out="estado, puerto y rutas" ;;
                fr) _mt_out="état, port et chemins" ;;
                de) _mt_out="Laufzustand, Port und Pfade" ;;
                zh-Hans) _mt_out="运行状态、端口与路径" ;;
                ja) _mt_out="実行状態、ポート、パス" ;;
                ko) _mt_out="실행 상태, 포트, 경로" ;;
                *) _mt_out="running, port, and paths" ;;
            esac
            ;;
        server_22_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="啟動 OpenSSH 常駐程式（背景執行，不是開機服務）" ;;
                es) _mt_out="iniciar el demonio OpenSSH (en segundo plano, no como servicio de arranque)" ;;
                fr) _mt_out="lancer le démon OpenSSH (en arrière-plan, pas un service de démarrage)" ;;
                de) _mt_out="OpenSSH-Daemon starten (im Hintergrund, kein Startdienst)" ;;
                zh-Hans) _mt_out="启动 OpenSSH 常驻程序（后台运行，不是开机服务）" ;;
                ja) _mt_out="OpenSSH デーモンを起動（バックグラウンド。起動時サービスではない）" ;;
                ko) _mt_out="OpenSSH 데몬 시작(백그라운드, 부팅 서비스 아님)" ;;
                *) _mt_out="launch the OpenSSH daemon (background, not a boot service)" ;;
            esac
            ;;
        server_23_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="結束正在執行的常駐程式" ;;
                es) _mt_out="terminar el demonio en ejecución" ;;
                fr) _mt_out="arrêter le démon en cours" ;;
                de) _mt_out="den laufenden Daemon beenden" ;;
                zh-Hans) _mt_out="结束正在运行的常驻程序" ;;
                ja) _mt_out="実行中のデーモンを終了" ;;
                ko) _mt_out="실행 중인 데몬 종료" ;;
                *) _mt_out="end the running daemon" ;;
            esac
            ;;
        server_24_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="先停止再啟動" ;;
                es) _mt_out="detener y luego iniciar" ;;
                fr) _mt_out="arrêter puis lancer" ;;
                de) _mt_out="stoppen und dann starten" ;;
                zh-Hans) _mt_out="先停止再启动" ;;
                ja) _mt_out="停止してから起動" ;;
                ko) _mt_out="중지한 다음 시작" ;;
                *) _mt_out="stop then start" ;;
            esac
            ;;
        self_81_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="放置 ${APP_NAME}；確保 rc 與 Termux 的 openssh/termux-auth；啟動 sshd" ;;
                es) _mt_out="colocar ${APP_NAME}; asegurar rc y openssh/termux-auth de Termux; iniciar sshd" ;;
                fr) _mt_out="placer ${APP_NAME} ; assurer rc et openssh/termux-auth de Termux ; lancer sshd" ;;
                de) _mt_out="${APP_NAME} ablegen; rc und Termux openssh/termux-auth sicherstellen; sshd starten" ;;
                zh-Hans) _mt_out="放置 ${APP_NAME}；确保 rc 与 Termux 的 openssh/termux-auth；启动 sshd" ;;
                ja) _mt_out="${APP_NAME} を配置；rc と Termux の openssh/termux-auth を整え；sshd を起動" ;;
                ko) _mt_out="${APP_NAME} 배치; rc와 Termux openssh/termux-auth 확보; sshd 시작" ;;
                *) _mt_out="place ${APP_NAME}; ensure rc + Termux openssh/termux-auth; start sshd" ;;
            esac
            ;;
        self_82_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示版本與詳細診斷（about）" ;;
                es) _mt_out="mostrar la versión y el diagnóstico detallado (about)" ;;
                fr) _mt_out="afficher la version et le diagnostic détaillé (about)" ;;
                de) _mt_out="Version und ausführliche Diagnose anzeigen (about)" ;;
                zh-Hans) _mt_out="显示版本与详细诊断（about）" ;;
                ja) _mt_out="バージョンと詳細な診断を表示（about）" ;;
                ko) _mt_out="버전과 자세한 진단 표시(about)" ;;
                *) _mt_out="show version and detailed diagnostics (about)" ;;
            esac
            ;;
        self_83_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示詳細診斷" ;;
                es) _mt_out="mostrar el diagnóstico detallado" ;;
                fr) _mt_out="afficher le diagnostic détaillé" ;;
                de) _mt_out="ausführliche Diagnose anzeigen" ;;
                zh-Hans) _mt_out="显示详细诊断" ;;
                ja) _mt_out="詳細な診断を表示" ;;
                ko) _mt_out="자세한 진단 표시" ;;
                *) _mt_out="show detailed diagnostics" ;;
            esac
            ;;
        self_84_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="比較本機與遠端版本" ;;
                es) _mt_out="comparar la versión local con la remota" ;;
                fr) _mt_out="comparer la version locale et la version distante" ;;
                de) _mt_out="lokale und ferne Version vergleichen" ;;
                zh-Hans) _mt_out="比较本机与远程版本" ;;
                ja) _mt_out="ローカルと遠隔のバージョンを比較" ;;
                ko) _mt_out="로컬과 원격 버전 비교" ;;
                *) _mt_out="compare local vs remote version" ;;
            esac
            ;;
        self_85_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將 ${APP_NAME} 更新到較新的遠端版本" ;;
                es) _mt_out="actualizar ${APP_NAME} a una versión remota más nueva" ;;
                fr) _mt_out="mettre ${APP_NAME} à jour vers une version distante plus récente" ;;
                de) _mt_out="${APP_NAME} auf eine neuere ferne Version aktualisieren" ;;
                zh-Hans) _mt_out="将 ${APP_NAME} 更新到较新的远程版本" ;;
                ja) _mt_out="${APP_NAME} を新しい遠隔バージョンへ更新" ;;
                ko) _mt_out="${APP_NAME}를 더 새로운 원격 버전으로 업데이트" ;;
                *) _mt_out="update ${APP_NAME} to a newer remote version" ;;
            esac
            ;;
        self_86_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="移除 ${APP_NAME}（安全清理 PATH）" ;;
                es) _mt_out="quitar ${APP_NAME} (limpieza segura de PATH)" ;;
                fr) _mt_out="retirer ${APP_NAME} (nettoyage sûr de PATH)" ;;
                de) _mt_out="${APP_NAME} entfernen (sicheres Aufräumen von PATH)" ;;
                zh-Hans) _mt_out="移除 ${APP_NAME}（安全清理 PATH）" ;;
                ja) _mt_out="${APP_NAME} を削除（PATH を安全に整理）" ;;
                ko) _mt_out="${APP_NAME} 제거(PATH를 안전하게 정리)" ;;
                *) _mt_out="remove ${APP_NAME} (safe PATH cleanup)" ;;
            esac
            ;;
        self_87_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="只放置這個 CLI（複製這個檔案，或在管線輸入時下載）" ;;
                es) _mt_out="colocar solo este CLI (copiar este archivo, o descargar si llega por una tubería)" ;;
                fr) _mt_out="placer seulement ce CLI (copier ce fichier, ou télécharger s'il arrive dans un tube)" ;;
                de) _mt_out="nur dieses CLI ablegen (diese Datei kopieren, oder laden wenn sie in einer Pipe ankommt)" ;;
                zh-Hans) _mt_out="只放置这个 CLI（复制这个文件，或在管道输入时下载）" ;;
                ja) _mt_out="この CLI だけを配置（このファイルをコピー、またはパイプで届いたとき取り込む）" ;;
                ko) _mt_out="이 CLI만 배치(이 파일을 복사하거나, 파이프로 들어올 때 가져오기)" ;;
                *) _mt_out="place this CLI only (copy this file, or download when piped)" ;;
            esac
            ;;
        line_back)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="0. 返回" ;;
                es) _mt_out="0. Atrás" ;;
                fr) _mt_out="0. Retour" ;;
                de) _mt_out="0. Zurück" ;;
                zh-Hans) _mt_out="0. 返回" ;;
                ja) _mt_out="0. 戻る" ;;
                ko) _mt_out="0. 뒤로" ;;
                *) _mt_out="0. Back" ;;
            esac
            ;;
        line_exit)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="9. 離開" ;;
                es) _mt_out="9. Salir" ;;
                fr) _mt_out="9. Quitter" ;;
                de) _mt_out="9. Beenden" ;;
                zh-Hans) _mt_out="9. 离开" ;;
                ja) _mt_out="9. 終了" ;;
                ko) _mt_out="9. 종료" ;;
                *) _mt_out="9. Exit" ;;
            esac
            ;;
        line_prompt)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="請輸入編號，或輸入指令名稱： " ;;
                es) _mt_out="Elija un número, o escriba el nombre del comando: " ;;
                fr) _mt_out="Choisissez un numéro, ou saisissez le nom de la commande : " ;;
                de) _mt_out="Wählen Sie eine Nummer, oder geben Sie den Befehlsnamen ein: " ;;
                zh-Hans) _mt_out="请输入编号，或输入指令名称： " ;;
                ja) _mt_out="番号を入力するか、コマンド名を入力してください: " ;;
                ko) _mt_out="번호를 입력하거나 명령 이름을 입력하세요: " ;;
                *) _mt_out="Choose a number, or type the command name: " ;;
            esac
            ;;
        lang_en_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用英文" ;;
                es) _mt_out="usar inglés en este menú" ;;
                fr) _mt_out="utiliser l'anglais pour ce menu" ;;
                de) _mt_out="Englisch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用英文" ;;
                ja) _mt_out="このメニューを英語にする" ;;
                ko) _mt_out="이 메뉴를 영어로" ;;
                *) _mt_out="use English for this menu" ;;
            esac
            ;;
        lang_zh_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用繁體中文" ;;
                es) _mt_out="usar chino tradicional en este menú" ;;
                fr) _mt_out="utiliser le chinois traditionnel pour ce menu" ;;
                de) _mt_out="Traditionelles Chinesisch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用繁体中文" ;;
                ja) _mt_out="このメニューを繁体字中国語にする" ;;
                ko) _mt_out="이 메뉴를 번체 중국어로" ;;
                *) _mt_out="use Traditional Chinese for this menu" ;;
            esac
            ;;
        lang_es_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用西班牙文" ;;
                es) _mt_out="usar español en este menú" ;;
                fr) _mt_out="utiliser l'espagnol pour ce menu" ;;
                de) _mt_out="Spanisch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用西班牙文" ;;
                ja) _mt_out="このメニューをスペイン語にする" ;;
                ko) _mt_out="이 메뉴를 스페인어로" ;;
                *) _mt_out="use Spanish for this menu" ;;
            esac
            ;;
        lang_fr_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用法文" ;;
                es) _mt_out="usar francés en este menú" ;;
                fr) _mt_out="utiliser le français pour ce menu" ;;
                de) _mt_out="Französisch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用法文" ;;
                ja) _mt_out="このメニューをフランス語にする" ;;
                ko) _mt_out="이 메뉴를 프랑스어로" ;;
                *) _mt_out="use French for this menu" ;;
            esac
            ;;
        lang_de_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用德文" ;;
                es) _mt_out="usar alemán en este menú" ;;
                fr) _mt_out="utiliser l'allemand pour ce menu" ;;
                de) _mt_out="Deutsch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用德文" ;;
                ja) _mt_out="このメニューをドイツ語にする" ;;
                ko) _mt_out="이 메뉴를 독일어로" ;;
                *) _mt_out="use German for this menu" ;;
            esac
            ;;
        lang_zh_hans_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用簡體中文" ;;
                es) _mt_out="usar chino simplificado en este menú" ;;
                fr) _mt_out="utiliser le chinois simplifié pour ce menu" ;;
                de) _mt_out="Vereinfachtes Chinesisch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用简体中文" ;;
                ja) _mt_out="このメニューを簡体字中国語にする" ;;
                ko) _mt_out="이 메뉴를 간체 중국어로" ;;
                *) _mt_out="use Simplified Chinese for this menu" ;;
            esac
            ;;
        lang_saved)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="選單語言是繁體中文" ;;
                es) _mt_out="El idioma del menú es español" ;;
                fr) _mt_out="La langue du menu est le français" ;;
                de) _mt_out="Die Menüsprache ist Deutsch" ;;
                zh-Hans) _mt_out="菜单语言是简体中文" ;;
                ja) _mt_out="メニューの言語は日本語" ;;
                ko) _mt_out="메뉴 언어는 한국어" ;;
                *) _mt_out="Menu language is English" ;;
            esac
            ;;
        lang_save_fail)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="無法儲存選單語言" ;;
                es) _mt_out="No se pudo guardar el idioma del menú" ;;
                fr) _mt_out="Impossible d'enregistrer la langue du menu" ;;
                de) _mt_out="Die Menüsprache konnte nicht gespeichert werden" ;;
                zh-Hans) _mt_out="无法保存菜单语言" ;;
                ja) _mt_out="メニューの言語を保存できませんでした" ;;
                ko) _mt_out="메뉴 언어를 저장하지 못했습니다" ;;
                *) _mt_out="Could not save the menu language" ;;
            esac
            ;;
        sudoers_header)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sudoers（免密碼授權與草稿）" ;;
                es) _mt_out="sudoers (concesión y borradores)" ;;
                fr) _mt_out="sudoers (autorisation et brouillons)" ;;
                de) _mt_out="sudoers (Freigabe und Entwürfe)" ;;
                zh-Hans) _mt_out="sudoers（免密码授权与草稿）" ;;
                ja) _mt_out="sudoers（パスワードなしの認可と下書き）" ;;
                ko) _mt_out="sudoers(비밀번호 없는 허가와 초안)" ;;
                *) _mt_out="sudoers (grant and drafts)" ;;
            esac
            ;;
        sudoers_72_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將 JSON 授權排入待處理佇列" ;;
                es) _mt_out="poner la concesión JSON en la cola de entrada" ;;
                fr) _mt_out="mettre l'autorisation JSON dans la file d'entrée" ;;
                de) _mt_out="die JSON-Freigabe in die Eingangs-Warteschlange legen" ;;
                zh-Hans) _mt_out="将 JSON 授权排入待处理队列" ;;
                ja) _mt_out="JSON 認可を受信待ちへ入れる" ;;
                ko) _mt_out="JSON 허가를 수신 대기열에 넣기" ;;
                *) _mt_out="Queue the JSON grant inbound" ;;
            esac
            ;;
        sudoers_73_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="輸出 sudoers 草稿" ;;
                es) _mt_out="emitir el borrador sudoers" ;;
                fr) _mt_out="émettre le brouillon sudoers" ;;
                de) _mt_out="sudoers-Entwurf ausgeben" ;;
                zh-Hans) _mt_out="输出 sudoers 草稿" ;;
                ja) _mt_out="sudoers 下書きを出力" ;;
                ko) _mt_out="sudoers 초안 출력" ;;
                *) _mt_out="Emit sudoers draft" ;;
            esac
            ;;
        sudoers_74_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="寫出管理者安裝腳本" ;;
                es) _mt_out="escribir el script de instalación del administrador" ;;
                fr) _mt_out="écrire le script d'installation pour l'administrateur" ;;
                de) _mt_out="Installationsskript für die Verwaltung schreiben" ;;
                zh-Hans) _mt_out="写出管理者安装脚本" ;;
                ja) _mt_out="管理者向けインストールスクリプトを書く" ;;
                ko) _mt_out="관리자 설치 스크립트 작성" ;;
                *) _mt_out="Write admin install script" ;;
            esac
            ;;
        sudoers_75_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="只移除 sudoers 草稿" ;;
                es) _mt_out="quitar solo el borrador sudoers" ;;
                fr) _mt_out="retirer seulement le brouillon sudoers" ;;
                de) _mt_out="nur den sudoers-Entwurf entfernen" ;;
                zh-Hans) _mt_out="只移除 sudoers 草稿" ;;
                ja) _mt_out="sudoers 下書きだけを削除" ;;
                ko) _mt_out="sudoers 초안만 제거" ;;
                *) _mt_out="Remove sudoers draft only" ;;
            esac
            ;;
        hidden_client)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="backup-config 與 sync-config 不適用於 ${_mt_extra}" ;;
                es) _mt_out="backup-config y sync-config no están disponibles para ${_mt_extra}" ;;
                fr) _mt_out="backup-config et sync-config ne sont pas disponibles pour ${_mt_extra}" ;;
                de) _mt_out="backup-config und sync-config sind nicht verfügbar für ${_mt_extra}" ;;
                zh-Hans) _mt_out="backup-config 与 sync-config 不适用于 ${_mt_extra}" ;;
                ja) _mt_out="backup-config と sync-config は ${_mt_extra} では使えません" ;;
                ko) _mt_out="backup-config 와 sync-config 는 ${_mt_extra} 에서 사용할 수 없습니다" ;;
                *) _mt_out="backup-config and sync-config not available for ${_mt_extra}" ;;
            esac
            ;;
        hidden_server)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="非 root 在 ${_mt_extra} 無法使用 start/stop/restart sshd" ;;
                es) _mt_out="las funciones start/stop/restart sshd no están disponibles sin root en ${_mt_extra}" ;;
                fr) _mt_out="les fonctions start/stop/restart sshd ne sont pas disponibles hors root sur ${_mt_extra}" ;;
                de) _mt_out="start/stop/restart sshd ist ohne root auf ${_mt_extra} nicht verfügbar" ;;
                zh-Hans) _mt_out="非 root 在 ${_mt_extra} 无法使用 start/stop/restart sshd" ;;
                ja) _mt_out="root 以外は ${_mt_extra} で start/stop/restart sshd を使えません" ;;
                ko) _mt_out="root가 아니면 ${_mt_extra} 에서 start/stop/restart sshd 를 사용할 수 없습니다" ;;
                *) _mt_out="start/stop/restart sshd features are not available for non-root in ${_mt_extra}" ;;
            esac
            ;;
        unknown_menu)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="未知的選單選項 '${_mt_extra}'。請從清單選擇編號，或輸入指令名稱。" ;;
                es) _mt_out="Opción de menú desconocida '${_mt_extra}'. Elija un número de la lista, o escriba el nombre del comando." ;;
                fr) _mt_out="Choix de menu inconnu '${_mt_extra}'. Choisissez un numéro dans la liste, ou saisissez le nom de la commande." ;;
                de) _mt_out="Unbekannte Menüauswahl '${_mt_extra}'. Wählen Sie eine Nummer aus der Liste, oder geben Sie den Befehlsnamen ein." ;;
                zh-Hans) _mt_out="未知的菜单选项 '${_mt_extra}'。请从清单选择编号，或输入指令名称。" ;;
                ja) _mt_out="未知のメニュー選択 '${_mt_extra}'。一覧の番号を選ぶか、コマンド名を入力してください。" ;;
                ko) _mt_out="알 수 없는 메뉴 선택 '${_mt_extra}'. 목록의 번호를 고르거나 명령 이름을 입력하세요." ;;
                *) _mt_out="Unknown menu choice '${_mt_extra}'. Choose a number from the list, or type the command name." ;;
            esac
            ;;
        unknown_sudoers)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="未知的 sudoers 選項 '${_mt_extra}'。請從清單選擇編號，或輸入指令名稱。" ;;
                es) _mt_out="Opción de sudoers desconocida '${_mt_extra}'. Elija un número de la lista, o escriba el nombre del comando." ;;
                fr) _mt_out="Choix sudoers inconnu '${_mt_extra}'. Choisissez un numéro dans la liste, ou saisissez le nom de la commande." ;;
                de) _mt_out="Unbekannte sudoers-Auswahl '${_mt_extra}'. Wählen Sie eine Nummer aus der Liste, oder geben Sie den Befehlsnamen ein." ;;
                zh-Hans) _mt_out="未知的 sudoers 选项 '${_mt_extra}'。请从清单选择编号，或输入指令名称。" ;;
                ja) _mt_out="未知の sudoers 選択 '${_mt_extra}'。一覧の番号を選ぶか、コマンド名を入力してください。" ;;
                ko) _mt_out="알 수 없는 sudoers 선택 '${_mt_extra}'. 목록의 번호를 고르거나 명령 이름을 입력하세요." ;;
                *) _mt_out="Unknown sudoers choice '${_mt_extra}'. Choose a number from the list, or type the command name." ;;
            esac
            ;;
        lang_ja_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用日文" ;;
                es) _mt_out="usar japonés en este menú" ;;
                fr) _mt_out="utiliser le japonais pour ce menu" ;;
                de) _mt_out="Japanisch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用日文" ;;
                ja) _mt_out="このメニューを日本語にする" ;;
                ko) _mt_out="이 메뉴를 일본어로" ;;
                *) _mt_out="use Japanese for this menu" ;;
            esac
            ;;
        lang_ko_long)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個選單改用韓文" ;;
                es) _mt_out="usar coreano en este menú" ;;
                fr) _mt_out="utiliser le coréen pour ce menu" ;;
                de) _mt_out="Koreanisch für dieses Menü verwenden" ;;
                zh-Hans) _mt_out="这个菜单改用韩文" ;;
                ja) _mt_out="このメニューを韓国語にする" ;;
                ko) _mt_out="이 메뉴를 한국어로" ;;
                *) _mt_out="use Korean for this menu" ;;
            esac
            ;;
        help_short)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="簡化 Termux 安裝 sshd" ;;
                es) _mt_out="simplificar la instalación de sshd en Termux" ;;
                fr) _mt_out="simplifier l'installation de sshd sur Termux" ;;
                de) _mt_out="sshd auf Termux einfach installieren" ;;
                zh-Hans) _mt_out="简化 Termux 安装 sshd" ;;
                ja) _mt_out="Termux で sshd を簡単に導入する" ;;
                ko) _mt_out="Termux에서 sshd 설치를 단순하게" ;;
                *) _mt_out="Simplify Termux to install sshd" ;;
            esac
            ;;
        help_desc)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="POSIX /bin/sh CLI：簡化 Termux 安裝並執行 OpenSSH sshd（status/start/stop/port/keys/dns），以及 self-install；Linux 主機上 ~/.ssh/config 的存放（backup-config / sync-config / sync-from-remote）。" ;;
                es) _mt_out="CLI POSIX /bin/sh: simplifica instalar y ejecutar OpenSSH sshd en Termux (status/start/stop/port/keys/dns) y self-install; depósito en el host Linux de ~/.ssh/config (backup-config / sync-config / sync-from-remote)." ;;
                fr) _mt_out="CLI POSIX /bin/sh : simplifier l'installation et l'exécution d'OpenSSH sshd sur Termux (status/start/stop/port/keys/dns), plus self-install ; dépôt sur l'hôte Linux de ~/.ssh/config (backup-config / sync-config / sync-from-remote)." ;;
                de) _mt_out="POSIX /bin/sh CLI: OpenSSH sshd auf Termux installieren und starten (status/start/stop/port/keys/dns) sowie self-install; Ablage von ~/.ssh/config auf dem Linux-Host (backup-config / sync-config / sync-from-remote)." ;;
                zh-Hans) _mt_out="POSIX /bin/sh CLI：简化 Termux 安装并运行 OpenSSH sshd（status/start/stop/port/keys/dns），以及 self-install；Linux 主机上 ~/.ssh/config 的存放（backup-config / sync-config / sync-from-remote）。" ;;
                ja) _mt_out="POSIX /bin/sh CLI。Termux で OpenSSH sshd を導入して動かす（status/start/stop/port/keys/dns）ほか self-install。Linux ホストへ ~/.ssh/config を預ける（backup-config / sync-config / sync-from-remote）。" ;;
                ko) _mt_out="POSIX /bin/sh CLI. Termux에서 OpenSSH sshd를 설치하고 실행(status/start/stop/port/keys/dns)하며 self-install. Linux 호스트에 ~/.ssh/config를 맡김(backup-config / sync-config / sync-from-remote)." ;;
                *) _mt_out="POSIX /bin/sh CLI: simplify Termux to install and run OpenSSH sshd (status/start/stop/port/keys/dns) plus self-install; Linux host deposit of ~/.ssh/config (backup-config / sync-config / sync-from-remote)." ;;
            esac
            ;;
        help_h_usage)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="用法：" ;;
                es) _mt_out="Uso:" ;;
                fr) _mt_out="Utilisation :" ;;
                de) _mt_out="Verwendung:" ;;
                zh-Hans) _mt_out="用法：" ;;
                ja) _mt_out="使い方:" ;;
                ko) _mt_out="사용법:" ;;
                *) _mt_out="Usage:" ;;
            esac
            ;;
        help_usage_args)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="[命令] [選項]" ;;
                es) _mt_out="[comando] [opciones]" ;;
                fr) _mt_out="[commande] [options]" ;;
                de) _mt_out="[Befehl] [Optionen]" ;;
                zh-Hans) _mt_out="[命令] [选项]" ;;
                ja) _mt_out="[コマンド] [オプション]" ;;
                ko) _mt_out="[명령] [옵션]" ;;
                *) _mt_out="[command] [options]" ;;
            esac
            ;;
        help_h_self)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="自我管理（這個登入）：" ;;
                es) _mt_out="Autogestión (este inicio):" ;;
                fr) _mt_out="Autogestion (cette session) :" ;;
                de) _mt_out="Selbstverwaltung (diese Anmeldung):" ;;
                zh-Hans) _mt_out="自我管理（这个登录）：" ;;
                ja) _mt_out="自己管理（このログイン）:" ;;
                ko) _mt_out="자기관리(이 로그인):" ;;
                *) _mt_out="Self-management (this login):" ;;
            esac
            ;;
        help_self_install)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="只放置這個 CLI（以腳本執行時複製這個檔案；從管線傳入時下載）" ;;
                es) _mt_out="colocar solo este CLI (copiar este archivo si se ejecuta como script; descargar si llega por una tubería)" ;;
                fr) _mt_out="placer seulement ce CLI (copier ce fichier s'il est lancé comme script ; télécharger s'il arrive dans un tube)" ;;
                de) _mt_out="nur dieses CLI ablegen (diese Datei kopieren, wenn sie als Skript läuft; laden, wenn sie in einer Pipe ankommt)" ;;
                zh-Hans) _mt_out="只放置这个 CLI（作为脚本运行时复制这个文件；从管道传入时下载）" ;;
                ja) _mt_out="この CLI だけを配置（スクリプトとして実行したときはこのファイルをコピー、パイプで届いたときは取り込む）" ;;
                ko) _mt_out="이 CLI만 배치(스크립트로 실행하면 이 파일을 복사, 파이프로 오면 가져오기)" ;;
                *) _mt_out="Place this CLI only (copy this file when run as a script; download when piped)" ;;
            esac
            ;;
        help_install)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="確保 rc 與 Termux 的 openssh/termux-auth；啟動 sshd（payload）" ;;
                es) _mt_out="asegurar rc y openssh/termux-auth de Termux; iniciar sshd (payload)" ;;
                fr) _mt_out="assurer rc et openssh/termux-auth de Termux ; lancer sshd (payload)" ;;
                de) _mt_out="rc und Termux openssh/termux-auth sicherstellen; sshd starten (Nutzlast)" ;;
                zh-Hans) _mt_out="确保 rc 与 Termux 的 openssh/termux-auth；启动 sshd（payload）" ;;
                ja) _mt_out="rc と Termux の openssh/termux-auth を整えて sshd を起動（payload）" ;;
                ko) _mt_out="rc와 Termux openssh/termux-auth를 확보하고 sshd 시작(payload)" ;;
                *) _mt_out="Ensure rc + Termux openssh/termux-auth; start sshd (payload)" ;;
            esac
            ;;
        help_version)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示目前版本（TTY 選單 82 會執行 about）" ;;
                es) _mt_out="mostrar la versión actual (el menú TTY 82 ejecuta about)" ;;
                fr) _mt_out="afficher la version actuelle (le menu TTY 82 lance about)" ;;
                de) _mt_out="aktuelle Version anzeigen (TTY-Menü 82 führt about aus)" ;;
                zh-Hans) _mt_out="显示当前版本（TTY 菜单 82 会运行 about）" ;;
                ja) _mt_out="現在のバージョンを表示（TTY メニュー 82 は about を実行）" ;;
                ko) _mt_out="현재 버전 표시(TTY 메뉴 82는 about 실행)" ;;
                *) _mt_out="Show current version (TTY menu 82 runs about)" ;;
            esac
            ;;
        help_about)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示詳細診斷" ;;
                es) _mt_out="mostrar el diagnóstico detallado" ;;
                fr) _mt_out="afficher le diagnostic détaillé" ;;
                de) _mt_out="ausführliche Diagnose anzeigen" ;;
                zh-Hans) _mt_out="显示详细诊断" ;;
                ja) _mt_out="詳細な診断を表示" ;;
                ko) _mt_out="자세한 진단 표시" ;;
                *) _mt_out="Show detailed diagnostics" ;;
            esac
            ;;
        help_version_check)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="比較本機與遠端版本（需要 SCRIPT_URL）" ;;
                es) _mt_out="comparar la versión local con la remota (hace falta SCRIPT_URL)" ;;
                fr) _mt_out="comparer la version locale et la version distante (SCRIPT_URL requis)" ;;
                de) _mt_out="lokale und ferne Version vergleichen (SCRIPT_URL nötig)" ;;
                zh-Hans) _mt_out="比较本机与远程版本（需要 SCRIPT_URL）" ;;
                ja) _mt_out="ローカルと遠隔のバージョンを比較（SCRIPT_URL が必要）" ;;
                ko) _mt_out="로컬과 원격 버전 비교(SCRIPT_URL 필요)" ;;
                *) _mt_out="Compare local vs remote version (needs SCRIPT_URL)" ;;
            esac
            ;;
        help_self_update)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="將 ${APP_NAME} 更新到較新的遠端版本" ;;
                es) _mt_out="actualizar ${APP_NAME} a una versión remota más nueva" ;;
                fr) _mt_out="mettre ${APP_NAME} à jour vers une version distante plus récente" ;;
                de) _mt_out="${APP_NAME} auf eine neuere ferne Version aktualisieren" ;;
                zh-Hans) _mt_out="将 ${APP_NAME} 更新到较新的远程版本" ;;
                ja) _mt_out="${APP_NAME} を新しい遠隔バージョンへ更新" ;;
                ko) _mt_out="${APP_NAME}를 더 새로운 원격 버전으로 업데이트" ;;
                *) _mt_out="Update ${APP_NAME} to a newer remote version" ;;
            esac
            ;;
        help_self_uninstall)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="移除 ${APP_NAME}（安全清理 PATH）" ;;
                es) _mt_out="quitar ${APP_NAME} (limpieza segura de PATH)" ;;
                fr) _mt_out="retirer ${APP_NAME} (nettoyage sûr de PATH)" ;;
                de) _mt_out="${APP_NAME} entfernen (sicheres Aufräumen von PATH)" ;;
                zh-Hans) _mt_out="移除 ${APP_NAME}（安全清理 PATH）" ;;
                ja) _mt_out="${APP_NAME} を削除（PATH を安全に整理）" ;;
                ko) _mt_out="${APP_NAME} 제거(PATH를 안전하게 정리)" ;;
                *) _mt_out="Remove ${APP_NAME} (safe PATH cleanup)" ;;
            esac
            ;;
        help_help)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示這份說明" ;;
                es) _mt_out="mostrar esta ayuda" ;;
                fr) _mt_out="afficher cette aide" ;;
                de) _mt_out="diese Hilfe anzeigen" ;;
                zh-Hans) _mt_out="显示这份说明" ;;
                ja) _mt_out="この説明を表示" ;;
                ko) _mt_out="이 도움말 표시" ;;
                *) _mt_out="Show this help" ;;
            esac
            ;;
        help_h_domain)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="網域指令（OpenSSH sshd）：" ;;
                es) _mt_out="Comandos de dominio (OpenSSH sshd):" ;;
                fr) _mt_out="Commandes du domaine (OpenSSH sshd) :" ;;
                de) _mt_out="Domänenbefehle (OpenSSH sshd):" ;;
                zh-Hans) _mt_out="领域命令（OpenSSH sshd）：" ;;
                ja) _mt_out="ドメインコマンド（OpenSSH sshd）:" ;;
                ko) _mt_out="도메인 명령(OpenSSH sshd):" ;;
                *) _mt_out="Domain commands (OpenSSH sshd):" ;;
            esac
            ;;
        help_status)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示 sshd 是否在執行，以及連接埠與路徑（Linux systemd：單元名稱與 active）" ;;
                es) _mt_out="mostrar si sshd está en ejecución, y el puerto/rutas (Linux systemd: nombre de la unidad + active)" ;;
                fr) _mt_out="afficher si sshd tourne, ainsi que le port et les chemins (Linux systemd : nom de l'unité + active)" ;;
                de) _mt_out="zeigen, ob sshd läuft, sowie Port und Pfade (Linux systemd: Unit-Name + active)" ;;
                zh-Hans) _mt_out="显示 sshd 是否在运行，以及端口与路径（Linux systemd：单元名称与 active）" ;;
                ja) _mt_out="sshd が動いているか、ポートとパスを表示（Linux systemd: ユニット名と active）" ;;
                ko) _mt_out="sshd 실행 여부와 포트/경로 표시(Linux systemd: 유닛 이름과 active)" ;;
                *) _mt_out="Show whether sshd is running, and the port/paths (Linux systemd: unit name + active)" ;;
            esac
            ;;
        help_start)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="啟動 sshd：Termux／沒有單元的 Linux = 背景常駐程式（sshd -f）；Linux 發行版單元 = 以 root 執行 systemctl start" ;;
                es) _mt_out="iniciar sshd: Termux / Linux sin unidad = demonio en segundo plano (sshd -f); unidad de la distro = systemctl start como root" ;;
                fr) _mt_out="lancer sshd : Termux / Linux sans unité = démon en arrière-plan (sshd -f) ; unité de la distribution = systemctl start en root" ;;
                de) _mt_out="sshd starten: Termux / Linux ohne Unit = Daemon im Hintergrund (sshd -f); Distro-Unit = systemctl start als root" ;;
                zh-Hans) _mt_out="启动 sshd：Termux／没有单元的 Linux = 后台常驻程序（sshd -f）；Linux 发行版单元 = 以 root 执行 systemctl start" ;;
                ja) _mt_out="sshd を起動：Termux／ユニットのない Linux = バックグラウンドのデーモン（sshd -f）；ディストロのユニット = root で systemctl start" ;;
                ko) _mt_out="sshd 시작: Termux / 유닛 없는 Linux = 백그라운드 데몬(sshd -f); 배포판 유닛 = root로 systemctl start" ;;
                *) _mt_out="Start sshd: Termux / no-unit Linux = background daemon (sshd -f); Linux distro unit = systemctl start as root" ;;
            esac
            ;;
        help_stop)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="停止 sshd（有發行版單元時用 systemctl stop）" ;;
                es) _mt_out="detener sshd (systemctl stop si existe una unidad de la distro)" ;;
                fr) _mt_out="arrêter sshd (systemctl stop si une unité de la distribution existe)" ;;
                de) _mt_out="sshd stoppen (systemctl stop, wenn eine Distro-Unit existiert)" ;;
                zh-Hans) _mt_out="停止 sshd（有发行版单元时用 systemctl stop）" ;;
                ja) _mt_out="sshd を停止（ディストロのユニットがあるときは systemctl stop）" ;;
                ko) _mt_out="sshd 중지(배포판 유닛이 있으면 systemctl stop)" ;;
                *) _mt_out="Stop sshd (systemctl stop when a distro unit exists)" ;;
            esac
            ;;
        help_restart)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="重新啟動 sshd（有發行版單元時用 systemctl restart；否則先停止再啟動）" ;;
                es) _mt_out="reiniciar sshd (systemctl restart si existe una unidad; si no, detener y luego iniciar)" ;;
                fr) _mt_out="relancer sshd (systemctl restart si une unité existe ; sinon arrêter puis lancer)" ;;
                de) _mt_out="sshd neu starten (systemctl restart, wenn eine Unit existiert; sonst stoppen und dann starten)" ;;
                zh-Hans) _mt_out="重新启动 sshd（有发行版单元时用 systemctl restart；否则先停止再启动）" ;;
                ja) _mt_out="sshd を再起動（ユニットがあるときは systemctl restart、なければ停止してから起動）" ;;
                ko) _mt_out="sshd 다시 시작(유닛이 있으면 systemctl restart, 없으면 중지 후 시작)" ;;
                *) _mt_out="Restart sshd (systemctl restart when a distro unit exists; else stop then start)" ;;
            esac
            ;;
        help_port)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示或設定 sshd_config 的聽候 Port" ;;
                es) _mt_out="mostrar o fijar el Port de escucha en sshd_config" ;;
                fr) _mt_out="afficher ou régler le Port d'écoute dans sshd_config" ;;
                de) _mt_out="Port zum Warten in sshd_config anzeigen oder setzen" ;;
                zh-Hans) _mt_out="显示或设置 sshd_config 里的监听 Port" ;;
                ja) _mt_out="sshd_config の待ち受け Port を表示または設定" ;;
                ko) _mt_out="sshd_config의 수신 Port를 표시하거나 설정" ;;
                *) _mt_out="Show or set the listen Port in sshd_config" ;;
            esac
            ;;
        help_config)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="顯示解析後的 sshd 路徑與重要設定" ;;
                es) _mt_out="mostrar las rutas resueltas de sshd y los ajustes principales" ;;
                fr) _mt_out="afficher les chemins sshd résolus et les réglages principaux" ;;
                de) _mt_out="aufgelöste sshd-Pfade und wichtige Einstellungen anzeigen" ;;
                zh-Hans) _mt_out="显示解析后的 sshd 路径与重要设置" ;;
                ja) _mt_out="解決済みの sshd パスと主要な設定を表示" ;;
                ko) _mt_out="해석된 sshd 경로와 주요 설정 표시" ;;
                *) _mt_out="Show resolved sshd paths and key settings" ;;
            esac
            ;;
        help_host_keys)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="列出或建立主機金鑰" ;;
                es) _mt_out="listar o crear claves de host" ;;
                fr) _mt_out="lister ou créer les clés d'hôte" ;;
                de) _mt_out="Host-Schlüssel auflisten oder anlegen" ;;
                zh-Hans) _mt_out="列出或建立主机密钥" ;;
                ja) _mt_out="ホスト鍵を一覧または作成" ;;
                ko) _mt_out="호스트 키를 나열하거나 만들기" ;;
                *) _mt_out="List or create host keys" ;;
            esac
            ;;
        help_auth_keys)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個登入的 authorized_keys" ;;
                es) _mt_out="authorized_keys de este inicio" ;;
                fr) _mt_out="authorized_keys de cette session" ;;
                de) _mt_out="authorized_keys dieser Anmeldung" ;;
                zh-Hans) _mt_out="这个登录的 authorized_keys" ;;
                ja) _mt_out="このログインの authorized_keys" ;;
                ko) _mt_out="이 로그인의 authorized_keys" ;;
                *) _mt_out="This login authorized_keys" ;;
            esac
            ;;
        help_fix_config)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="依這個作業系統，把 OpenSSH 用戶端設定檔裡不支援的關鍵字改成註解。可加 --input-file 與 --output-file。" ;;
                es) _mt_out="Comenta en el config del cliente OpenSSH las palabras que este sistema no admite. Opcional --input-file y --output-file." ;;
                fr) _mt_out="Met en commentaire les mots OpenSSH que ce système n'accepte pas dans le fichier client. --input-file et --output-file sont facultatifs." ;;
                de) _mt_out="Kommentiert OpenSSH-Client-Schlüssel, die dieses System nicht kennt, in der Client-Datei. --input-file und --output-file sind optional." ;;
                zh-Hans) _mt_out="按这个操作系统，把 OpenSSH 客户端配置文件里不支持的关键字改成注释。可加 --input-file 与 --output-file。" ;;
                ja) _mt_out="この OS が受け付けない OpenSSH クライアント設定の語をコメントにする。--input-file と --output-file は任意。" ;;
                ko) _mt_out="이 OS가 받지 않는 OpenSSH 클라이언트 설정의 낱말을 주석으로 바꿈. --input-file 과 --output-file 은 선택." ;;
                *) _mt_out="Comment OpenSSH client keywords this OS does not support in the client config. Optional --input-file and --output-file." ;;
            esac
            ;;
        help_dns)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="這個登入的 ~/.ssh/config Host 清單（dns-ip；as Termux / identity-file / Old OpenSSH；unset 只去掉額外設定，不去掉 dns 或 ip）" ;;
                es) _mt_out="lista Host de ~/.ssh/config de este inicio (dns-ip; as Termux / identity-file / Old OpenSSH; unset quita ajustes extra, no dns ni ip)" ;;
                fr) _mt_out="liste Host de ~/.ssh/config pour cette session (dns-ip ; as Termux / identity-file / Old OpenSSH ; unset retire les réglages en plus, pas dns ni ip)" ;;
                de) _mt_out="Host-Liste in ~/.ssh/config dieser Anmeldung (dns-ip; as Termux / identity-file / Old OpenSSH; unset entfernt Zusatz, nicht dns oder ip)" ;;
                zh-Hans) _mt_out="这个登录的 ~/.ssh/config Host 清单（dns-ip；as Termux / identity-file / Old OpenSSH；unset 只去掉额外设置，不去掉 dns 或 ip）" ;;
                ja) _mt_out="このログインの ~/.ssh/config の Host 一覧（dns-ip、as Termux / identity-file / Old OpenSSH。unset は追加設定だけを外し、dns と ip は残す）" ;;
                ko) _mt_out="이 로그인의 ~/.ssh/config Host 목록(dns-ip, as Termux / identity-file / Old OpenSSH. unset은 추가 설정만 지우고 dns와 ip는 남김)" ;;
                *) _mt_out="This login ~/.ssh/config Host list (dns-ip; as Termux / identity-file / Old OpenSSH; unset drops extra settings, not dns or ip)" ;;
            esac
            ;;
        help_ssh)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="以這個登入的 ~/.ssh/config 對 Host 開 OpenSSH 用戶端（TTY：先選編號，再選使用者與預設；註解的 HostKeyAlgorithms 會加上 -o HostKeyAlgorithms=+ssh-rsa）" ;;
                es) _mt_out="cliente OpenSSH hacia un Host de ~/.ssh/config de este inicio (TTY: elección numerada, luego usuario con predeterminado; HostKeyAlgorithms comentado pasa -o HostKeyAlgorithms=+ssh-rsa)" ;;
                fr) _mt_out="client OpenSSH vers un Host du ~/.ssh/config de cette session (TTY : choix numéroté, puis utilisateur avec défaut ; HostKeyAlgorithms en commentaire passe -o HostKeyAlgorithms=+ssh-rsa)" ;;
                de) _mt_out="OpenSSH-Client zu einem Host aus ~/.ssh/config dieser Anmeldung (TTY: nummerierte Wahl, dann Benutzer mit Vorgabe; kommentiertes HostKeyAlgorithms gibt -o HostKeyAlgorithms=+ssh-rsa)" ;;
                zh-Hans) _mt_out="用这个登录的 ~/.ssh/config 对 Host 打开 OpenSSH 客户端（TTY：先选编号，再选用户与默认；注释的 HostKeyAlgorithms 会加上 -o HostKeyAlgorithms=+ssh-rsa）" ;;
                ja) _mt_out="このログインの ~/.ssh/config の Host へ OpenSSH クライアント（TTY：番号で選び、次に既定つきのユーザー。コメントの HostKeyAlgorithms は -o HostKeyAlgorithms=+ssh-rsa を渡す）" ;;
                ko) _mt_out="이 로그인의 ~/.ssh/config Host로 OpenSSH 클라이언트(TTY: 번호로 고른 뒤 기본값이 있는 사용자. 주석 처리된 HostKeyAlgorithms는 -o HostKeyAlgorithms=+ssh-rsa 를 넘김)" ;;
                *) _mt_out="OpenSSH client to a Host from this login ~/.ssh/config (TTY: numbered pick, then user with default; commented HostKeyAlgorithms passes -o HostKeyAlgorithms=+ssh-rsa)" ;;
            esac
            ;;
        help_download)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="透過 ssh 把遠端資料夾打成 tar.gz 並在這裡解開（TTY：選 Host，再選使用者與預設，再選先前的編號資料夾或輸入路徑；可用 ~/folder）" ;;
                es) _mt_out="tar.gz de una carpeta remota por ssh y extraerla aquí (TTY: elegir Host, luego usuario con predeterminado, luego carpetas anteriores numeradas o escribir una ruta; ~/folder permitido)" ;;
                fr) _mt_out="tar.gz d'un dossier distant via ssh et l'extraire ici (TTY : choisir un Host, puis l'utilisateur avec défaut, puis les dossiers précédents numérotés ou saisir un chemin ; ~/folder permis)" ;;
                de) _mt_out="einen fernen Ordner per ssh als tar.gz holen und hier entpacken (TTY: Host wählen, dann Benutzer mit Vorgabe, dann nummerierte bisherige Ordner oder einen Pfad tippen; ~/folder erlaubt)" ;;
                zh-Hans) _mt_out="通过 ssh 把远程文件夹打成 tar.gz 并在这里解开（TTY：选 Host，再选用户与默认，再选先前的编号文件夹或输入路径；可用 ~/folder）" ;;
                ja) _mt_out="ssh 経由で遠隔フォルダを tar.gz にしてここで展開（TTY：Host を選び、次に既定つきのユーザー、次に過去の番号付きフォルダかパス。~/folder 可）" ;;
                ko) _mt_out="ssh로 원격 폴더를 tar.gz로 받아 여기서 풀기(TTY: Host를 고르고, 기본값이 있는 사용자를 고른 뒤, 이전 번호 폴더를 고르거나 경로 입력. ~/folder 가능)" ;;
                *) _mt_out="tar.gz a remote folder over ssh and extract it here (TTY: pick Host, then user with default, then numbered previous folders or type a path; ~/folder allowed)" ;;
            esac
            ;;
        help_upload)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="透過 ssh 把本機資料夾打成 tar.gz 並在遠端登入的家目錄解開（TTY：選 Host，再選使用者與預設，再選先前的本機編號資料夾或輸入路徑；~/folder 是這個登入）" ;;
                es) _mt_out="tar.gz de una carpeta local por ssh y extraerla en el home del inicio remoto (TTY: elegir Host, luego usuario con predeterminado, luego carpetas locales anteriores o escribir una ruta; ~/folder es este inicio)" ;;
                fr) _mt_out="tar.gz d'un dossier local via ssh et l'extraire dans le home de la session distante (TTY : choisir un Host, puis l'utilisateur avec défaut, puis les dossiers locaux précédents ou saisir un chemin ; ~/folder est cette session)" ;;
                de) _mt_out="einen lokalen Ordner per ssh als tar.gz legen und im Home der fernen Anmeldung entpacken (TTY: Host wählen, dann Benutzer mit Vorgabe, dann bisherige lokale Ordner oder einen Pfad; ~/folder ist diese Anmeldung)" ;;
                zh-Hans) _mt_out="通过 ssh 把本机文件夹打成 tar.gz 并在远程登录的主目录解开（TTY：选 Host，再选用户与默认，再选先前的本机编号文件夹或输入路径；~/folder 是这个登录）" ;;
                ja) _mt_out="ssh 経由でローカルフォルダを tar.gz にして遠隔ログインのホームで展開（TTY：Host、次に既定つきのユーザー、次に過去のローカルフォルダかパス。~/folder はこのログイン）" ;;
                ko) _mt_out="ssh로 로컬 폴더를 tar.gz로 보내 원격 로그인 홈에서 풀기(TTY: Host, 기본값이 있는 사용자, 이전 로컬 폴더 또는 경로. ~/folder는 이 로그인)" ;;
                *) _mt_out="tar.gz a local folder over ssh and extract it under the remote login home (TTY: pick Host, then user with default, then numbered previous local folders or type a path; ~/folder is this login)" ;;
            esac
            ;;
        help_backup)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="把這個登入的 ~/.ssh/config 複製到 /var/sshd-cli（sudoer-adm 之後可免密碼 sudo sshd-cli backup-config）" ;;
                es) _mt_out="copiar ~/.ssh/config de este inicio a /var/sshd-cli (sudo sin contraseña sshd-cli backup-config tras sudoer-adm)" ;;
                fr) _mt_out="copier le ~/.ssh/config de cette session vers /var/sshd-cli (sudo sans mot de passe sshd-cli backup-config après sudoer-adm)" ;;
                de) _mt_out="~/.ssh/config dieser Anmeldung nach /var/sshd-cli kopieren (passwortloses sudo sshd-cli backup-config nach sudoer-adm)" ;;
                zh-Hans) _mt_out="把这个登录的 ~/.ssh/config 复制到 /var/sshd-cli（sudoer-adm 之后可免密码 sudo sshd-cli backup-config）" ;;
                ja) _mt_out="このログインの ~/.ssh/config を /var/sshd-cli へコピー（sudoer-adm のあと、パスワードなしの sudo sshd-cli backup-config）" ;;
                ko) _mt_out="이 로그인의 ~/.ssh/config를 /var/sshd-cli로 복사(sudoer-adm 이후 비밀번호 없는 sudo sshd-cli backup-config)" ;;
                *) _mt_out="Copy this login ~/.ssh/config into /var/sshd-cli (passwordless sudo sshd-cli backup-config after sudoer-adm)" ;;
            esac
            ;;
        help_sync)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="把 /var/sshd-cli/config 複製進這個登入的 ~/.ssh/config（模式 600；不用 sudo）" ;;
                es) _mt_out="copiar /var/sshd-cli/config en ~/.ssh/config de este inicio (modo 600; sin sudo)" ;;
                fr) _mt_out="copier /var/sshd-cli/config dans le ~/.ssh/config de cette session (mode 600 ; sans sudo)" ;;
                de) _mt_out="/var/sshd-cli/config in ~/.ssh/config dieser Anmeldung kopieren (Modus 600; ohne sudo)" ;;
                zh-Hans) _mt_out="把 /var/sshd-cli/config 复制进这个登录的 ~/.ssh/config（模式 600；不用 sudo）" ;;
                ja) _mt_out="/var/sshd-cli/config をこのログインの ~/.ssh/config へコピー（モード 600、sudo なし）" ;;
                ko) _mt_out="/var/sshd-cli/config를 이 로그인의 ~/.ssh/config로 복사(모드 600, sudo 없음)" ;;
                *) _mt_out="Copy /var/sshd-cli/config into this login ~/.ssh/config (mode 600; no sudo)" ;;
            esac
            ;;
        help_sync_remote)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="把遠端主機的 /var/sshd-cli/config 複製進這個登入的 ~/.ssh/config（scp；記住上次的 user@host）" ;;
                es) _mt_out="copiar el /var/sshd-cli/config de otro equipo en ~/.ssh/config de este inicio (scp; recuerda el último user@host)" ;;
                fr) _mt_out="copier le /var/sshd-cli/config d'un hôte distant dans le ~/.ssh/config de cette session (scp ; retient le dernier user@host)" ;;
                de) _mt_out="/var/sshd-cli/config eines fernen Rechners in ~/.ssh/config dieser Anmeldung kopieren (scp; merkt sich das letzte user@host)" ;;
                zh-Hans) _mt_out="把远程主机的 /var/sshd-cli/config 复制进这个登录的 ~/.ssh/config（scp；记住上次的 user@host）" ;;
                ja) _mt_out="遠隔ホストの /var/sshd-cli/config をこのログインの ~/.ssh/config へコピー（scp。最後の user@host を覚える）" ;;
                ko) _mt_out="원격 호스트의 /var/sshd-cli/config를 이 로그인의 ~/.ssh/config로 복사(scp. 마지막 user@host를 기억)" ;;
                *) _mt_out="Copy a remote host's /var/sshd-cli/config into this login ~/.ssh/config (scp; remembers last user@host)" ;;
            esac
            ;;
        help_print_sudoers)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="輸出給管理者安裝用的 project-sudoers-file（草稿）" ;;
                es) _mt_out="emitir project-sudoers-file (borrador) para la instalación del administrador" ;;
                fr) _mt_out="émettre project-sudoers-file (brouillon) pour l'installation par l'administrateur" ;;
                de) _mt_out="project-sudoers-file (Entwurf) für die Admin-Installation ausgeben" ;;
                zh-Hans) _mt_out="输出给管理者安装用的 project-sudoers-file（草稿）" ;;
                ja) _mt_out="管理者のインストール用 project-sudoers-file（下書き）を出力" ;;
                ko) _mt_out="관리자 설치용 project-sudoers-file(초안) 출력" ;;
                *) _mt_out="Emit project-sudoers-file (draft) for admin install" ;;
            esac
            ;;
        help_print_script)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="寫出 sudo 安裝／移除／取代用的管理者腳本" ;;
                es) _mt_out="escribir el script de administrador para sudo install/uninstall/replace" ;;
                fr) _mt_out="écrire le script d'administration pour sudo install/uninstall/replace" ;;
                de) _mt_out="Admin-Skript für sudo install/uninstall/replace schreiben" ;;
                zh-Hans) _mt_out="写出 sudo 安装／移除／替换用的管理者脚本" ;;
                ja) _mt_out="sudo の install/uninstall/replace 用の管理者スクリプトを書く" ;;
                ko) _mt_out="sudo install/uninstall/replace 용 관리자 스크립트 작성" ;;
                *) _mt_out="Write admin script for sudo install/uninstall/replace" ;;
            esac
            ;;
        help_generate)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="單獨寫出一份 JSON 授權（backup-config 動詞）" ;;
                es) _mt_out="escribir por separado una concesión JSON (verbo backup-config)" ;;
                fr) _mt_out="écrire séparément une autorisation JSON (verbe backup-config)" ;;
                de) _mt_out="eigenständig eine JSON-Freigabe schreiben (Verb backup-config)" ;;
                zh-Hans) _mt_out="单独写出一份 JSON 授权（backup-config 动词）" ;;
                ja) _mt_out="JSON 認可を単独で書く（動詞は backup-config）" ;;
                ko) _mt_out="JSON 허가를 따로 작성(동사는 backup-config)" ;;
                *) _mt_out="Independently write a JSON grant (backup-config verb)" ;;
            esac
            ;;
        help_submit)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="透過 sudoer-cli 把 JSON sudoers 授權請求排入佇列" ;;
                es) _mt_out="encolar una solicitud JSON de concesión sudoers mediante sudoer-cli" ;;
                fr) _mt_out="mettre en file une demande JSON d'autorisation sudoers via sudoer-cli" ;;
                de) _mt_out="eine JSON-sudoers-Freigabe über sudoer-cli in die Warteschlange legen" ;;
                zh-Hans) _mt_out="通过 sudoer-cli 把 JSON sudoers 授权请求排入队列" ;;
                ja) _mt_out="sudoer-cli 経由で JSON の sudoers 認可要求を待ち行列へ入れる" ;;
                ko) _mt_out="sudoer-cli로 JSON sudoers 허가 요청을 대기열에 넣기" ;;
                *) _mt_out="Queue a JSON sudoers-grant request via sudoer-cli" ;;
            esac
            ;;
        help_remove)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="只刪除 project-sudoers-file 草稿" ;;
                es) _mt_out="borrar solo el borrador project-sudoers-file" ;;
                fr) _mt_out="supprimer seulement le brouillon project-sudoers-file" ;;
                de) _mt_out="nur den Entwurf project-sudoers-file löschen" ;;
                zh-Hans) _mt_out="只删除 project-sudoers-file 草稿" ;;
                ja) _mt_out="project-sudoers-file の下書きだけを削除" ;;
                ko) _mt_out="project-sudoers-file 초안만 삭제" ;;
                *) _mt_out="Delete project-sudoers-file draft only" ;;
            esac
            ;;
        help_h_termux)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="Termux（Android 喚醒鎖）：" ;;
                es) _mt_out="Termux (bloqueo de despertar de Android):" ;;
                fr) _mt_out="Termux (verrou de réveil Android) :" ;;
                de) _mt_out="Termux (Android-Wachhaltesperre):" ;;
                zh-Hans) _mt_out="Termux（Android 唤醒锁）：" ;;
                ja) _mt_out="Termux（Android の起動維持ロック）:" ;;
                ko) _mt_out="Termux(Android 깨어 있기 잠금):" ;;
                *) _mt_out="Termux (Android wake lock):" ;;
            esac
            ;;
        help_wake_lock)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="取得 Android 喚醒鎖，讓 sshd 在螢幕關閉時繼續聽候（可重複取得；若 Android 放下鎖就再取得）" ;;
                es) _mt_out="tomar el bloqueo de despertar de Android para que sshd siga escuchando con la pantalla apagada (se puede repetir; tomarlo de nuevo si Android lo soltó)" ;;
                fr) _mt_out="prendre le verrou de réveil Android pour que sshd continue d'écouter écran éteint (répétable ; le reprendre si Android l'a lâché)" ;;
                de) _mt_out="die Android-Wachhaltesperre nehmen, damit sshd bei ausgeschaltetem Bildschirm weiter wartet (wiederholbar; erneut nehmen, wenn Android sie losließ)" ;;
                zh-Hans) _mt_out="取得 Android 唤醒锁，让 sshd 在屏幕关闭时继续监听（可重复取得；若 Android 放开锁就再取得）" ;;
                ja) _mt_out="Android の起動維持ロックを取って、画面が消えても sshd が待ち受けを続ける（繰り返してよい。Android が外したらもう一度取る）" ;;
                ko) _mt_out="화면이 꺼져도 sshd가 계속 듣도록 Android 깨어 있기 잠금을 획득(반복 가능. Android가 놓으면 다시 획득)" ;;
                *) _mt_out="Acquire the Android wake lock so sshd can keep listening with the screen off (idempotent; acquire again if Android dropped it)" ;;
            esac
            ;;
        help_wake_unlock)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="放開 Android 喚醒鎖（不會停止 sshd；鎖是整個 Termux 共用）" ;;
                es) _mt_out="soltar el bloqueo de despertar de Android (no detiene sshd; el bloqueo es de todo Termux)" ;;
                fr) _mt_out="relâcher le verrou de réveil Android (n'arrête pas sshd ; le verrou vaut pour tout Termux)" ;;
                de) _mt_out="die Android-Wachhaltesperre loslassen (stoppt sshd nicht; die Sperre gilt für ganz Termux)" ;;
                zh-Hans) _mt_out="放开 Android 唤醒锁（不会停止 sshd；锁是整个 Termux 共用）" ;;
                ja) _mt_out="Android の起動維持ロックを放す（sshd は止めない。ロックは Termux 全体）" ;;
                ko) _mt_out="Android 깨어 있기 잠금 해제(sshd는 멈추지 않음. 잠금은 Termux 전체)" ;;
                *) _mt_out="Release the Android wake lock (does not stop sshd; lock is Termux-wide)" ;;
            esac
            ;;
        help_h_tests)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="測試（本機資料夾；不是安裝）：" ;;
                es) _mt_out="Pruebas (carpeta local; no es la instalación):" ;;
                fr) _mt_out="Essais (dossier local ; pas l'installation) :" ;;
                de) _mt_out="Tests (lokaler Ordner; nicht die Installation):" ;;
                zh-Hans) _mt_out="测试（本机文件夹；不是安装）：" ;;
                ja) _mt_out="テスト（ローカルフォルダ。インストールではない）:" ;;
                ko) _mt_out="테스트(로컬 폴더, 설치 아님):" ;;
                *) _mt_out="Tests (local folder; not install):" ;;
            esac
            ;;
        help_rc_test)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="在 --root 暫存目錄證明 PATH／profile 確保（--file bashrc|profile --case create|modify|noop）。不會寫這個登入真正的 ~/.bashrc" ;;
                es) _mt_out="probar el ensure de PATH/profile en un tmp de --root (--file bashrc|profile --case create|modify|noop). No escribe el ~/.bashrc real de este inicio" ;;
                fr) _mt_out="prouver l'ensure PATH/profile dans un tmp --root (--file bashrc|profile --case create|modify|noop). N'écrit pas le vrai ~/.bashrc de cette session" ;;
                de) _mt_out="PATH/Profil-Ensure in einem --root-tmp prüfen (--file bashrc|profile --case create|modify|noop). Schreibt nicht die echte ~/.bashrc dieser Anmeldung" ;;
                zh-Hans) _mt_out="在 --root 临时目录证明 PATH／profile 确保（--file bashrc|profile --case create|modify|noop）。不会写这个登录真正的 ~/.bashrc" ;;
                ja) _mt_out="--root の一時ディレクトリで PATH/profile の確保を確かめる（--file bashrc|profile --case create|modify|noop）。このログインの本物の ~/.bashrc は書かない" ;;
                ko) _mt_out="--root 임시 폴더에서 PATH/profile 확보를 확인(--file bashrc|profile --case create|modify|noop). 이 로그인의 실제 ~/.bashrc는 쓰지 않음" ;;
                *) _mt_out="Prove PATH/profile ensure in --root tmp (--file bashrc|profile --case create|modify|noop). Does not write this login's real ~/.bashrc" ;;
            esac
            ;;
        help_h_options)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="全域選項：" ;;
                es) _mt_out="Opciones globales:" ;;
                fr) _mt_out="Options globales :" ;;
                de) _mt_out="Globale Optionen:" ;;
                zh-Hans) _mt_out="全局选项：" ;;
                ja) _mt_out="全体オプション:" ;;
                ko) _mt_out="전역 옵션:" ;;
                *) _mt_out="Global Options:" ;;
            esac
            ;;
        help_quiet)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="不顯示 info／success（錯誤與警告仍會顯示）" ;;
                es) _mt_out="ocultar info/success (los errores y avisos siguen viéndose)" ;;
                fr) _mt_out="masquer info/success (les erreurs et avertissements restent visibles)" ;;
                de) _mt_out="info/success unterdrücken (Fehler und Warnungen bleiben sichtbar)" ;;
                zh-Hans) _mt_out="不显示 info／success（错误与警告仍会显示）" ;;
                ja) _mt_out="info/success を出さない（エラーと警告は出る）" ;;
                ko) _mt_out="info/success 숨김(오류와 경고는 그대로 표시)" ;;
                *) _mt_out="Suppress info/success (errors and warnings still shown)" ;;
            esac
            ;;
        help_force)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="強制重裝／略過移除確認／允許降版" ;;
                es) _mt_out="forzar reinstalación / omitir la confirmación de desinstalación / permitir bajar de versión" ;;
                fr) _mt_out="forcer la réinstallation / sauter la confirmation de retrait / permettre une version plus ancienne" ;;
                de) _mt_out="Neuinstallation erzwingen / Bestätigung der Entfernung überspringen / ältere Version erlauben" ;;
                zh-Hans) _mt_out="强制重装／跳过移除确认／允许降级" ;;
                ja) _mt_out="再インストールを強制／削除確認を飛ばす／古い版を許す" ;;
                ko) _mt_out="재설치 강제 / 제거 확인 건너뛰기 / 낮은 버전 허용" ;;
                *) _mt_out="Force reinstall / skip uninstall confirm / allow downgrade" ;;
            esac
            ;;
        help_debug)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="偵錯診斷寫到 stderr" ;;
                es) _mt_out="diagnóstico de depuración en stderr" ;;
                fr) _mt_out="diagnostic de débogage sur stderr" ;;
                de) _mt_out="Debug-Diagnose auf stderr" ;;
                zh-Hans) _mt_out="调试诊断写到 stderr" ;;
                ja) _mt_out="デバッグ診断を stderr へ" ;;
                ko) _mt_out="디버그 진단을 stderr로" ;;
                *) _mt_out="Debug diagnostics on stderr" ;;
            esac
            ;;
        help_h_env)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="環境：" ;;
                es) _mt_out="Entorno:" ;;
                fr) _mt_out="Environnement :" ;;
                de) _mt_out="Umgebung:" ;;
                zh-Hans) _mt_out="环境：" ;;
                ja) _mt_out="環境:" ;;
                ko) _mt_out="환경:" ;;
                *) _mt_out="Environment:" ;;
            esac
            ;;
        help_repo_user)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="用來組成預設 SCRIPT_URL 的 GitHub 擁有者" ;;
                es) _mt_out="propietario de GitHub usado para componer el SCRIPT_URL predeterminado" ;;
                fr) _mt_out="propriétaire GitHub utilisé pour composer le SCRIPT_URL par défaut" ;;
                de) _mt_out="GitHub-Eigentümer für die vorgegebene SCRIPT_URL" ;;
                zh-Hans) _mt_out="用来组成默认 SCRIPT_URL 的 GitHub 所有者" ;;
                ja) _mt_out="既定の SCRIPT_URL を組み立てる GitHub 所有者" ;;
                ko) _mt_out="기본 SCRIPT_URL을 만드는 GitHub 소유자" ;;
                *) _mt_out="GitHub owner used to compose default SCRIPT_URL" ;;
            esac
            ;;
        help_repo_name)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="用來組成預設 SCRIPT_URL 的 GitHub 倉儲" ;;
                es) _mt_out="repositorio de GitHub usado para componer el SCRIPT_URL predeterminado" ;;
                fr) _mt_out="dépôt GitHub utilisé pour composer le SCRIPT_URL par défaut" ;;
                de) _mt_out="GitHub-Repo für die vorgegebene SCRIPT_URL" ;;
                zh-Hans) _mt_out="用来组成默认 SCRIPT_URL 的 GitHub 仓库" ;;
                ja) _mt_out="既定の SCRIPT_URL を組み立てる GitHub リポジトリ" ;;
                ko) _mt_out="기본 SCRIPT_URL을 만드는 GitHub 저장소" ;;
                *) _mt_out="GitHub repo used to compose default SCRIPT_URL" ;;
            esac
            ;;
        help_url_unset)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="（未設定）" ;;
                es) _mt_out="(sin definir)" ;;
                fr) _mt_out="(non défini)" ;;
                de) _mt_out="(nicht gesetzt)" ;;
                zh-Hans) _mt_out="（未设置）" ;;
                ja) _mt_out="（未設定）" ;;
                ko) _mt_out="(설정 안 됨)" ;;
                *) _mt_out="(not set)" ;;
            esac
            ;;
        help_url_desc)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="標準安裝通道（可用環境變數覆寫；version-check／self-update 需要它）" ;;
                es) _mt_out="canal canónico de instalación (se puede cambiar por el entorno; hace falta para version-check/self-update)" ;;
                fr) _mt_out="canal d'installation canonique (surcharge par l'environnement ; requis pour version-check/self-update)" ;;
                de) _mt_out="kanonischer Installationskanal (per Umgebung überschreibbar; nötig für version-check/self-update)" ;;
                zh-Hans) _mt_out="标准安装通道（可用环境变量覆盖；version-check／self-update 需要它）" ;;
                ja) _mt_out="標準の導入経路（環境変数で上書き可。version-check/self-update に必要）" ;;
                ko) _mt_out="기본 설치 경로(환경 변수로 바꿀 수 있음. version-check/self-update에 필요)" ;;
                *) _mt_out="Canonical install channel (override via env; needed for version-check/self-update)" ;;
            esac
            ;;
        help_bashrc)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="install 的 PATH 確保所寫的互動 rc（預設 \${HOME}/.bashrc；測試／CI 可覆寫）" ;;
                es) _mt_out="rc interactivo que escribe el ensure de PATH de install (predeterminado \${HOME}/.bashrc; se puede cambiar en pruebas/CI)" ;;
                fr) _mt_out="rc interactif écrit par l'ensure PATH de install (défaut \${HOME}/.bashrc ; surcharge pour les essais/CI)" ;;
                de) _mt_out="interaktive rc, die das PATH-Ensure von install schreibt (Vorgabe \${HOME}/.bashrc; für Tests/CI überschreibbar)" ;;
                zh-Hans) _mt_out="install 的 PATH 确保所写的交互 rc（默认 \${HOME}/.bashrc；测试／CI 可覆盖）" ;;
                ja) _mt_out="install の PATH 確保が書く対話 rc（既定 \${HOME}/.bashrc。テスト／CI では上書き可）" ;;
                ko) _mt_out="install의 PATH 확보가 쓰는 대화형 rc(기본 \${HOME}/.bashrc. 테스트/CI에서 바꿀 수 있음)" ;;
                *) _mt_out="Interactive rc written by install PATH ensure (default \${HOME}/.bashrc; override for tests/CI)" ;;
            esac
            ;;
        help_root)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="耐久存放處（預設 /var/sshd-cli）" ;;
                es) _mt_out="almacén duradero (predeterminado /var/sshd-cli)" ;;
                fr) _mt_out="dépôt durable (défaut /var/sshd-cli)" ;;
                de) _mt_out="dauerhafter Speicher (Vorgabe /var/sshd-cli)" ;;
                zh-Hans) _mt_out="耐久存放处（默认 /var/sshd-cli）" ;;
                ja) _mt_out="永続の置き場（既定 /var/sshd-cli）" ;;
                ko) _mt_out="지속 저장소(기본 /var/sshd-cli)" ;;
                *) _mt_out="durable store (default /var/sshd-cli)" ;;
            esac
            ;;
        help_remote_root)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sync-from-remote 的遠端存放處（預設 /var/sshd-cli）" ;;
                es) _mt_out="almacén remoto para sync-from-remote (predeterminado /var/sshd-cli)" ;;
                fr) _mt_out="dépôt distant pour sync-from-remote (défaut /var/sshd-cli)" ;;
                de) _mt_out="ferner Speicher für sync-from-remote (Vorgabe /var/sshd-cli)" ;;
                zh-Hans) _mt_out="sync-from-remote 的远程存放处（默认 /var/sshd-cli）" ;;
                ja) _mt_out="sync-from-remote の遠隔の置き場（既定 /var/sshd-cli）" ;;
                ko) _mt_out="sync-from-remote용 원격 저장소(기본 /var/sshd-cli)" ;;
                *) _mt_out="remote store for sync-from-remote (default /var/sshd-cli)" ;;
            esac
            ;;
        help_scp)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="覆寫 scp 執行檔（測試會注入假的）" ;;
                es) _mt_out="sustituir el binario scp (las pruebas inyectan uno falso)" ;;
                fr) _mt_out="remplacer le binaire scp (les essais injectent un faux)" ;;
                de) _mt_out="scp-Programm ersetzen (Tests setzen ein Ersatzprogramm)" ;;
                zh-Hans) _mt_out="覆盖 scp 可执行文件（测试会注入假的）" ;;
                ja) _mt_out="scp 実行ファイルの差し替え（テストは偽物を入れる）" ;;
                ko) _mt_out="scp 바이너리 교체(테스트는 가짜를 넣음)" ;;
                *) _mt_out="scp binary override (tests inject a fake)" ;;
            esac
            ;;
        help_ssh_bin)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="覆寫 ssh 執行檔（測試會注入假的）" ;;
                es) _mt_out="sustituir el binario ssh (las pruebas inyectan uno falso)" ;;
                fr) _mt_out="remplacer le binaire ssh (les essais injectent un faux)" ;;
                de) _mt_out="ssh-Programm ersetzen (Tests setzen ein Ersatzprogramm)" ;;
                zh-Hans) _mt_out="覆盖 ssh 可执行文件（测试会注入假的）" ;;
                ja) _mt_out="ssh 実行ファイルの差し替え（テストは偽物を入れる）" ;;
                ko) _mt_out="ssh 바이너리 교체(테스트는 가짜를 넣음)" ;;
                *) _mt_out="ssh binary override (tests inject a fake)" ;;
            esac
            ;;
        help_json_note)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="請把 --json 用在 version、about、version-check、install、self-install、self-update、self-uninstall、rc-test。" ;;
                es) _mt_out="Use --json con version, about, version-check, install, self-install, self-update, self-uninstall, rc-test." ;;
                fr) _mt_out="Utilisez --json avec version, about, version-check, install, self-install, self-update, self-uninstall, rc-test." ;;
                de) _mt_out="--json mit version, about, version-check, install, self-install, self-update, self-uninstall, rc-test verwenden." ;;
                zh-Hans) _mt_out="请把 --json 用在 version、about、version-check、install、self-install、self-update、self-uninstall、rc-test。" ;;
                ja) _mt_out="--json は version、about、version-check、install、self-install、self-update、self-uninstall、rc-test と一緒に使う。" ;;
                ko) _mt_out="--json 은 version, about, version-check, install, self-install, self-update, self-uninstall, rc-test 와 함께 쓴다." ;;
                *) _mt_out="Use --json with version, about, version-check, install, self-install, self-update, self-uninstall, rc-test." ;;
            esac
            ;;
        help_menu)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="編號樹：1 用戶端、2 伺服器端、6 語言、7 sudoers、8 自我管理、9 離開。語言 61 English、62 繁體中文、63 Español、64 Français、65 Deutsch、66 简体中文、67 日本語、68 한국어。用戶端 11… dns/ssh/download/upload。伺服器 21… status/start/stop/restart。自我管理 81… install/version/about、87 self-install。子選單 0 返回。別名：main" ;;
                es) _mt_out="Árbol numerado: 1 cliente, 2 servidor, 6 idioma, 7 sudoers, 8 autogestión, 9 Salir. Idiomas 61 English, 62 繁體中文, 63 Español, 64 Français, 65 Deutsch, 66 简体中文, 67 日本語, 68 한국어. Cliente 11… dns/ssh/download/upload. Servidor 21… status/start/stop/restart. Autogestión 81… install/version/about, 87 self-install. Submenús 0 Atrás. Alias: main" ;;
                fr) _mt_out="Arbre numéroté : 1 client, 2 serveur, 6 langue, 7 sudoers, 8 autogestion, 9 Quitter. Langues 61 English, 62 繁體中文, 63 Español, 64 Français, 65 Deutsch, 66 简体中文, 67 日本語, 68 한국어. Client 11… dns/ssh/download/upload. Serveur 21… status/start/stop/restart. Autogestion 81… install/version/about, 87 self-install. Sous-menus 0 Retour. Alias : main" ;;
                de) _mt_out="Nummerierter Baum: 1 Client, 2 Server, 6 Sprache, 7 sudoers, 8 Selbstverwaltung, 9 Beenden. Sprachen 61 English, 62 繁體中文, 63 Español, 64 Français, 65 Deutsch, 66 简体中文, 67 日本語, 68 한국어. Client 11… dns/ssh/download/upload. Server 21… status/start/stop/restart. Selbstverwaltung 81… install/version/about, 87 self-install. Untermenüs 0 Zurück. Alias: main" ;;
                zh-Hans) _mt_out="编号树：1 客户端、2 服务器端、6 语言、7 sudoers、8 自我管理、9 离开。语言 61 English、62 繁體中文、63 Español、64 Français、65 Deutsch、66 简体中文、67 日本語、68 한국어。客户端 11… dns/ssh/download/upload。服务器 21… status/start/stop/restart。自我管理 81… install/version/about、87 self-install。子菜单 0 返回。别名：main" ;;
                ja) _mt_out="番号の木: 1 クライアント、2 サーバー、6 言語、7 sudoers、8 自己管理、9 終了。言語 61 English、62 繁體中文、63 Español、64 Français、65 Deutsch、66 简体中文、67 日本語、68 한국어。クライアント 11… dns/ssh/download/upload。サーバー 21… status/start/stop/restart。自己管理 81… install/version/about、87 self-install。サブメニュー 0 戻る。別名: main" ;;
                ko) _mt_out="번호 나무: 1 클라이언트, 2 서버, 6 언어, 7 sudoers, 8 자기관리, 9 종료. 언어 61 English, 62 繁體中文, 63 Español, 64 Français, 65 Deutsch, 66 简体中文, 67 日本語, 68 한국어. 클라이언트 11… dns/ssh/download/upload. 서버 21… status/start/stop/restart. 자기관리 81… install/version/about, 87 self-install. 하위 메뉴 0 뒤로. 별칭: main" ;;
                *) _mt_out="Numbered tree: 1 client-side, 2 server-side, 6 language, 7 sudoers, 8 self-management, 9 Exit. Language 61 English, 62 Traditional Chinese, 63 Spanish, 64 French, 65 German, 66 Simplified Chinese, 67 Japanese, 68 Korean. Client 11… dns/ssh/download/upload; server 21… status/start/stop/restart; self-management 81… install/version/about, 87 self-install. Submenus 0 Back. Alias: main" ;;
            esac
            ;;
        about_title)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="關於 / 診斷" ;;
                es) _mt_out="Acerca de / diagnóstico" ;;
                fr) _mt_out="À propos / diagnostic" ;;
                de) _mt_out="Über / Diagnose" ;;
                zh-Hans) _mt_out="关于 / 诊断" ;;
                ja) _mt_out="概要 / 診断" ;;
                ko) _mt_out="개요 / 진단" ;;
                *) _mt_out="About / Diagnostics" ;;
            esac
            ;;
        about_installed)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="${APP_NAME} 已正確安裝。" ;;
                es) _mt_out="${APP_NAME} está instalado correctamente." ;;
                fr) _mt_out="${APP_NAME} est correctement installé." ;;
                de) _mt_out="${APP_NAME} ist ordnungsgemäß installiert." ;;
                zh-Hans) _mt_out="${APP_NAME} 已正确安装。" ;;
                ja) _mt_out="${APP_NAME} は正しく配置されています。" ;;
                ko) _mt_out="${APP_NAME}가 올바르게 설치되어 있습니다." ;;
                *) _mt_out="${APP_NAME} is properly installed." ;;
            esac
            ;;
        about_missing)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="${APP_NAME} 沒有安裝在你的 PATH。" ;;
                es) _mt_out="${APP_NAME} NO está instalado en tu PATH." ;;
                fr) _mt_out="${APP_NAME} n'est PAS installé dans votre PATH." ;;
                de) _mt_out="${APP_NAME} ist NICHT in Ihrem PATH installiert." ;;
                zh-Hans) _mt_out="${APP_NAME} 没有安装在你的 PATH。" ;;
                ja) _mt_out="${APP_NAME} は PATH に入っていません。" ;;
                ko) _mt_out="${APP_NAME}가 PATH에 설치되어 있지 않습니다." ;;
                *) _mt_out="${APP_NAME} is NOT installed in your PATH." ;;
            esac
            ;;
        about_recommend)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="   建議：curl -fsSL ${SCRIPT_URL} | sh" ;;
                es) _mt_out="   Recomendado: curl -fsSL ${SCRIPT_URL} | sh" ;;
                fr) _mt_out="   Recommandé : curl -fsSL ${SCRIPT_URL} | sh" ;;
                de) _mt_out="   Empfohlen: curl -fsSL ${SCRIPT_URL} | sh" ;;
                zh-Hans) _mt_out="   建议：curl -fsSL ${SCRIPT_URL} | sh" ;;
                ja) _mt_out="   推奨: curl -fsSL ${SCRIPT_URL} | sh" ;;
                ko) _mt_out="   권장: curl -fsSL ${SCRIPT_URL} | sh" ;;
                *) _mt_out="   Recommended: curl -fsSL ${SCRIPT_URL} | sh" ;;
            esac
            ;;
        about_set_url)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="   請把 SCRIPT_URL 設成安裝腳本的 URL，然後： " ;;
                es) _mt_out="   Defina SCRIPT_URL con la URL del script de instalación y luego: " ;;
                fr) _mt_out="   Réglez SCRIPT_URL sur l'URL du script d'installation, puis : " ;;
                de) _mt_out="   Setzen Sie SCRIPT_URL auf die URL des Installationsskripts, dann: " ;;
                zh-Hans) _mt_out="   请把 SCRIPT_URL 设成安装脚本的 URL，然后： " ;;
                ja) _mt_out="   SCRIPT_URL を導入スクリプトの URL にしてから: " ;;
                ko) _mt_out="   SCRIPT_URL을 설치 스크립트 URL로 지정한 다음: " ;;
                *) _mt_out="   Set SCRIPT_URL to the install script URL, then: " ;;
            esac
            ;;
        about_global)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="全域安裝  (" ;;
                es) _mt_out="Instalación global  (" ;;
                fr) _mt_out="Installation globale  (" ;;
                de) _mt_out="Globale Installation  (" ;;
                zh-Hans) _mt_out="全局安装  (" ;;
                ja) _mt_out="全体インストール  (" ;;
                ko) _mt_out="전역 설치  (" ;;
                *) _mt_out="Global install  (" ;;
            esac
            ;;
        about_local)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="本機安裝   (" ;;
                es) _mt_out="Instalación local   (" ;;
                fr) _mt_out="Installation locale   (" ;;
                de) _mt_out="Lokale Installation   (" ;;
                zh-Hans) _mt_out="本机安装   (" ;;
                ja) _mt_out="ローカルインストール   (" ;;
                ko) _mt_out="로컬 설치   (" ;;
                *) _mt_out="Local install   (" ;;
            esac
            ;;
        about_not_found)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="找不到" ;;
                es) _mt_out="no encontrado" ;;
                fr) _mt_out="introuvable" ;;
                de) _mt_out="nicht gefunden" ;;
                zh-Hans) _mt_out="找不到" ;;
                ja) _mt_out="見つかりません" ;;
                ko) _mt_out="없음" ;;
                *) _mt_out="not found" ;;
            esac
            ;;
        about_user)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="目前使用者：      " ;;
                es) _mt_out="Usuario actual:      " ;;
                fr) _mt_out="Utilisateur actuel :      " ;;
                de) _mt_out="Aktueller Benutzer:      " ;;
                zh-Hans) _mt_out="当前用户：      " ;;
                ja) _mt_out="現在のユーザー:      " ;;
                ko) _mt_out="현재 사용자:      " ;;
                *) _mt_out="Current user:      " ;;
            esac
            ;;
        about_root)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="執行身分：root（可用全域安裝路徑）" ;;
                es) _mt_out="Contexto de ejecución: root (ruta de instalación global disponible)" ;;
                fr) _mt_out="Contexte d'exécution : root (chemin d'installation global disponible)" ;;
                de) _mt_out="Ausführungskontext: root (globaler Installationspfad verfügbar)" ;;
                zh-Hans) _mt_out="执行身份：root（可用全局安装路径）" ;;
                ja) _mt_out="実行コンテキスト: root（全体インストールのパスが使える）" ;;
                ko) _mt_out="실행 맥락: root(전역 설치 경로 사용 가능)" ;;
                *) _mt_out="Execution context: root (global install path available)" ;;
            esac
            ;;
        about_login)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="執行身分：這個登入（這個 CLI 不需要 root）" ;;
                es) _mt_out="Contexto de ejecución: este inicio (este CLI no necesita root)" ;;
                fr) _mt_out="Contexte d'exécution : cette session (ce CLI n'a pas besoin de root)" ;;
                de) _mt_out="Ausführungskontext: diese Anmeldung (dieses CLI braucht kein root)" ;;
                zh-Hans) _mt_out="执行身份：这个登录（这个 CLI 不需要 root）" ;;
                ja) _mt_out="実行コンテキスト: このログイン（この CLI に root は不要）" ;;
                ko) _mt_out="실행 맥락: 이 로그인(이 CLI에는 root가 필요 없음)" ;;
                *) _mt_out="Execution context: this login (no root required for this CLI)" ;;
            esac
            ;;
        about_shell)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="目前 shell：     " ;;
                es) _mt_out="Shell actual:     " ;;
                fr) _mt_out="Shell actuel :     " ;;
                de) _mt_out="Aktuelle Shell:     " ;;
                zh-Hans) _mt_out="当前 shell：     " ;;
                ja) _mt_out="現在のシェル:     " ;;
                ko) _mt_out="현재 셸:     " ;;
                *) _mt_out="Current shell:     " ;;
            esac
            ;;
        about_tty_yes)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="TTY／互動：是" ;;
                es) _mt_out="TTY / interactivo: sí" ;;
                fr) _mt_out="TTY / interactif : oui" ;;
                de) _mt_out="TTY / interaktiv: ja" ;;
                zh-Hans) _mt_out="TTY／交互：是" ;;
                ja) _mt_out="TTY / 対話: はい" ;;
                ko) _mt_out="TTY / 대화형: 예" ;;
                *) _mt_out="TTY / Interactive: yes" ;;
            esac
            ;;
        about_tty_no)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="TTY／互動：否（非互動／腳本模式）" ;;
                es) _mt_out="TTY / interactivo: no (modo no interactivo / script)" ;;
                fr) _mt_out="TTY / interactif : non (mode non interactif / script)" ;;
                de) _mt_out="TTY / interaktiv: nein (nicht interaktiv / Skript)" ;;
                zh-Hans) _mt_out="TTY／交互：否（非交互／脚本模式）" ;;
                ja) _mt_out="TTY / 対話: いいえ（非対話／スクリプト）" ;;
                ko) _mt_out="TTY / 대화형: 아니요(비대화 / 스크립트)" ;;
                *) _mt_out="TTY / Interactive: no (non-interactive / scripted mode)" ;;
            esac
            ;;
        about_cache_used)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="使用的快取資料夾：" ;;
                es) _mt_out="Carpeta de caché en uso: " ;;
                fr) _mt_out="Dossier de cache utilisé : " ;;
                de) _mt_out="Verwendeter Cache-Ordner: " ;;
                zh-Hans) _mt_out="使用的缓存文件夹：" ;;
                ja) _mt_out="使用中のキャッシュフォルダ: " ;;
                ko) _mt_out="사용 중인 캐시 폴더: " ;;
                *) _mt_out="Cache folder used: " ;;
            esac
            ;;
        about_cache_pref)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="快取資料夾（偏好）：" ;;
                es) _mt_out="Carpeta de caché (preferida): " ;;
                fr) _mt_out="Dossier de cache (préféré) : " ;;
                de) _mt_out="Cache-Ordner (bevorzugt): " ;;
                zh-Hans) _mt_out="缓存文件夹（首选）：" ;;
                ja) _mt_out="キャッシュフォルダ（優先）: " ;;
                ko) _mt_out="캐시 폴더(선호): " ;;
                *) _mt_out="Cache folder (preferred): " ;;
            esac
            ;;
        about_cache_1)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="快取資料夾（第 1 候補）：" ;;
                es) _mt_out="Carpeta de caché (1.er respaldo): " ;;
                fr) _mt_out="Dossier de cache (1er repli) : " ;;
                de) _mt_out="Cache-Ordner (1. Ausweich): " ;;
                zh-Hans) _mt_out="缓存文件夹（第 1 后备）：" ;;
                ja) _mt_out="キャッシュフォルダ（第1候補）: " ;;
                ko) _mt_out="캐시 폴더(1차 대안): " ;;
                *) _mt_out="Cache folder (1st fallback): " ;;
            esac
            ;;
        about_cache_2)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="快取資料夾（第 2 候補）：" ;;
                es) _mt_out="Carpeta de caché (2.º respaldo): " ;;
                fr) _mt_out="Dossier de cache (2e repli) : " ;;
                de) _mt_out="Cache-Ordner (2. Ausweich): " ;;
                zh-Hans) _mt_out="缓存文件夹（第 2 后备）：" ;;
                ja) _mt_out="キャッシュフォルダ（第2候補）: " ;;
                ko) _mt_out="캐시 폴더(2차 대안): " ;;
                *) _mt_out="Cache folder (2nd fallback): " ;;
            esac
            ;;
        about_persist)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="持久儲存：" ;;
                es) _mt_out="Almacenamiento persistente: " ;;
                fr) _mt_out="Stockage persistant : " ;;
                de) _mt_out="Dauerhafter Speicher: " ;;
                zh-Hans) _mt_out="持久存储：" ;;
                ja) _mt_out="永続ストレージ: " ;;
                ko) _mt_out="지속 저장소: " ;;
                *) _mt_out="Persistence storage: " ;;
            esac
            ;;
        about_platform)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sshd 平台：    " ;;
                es) _mt_out="plataforma sshd:    " ;;
                fr) _mt_out="plateforme sshd :    " ;;
                de) _mt_out="sshd-Plattform:    " ;;
                zh-Hans) _mt_out="sshd 平台：    " ;;
                ja) _mt_out="sshd のプラットフォーム:    " ;;
                ko) _mt_out="sshd 플랫폼:    " ;;
                *) _mt_out="sshd platform:    " ;;
            esac
            ;;
        about_binary)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sshd 執行檔：      " ;;
                es) _mt_out="binario sshd:      " ;;
                fr) _mt_out="binaire sshd :      " ;;
                de) _mt_out="sshd-Programm:      " ;;
                zh-Hans) _mt_out="sshd 可执行文件：      " ;;
                ja) _mt_out="sshd 実行ファイル:      " ;;
                ko) _mt_out="sshd 바이너리:      " ;;
                *) _mt_out="sshd binary:      " ;;
            esac
            ;;
        about_port)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sshd 連接埠：        " ;;
                es) _mt_out="puerto sshd:        " ;;
                fr) _mt_out="port sshd :        " ;;
                de) _mt_out="sshd-Port:        " ;;
                zh-Hans) _mt_out="sshd 端口：        " ;;
                ja) _mt_out="sshd ポート:        " ;;
                ko) _mt_out="sshd 포트:        " ;;
                *) _mt_out="sshd port:        " ;;
            esac
            ;;
        about_running_yes)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sshd 執行中：     是" ;;
                es) _mt_out="sshd en ejecución:     sí" ;;
                fr) _mt_out="sshd en cours :     oui" ;;
                de) _mt_out="sshd läuft:     ja" ;;
                zh-Hans) _mt_out="sshd 运行中：     是" ;;
                ja) _mt_out="sshd 実行中:     はい" ;;
                ko) _mt_out="sshd 실행 중:     예" ;;
                *) _mt_out="sshd running:     yes" ;;
            esac
            ;;
        about_running_no)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sshd 執行中：     否" ;;
                es) _mt_out="sshd en ejecución:     no" ;;
                fr) _mt_out="sshd en cours :     non" ;;
                de) _mt_out="sshd läuft:     nein" ;;
                zh-Hans) _mt_out="sshd 运行中：     否" ;;
                ja) _mt_out="sshd 実行中:     いいえ" ;;
                ko) _mt_out="sshd 실행 중:     아니요" ;;
                *) _mt_out="sshd running:     no" ;;
            esac
            ;;
        about_unit)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="sshd 單元：        " ;;
                es) _mt_out="unidad sshd:        " ;;
                fr) _mt_out="unité sshd :        " ;;
                de) _mt_out="sshd-Unit:        " ;;
                zh-Hans) _mt_out="sshd 单元：        " ;;
                ja) _mt_out="sshd ユニット:        " ;;
                ko) _mt_out="sshd 유닛:        " ;;
                *) _mt_out="sshd unit:        " ;;
            esac
            ;;
        about_active)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="active" ;;
                es) _mt_out="active" ;;
                fr) _mt_out="active" ;;
                de) _mt_out="active" ;;
                zh-Hans) _mt_out="active" ;;
                ja) _mt_out="active" ;;
                ko) _mt_out="active" ;;
                *) _mt_out="active" ;;
            esac
            ;;
        about_none)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="無" ;;
                es) _mt_out="ninguna" ;;
                fr) _mt_out="aucune" ;;
                de) _mt_out="keine" ;;
                zh-Hans) _mt_out="无" ;;
                ja) _mt_out="なし" ;;
                ko) _mt_out="없음" ;;
                *) _mt_out="none" ;;
            esac
            ;;
        about_useful)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="實用指令：" ;;
                es) _mt_out="Comandos útiles:" ;;
                fr) _mt_out="Commandes utiles :" ;;
                de) _mt_out="Nützliche Befehle:" ;;
                zh-Hans) _mt_out="实用命令：" ;;
                ja) _mt_out="便利なコマンド:" ;;
                ko) _mt_out="유용한 명령:" ;;
                *) _mt_out="Useful commands:" ;;
            esac
            ;;
        about_full_usage)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="完整用法" ;;
                es) _mt_out="Uso completo" ;;
                fr) _mt_out="Utilisation complète" ;;
                de) _mt_out="Vollständige Verwendung" ;;
                zh-Hans) _mt_out="完整用法" ;;
                ja) _mt_out="詳しい使い方" ;;
                ko) _mt_out="전체 사용법" ;;
                *) _mt_out="Full usage" ;;
            esac
            ;;
        about_cmd_update)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="更新到最新版本" ;;
                es) _mt_out="Actualizar a la última versión" ;;
                fr) _mt_out="Mettre à jour vers la dernière version" ;;
                de) _mt_out="Auf die neueste Version aktualisieren" ;;
                zh-Hans) _mt_out="更新到最新版本" ;;
                ja) _mt_out="最新バージョンへ更新" ;;
                ko) _mt_out="최신 버전으로 업데이트" ;;
                *) _mt_out="Update to latest version" ;;
            esac
            ;;
        about_cmd_remove)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="從系統乾淨移除" ;;
                es) _mt_out="Retirada limpia del sistema" ;;
                fr) _mt_out="Retrait propre du système" ;;
                de) _mt_out="Sauberes Entfernen vom System" ;;
                zh-Hans) _mt_out="从系统干净移除" ;;
                ja) _mt_out="システムからきれいに削除" ;;
                ko) _mt_out="시스템에서 깨끗이 제거" ;;
                *) _mt_out="Clean removal from system" ;;
            esac
            ;;
        about_footer)
            case "${_mt_lang}" in
                zh-Hant) _mt_out="執行 '${APP_NAME} help' 可看完整用法。" ;;
                es) _mt_out="Ejecute '${APP_NAME} help' para la información de uso completa." ;;
                fr) _mt_out="Lancez '${APP_NAME} help' pour l'information d'utilisation complète." ;;
                de) _mt_out="Führen Sie '${APP_NAME} help' für die vollständige Verwendung aus." ;;
                zh-Hans) _mt_out="运行 '${APP_NAME} help' 可看完整用法。" ;;
                ja) _mt_out="詳しい使い方は '${APP_NAME} help' を実行。" ;;
                ko) _mt_out="전체 사용법은 '${APP_NAME} help' 를 실행." ;;
                *) _mt_out="Run '${APP_NAME} help' for complete usage information." ;;
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
# Parent 6. 61 stores en. 62 stores zh-Hant. 63 stores es. 64 stores fr.
# 65 stores de. 66 stores zh-Hans. 67 stores ja. 68 stores ko.
# Each returns to the front board.
# 0 / empty / EOF is Back. The choice is a current-shell input builtin.
app_cmd_menu_language() {
    while true; do
        out_info "**${APP_NAME}**(*${VERSION}*) — $(app_menu_text cat_language)"
        out_menu_choice "61" "English" "$(app_menu_text lang_en_long)"
        out_menu_choice "62" "繁體中文" "$(app_menu_text lang_zh_long)"
        out_menu_choice "63" "Español" "$(app_menu_text lang_es_long)"
        out_menu_choice "64" "Français" "$(app_menu_text lang_fr_long)"
        out_menu_choice "65" "Deutsch" "$(app_menu_text lang_de_long)"
        out_menu_choice "66" "简体中文" "$(app_menu_text lang_zh_hans_long)"
        out_menu_choice "67" "日本語" "$(app_menu_text lang_ja_long)"
        out_menu_choice "68" "한국어" "$(app_menu_text lang_ko_long)"
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
            63|spanish|es|Español|español)
                if app_lang_save es; then
                    out_info "$(app_menu_text lang_saved)"
                else
                    out_warn "$(app_menu_text lang_save_fail)"
                fi
                unset _choice
                return 0
                ;;
            64|french|fr|Français|français)
                if app_lang_save fr; then
                    out_info "$(app_menu_text lang_saved)"
                else
                    out_warn "$(app_menu_text lang_save_fail)"
                fi
                unset _choice
                return 0
                ;;
            65|german|de|Deutsch|deutsch)
                if app_lang_save de; then
                    out_info "$(app_menu_text lang_saved)"
                else
                    out_warn "$(app_menu_text lang_save_fail)"
                fi
                unset _choice
                return 0
                ;;
            66|simplified-chinese|zh-hans|zh-Hans|简体中文)
                if app_lang_save zh-Hans; then
                    out_info "$(app_menu_text lang_saved)"
                else
                    out_warn "$(app_menu_text lang_save_fail)"
                fi
                unset _choice
                return 0
                ;;
            67|japanese|ja|日本語)
                if app_lang_save ja; then
                    out_info "$(app_menu_text lang_saved)"
                else
                    out_warn "$(app_menu_text lang_save_fail)"
                fi
                unset _choice
                return 0
                ;;
            68|korean|ko|한국어)
                if app_lang_save ko; then
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
        case "${APP_LANG:-en}" in
            zh-Hant)
                out_menu_choice "71" "generate-sudoer-request" "寫一份可閱讀的 JSON 授權"
                ;;
            es)
                out_menu_choice "71" "generate-sudoer-request" "Escribe una concesión JSON que se puede leer"
                ;;
            fr)
                out_menu_choice "71" "generate-sudoer-request" "Écrire une autorisation JSON lisible"
                ;;
            de)
                out_menu_choice "71" "generate-sudoer-request" "Eine lesbare JSON-Freigabe schreiben"
                ;;
            zh-Hans)
                out_menu_choice "71" "generate-sudoer-request" "写一份可阅读的 JSON 授权"
                ;;
            ja)
                out_menu_choice "71" "generate-sudoer-request" "読める JSON 認可を書く"
                ;;
            ko)
                out_menu_choice "71" "generate-sudoer-request" "읽을 수 있는 JSON 허가를 작성"
                ;;
            *)
                out_menu_choice "71" "generate-sudoer-request" "Write a JSON grant you can read"
                ;;
        esac
```

### 2.7 Implementation Notes (this project)

| Field | Value |
|-------|--------|
| Claimed | yes |
| Codes | `en` (default), `zh-Hant`, `es`, `fr`, `de`, `zh-Hans`, `ja`, `ko` |
| File | `${HOME}/.local/sshd-cli/language`, mode 0600 |
| Env override | `SSHD_CLI_LANG` set to one of the eight codes at process start |
| Load | `app_lang_load` once in `app_main`, after persistence is resolved, before dispatch |
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
- **Intentional**: eight codes, one file, one helper for the menu strings and for human help and about.
- **Anti-fragile**: `SSHD_CLI_LANG` can force a language for one process without deleting the file.
- **Over-protect**: `app_menu_text` stays free of a current-shell `read`, and the language board’s `read` stays in the current shell.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

- Default the menu to a code other than English.
- Hide row **6**, or number the language children **1** and **2**.
- Put `read` inside `app_menu_text`, `app_lang_load`, or `app_lang_save`, including inside a catalog sentence.
- Capture `app_cmd_menu_language` with `$()` or backticks.
- Call `app_lang_load` again after a pick in the same process.
- Add `language` as an argv verb without a revision of this file and of `requirement-shell-cli-interface`.
- Add a language code outside the eight in §2.1 without a new revision of this file.
- Leave human `help` or human `about` in English when `APP_LANG` is another accepted code.
- Pretend JSON about fields, argv `version`, the dns action board, Host and folder pickers, or operational command output follow `APP_LANG`.
- Store the language file in the cache folder or under `/var/sshd-cli`.
- Rewrite an unrecognized language file on load.
- Replace the §2.6 fences with a shortened catalog. Those fences stay the current `./sshd-cli` functions.
- Invent a sample line in §2.4.1, or a translation row in §2.4.2, that the ship unit does not print.
- Change a string listed in §2.4.1 or §2.4.2 without updating the §2.6 fence in the same revision.

## 5. Definition of done

This requirement is satisfied when all of the following hold:

1. Front **6**’s category short follows the code (`language`, `語言`, `语言`, `idioma`, `langue`, `Sprache`, `言語`, `언어`), on every host.
2. **61** stores `en`, **62** stores `zh-Hant`, **63** stores `es`, **64** stores `fr`, **65** stores `de`, **66** stores `zh-Hans`, **67** stores `ja`, and **68** stores `ko`, mode 0600, and the front board redisplays in that language.
3. **0** on the language board does not write the file.
4. A later interactive run with the same `$HOME` opens in the saved language. An unrecognized file still opens in English and is left as written.
5. `SSHD_CLI_LANG` set to one of the eight codes shows that language even when the file says `en`.
6. English menu tests still match the English catalog (default). English `help` still prints `Usage:`.
7. Human `help` and human `about` follow the saved code. JSON about fields stay English. Argv `version` stays English.
8. §2.6 quotes the current helpers from `./sshd-cli`.
9. §2.4.1 matches a live front board and the opening of human `help` and human `about` for each code. §2.4.2 lists the language-board longs, the choose-prompt, the menu-hidden sentences, the unknown-choice warns, row **71**, and the help and about lines that stay `case` arms.
10. **TP-CLI-24** is **have**.

### Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-24** **6** / **61–68**, file, unrecognized line, `SSHD_CLI_LANG`, Japanese and Korean `help` and `about` | `tests/test_cli.sh` | have |
| **TP-CLI-14** English front lists `language` | `tests/test_cli.sh` | have |
| **TP-SSHD-04** Termux front still lists `language` | `tests/test_cli.sh` | have |

**Map:** `reviews/test-plan.md`

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Numbered tree, row **6** / **61–68**, current-shell `read` |
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
| 2026-09-28 | v1.1.0: Spanish (`es`, **63**), French (`fr`, **64**), German (`de`, **65**), Simplified Chinese (`zh-Hans`, **66**). | Grok (owner request) |
| 2026-09-28 | v1.2.0: Japanese (`ja`, **67**), Korean (`ko`, **68**). Human `help` and human `about` follow `APP_LANG`. `app_lang_load` runs once in `app_main`. | Grok (owner request) |
| 2026-09-28 | v1.3.0: worked samples of each front board and of the opening of `help` and `about` (§2.4.1). Translation tables for the language-board longs, prompts, hide lines, warns, row **71**, and the help/about lines that stay `case` arms (§2.4.2). | Grok (owner request) |
| 2026-09-30 | v1.3.1: `help_fix_config` in the §2.6 `app_menu_text` fence. Live sample tokens follow `VERSION` **1.30.0**. | Grok (owner request) |

## 8. Terminology

Words this requirement uses. Each row is the term and the definition this file means by it. No glossary file paths.

| Term | Definition |
|------|------------|
| **Menu language** | The saved choice for the words on the numbered boards named in §2.4, and for human `help` and human `about`. English is the default. Traditional Chinese, Spanish, French, German, Simplified Chinese, Japanese, and Korean are the other choices. The numbers do not change. |
| **Language code** | `en`, `zh-Hant`, `es`, `fr`, `de`, `zh-Hans`, `ja`, or `ko`. The first line of the language file, or `SSHD_CLI_LANG` when that variable is one of those eight codes. Anything else is English for this process. |
| **Menu copy** | The layer titles, category shorts, long descriptions, Back, Exit, choose-prompt, unknown-choice warn, menu-hidden sentences, and the human text of `help` and `about` that follow the language code. Leaf shorts stay the English verb. JSON about fields stay English. |
| **English catalog** | The menu words printed when the language code is `en`. The tables in the menu requirement are this catalog. §2.4.1 shows that board. The other codes use the samples and the translation tables in this file. |
| **Worked sample** | A markdown transcription of a live board, or of the opening of `help` and `about`. Bold is the short. Italic is the long. The version token is the live `VERSION`. The source choose-prompt ends with a space that the sample omits. |
| **Do not capture `read`** | A `read`, and any helper whose body contains `read`, runs in the current shell. `app_cmd_menu_language` is that kind of helper. `app_menu_text` is not, and its body must stay free of those letters so a command substitution stays legal. |

**Last Updated**: 2026-09-30 (1.3.1 `help_fix_config` and live `VERSION` **1.30.0** in the samples. 1.3.0 worked samples and translation tables. 1.2.0 adds `ja`, `ko`, and human help/about. 1.1.0 adds `es`, `fr`, `de`, `zh-Hans`)
**Owner**: sshd-cli project maintainers
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
