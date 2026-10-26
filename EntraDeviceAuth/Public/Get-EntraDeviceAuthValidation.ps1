function Get-EntraDeviceAuthValidation {

    <#
    .SYNOPSIS
        Validates device properties and signatures against the Entra device information retrieved from Microsoft Graph.

    .DESCRIPTION
        This function validates the properties and signatures of a device against the Entra device information retrieved from Microsoft Graph.
        It requires an active Microsoft Graph connection (Connect-MgGraph) with the "Device.Read.All" permission.
        The function then compares various properties and signatures to detect any mismatches.

    .PARAMETER ValidationRequest
        The validation request object which contains the Thumbprint to be compared. (Generated with Get-EntraDeviceAuthRequest)

    .NOTES
        Author:      Florian Salzmann
        Contact:     @FlorianSLZ
        Created:     2024-06-21
        Updated:     2026-10-26

        Version history:
        1.0.0 - (2024-06-21) Function created
        1.0.1 - (2026-10-26) Fix mismatch messages, check Graph connection, use [psobject] parameter type
    #>

    param(
        [parameter(Mandatory = $true, HelpMessage = "Specify the validation request object which contains the Thumbprint to be compared. (Generated with Get-EntraDeviceAuthRequest)")]
        [ValidateNotNullOrEmpty()]
        [psobject]$ValidationRequest
    )
    try {
        # Make sure there is an active Microsoft Graph connection with the required permission
        $MgContext = Get-MgContext
        if (-not $MgContext) {
            throw "No Microsoft Graph connection found. Run Connect-MgGraph first."
        }
        if ($MgContext.Scopes -and $MgContext.Scopes -notcontains "Device.Read.All" -and $MgContext.Scopes -notcontains "Device.ReadWrite.All") {
            Write-Warning "The current Microsoft Graph connection does not list the 'Device.Read.All' scope."
        }

        try {
            $EntraDevice = Get-MgDevice -Filter "deviceId eq '$($ValidationRequest.DeviceID)'"
        } catch {
            Write-Error "Device not found: `n$_"
        }

        # Initialize an array to collect error messages
        $Mismatch = @()

        # Compare each variable and collect errors if there is a mismatch
        if ($ValidationRequest.DeviceName -ne $EntraDevice.DisplayName) {
            $Mismatch += "DeviceName mismatch. Expected: $($EntraDevice.DisplayName), Received: $($ValidationRequest.DeviceName)"
        }

        if ($ValidationRequest.DeviceID -ne $EntraDevice.DeviceID) {
            $Mismatch += "DeviceID mismatch. Expected: $($EntraDevice.DeviceID), Received: $($ValidationRequest.DeviceID)"
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

    } catch {
        Write-Error "$_"
    }

}
