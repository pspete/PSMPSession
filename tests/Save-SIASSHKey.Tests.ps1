BeforeDiscovery {

    #Get Current Directory
    $Here = Split-Path -Parent $PSCommandPath

    #Assume ModuleName from Repository Root folder
    $ModuleName = Split-Path (Split-Path $Here -Parent) -Leaf

    #Resolve Path to Module Directory
    $ModulePath = Resolve-Path "$Here\..\$ModuleName"

    #Define Path to Module Manifest
    $ManifestPath = Join-Path "$ModulePath" "$ModuleName.psd1"

    if ( -not (Get-Module -Name $ModuleName -All)) {

        Import-Module -Name "$ManifestPath" -ArgumentList $true -Force -ErrorAction Stop

    }

}

Describe $($PSCommandPath -Replace '.Tests.ps1') {

    InModuleScope $(Split-Path (Split-Path (Split-Path -Parent $PSCommandPath) -Parent) -Leaf ) {

        BeforeEach {

            #Simulate sftp saving the key to the destination path
            Mock sftp -MockWith { Set-Content -Path $args[-1] -Value 'SomeKey' }

            $KeyPath = Join-Path $TestDrive 'SomeKey'
            Remove-Item -Path $KeyPath -Force -ErrorAction Ignore

        }

        Context 'Connection String' {

            It 'Generates expected command for OpenSSH key' {

                Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath

                Should -Invoke sftp -ParameterFilter {

                    $args.Count -eq 2 -and
                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@key@SomeSubdomain.ssh.cyberark.cloud:/key' -and
                    $args[1] -eq $KeyPath

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for PPK key' {

                Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath -Format PPK

                Should -Invoke sftp -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@key_ppk@SomeSubdomain.ssh.cyberark.cloud:/key'

                } -Times 1 -Exactly -Scope It

            }

            It 'Uses specified Gateway' {

                Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath -Gateway 'SomeGateway'

                Should -Invoke sftp -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@key@SomeGateway:/key'

                } -Times 1 -Exactly -Scope It

            }

            It 'Passes SFTPArgument before connection string' {

                Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath -SFTPArgument '-P', '2222'

                Should -Invoke sftp -ParameterFilter {

                    $args.Count -eq 4 -and
                    $args[0] -eq '-P' -and
                    $args[1] -eq '2222' -and
                    $args[2] -eq 'SomeUser@SomeSuffix#SomeSubdomain@key@SomeSubdomain.ssh.cyberark.cloud:/key' -and
                    $args[3] -eq $KeyPath

                } -Times 1 -Exactly -Scope It

            }

        }

        Context 'Key File' {

            It 'Returns the saved key file' {

                $Result = Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath

                $Result | Should -BeOfType System.IO.FileInfo
                $Result.FullName | Should -Be $KeyPath

            }

            It 'Saves to a file named key when Path is a directory' {

                $Result = Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $TestDrive

                Should -Invoke sftp -ParameterFilter {

                    $args[1] -eq (Join-Path $TestDrive 'key')

                } -Times 1 -Exactly -Scope It

                $Result.FullName | Should -Be (Join-Path $TestDrive 'key')

            }

            It 'Throws if key file not saved' {

                Mock sftp -MockWith {}

                { Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath } |
                    Should -Throw "SSH key was not saved to $KeyPath"

            }

            It 'Restricts key file access to the current user' -Skip:(-not (($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows)) {

                Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath

                $Acl = Get-Acl -Path $KeyPath

                $Acl.AreAccessRulesProtected | Should -BeTrue
                $Acl.Access.Count | Should -Be 1
                $Acl.Access[0].IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]) |
                    Should -Be ([System.Security.Principal.WindowsIdentity]::GetCurrent().User)
                $Acl.Access[0].FileSystemRights | Should -Be 'FullControl'

            }

            It 'Does not invoke sftp with WhatIf' {

                Save-SIASSHKey -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -Path $KeyPath -WhatIf

                Should -Invoke sftp -Times 0 -Exactly -Scope It

            }

        }

    }

}
