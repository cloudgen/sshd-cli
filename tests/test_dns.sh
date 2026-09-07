# =============================================================================
# tests/test_dns.sh — this login ~/.ssh/config Host list (dns-ip)
# =============================================================================
# Primary REQs: requirement-domain-sshd, requirement-shell-interactive-vs-noninteractive,
# requirement-shell-cli-interface
# TP family: TP-DNS-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_dns_fixture() {
    mkdir -p "${CI_HOME}/.ssh"
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Host phone
    HostName 192.168.1.10
    Port 8022

Host laptop
    HostName 10.0.0.5
    User alice

Host *
    StrictHostKeyChecking accept-new
EOF
    chmod 700 "${CI_HOME}/.ssh"
    chmod 600 "${CI_HOME}/.ssh/config"
}

run_test_dns() {
    t_header "dns Host list (TP-DNS)"

    require_cmd sh
    require_cmd awk

    ci_isolated_env
    _dns_fixture

    # TP-DNS-01 help lists dns
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" help 2>&1)
    assert_contains "TP-DNS-01 help lists dns" "$_out" "dns ["

    # TP-DNS-02 numbered list; Host * omitted
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns list 2>&1)
    _ec=$?
    assert_eq "TP-DNS-02 dns list exit 0" 0 "$_ec"
    assert_contains "TP-DNS-02 row 1 phone" "$_out" "1. phone"
    assert_contains "TP-DNS-02 row 2 laptop" "$_out" "2. laptop"
    assert_contains "TP-DNS-02 phone ip" "$_out" "192.168.1.10"
    assert_not_contains "TP-DNS-02 no wildcard Host *" "$_out" "Host *"
    assert_not_contains "TP-DNS-02 no asterisk row" "$_out" "*  "

    # TP-DNS-03 show: user empty → empty; port set
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show 1 2>&1)
    assert_contains "TP-DNS-03 dns phone" "$_out" "dns:  phone"
    assert_contains "TP-DNS-03 ip" "$_out" "ip:   192.168.1.10"
    assert_contains "TP-DNS-03 user empty" "$_out" "user: empty"
    assert_contains "TP-DNS-03 port 8022" "$_out" "port: 8022"

    # TP-DNS-04 show by name: empty port displays 22
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show laptop 2>&1)
    assert_contains "TP-DNS-04 user alice" "$_out" "user: alice"
    assert_contains "TP-DNS-04 port default 22" "$_out" "port: 22"

    # TP-DNS-05 non-interactive set ip
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set 1 ip 10.9.8.7 2>&1)
    _ec=$?
    assert_eq "TP-DNS-05 set ip exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-05 config HostName updated" "$_cfg" "HostName 10.9.8.7"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show 1 2>&1)
    assert_contains "TP-DNS-05 show new ip" "$_out" "ip:   10.9.8.7"

    # TP-DNS-06 "" clears user
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set laptop user '""' 2>&1)
    _ec=$?
    assert_eq "TP-DNS-06 clear user exit 0" 0 "$_ec"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show laptop 2>&1)
    assert_contains "TP-DNS-06 user now empty" "$_out" "user: empty"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_not_contains "TP-DNS-06 User line omitted" "$_cfg" "User alice"

    # TP-DNS-07 JSON list
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json dns list 2>/dev/null)
    _ec=$?
    assert_eq "TP-DNS-07 json list exit 0" 0 "$_ec"
    assert_contains "TP-DNS-07 type dns_list" "$_out" '"type":"dns_list"'
    assert_contains "TP-DNS-07 items array" "$_out" '"items":['
    assert_contains "TP-DNS-07 phone in json" "$_out" '"dns":"phone"'
    assert_contains "TP-DNS-07 user_display" "$_out" '"user_display":"empty"'

    # TP-DNS-08 edit without TTY fails closed
    _err=$(HOME="${CI_HOME}" env -u INTERACTIVE sh "${SCRIPT}" dns edit 1 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DNS-08 edit non-tty exit 1" 1 "$_ec"
    assert_contains "TP-DNS-08 edit Next dns set" "$_err" "Next:"
    assert_contains "TP-DNS-08 edit names dns set" "$_err" "dns set"

    # TP-DNS-09 unknown n fail-closed
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show 99 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DNS-09 missing n exit 1" 1 "$_ec"
    assert_contains "TP-DNS-09 missing Next list" "$_err" "dns list"

    # TP-DNS-10 add non-interactive
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns add dns nas ip 10.0.0.8 port 2200 2>&1)
    _ec=$?
    assert_eq "TP-DNS-10 add exit 0" 0 "$_ec"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns list 2>&1)
    assert_contains "TP-DNS-10 nas listed" "$_out" "nas"
    assert_contains "TP-DNS-10 nas ip" "$_out" "10.0.0.8"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-10 Host nas written" "$_cfg" "Host nas"
    assert_contains "TP-DNS-10 Port 2200 written" "$_cfg" "Port 2200"

    # TP-DNS-11 non-interactive dns (no subcommand) lists, no hang
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns 2>&1)
    _ec=$?
    assert_eq "TP-DNS-11 bare dns exit 0" 0 "$_ec"
    assert_contains "TP-DNS-11 bare dns lists phone" "$_out" "1. phone"

    # TP-DNS-12 INTERACTIVE field walk: "" clears ip
    _out=$(HOME="${CI_HOME}" INTERACTIVE=1 sh "${SCRIPT}" dns edit 1 <<'EOF'
phone
""

EOF
)
    _ec=$?
    assert_eq "TP-DNS-12 interactive edit exit 0" 0 "$_ec"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show 1 2>&1)
    assert_contains "TP-DNS-12 ip cleared to empty" "$_out" "ip:   empty"

    # TP-DNS-13 pick 9 is Host row 9 (not Exit)
    {
        printf 'Host h1\n    HostName 10.0.0.1\n\n'
        printf 'Host h2\n    HostName 10.0.0.2\n\n'
        printf 'Host h3\n    HostName 10.0.0.3\n\n'
        printf 'Host h4\n    HostName 10.0.0.4\n\n'
        printf 'Host h5\n    HostName 10.0.0.5\n\n'
        printf 'Host h6\n    HostName 10.0.0.6\n\n'
        printf 'Host h7\n    HostName 10.0.0.7\n\n'
        printf 'Host h8\n    HostName 10.0.0.8\n\n'
        printf 'Host h9\n    HostName 10.0.0.9\n\n'
        printf 'Host h10\n    HostName 10.0.0.10\n\n'
        printf 'Host *\n    StrictHostKeyChecking accept-new\n'
    } > "${CI_HOME}/.ssh/config"
    _out=$(HOME="${CI_HOME}" INTERACTIVE=1 sh "${SCRIPT}" dns <<'EOF'
9
EOF
)
    _ec=$?
    assert_eq "TP-DNS-13 pick 9 exit 0" 0 "$_ec"
    assert_contains "TP-DNS-13 pick 9 shows h9" "$_out" "dns:  h9"
    assert_contains "TP-DNS-13 pick 9 ip" "$_out" "ip:   10.0.0.9"
    assert_not_contains "TP-DNS-13 no Exit 9 row" "$_out" "9. Exit"

    # TP-DNS-14 add inserts before trailing Host *
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Host phone
    HostName 192.168.1.10

