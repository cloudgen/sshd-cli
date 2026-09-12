# =============================================================================
# tests/test_ssh_download.sh — ssh Host pick + download remote folder
# =============================================================================
# Primary REQs: requirement-domain-sshd, requirement-shell-cli-interface,
# requirement-shell-interactive-vs-noninteractive
# TP families: TP-SSH-*, TP-DL-*
# Host names are minted per run (synthetic-test-fixture).
# Fake OpenSSH client via SSHD_CLI_SSH (no real SSH session).
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_ssh_dl_mint() {
    H_SSH=$(t_rand_host)
    H_DL=$(t_rand_host)
    IP_SSH=$(t_rand_ip)
    IP_DL=$(t_rand_ip)
}

_ssh_dl_fixture() {
    mkdir -p "${CI_HOME}/.ssh"
    cat > "${CI_HOME}/.ssh/config" <<EOF
Host ${H_SSH}
    HostName ${IP_SSH}
    User u1

Host ${H_DL}
    HostName ${IP_DL}

Host *
    StrictHostKeyChecking accept-new
EOF
    chmod 700 "${CI_HOME}/.ssh"
    chmod 600 "${CI_HOME}/.ssh/config"
}

_ssh_dl_fake() {
    mkdir -p "${CI_HOME}/bin"
    _fake_ssh="${CI_HOME}/bin/ssh"
    cat > "${_fake_ssh}" <<'FAKESSH'
#!/bin/sh
log="${SSHD_CLI_SSH_LOG:-}"
if [ -n "${log}" ]; then
    printf '%s\n' "$*" >> "${log}"
fi
fix="${SSHD_CLI_TAR_FIXTURE:-}"
base="${SSHD_CLI_TAR_BASE:-}"
if [ -n "${fix}" ] && [ -d "${fix}" ]; then
    if [ -z "${base}" ]; then
        base=$(basename "${fix}")
    fi
    tmp=$(mktemp -d "${TMPDIR:-/tmp}/fake-ssh-tar.XXXXXX") || exit 1
    mkdir -p "${tmp}/${base}"
    (cd "${fix}" && tar cf - .) | (cd "${tmp}/${base}" && tar xf -)
    tar czf - -C "${tmp}" "${base}"
    rm -rf "${tmp}"
    exit 0
fi
exit 0
FAKESSH
    chmod 0755 "${_fake_ssh}"
}

