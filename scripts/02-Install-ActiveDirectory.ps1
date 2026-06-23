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

# WARNING: this is a placeholder password for lab use only.
# Change it (or prompt with Read-Host -AsSecureString) before using this anywhere else.
$SafeModePassword = ConvertTo-SecureString -AsPlainText 'P@ssw0rd' -Force
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
