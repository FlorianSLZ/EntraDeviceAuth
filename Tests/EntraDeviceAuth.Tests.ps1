BeforeAll {
    $ModulePath = Join-Path $PSScriptRoot '..\EntraDeviceAuth\EntraDeviceAuth.psd1'
    # Import only the functions, the Graph modules listed in RequiredModules are not needed for these tests
    $ModuleRoot = Split-Path $ModulePath
    Get-ChildItem (Join-Path $ModuleRoot 'Public') -Filter *.ps1 | ForEach-Object { . $_.FullName }

    # Build a self-signed certificate and a matching request, the same way a device would
    $script:Cert = New-SelfSignedCertificate -Subject 'CN=11111111-2222-3333-4444-555555555555' -KeyAlgorithm RSA -KeyLength 2048 -CertStoreLocation 'Cert:\CurrentUser\My'
    $DeviceId = '11111111-2222-3333-4444-555555555555'
    $Rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($script:Cert)
    $Hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($DeviceId))
    $Signature = $Rsa.SignHash($Hash, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)

    $script:Request = [ordered]@{
        DeviceName = 'TEST-PC'
        DeviceID   = $DeviceId
        Signature  = [Convert]::ToBase64String($Signature)
        Thumbprint = $script:Cert.Thumbprint
        PublicKey  = [Convert]::ToBase64String($script:Cert.GetPublicKey())
    }
    $script:EntraDevice = [pscustomobject]@{
        deviceId               = $DeviceId
        DisplayName            = 'TEST-PC'
        AlternativeSecurityIds = @([pscustomobject]@{ Key = [System.Text.Encoding]::Unicode.GetBytes("X509:<SHA1-TP-PUBKEY>$($script:Cert.Thumbprint)") })
    }
}

AfterAll {
    if ($script:Cert) { Remove-Item "Cert:\CurrentUser\My\$($script:Cert.Thumbprint)" -ErrorAction SilentlyContinue }
}

Describe 'Module manifest' {
    It 'is valid' {
        { Test-ModuleManifest -Path $ModulePath -ErrorAction Stop } | Should -Not -Throw
    }
    It 'is not UTF-16 encoded' {
        $Bytes = [System.IO.File]::ReadAllBytes($ModulePath)
        ($Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) | Should -BeFalse
        $Bytes -contains 0 | Should -BeFalse
    }
}

Describe 'Compare-DeviceSignature' {
    It 'accepts a valid signature' {
        Compare-DeviceSignature -EntraDevice $script:EntraDevice -ValidationRequest $script:Request | Should -BeTrue
    }
    It 'rejects a signature for a different device id' {
        $Other = [pscustomobject]@{ deviceId = '99999999-2222-3333-4444-555555555555' }
        Compare-DeviceSignature -EntraDevice $Other -ValidationRequest $script:Request | Should -BeFalse
    }
}

Describe 'Compare-DeviceThumbprint' {
    It 'matches the thumbprint stored in Entra' {
        Compare-DeviceThumbprint -EntraDevice $script:EntraDevice -ValidationRequest $script:Request | Should -BeTrue
    }
    It 'rejects a different thumbprint' {
        $Bad = [pscustomobject]@{ Thumbprint = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' }
        Compare-DeviceThumbprint -EntraDevice $script:EntraDevice -ValidationRequest $Bad | Should -BeFalse
    }
}
