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


        # Download location (modify if needed)
        $downloadPath = "$($env:TEMP)\DownloadedFiles"
        $OnlineFolder = "Secure-Demo-Content"

        # Create the download directory if it doesn't exist
        if (!(Test-Path $downloadPath)) {New-Item -ItemType Directory -Path $downloadPath | Out-Null }

        $storageURI = [System.Uri] $Response.storageURI

        $storageAccountName = $storageURI.DnsSafeHost.Split(".")[0]
        $container = $storageURI.LocalPath.Substring(1)
        $sasToken = $storageURI.Query

        $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken


        $blobs = Get-AzStorageBlob -Context $storageContext -Container $container | Where-Object { $_.Name -like "$OnlineFolder/*" }

        # Download each blob
        foreach ($blob in $blobs) {
            $downloadFilePath = Join-Path $downloadPath ($blob.Name -replace "$OnlineFolder/", "")

            try {
                # Download the blob using SAS token and context
                Get-AzStorageBlobContent -Context $storageContext -CloudBlob $blob.ICloudBlob -Destination $downloadFilePath

                #Get-AzStorageBlobContent -Uri $blob.Uri -Context $storageContext -File $downloadFilePath -Force
                Write-Host "Download successful!"
            } catch {
                Write-Error "Error downloading $($blob.Name): $_"
            }
        }

        Write-Output "All files downloaded from $OnlineFolder to $downloadPath folder."

        exit 0


    }else{
        Write-Error "No valid Authentification: EntraDeviceAuthRequest failed."
        exit 1
    }

}