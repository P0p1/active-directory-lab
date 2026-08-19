<#
.SYNOPSIS
    Step 2 of 4: Install the AD DS role and promote this server to the first
    Domain Controller of a new forest.
.NOTES
    Run as Administrator, after 01-Prerequisites.ps1 has rebooted the server with its
    static IP/DNS configuration. This script will restart the server itself when done.
#>

#Requires -RunAsAdministrator

# --- Configuration -----------------------------------------------------
$Domain = 'ecorp.co.za'
$NetBIOSName = 'ECORP'

# Securely prompt for DSRM password instead of hardcoding
Write-Host "Enter the Directory Services Restore Mode (DSRM) password:" -ForegroundColor Cyan
$SafeModePassword = Read-Host -AsSecureString "DSRM Password"

# Validate password complexity
if ([string]::IsNullOrEmpty($SafeModePassword)) {
    throw "DSRM password cannot be empty. Please run the script again."
}
# -------------------------------------------------------------------------

Write-Host "Installing the AD DS role..." -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "Creating forest '$Domain' and promoting this server to a domain controller..." -ForegroundColor Cyan

# This will restart the server
Install-ADDSForest `
    -DomainName $Domain `
    -DomainNetbiosName $NetBIOSName `
    -CreateDnsDelegation:$false `
    -DatabasePath 'C:\Windows\NTDS' `
    -DomainMode 'WinThreshold' `
    -ForestMode 'WinThreshold' `
    -InstallDns:$true `
    -LogPath 'C:\Windows\NTDS' `
    -NoRebootOnCompletion:$false `
    -SafeModeAdministratorPassword $SafeModePassword `
    -SysvolPath 'C:\Windows\SYSVOL' `
    -Force:$true

Write-Host "Domain $Domain has been created and the server has been promoted to a domain controller. It will now restart." -ForegroundColor Green
