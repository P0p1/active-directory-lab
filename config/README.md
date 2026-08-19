# Configuration Directory

This directory contains centralized configuration files for the Active Directory lab deployment.

## Files

- `ADLabConfig.ini` - Main configuration file with network, AD, OU, and user settings

## Security Notes

⚠️ **IMPORTANT**: This directory is excluded from version control via `.gitignore`.

- Never commit files containing passwords or sensitive information
- Store configuration files securely in production environments
- Consider using Azure Key Vault, HashiCorp Vault, or Windows DPAPI for secrets management in production

## Usage

Scripts will automatically look for configuration files in this directory. You can override the default path using the `-ConfigPath` parameter:

```powershell
.\03-Build-OU-Structure.ps1 -ConfigPath "C:\Secure\Config\ADLabConfig.ini"
.\04-Populate-Users.ps1 -ConfigPath "C:\Secure\Config\ADLabConfig.ini" -UseSecurePassword
```
