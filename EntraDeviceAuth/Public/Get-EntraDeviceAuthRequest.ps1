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
        Updated:     2024-06-21

        Version history:
        1.0.0 - (2024-06-21) Function created

    #>

    param ()

    try {
        $AzureADJoinInfoRegistryKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo"

        # Check if the registry path for Azure AD Join info exists
        if (Test-Path -Path $AzureADJoinInfoRegistryKeyPath) {
            # Retrieve the certificate thumbprint from the registry
            $CertificateThumbprint = Get-ChildItem -Path $AzureADJoinInfoRegistryKeyPath | Select-Object -ExpandProperty "PSChildName"

            if ($CertificateThumbprint -ne $null) {
                # Retrieve the machine certificate based on the thumbprint from the registry key
                $AzureADJoinCertificate = Get-ChildItem -Path "Cert:\LocalMachine\My" -Recurse | Where-Object { $_.Thumbprint -eq $CertificateThumbprint }
                if ($AzureADJoinCertificate -ne $null) {
                    # Extract the device identifier from the certificate's subject name
                    $AzureADDeviceID = ($AzureADJoinCertificate | Select-Object -ExpandProperty "Subject") -replace "CN=", ""

                    # Get the public key bytes from the certificate and convert to Base64 string
                    [byte[]]$PublicKeyBytes = $AzureADJoinCertificate.GetPublicKey()
                    $PublicKey = [System.Convert]::ToBase64String($PublicKeyBytes)
                
                }else{
                    Write-Error "No Entra Device Certificate found."
                }
            } else {
                Write-Error "No Entra Device Certificate Thumbprint found."
            }

            # Generate the signature using the certificate thumbprint and device ID
            $Signature = New-RSASignatureFromCertificate -Content $AzureADDeviceID -Thumbprint $CertificateThumbprint

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

        } else {
            Write-Error "Device is not Entra joined."
        }

    } catch {
        Write-Error "Error while processing device authentication request `n$_"
    }
}
