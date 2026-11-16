# =============================================================================
# tests/test_upplace.sh — upplace (upload and replace)
# =============================================================================
# Primary REQs: requirement-domain-upplace, requirement-domain-sshd,
# requirement-shell-cli-interface, requirement-shell-exit-condition
# TP family: TP-UP-*
# Host names are minted per run (synthetic-test-fixture).
# Fake OpenSSH client via SSHD_CLI_SSH / SSHD_CLI_SCP (no real SSH session).
# The fake executes the remote script with HOME=SSHD_CLI_REMOTE_HOME and
# rewrites only /tmp/ to SSHD_CLI_FAKE_TMP. The product still sends /tmp.
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_up_mint() {
    H_UP=$(t_rand_host)
    IP_UP=$(t_rand_ip)
    H_UP_USER=$(t_rand_host)
    IP_UP_USER=$(t_rand_ip)
}

_up_fixture() {
    mkdir -p "${CI_HOME}/.ssh" "${CI_HOME}/box/app" "${CI_HOME}/ltmp"
    printf 'new\n' > "${CI_HOME}/box/app/new.txt"
    ln -s new.txt "${CI_HOME}/box/app/link.txt"
    chmod 0700 "${CI_HOME}/box/app"
    # Sandbox stays on the default temp dir. The fake rewrites only the product
    # archive and stage names (/tmp/.sshd-cli… and /tmp/sshd-cli.upstage…), so an
    # absolute home path under the same temp dir is not rewritten.
    UP_SAND=$(mktemp -d "${TMPDIR:-/tmp}/upplace-sand.XXXXXX")
    UP_REMOTE="${UP_SAND}/remote-home"
    UP_FAKE="${UP_SAND}/fake-tmp"
    mkdir -p "${UP_REMOTE}/sites/app" "${UP_FAKE}"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    cat > "${CI_HOME}/.ssh/config" <<EOF
Host ${H_UP}
    HostName ${IP_UP}

Host ${H_UP_USER}
    HostName ${IP_UP_USER}
    User ada

Host *
    StrictHostKeyChecking accept-new
EOF
    chmod 700 "${CI_HOME}/.ssh"
    chmod 600 "${CI_HOME}/.ssh/config"
}

_up_fakes() {
    mkdir -p "${CI_HOME}/bin"
    _fake_ssh="${CI_HOME}/bin/ssh"
    _fake_scp="${CI_HOME}/bin/scp"
    cat > "${_fake_ssh}" <<'FAKESSH'
#!/bin/sh
log="${SSHD_CLI_SSH_LOG:-}"
cmd=""
for a in "$@"; do
    cmd="$a"
done
if [ -n "${log}" ]; then
    printf '%s\n' "$*" >> "${log}"
    printf 'CMD<<\n%s\n>>CMD\n' "${cmd}" >> "${log}"
fi
case "${cmd}" in
    *__SSHD_CLI_UNAME__*)
        if [ -n "${SSHD_CLI_FAKE_UNAME:-}${SSHD_CLI_FAKE_OSTYPE:-}" ]; then
            printf '%s\n' "__SSHD_CLI_UNAME__${SSHD_CLI_FAKE_UNAME:-Linux}"
            printf '%s\n' "__SSHD_CLI_OSTYPE__${SSHD_CLI_FAKE_OSTYPE:-}"
            exit 0
        fi
        ;;
esac
home="${SSHD_CLI_REMOTE_HOME:-}"
fake="${SSHD_CLI_FAKE_TMP:-}"
if [ -z "${home}" ] || [ -z "${fake}" ]; then
    printf '%s\n' "fake ssh missing sandbox" >&2
    exit 1
fi
rewritten=$(printf '%s\n' "${cmd}" | sed \
    -e "s|/tmp/\\.sshd-cli|${fake}/.sshd-cli|g" \
    -e "s|/tmp/sshd-cli\\.upstage|${fake}/sshd-cli.upstage|g")
