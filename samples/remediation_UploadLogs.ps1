<#
.SYNOPSIS

.NOTES
    FileName:    remediation_UploadLogs.ps1
    Author:      Florian Salzmann
    Created:     2024-06-21
    Updated:     2024-06-21

    Version history:
    1.0.0 - (2024-05-14) Script created
#>
Process {

    # Define the required modules and versions in an array of hashtables
    $requiredModules = @(
        @{ Name = "EntraDeviceAuth"; Version = "24.6.21.5" },
        @{ Name = "Az.Storage"; Version = "7.0.0" }
    )

    # Loop through each module in the array
    foreach ($module in $requiredModules) {
        $moduleName = $module.Name
        $requiredVersion = $module.Version

        # Check if the module is installed and at least the required version
        $installedModule = Get-Module -Name $moduleName -ListAvailable | Where-Object { $_.Version -ge [System.Version]$requiredVersion }
        if (-not $installedModule) {
            Write-Host "Installing $moduleName version $requiredVersion"
            Install-Module -Name $moduleName -RequiredVersion $requiredVersion -Force -Scope CurrentUser -ErrorAction Stop
        } 
    }

    # Import the module to make it available in the current session
    Import-Module $requiredModules.Name




    # Use TLS 1.2 connection when calling Azure Function
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


    # Create body for Function App request
    $BodyTable = Get-EntraDeviceAuthRequest

    # Optional - extend body table with additional data
    $BodyTable.Add("Key", "Value")

    # Construct URI for Function App request
    $functionappURI = "https://entradeviceauth001.azurewebsites.net/api/Intune-Remediation?code=Ybu3JWOaJGX93eF7YhGHy3BEl5VxfUiiMuGVsIQieXR1AzFufRd5UQ%3D%3D"
    $Response = Invoke-RestMethod -Method "POST" -Uri $functionappURI -Body ($BodyTable | ConvertTo-Json) -ContentType "application/json" -ErrorAction Stop

    if($Response.storageURL -like "https://*"){


        # data to upload
        $DataUpload = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"


        # Enumerate files in C:\temp (modify for specific file selection)
        $filesToUpload = Get-ChildItem -Path $DataUpload -File

        # Create the folder name and the zip filename
        $zipFileName = "$((Get-WmiObject -class win32_bios).SerialNumber )-$(Get-Date -Format "yyyy-MM-dd_hh-mm").zip"

        # Create a temporary location for the zip file (modify if needed)
        $tempZipPath = "$($env:TEMP)\$zipFileName"
        $tempCache = "$($env:TEMP)\datacollectiondirecory"

        # Create the zip file (consider error handling)
        Copy-Item -Path $DataUpload -Destination $tempCache -Recurse -PassThru | 
        Get-ChildItem |
        Compress-Archive -DestinationPath $tempZipPath  -CompressionLevel Optimal -Force
        Write-Host "Created zip file: $tempZipPath"


        $storageURI = [System.Uri] $Response.storageURI

        $storageAccountName = $storageURI.DnsSafeHost.Split(".")[0]
        $container = $storageURI.LocalPath.Substring(1)
        $sasToken = $storageURI.Query

        $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken
        Set-AzStorageBlobContent -File $tempZipPath -Container $container -Context $storageContext -Force

        Remove-Item $tempCache -Force -Recurse
        Remove-Item $tempZipPath -Force

        Write-Output "Upload completed: $zipFileName"
        exit 0


    }else{
        Write-Error "No valid Authentification!"
        exit 1
    }

}