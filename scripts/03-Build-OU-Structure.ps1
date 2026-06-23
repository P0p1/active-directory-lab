<#
.SYNOPSIS
    Step 3 of 4: Create the base OU structure under the ecorp.co.za domain.
.NOTES
    Run as a Domain Admin (or equivalent), once the domain controller is up.
    You can modify $OUList to include any additional OUs you want to create.
#>

Import-Module ActiveDirectory

$OUList = @(
    'OU=Finance,DC=ecorp,DC=co,DC=za',
    'OU=Groups,DC=ecorp,DC=co,DC=za',
    'OU=Computers,DC=ecorp,DC=co,DC=za',
    'OU=Servers,DC=ecorp,DC=co,DC=za',
    'OU=Workstations,DC=ecorp,DC=co,DC=za'
)

# Sort shallowest-first so a parent OU is always created before any OU nested inside it
$OUList = $OUList | Sort-Object { ($_ -split ',').Count }

Write-Host "Creating Organizational Units (OUs) in Active Directory..." -ForegroundColor Cyan

foreach ($OU in $OUList) {

    # First check for any AD object at this distinguished name (not just OUs).
    $existingObj = $null
    try {
        $existingObj = Get-ADObject -Identity $OU -Properties objectClass -ErrorAction Stop
    }
    catch {
        $existingObj = $null
    }

    if ($existingObj) {
        if ($existingObj.ObjectClass -eq 'organizationalUnit') {
            Write-Host "OU already exists: $OU" -ForegroundColor Yellow
        }
        else {
            Write-Host "A non-OU object already exists at $OU (class: $($existingObj.ObjectClass)). Cannot create OU with the same name." -ForegroundColor Red
        }
    }
    else {
        # Extract the OU name and parent path from the full distinguished name
        $Name = (($OU -split ',')[0]) -replace '^OU=', ''
        $ParentPath = ($OU -replace '^OU=[^,]+,', '')

        try {
            New-ADOrganizationalUnit -Name $Name -Path $ParentPath -ProtectedFromAccidentalDeletion $true -ErrorAction Stop
            Write-Host "Created OU: $OU" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create OU: $OU. Error: $_" -ForegroundColor Red
        }
    }
}
