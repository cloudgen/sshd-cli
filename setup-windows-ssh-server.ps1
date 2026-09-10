<#
.SYNOPSIS
    Configure Windows OpenSSH Server so a chosen NON-ADMIN local user can log in
    from Linux, Git Bash, or PowerShell (LAN or, after router port-forward, the internet).

.DESCRIPTION
    Purpose
    -------
    Windows OpenSSH treats Administrators differently from normal users.
    For an Administrator, sshd IGNORES C:\Users\<user>\.ssh\authorized_keys and
    only reads C:\ProgramData\ssh\administrators_authorized_keys (because of
    "Match Group administrators" in C:\ProgramData\ssh\sshd_config).

    This script is for a *normal* (non-admin) account: the Linux public key is
    installed in that user's own .ssh\authorized_keys, with the ACLs OpenSSH
    requires. It does not put keys only in the admin file.

    SSH login shell
    ---------------
    After OpenSSH is up, you pick the shell that SSH sessions run:
      Git Bash     — Git for Windows bash.exe (not git-bash.exe / mintty)
      PowerShell   — Windows PowerShell 5.1
      pwsh         — PowerShell 7, if installed
      Windows cmd  — remove DefaultShell so sshd uses the Windows default

    Git Bash is detected from the Git for Windows registry and common install
    paths. DefaultShellCommandOption is --login -c so remote commands still
    get a login environment. Interactive SSH runs bash.exe, which reads ~/.bashrc.

    What you need on the client afterwards
    --------------------------------------
      ssh <windows-username>@<windows-lan-ip>
    Example:  ssh sshuser@192.168.2.1

    From the internet you still need a router port-forward of TCP 22 to this PC,
    and you must use the public IP (or DDNS), not 192.168.x.x.

    How to run
    ----------
    PowerShell (double-click or):
      powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\setup-windows-ssh-server.ps1

    Git Bash (UAC still prompts; this script is host setup, not a Type 0 CLI):
      powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w ./setup-windows-ssh-server.ps1)"

    Optional named arguments (forwarded through UAC):
      -User sshuser
      -Shell GitBash | PowerShell | Pwsh | Cmd | Ask
      -PublicKeyFile C:\Users\<you>\.ssh\id_ed25519.pub
      -SkipPause
      -SkipKeyPrompt

    The script re-launches itself with UAC elevation if it is not already admin.

    Steps this script performs
    --------------------------
    1.  Re-launch as Administrator (UAC) if the current token is not elevated.
    2.  Install OpenSSH Server if it is missing (Windows optional feature).
    3.  Start the sshd service and set startup type to Automatic.
    4.  Allow inbound TCP port 22 on ALL firewall profiles (Domain/Private/Public).
        The built-in "OpenSSH SSH Server (sshd)" rule is often Private-only, which
        blocks office/home Wi-Fi marked Public.
    5.  Leave sshd_config so that:
          - PubkeyAuthentication yes
          - PasswordAuthentication yes (until you prove key login)
          - non-admin users use  C:\Users\<user>\.ssh\authorized_keys
          - a global AllowGroups administrators line is commented (that would
            block the Users group)
          - the "Match Group administrators" block is left in place (correct)
    6.  List local enabled accounts and let you CHOOSE a non-admin user
        (or create a new non-admin user if none exist / you want a fresh one).
        Administrators cannot be selected for this path on purpose.
    7.  Create C:\Users\<user>\.ssh if needed (including when the profile has
        never been logged into). Grant that user access to a newly created home.
    8.  Optionally paste a Linux public key (id_ed25519.pub / id_rsa.pub) into
        that user's authorized_keys. Password login stays available by default.
    9.  Restrict ACLs on .ssh and authorized_keys to: the user, SYSTEM, and
        Administrators only (OpenSSH rejects keys that are too open).
   10.  Set the SSH DefaultShell: Git Bash, PowerShell, pwsh, or Windows cmd
        (HKLM\SOFTWARE\OpenSSH). For Git Bash, write ~/.bashrc / ~/.bash_profile
        when those files are missing so an SSH login is a usable Git Bash.
   11.  Print LAN IPv4 addresses, service/firewall status, key file path, shell,
        and the exact ssh command to run from Linux or Git Bash.

    Not done by this script
    -----------------------
    - Router / ISP port forwarding for access from the public internet
    - Disabling password authentication (leave that until key login is proven)
    - WSL bash (System32\bash.exe) as the SSH shell
    - Installing Git for Windows (Git Bash option is skipped until Git is present)

