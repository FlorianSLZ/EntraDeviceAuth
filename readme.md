|Florian Salzmann|[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)|
|----------------|-------------------------------|

# EntraDeviceAuth (IWD)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/EntraDeviceAuth)

The "Intune Win32 Deployer" allows you to transform Windows Package Manager (winget) and Chocolatey installations for Intune into a Win32 application (intunewin) and upload it straight away to your MEM environment. If you want to do without the automatic upload, you can also just generate the intunewin files.

## Installing the module from PSGallery

The IntuneWin32App module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/EntraDeviceAuth). 
Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name EntraDeviceAuth
```

## Import the module for testing

As an alternative to installing, you chan download this Repository and import it in a PowerShell Session. 
*The path may be different in your case*
```PowerShell
Import-Module -Name "C:\GitHub\EntraDeviceAuth\Module\EntraDeviceAuth" -Verbose -Force
```

## Module dependencies

EntraDeviceAuth module requires the following modules, which will be automatically installed as dependencies:
- Microsoft.Graph.Authentication
- Microsoft.Graph.Identity.DirectoryManagement

# Functions / Examples

Here are all functions and some examples to start with:

- Compare-DeviceSignature
- Compare-DeviceThumbprint
- Get-EntraDeviceAuth-Validation
- New-EntraDeviceAuth-Request
- New-RSASignatureFromCertificate


## Authentication
Before using any of the "Get-EntraDeviceAuth-Validation" function within this module, ensure you are authenticated. 

### User Authentication
With this command, you'll be connected to the Graph API and be able to use all commands
```PowerShell
# Authentication as User
Connect-MgGraph -Scopes Device.Read.All

```

