# Security Policy

## Reporting a vulnerability

Please do not open a public issue for security problems.
Report them privately via GitHub's "Report a vulnerability" button on the Security tab of this repository,
or contact the maintainer through https://scloud.work.

Include the affected function, the version (`ModuleVersion` in `EntraDeviceAuth.psd1`) and steps to reproduce.

## Note on file encoding

`EntraDeviceAuth.psd1` and `EntraDeviceAuth.psm1` are stored as UTF-8 (with BOM) so scanners and
Windows PowerShell 5.1 both read them correctly. If you regenerate the manifest with a Windows PowerShell 5.1 cmdlet
such as `New-ModuleManifest`, re-check the encoding before committing.
