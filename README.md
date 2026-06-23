# Active Directory Lab Deployment Scripts

PowerShell scripts to stand up a single-server Active Directory lab environment
for **ecorp.co.za**: configure networking, promote the server to a domain
controller, build a base OU structure, and provision sample user accounts.

> ⚠️ **Lab use only.** Passwords are stored in plaintext in these scripts for
> simplicity. Do not reuse this approach, or these passwords, anywhere outside
> an isolated test environment.

## Requirements

- Windows Server (tested for a single-DC lab forest)
- Run all scripts in an elevated (Administrator) PowerShell session
- An isolated/lab network — the static IP, gateway, and domain name below are
  defaults and should be changed to match your environment

## Run order

Scripts are numbered and must be run in order, on the same server, with a
reboot between steps 1 and 2:

| Step | Script | What it does | Reboots? |
|------|--------|---------------|----------|
| 1 | `01-Prerequisites.ps1` | Sets a static IP, gateway, and DNS (pointed at itself); renames the computer to `Server01` | Yes |
| 2 | `02-Install-ActiveDirectory.ps1` | Installs the AD DS role and promotes the server to a new forest's first Domain Controller | Yes |
| 3 | `03-Build-OU-Structure.ps1` | Creates the base OUs: `Users`, `Groups`, `Computers`, `Servers`, `Workstations` | No |
| 4 | `04-Populate-Users.ps1` | Creates 15 sample users (hardcoded list) in the `Users` OU | No |

`Install-User-From-CSV.ps1` is an alternative to step 4 — use it instead if
you'd rather provision users from a CSV file than the hardcoded list.

## Configuration

Each script has its variables set near the top — update these before running:

- **01-Prerequisites.ps1**: `$StaticIP`, `$Gateway`, `$DNS`, `$NewComputerName`
- **02-Install-ActiveDirectory.ps1**: `$Domain`, `$NetBIOSName`, `$SafeModePassword`
- **03-Build-OU-Structure.ps1**: `$OUList`
- **04-Populate-Users.ps1**: `$OU`, `$Domain`, `$Users`
- **Install-User-From-CSV.ps1**: `$CsvPath`, `$OU`, `$Domain`

### CSV format for `Install-User-From-CSV.ps1`

The CSV must have these headers:

```csv
FirstName,LastName,Username,Password
John,Doe,jdoe,P@ssw0rd1
Jane,Smith,jsmith,P@ssw0rd2
```

## Usage

```powershell
# On the server, as Administrator, in order:
.\01-Prerequisites.ps1            # reboots
.\02-Install-ActiveDirectory.ps1  # reboots
.\03-Build-OU-Structure.ps1
.\04-Populate-Users.ps1           # or: .\Install-User-From-CSV.ps1
```

## Notes

- Scripts are idempotent where practical (e.g. `03-Build-OU-Structure.ps1`
  skips OUs that already exist, `01-Prerequisites.ps1` clears any existing
  IP before assigning the static one) so they're safe to re-run if a step
  fails partway through.
- `04-Populate-Users.ps1` and `Install-User-From-CSV.ps1` both wrap user
  creation in a `try/catch` per user, so one failed account (e.g. a
  duplicate username) won't stop the rest from being created.
- Replace the placeholder Safe Mode Administrator Password and all sample
  user passwords before using this anywhere beyond a throwaway lab.
