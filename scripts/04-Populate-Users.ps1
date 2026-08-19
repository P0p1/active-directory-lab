<#
.SYNOPSIS
    Step 4 of 4: Create a fixed list of sample users in Active Directory.
.NOTES
    Run as a Domain Admin (or equivalent), after the OU structure has been created.
.PARAMETER ConfigPath
    Optional path to centralized configuration file. If not provided, uses default values.
.PARAMETER UseSecurePassword
    If specified, prompts for passwords interactively instead of using defaults.
.EXAMPLE
    .\04-Populate-Users.ps1 -ConfigPath "C:\config\ADLabConfig.ini" -UseSecurePassword
#>

param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\ADLabConfig.ini",
    [switch]$UseSecurePassword
)

Import-Module ActiveDirectory

# Load configuration from file if it exists
if (Test-Path $ConfigPath) {
    Write-Host "Loading configuration from $ConfigPath" -ForegroundColor Cyan
    $Config = Get-IniContent -Path $ConfigPath
    $OU = $Config.Users.UserOU
} else {
    Write-Host "Configuration file not found at $ConfigPath, using default values" -ForegroundColor Yellow
    $OU = 'OU=Finance,DC=ecorp,DC=co,DC=za'
}

$Domain = 'ecorp.co.za'   # Should match the domain used in previous scripts

# User data - in production, consider loading from CSV with secure password handling
if ($UseSecurePassword) {
    Write-Host "Secure password mode enabled. You will be prompted for each user's password." -ForegroundColor Cyan
    $Users = @(
        @{FirstName = 'John'; LastName = 'Doe'; Username = 'jdoe' },
        @{FirstName = 'Jane'; LastName = 'Smith'; Username = 'jsmith' },
        @{FirstName = 'Michael'; LastName = 'Johnson'; Username = 'mjohnson' },
        @{FirstName = 'Emily'; LastName = 'Davis'; Username = 'edavis' },
        @{FirstName = 'William'; LastName = 'Brown'; Username = 'wbrown' },
        @{FirstName = 'Olivia'; LastName = 'Jones'; Username = 'ojones' },
        @{FirstName = 'James'; LastName = 'Bond'; Username = 'jbond' },
        @{FirstName = 'Michael'; LastName = 'Carrick'; Username = 'mcarrick' },
        @{FirstName = 'Benjamin'; LastName = 'Sithole'; Username = 'bsithole' },
        @{FirstName = 'Sophie'; LastName = 'Molambo'; Username = 'smolambo' },
        @{FirstName = 'Lerato'; LastName = 'Mokoena'; Username = 'lmokoena' },
        @{FirstName = 'Thabo'; LastName = 'Mabena'; Username = 'tmabena' },
        @{FirstName = 'Sipho'; LastName = 'Nkosi'; Username = 'snkosi' },
        @{FirstName = 'Nokuthula'; LastName = 'Dlamini'; Username = 'ndlamini' },
        @{FirstName = 'Kgosi'; LastName = 'Mokgadi'; Username = 'kmokgadi' }
    )
} else {
    # Lab mode with default passwords - NOT recommended for production
    Write-Host "WARNING: Using default passwords. This is only for lab environments!" -ForegroundColor Red
    $Users = @(
        @{FirstName = 'John'; LastName = 'Doe'; Username = 'jdoe'; Password = 'P@ssw0rd1' },
        @{FirstName = 'Jane'; LastName = 'Smith'; Username = 'jsmith'; Password = 'P@ssw0rd2' },
        @{FirstName = 'Michael'; LastName = 'Johnson'; Username = 'mjohnson'; Password = 'P@ssw0rd3' },
        @{FirstName = 'Emily'; LastName = 'Davis'; Username = 'edavis'; Password = 'P@ssw0rd4' },
        @{FirstName = 'William'; LastName = 'Brown'; Username = 'wbrown'; Password = 'P@ssw0rd5' },
        @{FirstName = 'Olivia'; LastName = 'Jones'; Username = 'ojones'; Password = 'P@ssw0rd6' },
        @{FirstName = 'James'; LastName = 'Bond'; Username = 'jbond'; Password = 'P@ssw0rd7' },
        @{FirstName = 'Michael'; LastName = 'Carrick'; Username = 'mcarrick'; Password = 'P@ssw0rd8' },
        @{FirstName = 'Benjamin'; LastName = 'Sithole'; Username = 'bsithole'; Password = 'P@ssw0rd9' },
        @{FirstName = 'Sophie'; LastName = 'Molambo'; Username = 'smolambo'; Password = 'P@ssw0rd10' },
        @{FirstName = 'Lerato'; LastName = 'Mokoena'; Username = 'lmokoena'; Password = 'P@ssw0rd11' },
        @{FirstName = 'Thabo'; LastName = 'Mabena'; Username = 'tmabena'; Password = 'P@ssw0rd12' },
        @{FirstName = 'Sipho'; LastName = 'Nkosi'; Username = 'snkosi'; Password = 'P@ssw0rd13' },
        @{FirstName = 'Nokuthula'; LastName = 'Dlamini'; Username = 'ndlamini'; Password = 'P@ssw0rd14' },
        @{FirstName = 'Kgosi'; LastName = 'Mokgadi'; Username = 'kmokgadi'; Password = 'P@ssw0rd15' }
    )
}
# -------------------------------------------------------------------------

Write-Host "Populating Users in Active Directory..." -ForegroundColor Cyan

foreach ($User in $Users) {
    $FirstName = $User.FirstName
    $LastName = $User.LastName
    $Username = $User.Username

    $FullName = "$FirstName $LastName"
    $UserPrincipalName = "$Username@$Domain"

    # Handle password securely based on mode
    if ($UseSecurePassword) {
        $Password = Read-Host -AsSecureString "Enter password for user: $Username"
        if ([string]::IsNullOrEmpty($Password)) {
            Write-Host "Skipping user $Username - empty password provided" -ForegroundColor Red
            continue
        }
        $PasswordAsSecureString = $Password
    } else {
        $Password = $User.Password
        $PasswordAsSecureString = ConvertTo-SecureString -String $Password -AsPlainText -Force
    }

    # Check if the user already exists
    $existingUser = Get-ADUser -Filter { SamAccountName -eq $Username } -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "User already exists: $FullName with username: $Username" -ForegroundColor Yellow
        continue
    }
    try {
        New-ADUser `
            -Name $FullName `
            -GivenName $FirstName `
            -Surname $LastName `
            -SamAccountName $Username `
            -UserPrincipalName $UserPrincipalName `
            -AccountPassword $PasswordAsSecureString `
            -Enabled $true `
            -Path $OU `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

        Write-Host "Created user: $FullName with username: $Username" -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating user: $FullName with username: $Username. Error: $_" -ForegroundColor Red
    }
}

Write-Host "Users have been populated in Active Directory." -ForegroundColor Green