.PARAMETER User
    Existing non-admin local username to configure. Skips the account picker.

.PARAMETER Shell
    SSH DefaultShell: Ask (prompt), GitBash, PowerShell, Pwsh, or Cmd.

.PARAMETER PublicKeyFile
    Path to one OpenSSH public key file to install for the target user.

.PARAMETER SkipPause
    Do not wait for Enter at the end (Git Bash / scripted runs).

.PARAMETER SkipKeyPrompt
    Do not ask to paste a public key when -PublicKeyFile is omitted.
#>

#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$User = '',
    [ValidateSet('Ask', 'GitBash', 'PowerShell', 'Pwsh', 'Cmd')]
    [string]$Shell = 'Ask',
    [string]$PublicKeyFile = '',
    [switch]$SkipPause,
    [switch]$SkipKeyPrompt
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ---------------------------------------------------------------------------
# 1. Self-elevate (forward named arguments through UAC)
# ---------------------------------------------------------------------------
function Test-IsElevated {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsElevated)) {
    Write-Host 'This script must run as Administrator. Requesting UAC elevation...' -ForegroundColor Yellow
    $self = $MyInvocation.MyCommand.Path
    $ps   = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $argList = New-Object System.Collections.Generic.List[string]
    [void]$argList.Add('-NoProfile')
    [void]$argList.Add('-ExecutionPolicy')
    [void]$argList.Add('Bypass')
    [void]$argList.Add('-File')
    [void]$argList.Add($self)
    if ($User) {
        [void]$argList.Add('-User')
        [void]$argList.Add($User)
    }
    if ($Shell -and $Shell -ne 'Ask') {
        [void]$argList.Add('-Shell')
        [void]$argList.Add($Shell)
    }
    if ($PublicKeyFile) {
        [void]$argList.Add('-PublicKeyFile')
        [void]$argList.Add($PublicKeyFile)
    }
    if ($SkipKeyPrompt) {
        [void]$argList.Add('-SkipKeyPrompt')
    }
    if ($SkipPause -or $env:MSYSTEM) {
        [void]$argList.Add('-SkipPause')
    }
    try {
        Start-Process -FilePath $ps -Verb RunAs -ArgumentList $argList.ToArray() | Out-Null
    } catch {
        Write-Host "UAC elevation was declined or failed: $($_.Exception.Message)" -ForegroundColor Red
        if (-not $SkipPause -and -not $env:MSYSTEM) {
            Read-Host 'Press Enter to exit'
        }
        exit 1
    }
    exit 0
}

$Host.UI.RawUI.WindowTitle = 'Windows OpenSSH setup (non-admin user)'

function Write-Step {
    param([string]$Message)
    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "    OK  $Message" -ForegroundColor Green
}

function Write-Warn2 {
    param([string]$Message)
    Write-Host "    WARN  $Message" -ForegroundColor Yellow
}

