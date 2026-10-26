function Compare-DeviceSignature {
    <#
    .SYNOPSIS
        Verify the digital signature using the provided public key.

    .DESCRIPTION
        This function verifies the digital signature using the public key and content.

    .PARAMETER EntraDevice
        Specify the Entra device object which contains AlternativeSecurityIds. (Generated with Get-MgDevice)

    .PARAMETER ValidationRequest
        Specify the validation request object which contains the signature and public key. (Generated with Get-EntraDeviceAuthRequest)

    .NOTES
        Author:      Florian Salzmann
        Contact:     @FlorianSLZ
        Created:     2024-06-21
        Updated:     2026-10-26

        Version history:
        1.0.0 - (2024-06-21) Function created
        1.0.1 - (2026-10-26) Use RSA.Create() with a fresh RSAParameters, [psobject] parameter types

        Credits to Nickolaj Andersen for the initial function.
    #>
    param(
        [parameter(Mandatory = $true, HelpMessage = "Specify the Entra device object which contains AlternativeSecurityIds. (Generated with Get-MgDevice)")]
        [ValidateNotNullOrEmpty()]
        [psobject]$EntraDevice,

        [parameter(Mandatory = $true, HelpMessage = "Specify the validation request object which contains the signature and public key. (Generated with Get-EntraDeviceAuthRequest)")]
        [ValidateNotNullOrEmpty()]
        [psobject]$ValidationRequest
    )
    Process {
        # Convert from Base64 string to byte array
        $PublicKeyBytes = [Convert]::FromBase64String($ValidationRequest.PublicKey)

        # Convert signature from Base64 string
        $SignatureBytes = [Convert]::FromBase64String($ValidationRequest.Signature)

        # Extract the modulus and exponent based on public key data
        $ExponentData = $PublicKeyBytes[-3..-1]
        $ModulusData = $PublicKeyBytes[9..(9 + 255)]

        # Reconstruct the public key from modulus and exponent
        $RSAParameters = New-Object System.Security.Cryptography.RSAParameters
        $RSAParameters.Modulus = $ModulusData
        $RSAParameters.Exponent = $ExponentData
        $PublicKey = [System.Security.Cryptography.RSA]::Create()
        $PublicKey.ImportParameters($RSAParameters)

        # Compute the hash using SHA256
        $SHA256 = [System.Security.Cryptography.SHA256]::Create()
        $EncodedContentData = [System.Text.Encoding]::UTF8.GetBytes($EntraDevice.deviceId)
        $ComputedHash = $SHA256.ComputeHash($EncodedContentData)

        # Verify the signature with the computed hash of the content using the public key
        return $PublicKey.VerifyHash($ComputedHash, $SignatureBytes, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    }
}
