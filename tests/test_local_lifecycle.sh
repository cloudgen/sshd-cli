# =============================================================================
# tests/test_local_lifecycle.sh — local install / uninstall / where-is-me
# =============================================================================
# Primary REQs: requirement-shell-self-management, requirement-shell-idempotency,
# requirement-shell-interactive-vs-noninteractive
# TP family: TP-LC-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_local_lifecycle() {
    t_header "Local lifecycle (TP-LC)"

    require_cmd sh

    ci_isolated_env

    # TP-LC-01 install places binary under USER_BIN
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-01 install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-01 binary at USER_BIN" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-01 install success text" "$_out" "successfully installed"

    # TP-LC-02 installed version works
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" version 2>/dev/null)
    assert_eq "TP-LC-02 installed version exit 0" 0 "$?"
    assert_contains "TP-LC-02 installed version" "$_out" "${PRODUCT_VERSION}"

    # TP-LC-03 idempotent reinstall without force
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-03 reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-03 already installed" "$_out" "already installed"

    # TP-LC-04 about shows installed path
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-LC-04 about json exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 json installed true" "$_out" '"installed":"true"'
    assert_contains "TP-LC-04 json local_version" "$_out" "\"local_version\":\"${PRODUCT_VERSION}\""

    # TP-LC-05 self-uninstall --json without force fails closed
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json self-uninstall 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-LC-05 self-uninstall json no-force exit 1" 1 "$_ec"
    assert_file_exists "TP-LC-05 binary remains" "${CI_USER_BIN}/${APP_NAME}"

    # TP-LC-06 self-uninstall --force removes
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" self-uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-06 self-uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-06 binary removed" "${CI_USER_BIN}/${APP_NAME}"

    # TP-LC-07 self-uninstall when absent is success no-op
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" self-uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-07 self-uninstall absent exit 0" 0 "$_ec"
    assert_contains "TP-LC-07 nothing to uninstall" "$_out" "not installed"

    # TP-LC-08 about after install shows installed
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install >/dev/null 2>&1
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json about 2>/dev/null)
    assert_contains "TP-LC-08 about installed true" "$_out" '"installed":"true"'

    # TP-LC-09 managed binary mode must be 0755 (shell ship unit multi-user runnable)
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-09 install mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-09 install mode 0755" "0755" "${_mode}" ;;
    esac
    # Must be readable+executable (not 0711 execute-without-read)
    if [ -r "${CI_USER_BIN}/${APP_NAME}" ] && [ -x "${CI_USER_BIN}/${APP_NAME}" ]; then
        assert_eq "TP-LC-09 readable+executable" "1" "1"
    else
        assert_eq "TP-LC-09 readable+executable" "1" "0"
    fi

    # TP-LC-10 --force reinstall restores mode 0755 (0711 trap)
    chmod 0711 "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || chmod 711 "${CI_USER_BIN}/${APP_NAME}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-10 force reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-10 force reinstall success" "$_out" "successfully installed"
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-10 healed mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-10 healed mode 0755" "0755" "${_mode}" ;;
    esac

    # cleanup remaining binary
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" self-uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env
}