function Pause-End {
    if ($SkipPause) {
        return
    }
    Write-Host ''
    Read-Host 'Press Enter to close this window'
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Get-AdminLocalNames {
    $names = New-Object System.Collections.Generic.List[string]
    try {
        foreach ($m in Get-LocalGroupMember -Group 'Administrators' -ErrorAction Stop) {
            $n = $m.Name
            if ($n -like '*\*') { $n = $n.Split('\')[-1] }
            $names.Add($n)
        }
    } catch {
        Write-Warn2 "Could not read Administrators group: $($_.Exception.Message)"
    }
    return $names
}

function Test-UserIsAdmin {
    param([string]$UserName, [string[]]$AdminNames)
    foreach ($a in $AdminNames) {
        if ([string]::Equals($a, $UserName, [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Get-EnabledLocalUsers {
    Get-LocalUser | Where-Object { $_.Enabled -eq $true }
}

function New-NonAdminLocalUser {
    Write-Host ''
    Write-Host 'Create a non-admin local user (will be added to Users only, not Administrators).' -ForegroundColor White
    do {
        $name = (Read-Host 'New username').Trim()
        if ([string]::IsNullOrWhiteSpace($name)) {
            Write-Warn2 'Username cannot be empty.'
            continue
        }
        if ($name -notmatch '^[A-Za-z0-9._-]{1,20}$') {
            Write-Warn2 'Use 1-20 characters: letters, digits, dot, underscore, hyphen.'
            continue
        }
        if (Get-LocalUser -Name $name -ErrorAction SilentlyContinue) {
            Write-Warn2 "User '$name' already exists."
            continue
        }
        break
    } while ($true)

    do {
        $pw1 = Read-Host "Password for '$name'" -AsSecureString
        $pw2 = Read-Host 'Confirm password' -AsSecureString
        $b1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw1)
        $b2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw2)
        try {
            $s1 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b1)
            $s2 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b2)
        } finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b1)
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b2)
        }
        if ($s1 -ne $s2) {
            Write-Warn2 'Passwords do not match.'
            continue
        }
        if ($s1.Length -lt 1) {
            Write-Warn2 'Password cannot be empty.'
            continue
        }
        break
    } while ($true)

    try {
        New-LocalUser -Name $name -Password $pw1 -FullName $name -Description 'SSH non-admin login' -AccountNeverExpires -PasswordNeverExpires | Out-Null
        Add-LocalGroupMember -Group 'Users' -Member $name -ErrorAction SilentlyContinue
        Write-Ok "Created local user '$name' (Users group only)."
        return $name
    } catch {
        throw "Failed to create user '$name'. Windows password policy may have rejected the password. $($_.Exception.Message)"
    }
}

function Get-UserHomePath {
    param([string]$UserName)
    $sid = (Get-LocalUser -Name $UserName).SID.Value
    $prof = Get-CimInstance -ClassName Win32_UserProfile -ErrorAction SilentlyContinue |
        Where-Object { $_.SID -eq $sid } |
        Select-Object -First 1
    if ($prof -and $prof.LocalPath) {
        return $prof.LocalPath
    }
    return Join-Path $env:SystemDrive "Users\$UserName"
}

function Grant-UserHomeAccess {
    param(
        [Parameter(Mandatory = $true)][string]$HomePath,
        [Parameter(Mandatory = $true)][string]$UserName
    )
    $account = New-Object System.Security.Principal.NTAccount($env:COMPUTERNAME, $UserName)
    [void]$account.Translate([Security.Principal.SecurityIdentifier])
    $acl = Get-Acl -Path $HomePath
    $inherit = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor `
               [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    $prop = [System.Security.AccessControl.PropagationFlags]::None
    $allow = [System.Security.AccessControl.AccessControlType]::Allow
    $rights = [System.Security.AccessControl.FileSystemRights]::Modify
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($account, $rights, $inherit, $prop, $allow)
    $acl.AddAccessRule($rule)
    Set-Acl -Path $HomePath -AclObject $acl
}

function Set-SshRestrictedAcl {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$UserName,
        [Parameter(Mandatory = $true)][ValidateSet('Directory', 'File')][string]$Kind
    )

    $account = New-Object System.Security.Principal.NTAccount($env:COMPUTERNAME, $UserName)
    [void]$account.Translate([Security.Principal.SecurityIdentifier])

    if ($Kind -eq 'Directory') {
        $acl = New-Object System.Security.AccessControl.DirectorySecurity
        $inherit = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor `
                   [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    } else {
        $acl = New-Object System.Security.AccessControl.FileSecurity
        $inherit = [System.Security.AccessControl.InheritanceFlags]::None
    }
    $prop  = [System.Security.AccessControl.PropagationFlags]::None
    $allow = [System.Security.AccessControl.AccessControlType]::Allow
    $full  = [System.Security.AccessControl.FileSystemRights]::FullControl

    $acl.SetAccessRuleProtection($true, $false)
    foreach ($id in @(
        (New-Object System.Security.Principal.NTAccount('NT AUTHORITY', 'SYSTEM')),
        (New-Object System.Security.Principal.NTAccount('BUILTIN', 'Administrators')),
        $account
    )) {
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($id, $full, $inherit, $prop, $allow)
        $acl.AddAccessRule($rule)
    }
    $acl.SetOwner((New-Object System.Security.Principal.NTAccount('BUILTIN', 'Administrators')))
    Set-Acl -Path $Path -AclObject $acl
}

function Test-LooksLikeSshPublicKey {
    param([string]$Line)
    return ($Line -match '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521|sk-ssh-ed25519@openssh\.com|sk-ecdsa-sha2-nistp256@openssh\.com)\s+\S+')
}

function Get-LanIPv4 {
    Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike '127.*' -and
            $_.IPAddress -notlike '169.254.*' -and
            $_.PrefixOrigin -ne 'WellKnown'
        } |
        Select-Object -ExpandProperty IPAddress -Unique
}