Host *
    User ubuntu
    Port 22
EOF
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns add dns nas ip 10.0.0.8 user termux port 8022 2>&1)
    _ec=$?
    assert_eq "TP-DNS-14 add before Host * exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    _seq=$(awk '{s=$0; sub(/^[[:space:]]+/,"",s); if (s ~ /^[Hh][Oo][Ss][Tt][[:space:]]/) { sub(/^[Hh][Oo][Ss][Tt][[:space:]]+/, "", s); print s }}' "${CI_HOME}/.ssh/config")
    _nas_line=$(printf '%s\n' "$_seq" | awk '/^nas($| )/{print NR; exit}')
    _star_line=$(printf '%s\n' "$_seq" | awk '/^\*/{print NR; exit}')
    _ok=0
    if [ -n "$_nas_line" ] && [ -n "$_star_line" ] && [ "$_nas_line" -lt "$_star_line" ]; then
        _ok=1
    fi
    assert_eq "TP-DNS-14 nas Host line before Host *" 1 "$_ok"
    assert_contains "TP-DNS-14 nas user written" "$_cfg" "User termux"
    assert_contains "TP-DNS-14 nas port written" "$_cfg" "Port 8022"

    # TP-DNS-15 extra Host aliases kept on set
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Host phone phone.lan
    IdentityFile ~/.ssh/id_ed25519
    HostName 192.168.1.10
