<p align="center">
    <a href="https://scloud.work" alt="Florian Salzmann | scloud"></a>
            <img src="https://scloud.work/wp-content/uploads/EntraDeviceAuth-Icon.png" width="75" height="75" /></a>
</p>
<p align="center">
    <a href="https://www.linkedin.com/in/fsalzmann/">
        <img alt="Made by" src="https://img.shields.io/static/v1?label=made%20by&message=Florian%20Salzmann&color=04D361">
    </a>
    <a href="https://x.com/FlorianSLZ" alt="X / Twitter">
    	<img src="https://img.shields.io/twitter/follow/FlorianSLZ.svg?style=social"/>
    </a>
</p>
<p align="center">
    <a href="https://www.powershellgallery.com/packages/EntraDeviceAuth/" alt="PowerShell Gallery Version">
        <img src="https://img.shields.io/powershellgallery/v/EntraDeviceAuth.svg" />
    </a>
    <a href="https://www.powershellgallery.com/packages/EntraDeviceAuth/" alt="PS Gallery Downloads">
        <img src="https://img.shields.io/powershellgallery/dt/EntraDeviceAuth.svg" />
    </a>
</p>
<p align="center">
    <a href="https://raw.githubusercontent.com/FlorianSLZ/EntraDeviceAuth/master/LICENSE" alt="GitHub License">
        <img src="https://img.shields.io/github/license/FlorianSLZ/EntraDeviceAuth.svg" />
    </a>
    <a href="https://github.com/FlorianSLZ/EntraDeviceAuth/graphs/contributors" alt="GitHub Contributors">
        <img src="https://img.shields.io/github/contributors/FlorianSLZ/EntraDeviceAuth.svg"/>
    </a>
</p>

<p align="center">
    <a href='https://buymeacoffee.com/scloud' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Glass of wine' /></a>
</p>

# EntraDeviceAuth
<a href="https://www.powershellgallery.com/packages/EntraDeviceAuth/" alt="PowerShell Gallery Version">
    <img src="https://img.shields.io/powershellgallery/v/EntraDeviceAuth.svg" />
</a>
The EntraDeviceAuth PowerShell module simplifies the process of creating a robust authentication mechanism for Entra ID-enrolled devices using their device certificates. This module is designed to enhance security and streamline operations by leveraging Azure Function Apps for authentication handling.

*Use Cases*

- Securely distribute configuration files to managed devices.
- Securely collect data from managed devices.
- Automate device-specific tasks and workflows.
  
By leveraging the EntraDeviceAuth module, organizations can establish a secure and efficient authentication infrastructure for their Entra ID-enrolled devices, empowering them to confidently manage and protect their resources.

## Installing the module from PSGallery

The EntraDeviceAuth module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/EntraDeviceAuth). 
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

