function Compare-DeviceSignature {
    <#
    .SYNOPSIS
        Verify the digital signature using the provided public key.
    
    .DESCRIPTION
        This function verifies the digital signature using the public key and content.

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

        Credits to Nickolaj Andersen for the initial function. 
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
        # Convert from Base64 string to byte array
        $PublicKeyBytes = [Convert]::FromBase64String($ValidationRequest.Body.PublicKey)

        # Convert signature from Base64 string
        $SignatureBytes = [Convert]::FromBase64String($ValidationRequest.Body.Signature)

        # Extract the modulus and exponent based on public key data
        $ExponentData = $PublicKeyBytes[-3..-1]
        $ModulusData = $PublicKeyBytes[9..(9 + 255)]

        # Construct RSACryptoServiceProvider and import modulus and exponent data as parameters to reconstruct the public key from bytes
        $PublicKey = [System.Security.Cryptography.RSACryptoServiceProvider]::Create(2048)
        $RSAParameters = $PublicKey.ExportParameters($false)
        $RSAParameters.Modulus = $ModulusData
        $RSAParameters.Exponent = $ExponentData
        $PublicKey.ImportParameters($RSAParameters)

        # Compute the hash using SHA256
        $SHA256Managed = [System.Security.Cryptography.SHA256]::Create()
        $EncodedContentData = [System.Text.Encoding]::UTF8.GetBytes($EntraDevice.deviceId)
        $ComputedHash = $SHA256Managed.ComputeHash($EncodedContentData)

        # Verify the signature with the computed hash of the content using the public key
        return $PublicKey.VerifyHash($ComputedHash, $SignatureBytes, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    }
}

