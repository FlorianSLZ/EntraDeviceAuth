function Compare-DeviceThumbprint {
    <#
    .SYNOPSIS
        Compare the thumbprint from the Entra device with the thumbprint from the validation request.
    
    .DESCRIPTION
        This function extracts the thumbprint from the Entra device's AlternativeSecurityIds and compares it with the thumbprint provided in the validation request.

    .PARAMETER EntraDevice
        Specify the Entra device object which contains AlternativeSecurityIds. (Genarated with Get-MgDevice)

    .PARAMETER ValidationRequest
        Specify the validation request object which contains the Thumbprint to be compared. (Genarated with Get-EntraDeviceAuth-Local)
    
    .NOTES
        Author:      Florian Salzmann
        Contact:     @FlorianSLZ
        Created:     2024-06-21
        Updated:     2024-06-21
    
        Version history:
        1.0.0 - (2024-06-21) Function created
    #>
    param(
        [parameter(Mandatory = $true, HelpMessage = "Specify the Entra device object which contains AlternativeSecurityIds. (Genarated with Get-MgDevice)")]
        [ValidateNotNullOrEmpty()]
        [array]$EntraDevice,

        [parameter(Mandatory = $true, HelpMessage = "Specify the validation request object which contains the Thumbprint to be compared. (Genarated with Get-EntraDeviceAuth-Local)")]
        [ValidateNotNullOrEmpty()]
        [array]$ValidationRequest
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
        if ($EntraThumbprint -eq $null) {
            Write-Warning "Thumbprint key in Entra ID not found."
        }elseif($EntraThumbprint -like "*$($ValidationRequest.Body.Thumbprint)*"){
            return $true
        }else{
            return $false
        }

    }
}

