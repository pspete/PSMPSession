[![PSMPSession][]][Docs]

[PSMPSession]:/media/PSMPSession1.png
[Logo]:/media/PSMPSession.png
[Docs]:https://github.com/pspete/PSMPSession/

# **PSMPSession**

Format an ssh connection command and connect to a target server, using a target account via CyberArk PSMP.

| Main Branch            | Latest Build            | CodeFactor                | Coverage                    |  PowerShell Gallery       |  License                   |
|--------------------------|-------------------------|---------------------------|-----------------------------|---------------------------|----------------------------|
|[![appveyor][]][av-site]  |[![tests][]][tests-site] | [![codefactor][]][cf-site]| [![codecov][]][codecov-link]| [![psgallery][]][ps-site] |[![license][]][license-link]|
|                          |                         |                           | [![coveralls][]][cv-site]   | [![downloads][]][ps-site] |                            |

<!---
| Latest Release          | License                    | Download                | Stats                   |
|-------------------------|----------------------------|-------------------------|-------------------------|
|[![appveyor][]][av-site] |[![license][]][license-link]|[![psgallery][]][ps-site]|[![downloads][]][ps-site]|
||||[![tests][]][tests-site] |
||||[![codecov][]][codecov-link] |
||||[![coveralls][]][cv-site] |
||||[![codefactor][]][cf-site] |
-->

[appveyor]:https://ci.appveyor.com/api/projects/status/y6ad0firmgxok216?svg=true
[av-site]:https://ci.appveyor.com/project/pspete/psmpsession/branch/main
[coveralls]:https://coveralls.io/repos/github/pspete/PSMPSession/badge.svg?branch=main
[cv-site]:https://coveralls.io/github/pspete/PSMPSession?branch=main
[psgallery]:https://img.shields.io/powershellgallery/v/PSMPSession.svg
[ps-site]:https://www.powershellgallery.com/packages/PSMPSession
[tests]:https://img.shields.io/appveyor/tests/pspete/psmpsession.svg
[tests-site]:https://ci.appveyor.com/project/pspete/psmpsession
[downloads]:https://img.shields.io/powershellgallery/dt/psmpsession.svg?color=blue
[cf-site]:https://www.codefactor.io/repository/github/pspete/psmpsession
[codefactor]:https://www.codefactor.io/repository/github/pspete/psmpsession/badge
[codecov]:https://codecov.io/gh/pspete/PSMPSession/branch/main/graph/badge.svg
[codecov-link]:https://codecov.io/gh/pspete/PSMPSession
[license]:https://img.shields.io/github/license/pspete/psmpsession.svg
[license-link]:https://github.com/pspete/PSMPSession/blob/main/LICENSE

## Usage

[Local]:/media/New-PSMPSession-Local.png
[Domain]:/media/New-PSMPSession-Domain.png
[VaultUPN]:/media/New-PSMPSession-VaultUPN.png
[TargetUPN]:/media/New-PSMPSession-TargetUPN.png
[UPN]:/media/New-PSMPSession-UPN.png

### New-PSMPSession

#### Local Account Targets

![Local][Local]

#### Domain Account Targets

![Domain][Domain]

#### Vault Usernames in UPN Format

![VaultUPN][VaultUPN]

#### Target Usernames in UPN Format

![TargetUPN][TargetUPN]

#### Vault Username and Target Username in UPN Format

![UPN][UPN]

## Installation

### Prerequisites

- PowerShell Core or Powershell v5 (minimum).
- SSH Client installed and configured on your PATH
- Target account to connect to a target server through CyberArk PSMP.

### Install Options

Use one of the following methods:

#### Option 1: Install from PowerShell Gallery

**PowerShell 5.0 or above must be used**

This is the simplest & preferred method for installation of the module.

To install the module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSMPSession/), </br>
from a PowerShell prompt, run:

`Install-Module -Name PSMPSession -Scope CurrentUser`

#### Option 2: Manual Install

You can manually copy the module files to one of your powershell module folders.

Find your PowerShell Module Paths with the following command:

`$env:PSModulePath.split(';')`

The module files should be placed in a folder named `PSMPSession` in one of the listed locations.

More: [about_PSModulePath](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath)

There are multiple options for downloading the module files:

##### PowerShell Gallery

- Download from the module [PowerShell Gallery](https://www.powershellgallery.com/packages/PSMPSession/):
  - Run the PowerShell command `Save-Module -Name PSMPSession -Path C:\temp`
  - Copy the `C:\temp\PSMPSession` folder to your "Powershell Modules" directory of choice.

##### PSMPSession Release

- [Download the latest release](https://github.com/pspete/PSMPSession/releases/latest)
  - Unblock & Extract the archive
  - Rename the extracted `PSMPSession-v#.#.#` folder to `PSMPSession`
  - Copy the `PSMPSession` folder to your "Powershell Modules" directory of choice.

##### PSMPSession Branch

- [Download the ```main branch```](https://github.com/pspete/PSMPSession/archive/main.zip)
  - Unblock & Extract the archive
  - Copy the `PSMPSession` (`\<Archive Root>\PSMPSession-main\PSMPSession`) folder to your "Powershell Modules" directory of choice.