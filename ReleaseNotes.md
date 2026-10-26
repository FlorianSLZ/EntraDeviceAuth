# Release notes for EntraDeviceAuth module

## 26.10.26.1
- Manifest and module file re-encoded from UTF-16 to UTF-8 (fixes false "obfuscated code" findings in security scans)
- Fixed `LicenseUri` in the manifest
- `Get-EntraDeviceAuthRequest`: stops with an error if the join certificate is missing instead of signing empty values; handles multiple JoinInfo entries
- `Get-EntraDeviceAuthValidation`: checks for a Microsoft Graph connection, fixed mismatch messages
- Replaced `SHA256Managed` / `RSACryptoServiceProvider` with `SHA256.Create()` / `RSA.Create()`
- Parameters typed as `[psobject]` instead of `[array]`
- Simplified `EntraDeviceAuth.psm1`
- Help text and typo fixes
- Added Pester tests, PSScriptAnalyzer/Pester GitHub Action, `.gitattributes` and `SECURITY.md`

## 24.06.21.2 - .5
- function optimisation/renaming

## 24.06.21.1
- Initial release, see README.md for documentation.