function Find-GitBashExe {
    $candidates = New-Object System.Collections.Generic.List[string]
    foreach ($rk in @(
        'HKLM:\SOFTWARE\GitForWindows',
        'HKLM:\SOFTWARE\WOW6432Node\GitForWindows'
    )) {
        if (Test-Path $rk) {
            $install = (Get-ItemProperty -Path $rk -ErrorAction SilentlyContinue).InstallPath
            if ($install) {
                [void]$candidates.Add((Join-Path $install 'bin\bash.exe'))
            }
        }
    }
    $pf86 = ${env:ProgramFiles(x86)}
    [void]$candidates.Add((Join-Path $env:ProgramFiles 'Git\bin\bash.exe'))
    if ($pf86) {
        [void]$candidates.Add((Join-Path $pf86 'Git\bin\bash.exe'))
    }
    [void]$candidates.Add((Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe'))

    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) {
            return $c
        }
    }

    $cmd = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($null -ne $cmd -and $cmd.Source -match '\\Git\\bin\\bash\.exe$' -and $cmd.Source -notmatch '\\System32\\bash\.exe$') {
        return $cmd.Source
    }
    return $null
}

function Find-WindowsPowerShellExe {
    return (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe')
}

function Find-PwshExe {
    $cmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($null -ne $cmd -and $cmd.Source) {
        return $cmd.Source
    }
    $p7 = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
    if (Test-Path -LiteralPath $p7) {
        return $p7
    }
    return $null
}

function Set-OpenSshDefaultShell {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('GitBash', 'PowerShell', 'Pwsh', 'Cmd')]
        [string]$Kind,
        [string]$GitBashPath,
        [string]$PowerShellPath,
        [string]$PwshPath
    )

    $regPath = 'HKLM:\SOFTWARE\OpenSSH'
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    if ($Kind -eq 'Cmd') {
        Remove-ItemProperty -Path $regPath -Name DefaultShell -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $regPath -Name DefaultShellCommandOption -ErrorAction SilentlyContinue
        Write-Ok 'Removed DefaultShell (Windows default, usually cmd).'
        return 'Windows cmd (default)'
    }

    $shellPath = $null
    $option = $null
    $label = $null
    if ($Kind -eq 'GitBash') {
        if (-not $GitBashPath -or -not (Test-Path -LiteralPath $GitBashPath)) {
            throw 'Git Bash was selected, but Git for Windows bash.exe was not found. Next: install Git for Windows, then re-run this script with -Shell GitBash.'
        }
        $shellPath = $GitBashPath
        $option = '--login -c'
        $label = "Git Bash ($GitBashPath)"
    } elseif ($Kind -eq 'PowerShell') {
        if (-not $PowerShellPath -or -not (Test-Path -LiteralPath $PowerShellPath)) {
            throw "Windows PowerShell was not found at $PowerShellPath"
        }
        $shellPath = $PowerShellPath
        $option = '-NoLogo -Command'
        $label = "Windows PowerShell ($PowerShellPath)"
    } else {
        if (-not $PwshPath -or -not (Test-Path -LiteralPath $PwshPath)) {
            throw 'PowerShell 7 (pwsh) was selected, but pwsh.exe was not found. Next: install PowerShell 7, or pick PowerShell / Git Bash / Cmd.'
        }
        $shellPath = $PwshPath
        $option = '-NoLogo -Command'
        $label = "pwsh ($PwshPath)"
    }

    New-ItemProperty -Path $regPath -Name DefaultShell -Value $shellPath -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $regPath -Name DefaultShellCommandOption -Value $option -PropertyType String -Force | Out-Null
    Write-Ok "DefaultShell = $shellPath"
    Write-Ok "DefaultShellCommandOption = $option"
    return $label
}