if [ "${SSHD_CLI_FAKE_NO_TMP:-}" = "1" ]; then
    rewritten=$(printf '%s\n' "${rewritten}" | sed \
        -e 's|\[ -d /tmp \] && \[ -w /tmp \] && \[ -x /tmp \]|[ -d /no/such/tmp ]|')
fi
HOME="${home}" sh -c "${rewritten}"
exit $?
FAKESSH
    cat > "${_fake_scp}" <<'FAKESCP'
#!/bin/sh
log="${SSHD_CLI_SCP_LOG:-}"
if [ -n "${log}" ]; then
    printf '%s\n' "$*" >> "${log}"
fi
if [ "${SSHD_CLI_SCP_FAIL:-}" = "1" ]; then
    printf '%s\n' "fake scp refused" >&2
    exit 1
fi
prev=""
last=""
for a in "$@"; do
    prev="${last}"
    last="${a}"
done
src="${prev}"
dst="${last}"
remote="${dst#*:}"
fake="${SSHD_CLI_FAKE_TMP:-}"
case "${remote}" in
    /tmp/.sshd-cli*|/tmp/sshd-cli.upstage*)
        base=$(basename "${remote}")
        cp "${src}" "${fake}/${base}" || exit 1
        ;;
    /*)
        mkdir -p "$(dirname "${remote}")" || exit 1
        cp "${src}" "${remote}" || exit 1
        ;;
    *)
        printf '%s\n' "fake scp dest not /tmp" >&2
        exit 1
        ;;
esac
exit 0
FAKESCP
    chmod 0755 "${_fake_ssh}" "${_fake_scp}"
}

_up_env() {
    # Usage: _up_env  — prints nothing; caller prefixes the command.
    # Kept as a comment marker. Invocations inline the exports.
    :
}

_up_run() {
    # stdin via _up_in if set. Extra env already in the caller's command.
    :
}

run_test_upplace() {
    t_header "upplace upload-and-replace (TP-UP)"

    require_cmd sh
    require_cmd tar
    require_cmd gzip
    require_cmd zip
    require_cmd unzip
    require_cmd awk
    require_cmd sed

    ci_isolated_env
    _up_mint
    _up_fixture
    _up_fakes
    _ssh_log="${CI_HOME}/ssh.log"
    _scp_log="${CI_HOME}/scp.log"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _day=$(date +%Y%m%d)

    # TP-UP-01 help lists upplace
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-UP-01 help lists upplace" "${_out}" "upplace [N|name] [folder] [target]"
    assert_contains "TP-UP-01 help names backup" "${_out}" "same-named remote folder"
    assert_contains "TP-UP-01 help tree names upplace" "${_out}" "dns/ssh/download/upload/upplace"

    # TP-UP-02 non-interactive happy path
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _out=$(HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    assert_eq "TP-UP-02 happy exit 0" 0 "${_ec}"
    assert_contains "TP-UP-02 success names backup" "${_out}" "app.${_day}.bak"
    assert_contains "TP-UP-02 success names target" "${_out}" "~/sites/app"
    assert_file_exists "TP-UP-02 new file replaced" "${UP_REMOTE}/sites/app/new.txt"
    assert_file_missing "TP-UP-02 old file not merged" "${UP_REMOTE}/sites/app/old.txt"
    assert_file_exists "TP-UP-02 bak keeps old file" "${UP_REMOTE}/sites/app.${_day}.bak/old.txt"
    if [ -L "${UP_REMOTE}/sites/app/link.txt" ]; then
        t_pass "TP-UP-02 symlink kept (cp -rP)"
    else
        t_fail "TP-UP-02 symlink kept (cp -rP)"
    fi
    _left=$(find "${UP_FAKE}" -mindepth 1 -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-02 remote temp gone" "" "${_left}"
    _left=$(find "${CI_HOME}/ltmp" -mindepth 1 -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-02 local temp gone" "" "${_left}"
    _log=$(cat "${_ssh_log}")
    assert_contains "TP-UP-02 ssh log has /tmp" "${_log}" "/tmp/"
    assert_contains "TP-UP-02 ssh log has cp -rP" "${_log}" "cp -rP"
    assert_not_contains "TP-UP-02 no stdin tar pipe" "${_log}" "tar xzf -"
    _slog=$(cat "${_scp_log}")
    assert_contains "TP-UP-02 scp dest is /tmp" "${_slog}" ":/tmp/"
    assert_not_contains "TP-UP-02 scp is not the home" "${_slog}" ":app"

    # TP-UP-03 local ~/folder expands on this login only
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    : > "${_ssh_log}"
    _out=$(HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" '~/box/app' '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    assert_eq "TP-UP-03 tilde local exit 0" 0 "${_ec}"
    assert_file_exists "TP-UP-03 tilde local uploaded new.txt" "${UP_REMOTE}/sites/app/new.txt"

    # TP-UP-04 missing remote folder (same basename, no directory) returns 1
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _err=$(HOME="${CI_HOME}" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-04 missing exit 1" 1 "${_ec}"
    assert_contains "TP-UP-04 missing names folder" "${_err}" "has no folder named app"
    assert_contains "TP-UP-04 missing names target" "${_err}" "~/sites/app"
    _log=$(cat "${_ssh_log}")
    assert_not_contains "TP-UP-04 missing did not mv" "${_log}" "mv "
    assert_eq "TP-UP-04 missing did not scp" "" "$(cat "${_scp_log}")"
    assert_file_missing "TP-UP-04 no bak created" "${UP_REMOTE}/sites/missing.${_day}.bak"

    # TP-UP-05 basename mismatch
    mkdir -p "${UP_REMOTE}/sites/other"
    printf 'keep\n' > "${UP_REMOTE}/sites/other/keep.txt"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _err=$(HOME="${CI_HOME}" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/other' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-05 name exit 1" 1 "${_ec}"
    assert_contains "TP-UP-05 name mismatch" "${_err}" "is not named app"
    assert_file_exists "TP-UP-05 other untouched" "${UP_REMOTE}/sites/other/keep.txt"
    assert_eq "TP-UP-05 name did not scp" "" "$(cat "${_scp_log}")"

    # TP-UP-06 target is the remote home
    : > "${_ssh_log}"
    _err=$(HOME="${CI_HOME}" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" "${UP_REMOTE}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-06 home exit 1" 1 "${_ec}"
    assert_contains "TP-UP-06 home refused" "${_err}" "is the remote home"
    _log=$(cat "${_ssh_log}")
    assert_not_contains "TP-UP-06 home did not mv" "${_log}" "mv "
    assert_file_missing "TP-UP-06 home was not renamed" "${UP_REMOTE}.${_day}.bak"

    # TP-UP-07 bad target forms never call ssh
    : > "${_ssh_log}"
    for _bad in '~' '~/' 'sites/app' '~other/box' '~/sites/app;rm' '/'; do
        _err=$(HOME="${CI_HOME}" \
            SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
            SSHD_CLI_SSH_LOG="${_ssh_log}" \
            SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
            sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" "${_bad}" 2>&1 >/dev/null)
        _ec=$?
        assert_eq "TP-UP-07 '${_bad}' exit 1" 1 "${_ec}"
        assert_contains "TP-UP-07 '${_bad}' refused" "${_err}" "not allowed"
    done
    assert_eq "TP-UP-07 bad forms did not ssh" "" "$(cat "${_ssh_log}")"
    unset _bad _err _ec

    # TP-UP-08 Host * is not a concrete entry
    _err=$(HOME="${CI_HOME}" SSHD_CLI_SSH="${_fake_ssh}" \
        sh "${SCRIPT}" upplace '*' "${CI_HOME}/box/app" '~/sites/app' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-08 star exit 1" 1 "${_ec}"
    assert_contains "TP-UP-08 star no host" "${_err}" "No Host entry"

    # TP-UP-09 TTY user default passes -l
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    : > "${_ssh_log}"
    _out=$(printf '\n' | HOME="${CI_HOME}" TTY=1 TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP_USER}" "${CI_HOME}/box/app" '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    assert_eq "TP-UP-09 tty user exit 0" 0 "${_ec}"
    _log=$(cat "${_ssh_log}")
    assert_contains "TP-UP-09 ssh log has -l ada" "${_log}" "-l ada"
    _slog=$(cat "${_scp_log}")
    assert_contains "TP-UP-09 scp has user" "${_slog}" "ada@${H_UP_USER}:/tmp/"

    # TP-UP-10 backup name already exists: no mv of the live folder, no scp
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    printf 'live\n' > "${UP_REMOTE}/sites/app/old.txt"
    printf 'prior\n' > "${UP_REMOTE}/sites/app.${_day}.bak/prior.txt"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _err=$(HOME="${CI_HOME}" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-10 bak exists exit 1" 1 "${_ec}"
    assert_contains "TP-UP-10 bak message" "${_err}" "already exists"
    assert_file_exists "TP-UP-10 live folder stayed" "${UP_REMOTE}/sites/app/old.txt"
    assert_file_exists "TP-UP-10 prior bak stayed" "${UP_REMOTE}/sites/app.${_day}.bak/prior.txt"
    assert_eq "TP-UP-10 bak did not scp" "" "$(cat "${_scp_log}")"

    # TP-UP-11 scp failure rolls the renamed folder back and cleans temps
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _err=$(HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" SSHD_CLI_SCP_FAIL=1 \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-11 scp fail exit 1" 1 "${_ec}"
    assert_contains "TP-UP-11 scp fail message" "${_err}" "scp to ${H_UP} failed"
    assert_file_exists "TP-UP-11 live folder restored" "${UP_REMOTE}/sites/app/old.txt"
    assert_file_missing "TP-UP-11 bak removed by rollback" "${UP_REMOTE}/sites/app.${_day}.bak"
    _left=$(find "${UP_FAKE}" -mindepth 1 -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-11 remote temp gone after scp fail" "" "${_left}"
    _left=$(find "${CI_HOME}/ltmp" -mindepth 1 -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-11 local temp gone after scp fail" "" "${_left}"
    unset SSHD_CLI_SCP_FAIL

    # TP-UP-12 JSON one object; JSON missing is an error object and status 1
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    _j=$(HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" --json upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    assert_eq "TP-UP-12 json exit 0" 0 "${_ec}"
    _n=$(printf '%s\n' "${_j}" | awk 'NF{c++} END{print c+0}')
    assert_eq "TP-UP-12 json one object" "1" "${_n}"
    assert_contains "TP-UP-12 json type" "${_j}" '"type":"upplace"'
    assert_contains "TP-UP-12 json backup" "${_j}" "\"backup\":\"app.${_day}.bak\""
    assert_contains "TP-UP-12 json target" "${_j}" '"target":"~/sites/app"'
    assert_contains "TP-UP-12 json user empty shape" "${_j}" '"user":""'
    _jerr=$(HOME="${CI_HOME}" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" --json upplace "${H_UP}" "${CI_HOME}/box/app" '~/nope/app' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-12 json missing exit 1" 1 "${_ec}"
    assert_contains "TP-UP-12 json error type" "${_jerr}" '"type":"out_error"'
    assert_contains "TP-UP-12 json error code" "${_jerr}" '"code":"upplace_missing"'

    # TP-UP-13 menu missing target returns to the front board (process status 0)
    : > "${_ssh_log}"
    _out=$(printf '%s\n' '1' '19' '1' '' "${CI_HOME}/box/app" '~/nope/app' '9' | \
        HOME="${CI_HOME}" TTY=1 \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" 2>&1)
    # The menu feed uses ~/nope/app (same basename, absent directory).
    _ec=$?
    assert_eq "TP-UP-13 menu exit 0" 0 "${_ec}"
    assert_contains "TP-UP-13 menu shows the error" "${_out}" "has no folder named app"
    _n=$(t_count_substr "${_out}" "9. Exit")
    assert_eq "TP-UP-13 front board returns" "2" "${_n}"
    assert_contains "TP-UP-13 client row 19" "${_out}" "19."
    assert_contains "TP-UP-13 client short upplace" "${_out}" "upplace"

    # TP-UP-14 direct command missing target is status 1 (not a menu)
    _err=$(HOME="${CI_HOME}" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-14 missing operand exit 1" 1 "${_ec}"
    assert_contains "TP-UP-14 missing operand names upplace" "${_err}" "upplace needs a target folder"

    # TP-UP-15 this login Windows cmd uses zip and still lands the archive in /tmp
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _out=$(OS=Windows_NT HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    _log=$(cat "${_ssh_log}")
    _slog=$(cat "${_scp_log}")
    assert_eq "TP-UP-15 windows zip exit 0" 0 "${_ec}"
    assert_contains "TP-UP-15 success names backup" "${_out}" "app.${_day}.bak"
    assert_file_exists "TP-UP-15 new file replaced" "${UP_REMOTE}/sites/app/new.txt"
    assert_contains "TP-UP-15 ssh log has cp -rP" "${_log}" "cp -rP"
    assert_contains "TP-UP-15 ssh log has unzip" "${_log}" "unzip -q -o"
    assert_not_contains "TP-UP-15 no tar xzf" "${_log}" "tar xzf"
    assert_contains "TP-UP-15 scp dest is /tmp" "${_slog}" ":/tmp/"
    assert_contains "TP-UP-15 scp zip" "${_slog}" ".zip"
    assert_not_contains "TP-UP-15 scp is not tar.gz" "${_slog}" ".tar.gz"
    assert_not_contains "TP-UP-15 scp is not the home" "${_slog}" ":app"
    _left=$(find "${UP_FAKE}" -mindepth 1 -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-15 remote temp gone" "" "${_left}"

    # TP-UP-16 this login Git Bash uses zip the same way
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _out=$(MSYSTEM=MINGW64 HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    _log=$(cat "${_ssh_log}")
    _slog=$(cat "${_scp_log}")
    assert_eq "TP-UP-16 git bash zip exit 0" 0 "${_ec}"
    assert_contains "TP-UP-16 ssh log has unzip" "${_log}" "unzip -q -o"
    assert_not_contains "TP-UP-16 no stdin tar" "${_log}" "tar xzf -"
    assert_contains "TP-UP-16 scp dest is /tmp" "${_slog}" ":/tmp/"
    assert_contains "TP-UP-16 scp zip" "${_slog}" ".zip"
    assert_file_exists "TP-UP-16 new file replaced" "${UP_REMOTE}/sites/app/new.txt"

    # TP-UP-17 local /tmp refused: the zip is built under the cache folder
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _out=$(OS=Windows_NT SSHD_CLI_NO_TMP=1 HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    _slog=$(cat "${_scp_log}")
    assert_eq "TP-UP-17 cache zip exit 0" 0 "${_ec}"
    assert_contains "TP-UP-17 scp source is cache" "${_slog}" "cache-${APP_NAME}"
    assert_contains "TP-UP-17 scp zip" "${_slog}" ".zip"
    assert_not_contains "TP-UP-17 scp is not tar.gz" "${_slog}" ".tar.gz"
    assert_file_exists "TP-UP-17 new file replaced" "${UP_REMOTE}/sites/app/new.txt"
    _left=$(find "${CI_HOME}/ltmp" -name '*.zip' -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-17 zip not left in TMPDIR" "" "${_left}"

    # TP-UP-18 remote /tmp refused: the zip lands in the remote cache folder
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    : > "${_ssh_log}"
    : > "${_scp_log}"
    _out=$(SSHD_CLI_FAKE_UNAME=Windows_NT SSHD_CLI_FAKE_NO_TMP=1 \
        HOME="${CI_HOME}" TMPDIR="${CI_HOME}/ltmp" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>"${CI_HOME}/up.err")
    _ec=$?
    _log=$(cat "${_ssh_log}")
    _slog=$(cat "${_scp_log}")
    assert_eq "TP-UP-18 remote cache exit 0" 0 "${_ec}"
    assert_contains "TP-UP-18 scp dest is cache" "${_slog}" ".cache/cache-"
    assert_contains "TP-UP-18 scp zip" "${_slog}" ".zip"
    assert_contains "TP-UP-18 ssh log has cp -rP" "${_log}" "cp -rP"
    assert_file_exists "TP-UP-18 new file replaced" "${UP_REMOTE}/sites/app/new.txt"
    _left=$(find "${UP_REMOTE}" -name '*.zip' -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-18 remote zip gone" "" "${_left}"
    _left=$(find "${UP_FAKE}" -mindepth 1 -print 2>/dev/null | head -n 5)
    assert_eq "TP-UP-18 /tmp archive unused" "" "${_left}"

    # TP-UP-19 missing zip dies before the rename
    /bin/rm -rf "${UP_REMOTE}/sites/app" "${UP_REMOTE}/sites/app.${_day}.bak"
    mkdir -p "${UP_REMOTE}/sites/app"
    printf 'old\n' > "${UP_REMOTE}/sites/app/old.txt"
    _noz=$(mktemp -d "${TMPDIR:-/tmp}/up-noz.XXXXXX")
    for _d in /bin /usr/bin; do
        for _p in "${_d}"/*; do
            [ -e "${_p}" ] || continue
            _c=$(basename "${_p}")
            case "${_c}" in
                zip|unzip) continue ;;
            esac
            if [ ! -e "${_noz}/${_c}" ]; then
                ln -s "${_p}" "${_noz}/${_c}"
            fi
        done
    done
    : > "${_ssh_log}"
    _err=$(OS=Windows_NT PATH="${_noz}" HOME="${CI_HOME}" \
        SSHD_CLI_SSH="${_fake_ssh}" SSHD_CLI_SCP="${_fake_scp}" \
        SSHD_CLI_SSH_LOG="${_ssh_log}" SSHD_CLI_SCP_LOG="${_scp_log}" \
        SSHD_CLI_REMOTE_HOME="${UP_REMOTE}" SSHD_CLI_FAKE_TMP="${UP_FAKE}" \
        sh "${SCRIPT}" upplace "${H_UP}" "${CI_HOME}/box/app" '~/sites/app' 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-UP-19 zip missing exit 1" 1 "${_ec}"
    assert_contains "TP-UP-19 names zip" "${_err}" "zip not found"
    assert_file_exists "TP-UP-19 folder not renamed" "${UP_REMOTE}/sites/app/old.txt"
    assert_file_missing "TP-UP-19 no bak" "${UP_REMOTE}/sites/app.${_day}.bak"
    /bin/rm -rf "${_noz}"

    if [ -n "${UP_SAND:-}" ] && [ -d "${UP_SAND}" ]; then
        /bin/rm -rf "${UP_SAND}"
    fi
    if [ -n "${T_REAL_HOME:-}" ]; then
        HOME="${T_REAL_HOME}"
        export HOME
    fi
    ci_cleanup_env
    unset H_UP IP_UP H_UP_USER IP_UP_USER UP_REMOTE UP_FAKE UP_SAND _fake_ssh _fake_scp _ssh_log _scp_log _day _out _err _ec _log _slog _left _j _jerr _n
}
