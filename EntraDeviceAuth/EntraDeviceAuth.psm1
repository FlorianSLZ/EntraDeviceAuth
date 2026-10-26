<#
.SYNOPSIS
    Script that initiates the EntraDeviceAuth module

.NOTES
    Author:      Florian Salzmann
    Contact:     @FlorianSLZ / https://scloud.work
    Created:     2024-06-21
    Updated:     2026-10-26

    Version history:
    1.0.0 - (2024-06-21) Function created
    1.0.1 - (2026-10-26) Simplified loader
#>

# Locate all the public and private function specific files
$PublicFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Public") -Filter "*.ps1" -ErrorAction SilentlyContinue
$PrivateFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Private") -Filter "*.ps1" -ErrorAction SilentlyContinue

# Dot source the function files
foreach ($FunctionFile in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $FunctionFile.FullName
    }
    catch {
        Write-Error -Message "Failed to import function '$($FunctionFile.FullName)' with error: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
