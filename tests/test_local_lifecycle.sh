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

    # TP-LC-11 install creates ~/.bashrc with USER_BIN PATH
    assert_file_exists "TP-LC-11 created ~/.bashrc" "${CI_HOME}/.bashrc"
    _bashrc=$(cat "${CI_HOME}/.bashrc" 2>/dev/null || true)
    assert_contains "TP-LC-11 bashrc has USER_BIN" "$_bashrc" "${CI_USER_BIN}"

    # TP-LC-12 install creates ~/.profile that sources ~/.bashrc
    assert_file_exists "TP-LC-12 created ~/.profile" "${CI_HOME}/.profile"
    _profile=$(cat "${CI_HOME}/.profile" 2>/dev/null || true)
    assert_contains "TP-LC-12 profile sources bashrc" "$_profile" '. "${HOME}/.bashrc"'

    # TP-LC-02 installed version works
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" version 2>/dev/null)
    assert_eq "TP-LC-02 installed version exit 0" 0 "$?"
    assert_contains "TP-LC-02 installed version" "$_out" "${PRODUCT_VERSION}"

    # TP-LC-03 idempotent reinstall without force
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-03 reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-03 already installed" "$_out" "already installed"

    # TP-LC-13 re-run does not duplicate PATH lines
    _path_hits=$(grep -cF "${CI_USER_BIN}" "${CI_HOME}/.bashrc" 2>/dev/null || echo 0)
    assert_eq "TP-LC-13 bashrc PATH line once" "1" "$_path_hits"

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

    # TP-LC-14 existing ~/.profile body is kept; ~/.bashrc is modified not replaced
    ci_isolated_env
    printf '%s\n' "# keep-me-profile" > "${CI_HOME}/.profile"
    printf '%s\n' "# keep-me-bashrc" > "${CI_HOME}/.bashrc"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-14 install with existing rc exit 0" 0 "$_ec"
    _profile=$(cat "${CI_HOME}/.profile" 2>/dev/null || true)
    _bashrc=$(cat "${CI_HOME}/.bashrc" 2>/dev/null || true)
    assert_contains "TP-LC-14 profile body kept" "$_profile" "keep-me-profile"
    assert_not_contains "TP-LC-14 profile not replaced with marker block" "$_profile" "BEGIN ${APP_NAME} profile"
    assert_contains "TP-LC-14 bashrc body kept" "$_bashrc" "keep-me-bashrc"
    assert_contains "TP-LC-14 bashrc still got PATH" "$_bashrc" "${CI_USER_BIN}"
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" self-uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env

    # TP-LC-15 not Termux: pkg is not invoked
    ci_isolated_env
    mkdir -p "${CI_HOME}/stubbin"
    printf '%s\n' '#!/bin/sh' "echo CALLED >> \"${CI_HOME}/pkg-called.log\"" 'exit 1' > "${CI_HOME}/stubbin/pkg"
    chmod +x "${CI_HOME}/stubbin/pkg"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" PATH="${CI_HOME}/stubbin:${PATH}" env -u TERMUX_VERSION sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-15 non-Termux install exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-15 pkg not called" "${CI_HOME}/pkg-called.log"
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" self-uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env

    # TP-LC-16 Termux mock: pkg install -y openssh termux-auth
    # TP-LC-17 install ends by starting sshd (stub daemon)
    ci_isolated_env
    PREFIX="${CI_HOME}/usr"
    mkdir -p "${PREFIX}/bin" "${PREFIX}/etc/ssh" "${PREFIX}/var/run" "${CI_HOME}/stubbin"
    printf '%s\n' 'Port 8022' "PidFile ${PREFIX}/var/run/sshd.pid" > "${PREFIX}/etc/ssh/sshd_config"
    : > "${PREFIX}/etc/ssh/ssh_host_ed25519_key"
    cat > "${PREFIX}/bin/sshd" <<EOF
#!/bin/sh
if [ "\$1" = "-t" ]; then
    exit 0
fi
nohup sleep 120 >/dev/null 2>&1 &
echo \$! > "${PREFIX}/var/run/sshd.pid"
exit 0
EOF
    chmod +x "${PREFIX}/bin/sshd"
    printf '%s\n' '#!/bin/sh' "printf '%s\\n' \"\$*\" >> \"${CI_HOME}/pkg-args.log\"" 'exit 0' > "${CI_HOME}/stubbin/pkg"
    chmod +x "${CI_HOME}/stubbin/pkg"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" PREFIX="${PREFIX}" PATH="${CI_HOME}/stubbin:${PREFIX}/bin:${PATH}" TERMUX_VERSION=1 sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-16 Termux mock install exit 0" 0 "$_ec"
    _pkg_args=$(cat "${CI_HOME}/pkg-args.log" 2>/dev/null || true)
    assert_contains "TP-LC-16 pkg install -y" "$_pkg_args" "install -y openssh termux-auth"
    assert_contains "TP-LC-17 install started sshd" "$_out" "sshd started"
    assert_file_exists "TP-LC-17 stub pidfile" "${PREFIX}/var/run/sshd.pid"
    _stub_pid=$(tr -d ' \n\r\t' < "${PREFIX}/var/run/sshd.pid" 2>/dev/null || true)
    if [ -n "${_stub_pid}" ] && kill -0 "${_stub_pid}" 2>/dev/null; then
        t_pass "TP-LC-17 stub sshd pid is live"
        kill "${_stub_pid}" 2>/dev/null || true
    else
        t_fail "TP-LC-17 stub sshd pid is live"
    fi
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" self-uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env
}
