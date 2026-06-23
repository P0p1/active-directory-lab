# Install-User-From-CSV.ps1

Import-Module ActiveDirectory

# --- Configuration -----------------------------------------------------
$CsvPath = 'C:\Path\To\Your\Users.csv'   # Update the path to your CSV file
$OU = 'OU=Finance,DC=ecorp,DC=co,DC=za'   # Update to match your OU and domain
$Domain = 'ecorp.co.za'   # Update to match your domain
# -------------------------------------------------------------------------

# file missing, that throws an unhandled, unfriendly error and stops the whole script.
if (-not (Test-Path -Path $CsvPath)) {
    throw "CSV file not found at '$CsvPath'. Update `$CsvPath and try again."
}

try {
    $Users = Import-Csv -Path $CsvPath -ErrorAction Stop
}
catch {
    throw "Failed to read CSV file '$CsvPath'. Error: $_"
}

Write-Host "Populating Users in Active Directory from CSV file..." -ForegroundColor Cyan

foreach ($User in $Users) {
    $FirstName = $User.FirstName
    $LastName = $User.LastName
    $Username = $User.Username
    $Password = $User.Password

    if (-not $FirstName -or -not $LastName -or -not $Username -or -not $Password) {
        Write-Host "Skipping row with missing data: $($User | Out-String)" -ForegroundColor Yellow
        continue
    }

    $FullName = "$FirstName $LastName"
    $PasswordAsSecureString = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $UserPrincipalName = "$Username@$Domain"

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

Write-Host "Users have been populated in Active Directory from CSV file." -ForegroundColor Green
