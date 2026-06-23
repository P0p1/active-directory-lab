<#
.SYNOPSIS
    Step 1 of 4: Configure networking prerequisites for the future domain controller.
.NOTES
    Run as Administrator. The computer will reboot at the end of this script.
#>

#Requires -RunAsAdministrator

# --- Configuration -----------------------------------------------------
$StaticIP = '192.168.83.10'
$PrefixLength = 24
$Gateway = '192.168.83.1'
$DNS = '127.0.0.1'   # Points to itself - this server becomes the DNS server once AD DS/DNS is installed in step 2
$NewComputerName = 'Server01'
# -------------------------------------------------------------------------

$Interface = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

if (-not $Interface) {
    throw "No active ('Up') network adapter was found. Aborting before any changes are made."
}

Write-Host "Configuring network interface '$($Interface.Name)' with static IP $StaticIP/$PrefixLength, gateway $Gateway, and DNS $DNS" -ForegroundColor Cyan


Set-NetIPInterface -InterfaceAlias $Interface.Name -Dhcp Disabled -ErrorAction SilentlyContinue

Get-NetIPAddress -InterfaceAlias $Interface.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue |
Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue

Get-NetRoute -InterfaceAlias $Interface.Name -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue

try {
    New-NetIPAddress -InterfaceAlias $Interface.Name -IPAddress $StaticIP -PrefixLength $PrefixLength -DefaultGateway $Gateway -ErrorAction Stop
    Set-DnsClientServerAddress -InterfaceAlias $Interface.Name -ServerAddresses $DNS -ErrorAction Stop
}
catch {
    throw "Failed to apply static IP configuration to '$($Interface.Name)'. Error: $_"
}

Write-Host "Renaming computer to '$NewComputerName'" -ForegroundColor Cyan
Rename-Computer -NewName $NewComputerName -Force -Restart