function Write-GitBashLoginRc {
    param(
        [Parameter(Mandatory = $true)][string]$HomePath
    )
    $bashrc = Join-Path $HomePath '.bashrc'
    $bashProfile = Join-Path $HomePath '.bash_profile'
    $bashrcBody = @(
        '# Written by setup-windows-ssh-server.ps1 for Git Bash over OpenSSH.'
        '# Interactive SSH runs bash.exe (not git-bash.exe). This file is the rc.'
        'export MSYSTEM="${MSYSTEM:-MINGW64}"'
        '# Native Windows console programs need winpty, e.g. winpty grok'
        ''
    ) -join "`n"
    $bashProfileBody = @(
        '# Written by setup-windows-ssh-server.ps1 for Git Bash over OpenSSH.'
        '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"'
        ''
    ) -join "`n"

    $wrote = $false
    if (-not (Test-Path -LiteralPath $bashrc)) {
        Set-Content -Path $bashrc -Value $bashrcBody -Encoding ascii
        Write-Ok "Created $bashrc (MSYSTEM=MINGW64 for Git Bash detect)"
        $wrote = $true
    } else {
        Write-Ok "Left existing $bashrc unchanged"
    }
    if (-not (Test-Path -LiteralPath $bashProfile)) {
        Set-Content -Path $bashProfile -Value $bashProfileBody -Encoding ascii
        Write-Ok "Created $bashProfile (sources .bashrc on login)"
        $wrote = $true
    } else {
        Write-Ok "Left existing $bashProfile unchanged"
    }
    return $wrote
}

function Protect-NormalUserSshdConfig {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "sshd_config not found at $Path"
    }

    $lines = @(Get-Content -Path $Path)
    $inMatch = $false
    $changed = $false
    $hasPubkeyYes = $false
    $hasPasswordYes = $false
    $out = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        if ($line -match '^\s*Match\s+') {
            $inMatch = $true
        }

        if (-not $inMatch -and $line -match '^\s*AllowGroups\s+administrators\s*$') {
            [void]$out.Add('# Commented by setup-windows-ssh-server.ps1 so a normal (Users) account can SSH.')
            [void]$out.Add("# $line")
            $changed = $true
            Write-Warn2 'Commented global AllowGroups administrators (that line blocks non-admin SSH).'
            continue
        }

        if (-not $inMatch -and $line -match '^\s*PubkeyAuthentication\s+yes\s*$') {
            $hasPubkeyYes = $true
        }
        if (-not $inMatch -and $line -match '^\s*PasswordAuthentication\s+yes\s*$') {
            $hasPasswordYes = $true
        }
        if (-not $inMatch -and $line -match '^\s*PasswordAuthentication\s+no\s*$') {
            [void]$out.Add('PasswordAuthentication yes')
            $hasPasswordYes = $true
            $changed = $true
            Write-Ok 'Set PasswordAuthentication yes (key login can be required later).'
            continue
        }

        [void]$out.Add($line)
    }

    if (-not $hasPubkeyYes) {
        [void]$out.Add('')
        [void]$out.Add('PubkeyAuthentication yes')
        $changed = $true
        Write-Ok 'Added PubkeyAuthentication yes'
    } else {
        Write-Ok 'PubkeyAuthentication yes is set.'
    }

    if (-not $hasPasswordYes) {
        [void]$out.Add('PasswordAuthentication yes')
        $changed = $true
        Write-Ok 'Added PasswordAuthentication yes'
    } else {
        Write-Ok 'PasswordAuthentication yes is set.'
    }

    if ($changed) {
        Set-Content -Path $Path -Value $out.ToArray() -Encoding ascii
    }

    Write-Ok 'Non-admin users read C:\Users\<user>\.ssh\authorized_keys'
    Write-Ok 'Match Group administrators is left unchanged (admin keys stay in ProgramData).'
}

