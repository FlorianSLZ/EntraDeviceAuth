function Get-EntraDeviceAuthRequest {
    <#
    .SYNOPSIS
        Creates a new device authentication request for an Entra-joined device.

    .DESCRIPTION
        This function generates a new device authentication request for an Entra-joined device by retrieving the necessary certificate information, creating a signature, and constructing the validation request.

    .NOTES
        Author:      Florian Salzmann
        Contact:     @FlorianSLZ
        Created:     2024-06-21
        Updated:     2026-10-26

        Version history:
        1.0.0 - (2024-06-21) Function created
        1.0.1 - (2026-10-26) Stop on missing certificate instead of signing with empty values

    #>

    param ()

    try {
        $AzureADJoinInfoRegistryKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo"

        # Check if the registry path for Azure AD Join info exists
        if (-not (Test-Path -Path $AzureADJoinInfoRegistryKeyPath)) {
            throw "Device is not Entra joined."
        }

        # Retrieve the certificate thumbprint from the registry (use the first entry if several exist)
        $CertificateThumbprint = Get-ChildItem -Path $AzureADJoinInfoRegistryKeyPath | Select-Object -First 1 -ExpandProperty "PSChildName"
        if (-not $CertificateThumbprint) {
            throw "No Entra Device Certificate Thumbprint found."
        }

        # Retrieve the machine certificate based on the thumbprint from the registry key
        $AzureADJoinCertificate = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Thumbprint -eq $CertificateThumbprint }
        if (-not $AzureADJoinCertificate) {
            throw "No Entra Device Certificate found."
        }

        # Extract the device identifier from the certificate's subject name
        $AzureADDeviceID = $AzureADJoinCertificate.Subject -replace "CN=", ""

        # Get the public key bytes from the certificate and convert to Base64 string
        [byte[]]$PublicKeyBytes = $AzureADJoinCertificate.GetPublicKey()
        $PublicKey = [System.Convert]::ToBase64String($PublicKeyBytes)

        # Generate the signature using the certificate thumbprint and device ID
        $Signature = New-RSASignatureFromCertificate -Content $AzureADDeviceID -Thumbprint $CertificateThumbprint -ErrorAction Stop

        # Construct the validation request object with necessary details
        $ValidationRequest = [ordered]@{
            DeviceName  = $env:COMPUTERNAME
            DeviceID    = $AzureADDeviceID
            Signature   = $Signature
            Thumbprint  = $CertificateThumbprint
            PublicKey   = $PublicKey
        }

        # Return the validation request object
        return $ValidationRequest

    } catch {
        Write-Error "Error while processing device authentication request `n$_"
    }
}
