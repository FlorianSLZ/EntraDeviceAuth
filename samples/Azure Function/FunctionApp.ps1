using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."


<#
Modules:
Microsoft.Graph.Authentication
Microsoft.Graph.Identity.DirectoryManagement
EntraDeviceAuth
#>



# Initate variables
$StatusCode = [HttpStatusCode]::OK
$Body = [string]::Empty

try{

    # establlish graph connection with managed identiy
    Connect-MgGraph -Identity -NoWelcome

    Write-Output $Request

    $RequestBody = $Request.Body

    $EntraDeviceAuthValidation = Get-EntraDeviceAuthValidation -ValidationRequest $RequestBody -ErrorAction Stop
    if($EntraDeviceAuthValidation -eq $true){

        Write-Output "Validation successful: EntraDeviceAuthValidation Result: $EntraDeviceAuthValidation"

        $StorageAccountName = "intunelog001"
        $ResourceGroupName = "rg-intunelog-001"
        $ContainerName = "logs"
        $permissions   = "rwl"
        $SASTokenLifeMin = 10
        $startTime     = (Get-Date).AddMinutes(-5).ToUniversalTime()
        $expiryTime    = (Get-Date).AddMinutes($SASTokenLifeMin).ToUniversalTime()

        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName


        $storageToken = $storageAccount | New-AzStorageContainerSASToken -Container $ContainerName -Permission $permissions -StartTime $startTime -ExpiryTime $expiryTime
        Write-Host "New token generated - will expire in $SASTokenLifeMin minutes."
        

        # Construct the blob storage URI with SAS token
        $storageURL = "$($storageAccount.PrimaryEndpoints.Blob)$ContainerName"
        $storageURI = "$storageURL" + "?" + "$storageToken"

        $storageInfo = @{
            storageURL          = $storageURL
            storageURI          = $storageURI
            storageToken        = $storageToken
        }

         $storageInfo

        $status = [HttpStatusCode]::OK
        $body = $storageInfo

    }else{

        Write-Output "Validation failed: EntraDeviceAuthValidation Result: $EntraDeviceAuthValidation"

        $StatusCode = [HttpStatusCode]::Forbidden
        $Body = "Validation failed: EntraDeviceAuthValidation Result: $EntraDeviceAuthValidation"
    }


}catch{
    Write-Error $_
    $StatusCode = [HttpStatusCode]::InternalServerError
    $Body = "Process Error: See Function App Logs for more deatils. "
}



# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $StatusCode
    Body = $Body
})
