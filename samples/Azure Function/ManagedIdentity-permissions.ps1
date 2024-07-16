################################################################################
#   Graph permission
################################################################################

<#
Modules:
Install-Module Microsoft.Graph.Authentication -Force
Install-Module Microsoft.Graph.Applications -Force

#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All","AppRoleAssignment.ReadWrite.All","RoleManagement.ReadWrite.Directory"


# You will be prompted for the Name of you Managed Identity
$MdId_Name = Read-Host "Name of your Managed Identity"
$MdId_ID = (Get-MgServicePrincipal -Filter "displayName eq '$MdId_Name'").id

# Adding Microsoft Graph permissions
$graphApp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

# Add the required Graph scopes
$graphScopes = @(
  "Device.Read.All"
)
ForEach($scope in $graphScopes){
  $appRole = $graphApp.AppRoles | Where-Object {$_.Value -eq $scope}

  if ($null -eq $appRole) { Write-Warning "Unable to find App Role for scope $scope"; continue; }

  # Check if permissions isn't already assigned
  $assignedAppRole = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MdId_ID | Where-Object { $_.AppRoleId -eq $appRole.Id -and $_.ResourceDisplayName -eq "Microsoft Graph" }

  if ($null -eq $assignedAppRole) {
    New-MgServicePrincipalAppRoleAssignment -PrincipalId $MdId_ID -ServicePrincipalId $MdId_ID -ResourceId $graphApp.Id -AppRoleId $appRole.Id
  }else{
    Write-host "Scope $scope already assigned"
  }
}

<#

# Removing all Graph scopes
$MdId_permissions = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MdId_ID
ForEach($Assignment in $MdId_permissions){
  Remove-MgServicePrincipalAppRoleAssignment -AppRoleAssignmentId $Assignment.Id -ServicePrincipalId $MdId_ID
}


#>
