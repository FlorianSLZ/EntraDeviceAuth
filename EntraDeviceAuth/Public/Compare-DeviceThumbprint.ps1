function Compare-DeviceThumbprint {
    <#
    .SYNOPSIS
        Compare the thumbprint from the Entra device with the thumbprint from the validation request.

    .DESCRIPTION
        This function extracts the thumbprint from the Entra device's AlternativeSecurityIds and compares it with the thumbprint provided in the validation request.

    .PARAMETER EntraDevice
        Specify the Entra device object which contains AlternativeSecurityIds. (Generated with Get-MgDevice)

    .PARAMETER ValidationRequest
        Specify the validation request object which contains the Thumbprint to be compared. (Generated with Get-EntraDeviceAuthRequest)

    .NOTES
        Author:      Florian Salzmann
        Contact:     @FlorianSLZ
        Created:     2024-06-21
        Updated:     2026-10-26

        Version history:
        1.0.0 - (2024-06-21) Function created
        1.0.1 - (2026-10-26) [psobject] parameter types, help text fixes
    #>
    param(
        [parameter(Mandatory = $true, HelpMessage = "Specify the Entra device object which contains AlternativeSecurityIds. (Generated with Get-MgDevice)")]
        [ValidateNotNullOrEmpty()]
        [psobject]$EntraDevice,

        [parameter(Mandatory = $true, HelpMessage = "Specify the validation request object which contains the Thumbprint to be compared. (Generated with Get-EntraDeviceAuthRequest)")]
        [ValidateNotNullOrEmpty()]
        [psobject]$ValidationRequest
    )
    Process {
        # Extract the AlternativeSecurityIds
        $AlternativeSecurityIds = $EntraDevice.AlternativeSecurityIds

        # Initialize a variable to store the thumbprint
        $EntraThumbprint = $null

        # Loop through each AlternativeSecurityId
        foreach ($securityId in $AlternativeSecurityIds) {
            if ($securityId.Key -is [Array]) {
                # Remove the zero bytes (assuming Unicode)
                $filteredKey = $securityId.Key | Where-Object { $_ -ne 0 }

                # Convert the array of bytes to a string
                $EntraThumbprint = -join ([char[]]$filteredKey)
            }
        }

        # Check if thumbprint was found
        if ($null -eq $EntraThumbprint) {
            Write-Warning "Thumbprint key in Entra ID not found."
        } elseif ($EntraThumbprint -like "*$($ValidationRequest.Thumbprint)*") {
            return $true
        } else {
            return $false
        }

    }
}
