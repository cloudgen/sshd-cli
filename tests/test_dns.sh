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
    assert_contains "TP-DNS-01 help lists delete" "$_out" "delete"

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
    assert_not_contains "TP-DNS-10 no Termux bundle without termux yes" "$_cfg" "ServerAliveInterval"

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
1
9
EOF
)
    _ec=$?
    assert_eq "TP-DNS-13 pick 9 exit 0" 0 "$_ec"
    assert_contains "TP-DNS-13 action menu Edit" "$_out" "1. Edit"
    assert_contains "TP-DNS-13 action menu Exit 9" "$_out" "9. Exit"
    assert_contains "TP-DNS-13 pick 9 shows h9" "$_out" "dns:  h9"
    assert_contains "TP-DNS-13 pick 9 ip" "$_out" "ip:   10.0.0.9"
    assert_contains "TP-DNS-13 Host pick leave 0" "$_out" "0. Exit"

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

    # TP-DNS-20 TTY menu row 5 opens the Host list (discoverable dns)
    _dns_fixture
    _out=$(HOME="${CI_HOME}" TTY=1 INTERACTIVE=1 sh "${SCRIPT}" menu <<'EOF'
5
9
EOF
)
    _ec=$?
    assert_eq "TP-DNS-20 menu 5 exit 0" 0 "$_ec"
    assert_contains "TP-DNS-20 menu lists dns row" "$_out" "5. SSH names (dns)"
    assert_contains "TP-DNS-20 choice 5 lists phone" "$_out" "phone"
    assert_contains "TP-DNS-20 action Edit" "$_out" "1. Edit"
    assert_contains "TP-DNS-20 action Add" "$_out" "2. Add"
    assert_contains "TP-DNS-20 action Delete" "$_out" "3. Delete"
    assert_contains "TP-DNS-20 action Exit 9" "$_out" "9. Exit"
    assert_not_contains "TP-DNS-20 context is not Host pick 1." "$_out" "1. phone"

    # TP-DNS-21 TTY Edit then Host 1 (action menu, not pick-to-update)
    _dns_fixture
    _out=$(HOME="${CI_HOME}" INTERACTIVE=1 sh "${SCRIPT}" dns <<'EOF'
1
1
EOF
)
    _ec=$?
    assert_eq "TP-DNS-21 edit via action menu exit 0" 0 "$_ec"
    assert_contains "TP-DNS-21 action Edit" "$_out" "1. Edit"
    assert_contains "TP-DNS-21 Host pick phone" "$_out" "1. phone"
    assert_contains "TP-DNS-21 shows phone details" "$_out" "dns:  phone"

    # TP-DNS-22 non-interactive delete; Host * kept
    _dns_fixture
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns delete 1 2>&1)
    _ec=$?
    assert_eq "TP-DNS-22 delete exit 0" 0 "$_ec"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns list 2>&1)
    assert_not_contains "TP-DNS-22 phone gone" "$_out" "phone"
    assert_contains "TP-DNS-22 laptop remains" "$_out" "1. laptop"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-22 Host * kept" "$_cfg" "Host *"
    assert_contains "TP-DNS-22 wildcard body kept" "$_cfg" "StrictHostKeyChecking accept-new"
    assert_not_contains "TP-DNS-22 Host phone gone from file" "$_cfg" "Host phone"

    # TP-DNS-23 TTY delete cancel (n)
    _dns_fixture
    _out=$(HOME="${CI_HOME}" TTY=1 INTERACTIVE=1 sh "${SCRIPT}" dns <<'EOF'
3
1
n
EOF
)
    _ec=$?
    assert_eq "TP-DNS-23 delete cancel exit 0" 0 "$_ec"
    assert_contains "TP-DNS-23 cancelled" "$_out" "Delete cancelled"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns list 2>&1)
    assert_contains "TP-DNS-23 phone still listed" "$_out" "1. phone"

    # TP-DNS-24 TTY delete yes
    _dns_fixture
    _out=$(HOME="${CI_HOME}" TTY=1 INTERACTIVE=1 sh "${SCRIPT}" dns <<'EOF'
3
1
y
EOF
)
    _ec=$?
    assert_eq "TP-DNS-24 delete yes exit 0" 0 "$_ec"
    assert_contains "TP-DNS-24 deleted" "$_out" "Deleted Host phone"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns list 2>&1)
    assert_not_contains "TP-DNS-24 phone gone after yes" "$_out" "phone"
    assert_contains "TP-DNS-24 laptop remains after yes" "$_out" "1. laptop"

    # TP-DNS-25 delete missing n fail-closed
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns delete 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DNS-25 delete missing n exit 1" 1 "$_ec"
    assert_contains "TP-DNS-25 Next dns list" "$_err" "dns list"

    # TP-DNS-26 JSON delete one object; extra aliases on other Host kept
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Host phone phone-alias
    HostName 192.168.1.10
    IdentityFile ~/.ssh/id_ed25519
