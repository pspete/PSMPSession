[![PSMPSession][]][Docs]

[PSMPSession]:/media/PSMPSession1.png
[Logo]:/media/PSMPSession.png
[Docs]:https://github.com/pspete/PSMPSession/

# **PSMPSession**

Format an ssh connection command and connect to a target server, using a target account via CyberArk PSMP or SIA.

| Main Branch              | Dev Branch           | CodeFactor                 | Coverage                     | PowerShell Gallery        | License                      |
| ------------------------ | -------------------- | -------------------------- | ---------------------------- | ------------------------- | ---------------------------- |
| [![build][]][build-site] | [![dev][]][dev-site] | [![codefactor][]][cf-site] | [![codecov][]][codecov-link] | [![psgallery][]][ps-site] | [![license][]][license-link] |
|                          |                      |                            |                              | [![downloads][]][ps-site] |                              |

[build]:https://github.com/pspete/PSMPSession/actions/workflows/ci.yml/badge.svg?branch=main&event=push
[build-site]:https://github.com/pspete/PSMPSession/actions/workflows/ci.yml?query=branch%3Amain
[dev]:https://github.com/pspete/PSMPSession/actions/workflows/ci.yml/badge.svg?branch=dev&event=push
[dev-site]:https://github.com/pspete/PSMPSession/actions/workflows/ci.yml?query=branch%3Adev
[psgallery]:https://img.shields.io/powershellgallery/v/PSMPSession.svg
[ps-site]:https://www.powershellgallery.com/packages/PSMPSession
[downloads]:https://img.shields.io/powershellgallery/dt/psmpsession.svg?color=blue
[cf-site]:https://www.codefactor.io/repository/github/pspete/psmpsession
[codefactor]:https://www.codefactor.io/repository/github/pspete/psmpsession/badge?s=a6f451bc33d88274e1698cc1465e5f1e1379e0ea
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

#### Target Port & Tunnel Port

```powershell
New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetPort 2222 -PSMPAddress psmp
# pspete@root@server#2222@psmp

New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetPort 22 -TunnelPort 5432 -PSMPAddress psmp -SSHArgument '-L', '5432:127.0.0.1:5432'
# ssh -L 5432:127.0.0.1:5432 pspete@root@server#22#5432@psmp
```

#### Additional ssh Arguments & Remote Command

```powershell
New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -PSMPAddress psmp -SSHArgument '-t' -Command 'uptime'
# ssh -t pspete@root@server@psmp uptime

New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -PSMPAddress psmp -SSHArgument '-i', 'C:\keys\psmp_key'
# ssh -i C:\keys\psmp_key pspete@root@server@psmp
```

Specify each ssh switch and its value as separate array elements (`'-i', 'C:\keys\psmp_key'`, not `'-i C:\keys\psmp_key'`).
An SSH key supplied with `-i` authenticates you to PSMP / the SIA gateway (e.g. an MFA caching key), not to the target.

#### Pipeline Input

```powershell
Import-Csv .\targets.csv | New-PSMPSession -VaultUser pspete -PSMPAddress psmp
```

Use `-WhatIf` or `-Debug` with either function to view the connection string without connecting.

### New-SIASession

Connect through CyberArk Secure Infrastructure Access (SIA). Supplying `-TargetAccount` uses vaulted access; omitting it uses zero standing privileges (ZSP).

#### Zero Standing Privileges

```powershell
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5
# pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud

New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -TargetPort 2222 -NetworkName Net1
# pete@pspete.dev#acme@10.0.0.5:2222#Net1@acme.ssh.cyberark.cloud
```

#### Vaulted Access

```powershell
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAccount root -TargetAddress server.pspete.dev
# pete@pspete.dev#acme@root@server.pspete.dev@acme.ssh.cyberark.cloud

New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAccount admin -TargetDomain pspete.dev -TargetAddress server.pspete.dev
# pete@pspete.dev#acme@admin#pspete.dev@server.pspete.dev@acme.ssh.cyberark.cloud
```

#### Gateway, ssh Arguments & Inline Commands

```powershell
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -Gateway ssh.vanity.example.com
# pete@pspete.dev#acme@10.0.0.5@ssh.vanity.example.com

New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-L', '8080:10.0.0.5:80' -Command 'touch tmp.txt; cat tmp.txt'
# ssh -L 8080:10.0.0.5:80 pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud 'touch tmp.txt; cat tmp.txt'

New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-i', 'C:\keys\sia_key'
# ssh -i C:\keys\sia_key pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud
```

### Save-SIASSHKey

Download an SIA MFA caching SSH key, then use it with `New-SIASession` to connect without repeating MFA until the key expires.

```powershell
$Key = Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete
# sftp pete@pspete.dev#acme@key@acme.ssh.cyberark.cloud:/key C:\Users\pete\.ssh\acme_pete

New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-i', $Key.FullName

Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete.ppk -Format PPK
# sftp pete@pspete.dev#acme@key_ppk@acme.ssh.cyberark.cloud:/key C:\Users\pete\.ssh\acme_pete.ppk
```

Access to the saved key is restricted to the current user. SIA only accepts the key from the IP address it was downloaded from.

## Installation

### Prerequisites

- PowerShell Core or Powershell v5.1 (minimum).
- SSH Client (and SFTP client for `Save-SIASSHKey`) installed and configured on your PATH
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