EOF
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set 1 ip 10.1.2.3 2>&1)
    _ec=$?
    assert_eq "TP-DNS-15 set ip extra aliases exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-15 Host aliases kept" "$_cfg" "Host phone phone.lan"
    assert_contains "TP-DNS-15 IdentityFile kept" "$_cfg" "IdentityFile ~/.ssh/id_ed25519"
    assert_contains "TP-DNS-15 new ip" "$_cfg" "HostName 10.1.2.3"

    # TP-DNS-16 Keyword=value / Keyword = value parse; set does not corrupt User
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Host phone
    HostName=192.168.1.10
    User = alice
    Port 8022
EOF
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show 1 2>&1)
    assert_contains "TP-DNS-16 show equals-form ip" "$_out" "ip:   192.168.1.10"
    assert_contains "TP-DNS-16 show equals-form user" "$_out" "user: alice"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set 1 ip 10.9.8.7 2>&1)
    _ec=$?
    assert_eq "TP-DNS-16 set ip equals-form exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-16 HostName canonical" "$_cfg" "HostName 10.9.8.7"
    assert_contains "TP-DNS-16 User alice kept" "$_cfg" "User alice"
    assert_not_contains "TP-DNS-16 no User equals leftover" "$_cfg" "User ="
    assert_not_contains "TP-DNS-16 old HostName= gone" "$_cfg" "HostName=192.168.1.10"

    # TP-DNS-17 Match / Include skipped on list
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Include /no/such/config
Match host foo
    HostName 9.9.9.9
Host phone
    HostName 192.168.1.10
Host *
    User ubuntu
EOF
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns list 2>&1)
    assert_contains "TP-DNS-17 lists phone" "$_out" "1. phone"
    assert_not_contains "TP-DNS-17 no Match host" "$_out" "foo"
    assert_not_contains "TP-DNS-17 no Include path" "$_out" "/no/such"
    assert_not_contains "TP-DNS-17 no Host *" "$_out" "*  "

    # TP-DNS-18 after COMMAND=dns, token dns is a field name
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Host phone
    HostName 192.168.1.10
EOF
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set 1 dns phone2 2>&1)
    _ec=$?
    assert_eq "TP-DNS-18 set dns field exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-18 renamed Host" "$_cfg" "Host phone2"
    _first=$(awk '{k=$1; gsub(/[[:space:]]/,"",k); if (tolower(k)=="host") { print $2; exit }}' "${CI_HOME}/.ssh/config")
    assert_eq "TP-DNS-18 first Host pattern is phone2" "phone2" "$_first"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show phone2 2>&1)
    assert_contains "TP-DNS-18 show by new name" "$_out" "dns:  phone2"

    # TP-DNS-19 add without dns name Next mentions add
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns add ip 10.0.0.1 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DNS-19 add missing name exit 1" 1 "$_ec"
    assert_contains "TP-DNS-19 Next dns add" "$_err" "dns add dns"

    ci_cleanup_env
}
