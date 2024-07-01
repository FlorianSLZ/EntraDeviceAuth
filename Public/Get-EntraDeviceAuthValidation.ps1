function Get-EntraDeviceAuthValidation{
    
    <#
    .SYNOPSIS
        Validates device properties and signatures against the Entra device information retrieved from Microsoft Graph.

    .DESCRIPTION
        This function validates the properties and signatures of a device against the Entra device information retrieved from Microsoft Graph. 
        It ensures that the connection to Microsoft Graph is active and has the necessary permissions ("Device.Read.All"). 
        The function then compares various properties and signatures to detect any mismatches.

    .PARAMETER ValidationRequest
        The validation request object which contains the Thumbprint to be compared. (Generated with Get-EntraDeviceAuth-Local)
    
    .NOTES
        Author:      Florian Salzmann
        Contact:     @FlorianSLZ
        Created:     2024-06-21
        Updated:     2024-06-21
    
        Version history:
        1.0.0 - (2024-06-21) Function created
    #>

    param(
        [parameter(Mandatory = $true, HelpMessage = "Specify the validation request object which contains the Thumbprint to be compared. (Genarated with Get-EntraDeviceAuth-Local)")]
        [ValidateNotNullOrEmpty()]
        [array]$ValidationRequest
    )
    try{
        try{
            $EntraDevice = Get-MgDevice -Filter "deviceId eq '$($ValidationRequest.DeviceID)'"
        }catch{
            Write-Error "Device not found: `n$_"

        }

        # Initialize an array to collect error messages
        $Mismatch = @()

        # Compare each variable and collect errors if there is a mismatch
        if ($ValidationRequest.DeviceName -ne $EntraDevice.DisplayName) {
            $Mismatch += "DeviceName mismatch. Expected: $($EntraDevice.DeviceName), Received: $DeviceName"
        }

        if ($ValidationRequest.DeviceID -ne $EntraDevice.DeviceID) {
            $Mismatch += "DeviceID mismatch. Expected: $($EntraDevice.DeviceID), Received: $DeviceID"
        }

        if (!$(Compare-DeviceSignature -EntraDevice $EntraDevice -ValidationRequest $ValidationRequest)) {
            $Mismatch += "Signature mismatch. Signature verification failed."
        }

        if (!$(Compare-DeviceThumbprint -EntraDevice $EntraDevice -ValidationRequest $ValidationRequest)) {
            $Mismatch += "Thumbprint mismatch. Thumbprint verification failed."
        }

        # Check if there are any errors
        if ($Mismatch.Count -eq 0) {
            return $true
        } else {
            # If there are errors, return the errors
            Write-Verbose "Mismatch:  $($Mismatch -join "; ")"
            return $false
        }
        

        
        
    }catch{
        Write-Error "$_"
    }

}
