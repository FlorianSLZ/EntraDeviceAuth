function Add-xxx{
    
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


        # Check if Graph API Connection is active with rights to: Device.Read.All
        if(!$((Get-MgContext).Scopes -contains "Device.Read.All")){
            Write-Error 'No active Graph connection. Call "Connect-MgGraph -Scopes Device.Read.All" first.'
            exit 
        }

        try{
            $EntraDevice = Get-MgDevice -Filter "deviceId eq '$DeviceID'"
        }catch{
            Write-Error "Device not found: `n$_"

        }

        # Initialize an array to collect error messages
        $Mismatch = @()

        # Compare each variable and collect errors if there is a mismatch
        if ($DeviceName -ne $EntraDevice.DisplayName) {
            $Mismatch += "DeviceName mismatch. Expected: $($EntraDevice.DeviceName), Received: $DeviceName"
        }

        if ($DeviceID -ne $EntraDevice.DeviceID) {
            $Mismatch += "DeviceID mismatch. Expected: $($EntraDevice.DeviceID), Received: $DeviceID"
        }

        $DeviceSignatureVerification = Compare-DeviceSignature -PublicKeyEncoded $PublicKey -Signature $Signature -Content $EntraDevice.deviceId
        $DeviceSignatureVerification = Compare-DeviceSignature -EntraDevice $EntraDevice -ValidationRequest $ValidationRequest
        if ($DeviceSignatureVerification -eq $true) {
            $Mismatch += "Signature mismatch. Expected: $($EntraDevice.Signature), Received: $Signature"
        }

        $DeviceThumbprintVerification = Compare-DeviceThumbprint -EntraDevice $EntraDevice -ValidationRequest $ValidationRequest
        if ($DeviceThumbprintVerification -eq $true) {
            $Mismatch += "Thumbprint mismatch. Expected: $($EntraDevice.Thumbprint), Received: $Thumbprint"
        }

        # Check if there are any errors
        if ($Mismatch.Count -eq 0) {
            return $true
        } else {
            # If there are errors, return the errors
            Write-Verbose "Mismatch: " + ($Mismatch -join "; ")
            return $false
        }
        

        
        
    }catch{
        Write-Error "$_"
    }

}