Host laptop
    HostName 10.0.0.5
    User alice
Host *
    StrictHostKeyChecking accept-new
EOF
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json dns delete 1 2>/dev/null)
    _ec=$?
    assert_eq "TP-DNS-26 json delete exit 0" 0 "$_ec"
    assert_contains "TP-DNS-26 json success type" "$_out" '"type":"out_success"'
    assert_contains "TP-DNS-26 json dns phone" "$_out" '"dns":"phone"'
    assert_not_contains "TP-DNS-26 json not a second dns_show" "$_out" '"type":"dns_show"'
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_not_contains "TP-DNS-26 phone stanza gone" "$_cfg" "Host phone"
    assert_contains "TP-DNS-26 laptop kept" "$_cfg" "Host laptop"
    assert_contains "TP-DNS-26 laptop User kept" "$_cfg" "User alice"
    assert_contains "TP-DNS-26 Host * kept" "$_cfg" "Host *"

    # TP-DNS-27 non-interactive add termux yes writes Port 8022 + keep-alive bundle
    _dns_fixture
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns add dns tphone ip 10.4.4.4 termux yes 2>&1)
    _ec=$?
    assert_eq "TP-DNS-27 termux add exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-27 Host tphone" "$_cfg" "Host tphone"
    assert_contains "TP-DNS-27 Port 8022" "$_cfg" "Port 8022"
    assert_contains "TP-DNS-27 ServerAliveInterval 15" "$_cfg" "ServerAliveInterval 15"
    assert_contains "TP-DNS-27 ServerAliveCountMax 12" "$_cfg" "ServerAliveCountMax 12"
    assert_contains "TP-DNS-27 TCPKeepAlive yes" "$_cfg" "TCPKeepAlive yes"
    assert_contains "TP-DNS-27 IPQoS none" "$_cfg" "IPQoS none"
    assert_contains "TP-DNS-27 Ciphers aes128-ctr,aes256-ctr" "$_cfg" "Ciphers aes128-ctr,aes256-ctr"
    assert_contains "TP-DNS-27 MACs hmac-sha2-256" "$_cfg" "MACs hmac-sha2-256"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show tphone 2>&1)
    assert_contains "TP-DNS-27 show termux yes" "$_out" "termux: yes"

    # TP-DNS-28 old-openssh yes writes rsa/dss algorithm lines
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns add dns oldbox ip 10.5.5.5 old-openssh yes 2>&1)
    _ec=$?
    assert_eq "TP-DNS-28 old-openssh add exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-28 HostKeyAlgorithms" "$_cfg" "HostKeyAlgorithms +ssh-rsa,ssh-dss"
    assert_contains "TP-DNS-28 PubkeyAcceptedAlgorithms" "$_cfg" "PubkeyAcceptedAlgorithms +ssh-rsa,ssh-dss"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show oldbox 2>&1)
    assert_contains "TP-DNS-28 show old-openssh yes" "$_out" "old-openssh: yes"

    # TP-DNS-29 identity-file + identities-only
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns add dns idbox ip 10.6.6.6 identity-file '~/.ssh/id_ed25519' identities-only yes 2>&1)
    _ec=$?
    assert_eq "TP-DNS-29 identity add exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-29 IdentityFile" "$_cfg" "IdentityFile ~/.ssh/id_ed25519"
    assert_contains "TP-DNS-29 IdentitiesOnly yes" "$_cfg" "IdentitiesOnly yes"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show idbox 2>&1)
    assert_contains "TP-DNS-29 show identity-file" "$_out" "identity-file: ~/.ssh/id_ed25519"
    assert_contains "TP-DNS-29 show identities-only" "$_out" "identities-only: yes"

    # TP-DNS-30 INTERACTIVE add: default as Termux (Y) + default Old OpenSSH (Y)
    _out=$(HOME="${CI_HOME}" INTERACTIVE=1 sh "${SCRIPT}" dns add <<'EOF'
walktermux
10.7.7.7
u

EOF
)
    _ec=$?
    assert_eq "TP-DNS-30 interactive Termux default exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-30 walk Host" "$_cfg" "Host walktermux"
    assert_contains "TP-DNS-30 walk Port 8022" "$_cfg" "Port 8022"
    assert_contains "TP-DNS-30 walk ServerAliveInterval" "$_cfg" "ServerAliveInterval 15"
    assert_contains "TP-DNS-30 walk Ciphers" "$_cfg" "Ciphers aes128-ctr,aes256-ctr"
    assert_contains "TP-DNS-30 walk MACs" "$_cfg" "MACs hmac-sha2-256"
    assert_contains "TP-DNS-30 walk HostKeyAlgorithms" "$_cfg" "HostKeyAlgorithms +ssh-rsa,ssh-dss"

    # TP-DNS-31 INTERACTIVE add: Termux n prompts Port; Old OpenSSH n omits algorithms
    _out=$(HOME="${CI_HOME}" INTERACTIVE=1 sh "${SCRIPT}" dns add <<'EOF'
walklinux
10.8.8.8
u
n
2200


n
EOF
)
    _ec=$?
    assert_eq "TP-DNS-31 interactive Termux n exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-31 Host walklinux" "$_cfg" "Host walklinux"
    assert_contains "TP-DNS-31 Port 2200" "$_cfg" "Port 2200"
    _wl=$(awk 'BEGIN{p=0} /^Host walklinux/{p=1; next} /^Host /{p=0} p{print}' "${CI_HOME}/.ssh/config")
    assert_not_contains "TP-DNS-31 no ServerAlive on Termux n" "$_wl" "ServerAliveInterval"
    assert_not_contains "TP-DNS-31 no Ciphers on Termux n" "$_wl" "Ciphers"
    assert_not_contains "TP-DNS-31 no MACs on Termux n" "$_wl" "MACs"
    assert_not_contains "TP-DNS-31 no HostKeyAlgorithms on old n" "$_wl" "HostKeyAlgorithms"

    # TP-DNS-32 set termux no strips keep-alives; Port stays unless set
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set tphone termux no 2>&1)
    _ec=$?
    assert_eq "TP-DNS-32 set termux no exit 0" 0 "$_ec"
    _cfg=$(cat "${CI_HOME}/.ssh/config")
    _tp=$(awk 'BEGIN{p=0} /^Host tphone/{p=1; next} /^Host /{p=0} p{print}' "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-32 Port 8022 kept" "$_tp" "Port 8022"
    assert_not_contains "TP-DNS-32 ServerAlive stripped" "$_tp" "ServerAliveInterval"
    assert_not_contains "TP-DNS-32 TCPKeepAlive stripped" "$_tp" "TCPKeepAlive"
    assert_not_contains "TP-DNS-32 Ciphers stripped" "$_tp" "Ciphers"
    assert_not_contains "TP-DNS-32 MACs stripped" "$_tp" "MACs"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show tphone 2>&1)
    assert_contains "TP-DNS-32 show termux no" "$_out" "termux: no"

    # TP-DNS-33 set old-openssh no strips algorithm lines
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set oldbox old-openssh no 2>&1)
    _ec=$?
    assert_eq "TP-DNS-33 old-openssh no exit 0" 0 "$_ec"
    _ob=$(awk 'BEGIN{p=0} /^Host oldbox/{p=1; next} /^Host /{p=0} p{print}' "${CI_HOME}/.ssh/config")
    assert_not_contains "TP-DNS-33 HostKeyAlgorithms stripped" "$_ob" "HostKeyAlgorithms"
    assert_not_contains "TP-DNS-33 PubkeyAcceptedAlgorithms stripped" "$_ob" "PubkeyAcceptedAlgorithms"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show oldbox 2>&1)
    assert_contains "TP-DNS-33 show old-openssh no" "$_out" "old-openssh: no"

    # TP-DNS-34 show names identity / termux / old-openssh fields
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show idbox 2>&1)
    assert_contains "TP-DNS-34 identity-file label" "$_out" "identity-file:"
    assert_contains "TP-DNS-34 identities-only label" "$_out" "identities-only:"
    assert_contains "TP-DNS-34 termux label" "$_out" "termux:"
    assert_contains "TP-DNS-34 old-openssh label" "$_out" "old-openssh:"

    # TP-DNS-35 unknown field fail-closed names the allowed list
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set 1 not-a-field x 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-DNS-35 unknown field exit 1" 1 "$_ec"
    assert_contains "TP-DNS-35 names identity-file" "$_err" "identity-file"
    assert_contains "TP-DNS-35 names termux" "$_err" "termux"
    assert_contains "TP-DNS-35 names old-openssh" "$_err" "old-openssh"

    # TP-DNS-36 keep-alive-only stanza (no simpler Ciphers/MACs) is not the Termux bundle
    _dns_fixture
    cat > "${CI_HOME}/.ssh/config" <<'EOF'
Host oldtx
    HostName 10.9.9.9
    Port 8022
    ServerAliveInterval 15
    ServerAliveCountMax 12
    TCPKeepAlive yes
    IPQoS none
EOF
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show oldtx 2>&1)
    assert_contains "TP-DNS-36 old keep-alives termux no" "$_out" "termux: no"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns set oldtx termux yes 2>&1)
    _ec=$?
    assert_eq "TP-DNS-36 set termux yes exit 0" 0 "$_ec"
    _ot=$(awk 'BEGIN{p=0} /^Host oldtx/{p=1; next} /^Host /{p=0} p{print}' "${CI_HOME}/.ssh/config")
    assert_contains "TP-DNS-36 Ciphers written" "$_ot" "Ciphers aes128-ctr,aes256-ctr"
    assert_contains "TP-DNS-36 MACs written" "$_ot" "MACs hmac-sha2-256"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" dns show oldtx 2>&1)
    assert_contains "TP-DNS-36 show termux yes after set" "$_out" "termux: yes"

    ci_cleanup_env
}
