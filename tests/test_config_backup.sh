# =============================================================================
# tests/test_config_backup.sh — backup-config / sync-config / sudoers (local)
# =============================================================================
# Primary REQs: requirement-sshd-config-backup, requirement-sudoer-json-file,
# requirement-shell-sudo-command, requirement-domain-sshd
# TP family: TP-CFG-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_config_backup() {
    t_header "SSH config deposit (TP-CFG)"

    require_cmd sh
    require_cmd grep

    # TP-CFG-01 Type 0 backup-config into SSHD_CLI_ROOT (no sudo)
    ci_isolated_env
    mkdir -p "${CI_HOME}/.ssh"
    printf 'Host cfghost\n  HostName example.test\n' > "${CI_HOME}/.ssh/config"
    chmod 600 "${CI_HOME}/.ssh/config"
    _store=$(mktemp -d "${TMPDIR:-/tmp}/sshd-store.XXXXXX")
    _out=$(HOME="${CI_HOME}" SSHD_CLI_ROOT="${_store}" sh "${SCRIPT}" backup-config 2>&1)
    _ec=$?
    assert_eq "TP-CFG-01 backup-config exit 0" 0 "$_ec"
    assert_file_exists "TP-CFG-01 store config exists" "${_store}/config"
    assert_contains "TP-CFG-01 backup-config complete" "$_out" "backup-config complete"
    ci_cleanup_env

    # TP-CFG-02 sync-config writes ~/.ssh/config mode 600
    ci_isolated_env
    mkdir -p "${_store}"
    printf 'Host synchost\n  HostName example.test\n' > "${_store}/config"
    chmod 644 "${_store}/config"
    _out=$(HOME="${CI_HOME}" SSHD_CLI_ROOT="${_store}" sh "${SCRIPT}" sync-config 2>&1)
    _ec=$?
    assert_eq "TP-CFG-02 sync-config exit 0" 0 "$_ec"
    assert_file_exists "TP-CFG-02 dest config exists" "${CI_HOME}/.ssh/config"
    assert_contains "TP-CFG-02 sync-config complete" "$_out" "sync-config complete"
    _mode=$(stat -c '%a' "${CI_HOME}/.ssh/config" 2>/dev/null || stat -f '%OLp' "${CI_HOME}/.ssh/config")
    assert_eq "TP-CFG-02 dest mode 600" "600" "${_mode}"
    ci_cleanup_env

    # TP-CFG-03 missing source fail-closed + Next
    ci_isolated_env
    _err=$(HOME="${CI_HOME}" SSHD_CLI_ROOT="${_store}" sh "${SCRIPT}" backup-config 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CFG-03 missing source exit 1" 1 "$_ec"
    assert_contains "TP-CFG-03 missing source Next" "$_err" "Next:"
    ci_cleanup_env

    # TP-CFG-04 Termux: backup-config fail-closed; INFO on menu
    ci_isolated_env
    _err=$(HOME="${CI_HOME}" TERMUX_VERSION=1 sh "${SCRIPT}" backup-config 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CFG-04 Termux backup-config exit 1" 1 "$_ec"
    assert_contains "TP-CFG-04 Termux not available" "$_err" "not available for termux"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 TERMUX_VERSION=1 sh "${SCRIPT}" </dev/null 2>&1)
    assert_contains "TP-CFG-04 Termux menu INFO" "$_out" "backup-config and sync-config not available for termux"
    assert_not_contains "TP-CFG-04 Termux no row 6" "$_out" "6. backup-config"
    ci_cleanup_env

    # TP-CFG-05 Git Bash menu INFO
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 MSYSTEM=MINGW64 env -u TERMUX_VERSION sh "${SCRIPT}" </dev/null 2>&1)
    assert_contains "TP-CFG-05 Git Bash menu INFO" "$_out" "backup-config and sync-config not available for gitbash"
    assert_not_contains "TP-CFG-05 Git Bash no row 6" "$_out" "6. backup-config"
    _err=$(HOME="${CI_HOME}" MSYSTEM=MINGW64 env -u TERMUX_VERSION sh "${SCRIPT}" sync-config 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CFG-05 Git Bash sync-config exit 1" 1 "$_ec"
    ci_cleanup_env

    # TP-CFG-06 print-sudoers --allow-test-local names backup-config only
    ci_isolated_env
    _draft="${CI_HOME}/sudoers.fragment"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --allow-test-local print-sudoers "${_draft}" 2>&1)
    _ec=$?
    assert_eq "TP-CFG-06 print-sudoers test-local exit 0" 0 "$_ec"
    assert_file_exists "TP-CFG-06 fragment written" "${_draft}"
    assert_contains "TP-CFG-06 fragment backup-config" "$(cat "${_draft}")" "backup-config"
    assert_not_contains "TP-CFG-06 no /bin/cp" "$(cat "${_draft}")" "/bin/cp"
    assert_not_contains "TP-CFG-06 no /bin/chmod" "$(cat "${_draft}")" "/bin/chmod"
    ci_cleanup_env

    # TP-CFG-07 generate-sudoer-request JSON grant
    ci_isolated_env
    _jsonf="${CI_HOME}/grant.json"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --allow-test-local generate-sudoer-request "${_jsonf}" 2>&1)
    _ec=$?
    assert_eq "TP-CFG-07 generate-sudoer-request exit 0" 0 "$_ec"
    assert_file_exists "TP-CFG-07 json written" "${_jsonf}"
    assert_contains "TP-CFG-07 json backup-config" "$(cat "${_jsonf}")" '"backup-config"'
    assert_contains "TP-CFG-07 json service" "$(cat "${_jsonf}")" "\"service\":\"${APP_NAME}\""
    ci_cleanup_env

    # TP-CFG-08 restore-config is not a verb
    _err=$(sh "${SCRIPT}" restore-config 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CFG-08 restore-config exit 1" 1 "$_ec"
    assert_contains "TP-CFG-08 restore-config unknown" "$_err" "Unknown command"

    # TP-CFG-09 Windows cmd menu INFO
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" TTY=1 OS=Windows_NT COMSPEC='C:\\Windows\\system32\\cmd.exe' env -u TERMUX_VERSION -u MSYSTEM -u WSL_DISTRO_NAME sh "${SCRIPT}" </dev/null 2>&1)
    assert_contains "TP-CFG-09 Windows cmd menu INFO" "$_out" "backup-config and sync-config not available for windows-cmd"
    ci_cleanup_env

    if [ -n "${_store:-}" ] && [ -d "${_store}" ]; then
        rm -rf "${_store}"
    fi
    unset _store _out _ec _err _mode _draft _jsonf
}