# ---------------------------------------------------------------------------
# 2. OpenSSH Server
# ---------------------------------------------------------------------------
try {
    Write-Step 'Install / verify OpenSSH Server'
    $serverCap = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH.Server*' } | Select-Object -First 1
    if (-not $serverCap) {
        Write-Warn2 'OpenSSH.Server capability not found. Trying Add-WindowsCapability by name anyway.'
        Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0' | Out-Null
    } elseif ($serverCap.State -ne 'Installed') {
        Write-Host "    Installing $($serverCap.Name) ..."
        Add-WindowsCapability -Online -Name $serverCap.Name | Out-Null
        Write-Ok 'OpenSSH Server installed.'
    } else {
        Write-Ok "Already installed ($($serverCap.Name))."
    }

    Write-Step 'Start sshd and set Automatic startup'
    Set-Service -Name sshd -StartupType Automatic
    $svc = Get-Service -Name sshd
    if ($svc.Status -ne 'Running') {
        Start-Service -Name sshd
    }
    $svc.Refresh()
    Write-Ok "sshd is $($svc.Status), StartType=$($(Get-CimInstance Win32_Service -Filter "Name='sshd'").StartMode)"

    # ---------------------------------------------------------------------------
    # 3. Firewall (all profiles)
    # ---------------------------------------------------------------------------
    Write-Step 'Allow inbound TCP 22 on Domain, Private, and Public'
    $ruleName = 'OpenSSH-Server-Inbound-AllProfiles'
    $existing = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
    if (-not $existing) {
        New-NetFirewallRule `
            -Name $ruleName `
            -DisplayName 'OpenSSH Server (TCP 22, all profiles)' `
            -Enabled True `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort 22 `
            -Action Allow `
            -Profile Any | Out-Null
        Write-Ok "Created firewall rule '$ruleName'."
    } else {
        Set-NetFirewallRule -Name $ruleName -Enabled True -Profile Any -Action Allow -Direction Inbound
        Write-Ok "Firewall rule '$ruleName' already exists; ensured Enabled/Allow/Any."
    }

    $builtin = Get-NetFirewallRule -DisplayName 'OpenSSH SSH Server (sshd)' -ErrorAction SilentlyContinue
    if ($builtin) {
        $profiles = ($builtin | Select-Object -ExpandProperty Profile) -join ','
        Write-Host "    Built-in OpenSSH rule profile(s): $profiles (this script's all-profile rule is the one that matters on Public Wi-Fi)."
    }

    # ---------------------------------------------------------------------------
    # 4. sshd_config: keep non-admin AuthorizedKeysFile behavior
    # ---------------------------------------------------------------------------
    Write-Step 'Verify sshd_config for non-admin (normal user) SSH'
    $sshdCfg = Join-Path $env:ProgramData 'ssh\sshd_config'
    Protect-NormalUserSshdConfig -Path $sshdCfg

    # ---------------------------------------------------------------------------
    # 5. Choose or create a NON-admin account
    # ---------------------------------------------------------------------------
    Write-Step 'Choose a non-admin local user for SSH login'
    $adminNames = @(Get-AdminLocalNames)
    $allEnabled = @(Get-EnabledLocalUsers)
    $nonAdmins = @($allEnabled | Where-Object { -not (Test-UserIsAdmin -UserName $_.Name -AdminNames $adminNames) })

    Write-Host ''
    Write-Host 'Enabled local users:' -ForegroundColor White
    foreach ($u in $allEnabled) {
        $tag = if (Test-UserIsAdmin -UserName $u.Name -AdminNames $adminNames) { 'ADMIN (cannot use this path)' } else { 'non-admin' }
        Write-Host ("    {0,-20} {1}" -f $u.Name, $tag)
    }

    $targetUser = $null
    if ($User) {
        $exists = Get-LocalUser -Name $User -ErrorAction SilentlyContinue
        if (-not $exists) {
            throw "Local user '$User' does not exist. Next: omit -User to pick from a list, or create a non-admin account in the menu."
        }
        if (-not $exists.Enabled) {
            throw "Local user '$User' is disabled. Next: enable the account in Computer Management, then re-run."
        }
        $targetUser = $exists.Name
    } elseif ($nonAdmins.Count -eq 0) {
        Write-Host ''
        Write-Warn2 'There is no enabled non-admin local user.'
        Write-Warn2 'Administrators must use ProgramData\ssh\administrators_authorized_keys instead.'
        $ans = Read-Host 'Create a new non-admin user now? [Y/n]'
        if ($ans -match '^[Nn]') {
            throw 'Aborted: a non-admin account is required for this setup path.'
        }
        $targetUser = New-NonAdminLocalUser
    } else {
        Write-Host ''
        Write-Host 'Non-admin accounts you can select:' -ForegroundColor White
        for ($i = 0; $i -lt $nonAdmins.Count; $i++) {
            Write-Host ("    [{0}] {1}" -f ($i + 1), $nonAdmins[$i].Name)
        }
        Write-Host '    [C] Create a new non-admin user'
        do {
            $choice = (Read-Host 'Select number or C').Trim()
            if ($choice -match '^[Cc]$') {
                $targetUser = New-NonAdminLocalUser
                break
            }
            $n = 0
            if ([int]::TryParse($choice, [ref]$n) -and $n -ge 1 -and $n -le $nonAdmins.Count) {
                $targetUser = $nonAdmins[$n - 1].Name
                break
            }
            Write-Warn2 'Invalid selection.'
        } while ($true)
    }

    if (Test-UserIsAdmin -UserName $targetUser -AdminNames @(Get-AdminLocalNames)) {
        throw "'$targetUser' is in Administrators. Refusing: this script only configures the non-admin authorized_keys path."
    }
    Write-Ok "Target SSH user: $targetUser  (normal user / Users group)"

    # ---------------------------------------------------------------------------
    # 6-9. Home, .ssh, optional public key, ACLs
    # ---------------------------------------------------------------------------
    Write-Step "Prepare .ssh for non-admin user '$targetUser'"
    $homePath = Get-UserHomePath -UserName $targetUser
    $createdHome = $false
    if (-not (Test-Path $homePath)) {
        New-Item -ItemType Directory -Path $homePath -Force | Out-Null
        $createdHome = $true
        Write-Ok "Created profile directory $homePath"
    } else {
        Write-Ok "Profile directory $homePath"
    }
    if ($createdHome) {
        Grant-UserHomeAccess -HomePath $homePath -UserName $targetUser
        Write-Ok "Granted '$targetUser' Modify on the new home (created as Administrator)."
    }

    $sshDir = Join-Path $homePath '.ssh'
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        Write-Ok "Created $sshDir"
    }
    $authKeys = Join-Path $sshDir 'authorized_keys'
    if (-not (Test-Path $authKeys)) {
        New-Item -ItemType File -Path $authKeys -Force | Out-Null
        Write-Ok "Created $authKeys"
    }

    $pub = ''
    if ($PublicKeyFile) {
        if (-not (Test-Path -LiteralPath $PublicKeyFile)) {
            throw "Public key file not found: $PublicKeyFile"
        }
        $pub = ((Get-Content -LiteralPath $PublicKeyFile | Where-Object { $_.Trim() -ne '' } | Select-Object -First 1) + '').Trim()
    } elseif (-not $SkipKeyPrompt) {
        Write-Host ''
        Write-Host 'Paste ONE Linux public key line (from ~/.ssh/id_ed25519.pub or id_rsa.pub).' -ForegroundColor White
        Write-Host 'Leave blank to skip (Windows password login remains enabled).' -ForegroundColor DarkGray
        $pub = (Read-Host 'Public key').Trim()
    } else {
        Write-Host '    Skipped public-key prompt (-SkipKeyPrompt).'
    }

    if ($pub) {
        if (-not (Test-LooksLikeSshPublicKey $pub)) {
            throw "That does not look like an OpenSSH public key. Example starts with: ssh-ed25519 AAAA..."
        }
        $existingKeys = @(Get-Content -Path $authKeys -ErrorAction SilentlyContinue | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        if ($existingKeys -contains $pub) {
            Write-Ok 'That public key is already in authorized_keys.'
        } else {
            Add-Content -Path $authKeys -Value $pub -Encoding ascii
            Write-Ok 'Appended public key to authorized_keys.'
        }
    } else {
        Write-Warn2 'No public key added. The client can still log in with the Windows account password.'
    }

    Set-SshRestrictedAcl -Path $sshDir  -UserName $targetUser -Kind Directory
    Set-SshRestrictedAcl -Path $authKeys -UserName $targetUser -Kind File
    Write-Ok 'ACL set: user + SYSTEM + Administrators only (inheritance disabled).'

    # ---------------------------------------------------------------------------
    # 10. SSH login shell: Git Bash / PowerShell / pwsh / cmd
    # ---------------------------------------------------------------------------
    Write-Step 'SSH login shell (Git Bash, PowerShell, or Windows cmd)'
    $gitBash = Find-GitBashExe
    $winPs   = Find-WindowsPowerShellExe
    $pwsh    = Find-PwshExe
    if ($gitBash) {
        Write-Ok "Git Bash found: $gitBash"
    } else {
        Write-Host '    Git Bash not found (install Git for Windows to use it as the SSH shell).'
    }
    if ($pwsh) {
        Write-Ok "pwsh found: $pwsh"
    }

    $shellKind = $Shell
    if ($shellKind -eq 'Ask') {
        Write-Host ''
        Write-Host 'Which shell should SSH sessions use for this normal user?' -ForegroundColor White
        if ($gitBash) {
            Write-Host "    [1] Git Bash     $gitBash"
        } else {
            Write-Host '    [1] Git Bash     (not installed)'
        }
        Write-Host "    [2] PowerShell   $winPs"
        if ($pwsh) {
            Write-Host "    [3] pwsh         $pwsh"
        } else {
            Write-Host '    [3] pwsh         (not installed)'
        }
        Write-Host '    [4] Windows cmd  (sshd default)'
        $defaultPick = '2'
        if ($gitBash) { $defaultPick = '1' }
        $ans = (Read-Host "Select 1-4 [$defaultPick]").Trim()
        if ([string]::IsNullOrWhiteSpace($ans)) { $ans = $defaultPick }
        switch ($ans) {
            '1' { $shellKind = 'GitBash' }
            '2' { $shellKind = 'PowerShell' }
            '3' { $shellKind = 'Pwsh' }
            '4' { $shellKind = 'Cmd' }
            default { throw "Invalid shell selection '$ans'. Next: pick 1 (Git Bash), 2 (PowerShell), 3 (pwsh), or 4 (cmd)." }
        }
    }

    $shellLabel = Set-OpenSshDefaultShell -Kind $shellKind -GitBashPath $gitBash -PowerShellPath $winPs -PwshPath $pwsh
    if ($shellKind -eq 'GitBash') {
        Write-GitBashLoginRc -HomePath $homePath | Out-Null
    }

    # Restart sshd so shell/config/firewall are picked up cleanly
    Write-Step 'Restart sshd'
    Restart-Service sshd -Force
    Write-Ok 'sshd restarted.'

    # ---------------------------------------------------------------------------
    # 11. Summary
    # ---------------------------------------------------------------------------
    Write-Step 'Summary'
    $ips = @(Get-LanIPv4)
    $listen = Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue
    Write-Host "    Computer        : $env:COMPUTERNAME"
    Write-Host "    SSH user        : $targetUser   (non-admin / normal user)"
    Write-Host "    SSH shell       : $shellLabel"
    Write-Host "    authorized_keys : $authKeys"
    Write-Host "    sshd            : $((Get-Service sshd).Status)"
    Write-Host "    Listening :22   : $(if ($listen) { 'yes' } else { 'NO' })"
    if ($ips.Count -gt 0) {
        Write-Host "    LAN IPv4        : $($ips -join ', ')"
    } else {
        Write-Warn2 'No non-APIPA LAN IPv4 address found.'
    }

    $net = Get-NetConnectionProfile -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($net) {
        Write-Host "    Network         : $($net.Name)  category=$($net.NetworkCategory)"
        if ($net.NetworkCategory -eq 'Public') {
            Write-Host '    (Public is OK because the firewall rule allows all profiles.)' -ForegroundColor DarkGray
        }
    }

    Write-Host ''
    Write-Host 'From Linux or Git Bash (same LAN):' -ForegroundColor Green
    if ($ips.Count -gt 0) {
        foreach ($ip in $ips) {
            Write-Host "    ssh $targetUser@$ip"
        }
    } else {
        Write-Host "    ssh $targetUser@<windows-lan-ip>"
    }
    Write-Host ''
    Write-Host 'From the internet: forward router TCP 22 to this PC, then:' -ForegroundColor Green
    Write-Host "    ssh $targetUser@<public-ip-or-ddns>"
    Write-Host ''
    Write-Host 'If login fails, on the client run:  ssh -v ' + "$targetUser@<ip>" -ForegroundColor DarkGray
    Write-Host 'No connection at all = firewall/NAT.  Permission denied = user/key/password.' -ForegroundColor DarkGray
    Write-Host 'Administrators cannot use this path: their keys live under ProgramData\ssh.' -ForegroundColor DarkGray

    Pause-End
    exit 0
} catch {
    Write-Host ''
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    Pause-End
    exit 1
}