run_test_ssh_download() {
    t_header "ssh Host pick + download folder (TP-SSH / TP-DL)"

    require_cmd sh
    require_cmd tar
    require_cmd awk

    ci_isolated_env
    _ssh_dl_mint
    _ssh_dl_fixture
    _ssh_dl_fake
    _ssh_log="${CI_HOME}/ssh.log"
    : > "${_ssh_log}"

    # TP-SSH-01 help lists ssh
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" help 2>&1)
    assert_contains "TP-SSH-01 help lists ssh" "$_out" "ssh ["
    assert_contains "TP-SSH-01 help lists download" "$_out" "download ["

    # TP-SSH-02 non-interactive ssh by name uses Host alias
    : > "${_ssh_log}"
    _out=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
        sh "${SCRIPT}" ssh "${H_SSH}" 2>&1)
    _ec=$?
    assert_eq "TP-SSH-02 ssh by name exit 0" 0 "$_ec"
    _log=$(cat "${_ssh_log}")
    assert_contains "TP-SSH-02 log has alias" "$_log" "${H_SSH}"
    assert_not_contains "TP-SSH-02 log has no HostName" "$_log" "${IP_SSH}"

    # TP-SSH-03 ssh by number
    : > "${_ssh_log}"
    _out=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
        sh "${SCRIPT}" ssh 1 2>&1)
    _ec=$?
    assert_eq "TP-SSH-03 ssh by number exit 0" 0 "$_ec"
    _log=$(cat "${_ssh_log}")
    assert_contains "TP-SSH-03 log first host" "$_log" "${H_SSH}"

    # TP-SSH-04 missing operand fail-closed
    _err=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" sh "${SCRIPT}" ssh 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-SSH-04 missing n exit 1" 1 "$_ec"
    assert_contains "TP-SSH-04 Next dns list" "$_err" "dns list"

    # TP-SSH-05 unknown host fail-closed
    _err=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" sh "${SCRIPT}" ssh no-such-host 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-SSH-05 unknown host exit 1" 1 "$_ec"
    assert_contains "TP-SSH-05 Next dns list" "$_err" "dns list"

    # TP-SSH-06 JSON does not start a session
    : > "${_ssh_log}"
    _out=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
        sh "${SCRIPT}" --json ssh "${H_SSH}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-SSH-06 json ssh exit 0" 0 "$_ec"
    assert_contains "TP-SSH-06 json type" "$_out" '"type":"ssh"'
    assert_contains "TP-SSH-06 json dns" "$_out" "\"dns\":\"${H_SSH}\""
    _log=$(cat "${_ssh_log}")
    assert_eq "TP-SSH-06 json did not invoke ssh" "" "${_log}"

    # TP-SSH-07 TTY pick 1
    : > "${_ssh_log}"
    _out=$(HOME="${CI_HOME}" INTERACTIVE=1 SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
        sh "${SCRIPT}" ssh <<'EOF'
1
EOF
)
    _ec=$?
    assert_eq "TP-SSH-07 tty pick exit 0" 0 "$_ec"
    _log=$(cat "${_ssh_log}")
    assert_contains "TP-SSH-07 tty picked first alias" "$_log" "${H_SSH}"

    # TP-DL-01 help lists download (also TP-SSH-01)
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" help 2>&1)
    assert_contains "TP-DL-01 help download operand" "$_out" "download [N|name]"

    _fix="${CI_HOME}/remote-box"
    mkdir -p "${_fix}"
    printf 'ok\n' > "${_fix}/ok.txt"
    _wd=$(mktemp -d "${TMPDIR:-/tmp}/dl-wd.XXXXXX")

    # TP-DL-02 non-interactive download extracts in cwd
    _out=$(
        cd "${_wd}" || exit 1
        HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
            SSHD_CLI_TAR_FIXTURE="${_fix}" SSHD_CLI_TAR_BASE="app" \
            sh "${SCRIPT}" download "${H_DL}" /opt/app 2>&1
    )
    _ec=$?
    assert_eq "TP-DL-02 download exit 0" 0 "$_ec"
    assert_file_exists "TP-DL-02 extracted marker" "${_wd}/app/ok.txt"
    assert_contains "TP-DL-02 success names host" "$_out" "${H_DL}"

    # TP-DL-03 remembers folder for that dns
    _mem="${CI_HOME}/.local/sshd-cli/download-folders"
    assert_file_exists "TP-DL-03 memory file" "${_mem}"
    _mc=$(cat "${_mem}")
    assert_contains "TP-DL-03 memory dns" "$_mc" "${H_DL}"
    assert_contains "TP-DL-03 memory path" "$_mc" "/opt/app"

    # TP-DL-04 TTY numbered previous folder
    _wd2=$(mktemp -d "${TMPDIR:-/tmp}/dl-wd2.XXXXXX")
    : > "${_ssh_log}"
    _out=$(
        cd "${_wd2}" || exit 1
        HOME="${CI_HOME}" INTERACTIVE=1 SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
            SSHD_CLI_TAR_FIXTURE="${_fix}" SSHD_CLI_TAR_BASE="app" \
            sh "${SCRIPT}" download "${H_DL}" <<'EOF'
1
EOF
    )
    _ec=$?
    assert_eq "TP-DL-04 tty previous exit 0" 0 "$_ec"
    assert_contains "TP-DL-04 lists previous path" "$_out" "/opt/app"
    assert_file_exists "TP-DL-04 extracted from previous" "${_wd2}/app/ok.txt"

    # TP-DL-05 TTY type a new folder path (non-number)
    _wd3=$(mktemp -d "${TMPDIR:-/tmp}/dl-wd3.XXXXXX")
    _out=$(
        cd "${_wd3}" || exit 1
        HOME="${CI_HOME}" INTERACTIVE=1 SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
            SSHD_CLI_TAR_FIXTURE="${_fix}" SSHD_CLI_TAR_BASE="other" \
            sh "${SCRIPT}" download "${H_DL}" <<'EOF'
/var/data/other
EOF
    )
    _ec=$?
    assert_eq "TP-DL-05 tty new path exit 0" 0 "$_ec"
    assert_file_exists "TP-DL-05 extracted other" "${_wd3}/other/ok.txt"
    _mc=$(cat "${_mem}")
    assert_contains "TP-DL-05 memory new path" "$_mc" "/var/data/other"

    # TP-DL-06 missing folder fail-closed
    _err=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" sh "${SCRIPT}" download "${H_DL}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DL-06 missing folder exit 1" 1 "$_ec"
    assert_contains "TP-DL-06 Next folder" "$_err" "download"

    # TP-DL-07 refuse shell metacharacters
    _err=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" sh "${SCRIPT}" download "${H_DL}" '/opt/app;rm' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DL-07 bad folder exit 1" 1 "$_ec"
    assert_contains "TP-DL-07 not allowed" "$_err" "not allowed"

    # TP-DL-08 JSON download one object
    _wd4=$(mktemp -d "${TMPDIR:-/tmp}/dl-wd4.XXXXXX")
    _out=$(
        cd "${_wd4}" || exit 1
        HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SSH_LOG="${_ssh_log}" \
            SSHD_CLI_TAR_FIXTURE="${_fix}" SSHD_CLI_TAR_BASE="app" \
            sh "${SCRIPT}" --json download "${H_DL}" /opt/app 2>/dev/null
    )
    _ec=$?
    assert_eq "TP-DL-08 json download exit 0" 0 "$_ec"
    assert_contains "TP-DL-08 json type" "$_out" '"type":"download"'
    assert_contains "TP-DL-08 json dns" "$_out" "\"dns\":\"${H_DL}\""
    assert_contains "TP-DL-08 json folder" "$_out" '"folder":"/opt/app"'
    assert_file_exists "TP-DL-08 json extracted" "${_wd4}/app/ok.txt"

    # TP-DL-09 Host * is not a download/ssh row
    _err=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" sh "${SCRIPT}" ssh '*' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DL-09 wildcard ssh exit 1" 1 "$_ec"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns list 2>&1)
    assert_not_contains "TP-DL-09 list has no asterisk row" "$_out" "*  "

    rm -rf "${_wd}" "${_wd2}" "${_wd3}" "${_wd4}" "${_fix}"
    ci_cleanup_env
}
