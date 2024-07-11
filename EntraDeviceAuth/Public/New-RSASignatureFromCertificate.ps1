function New-RSASignatureFromCertificate {
    <#
    .SYNOPSIS
        Creates a new signature based on content using the private key of a certificate identified by its thumbprint.

    .DESCRIPTION
        Creates a new signature based on content using the private key of a certificate identified by its thumbprint.
        The certificate must be available in the LocalMachine\My certificate store and have a private key.

    .PARAMETER Content
        Specifies the content string to be signed.

    .PARAMETER Thumbprint
        Specifies the thumbprint of the certificate.

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
        [parameter(Mandatory = $true, HelpMessage = "Specify the content string to be signed.")]
        [ValidateNotNullOrEmpty()]
        [string]$Content,

        [parameter(Mandatory = $true, HelpMessage = "Specify the thumbprint of the certificate.")]
        [ValidateNotNullOrEmpty()]
        [string]$Thumbprint
    )

    Process {
        try {
            # Retrieve the certificate based on thumbprint
            $Certificate = Get-ChildItem -Path "Cert:\LocalMachine\My" -Recurse | Where-Object { $_.Thumbprint -eq $Thumbprint }

            if ($Certificate -ne $null -and $Certificate.HasPrivateKey) {
                # Get the RSA private key
                $RSAPrivateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate)

                if ($RSAPrivateKey -ne $null) {
                    # Compute SHA256 hash of the content
                    $SHA256Managed = [System.Security.Cryptography.SHA256Managed]::Create()
                    $EncodedContentData = [System.Text.Encoding]::UTF8.GetBytes($Content)
                    $ComputedHash = $SHA256Managed.ComputeHash($EncodedContentData)

                    # Sign the hash with RSA private key
                    $SignatureSigned = $RSAPrivateKey.SignHash($ComputedHash, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)

                    # Convert signature to Base64 string
                    $SignatureString = [System.Convert]::ToBase64String($SignatureSigned)

                    return $SignatureString
                } else {
                    Write-Error "Failed to retrieve RSA private key from the certificate."
                }
            } else {
                Write-Error "Certificate with thumbprint $Thumbprint not found or does not have a private key."
            }
        } catch {
            Write-Error "Error while creating RSA certificate signature: $_"
        }
    }
}
