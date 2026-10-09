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

            Mock ssh -MockWith {}

        }

        Context 'Zero Standing Privileges' {

            It 'Generates expected command for ZSP' {
                #U#S@T@GW
                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAddress 'SomeTargetAddress'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@SomeTargetAddress@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for ZSP with Target Port and Network Name' {
                #U#S@T:P#N@GW
                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAddress 'SomeTargetAddress' -TargetPort 2222 -NetworkName 'SomeNetwork'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@SomeTargetAddress:2222#SomeNetwork@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for User without login suffix' {

                New-SIASession -User 'SomeUser' -Subdomain 'SomeSubdomain' -TargetAddress 'SomeTargetAddress'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser#SomeSubdomain@SomeTargetAddress@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

            }

            It 'Uses specified Gateway' {

                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAddress 'SomeTargetAddress' -Gateway 'SomeGateway'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@SomeTargetAddress@SomeGateway'

                } -Times 1 -Exactly -Scope It

            }

        }

        Context 'Vaulted' {

            It 'Generates expected command for Vaulted Local Account' {
                #U#S@TU@T@GW
                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@SomeTargetAccount@SomeTargetAddress@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Vaulted Domain Account' {
                #U#S@TU#TD@T@GW
                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAccount 'SomeTargetAccount' -TargetDomain 'SomeTargetDomain' -TargetAddress 'SomeTargetAddress'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@SomeTargetAccount#SomeTargetDomain@SomeTargetAddress@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Vaulted Domain Account with Target Port and Network Name' {
                #U#S@TU#TD@T:P#N@GW
                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAccount 'SomeTargetAccount' -TargetDomain 'SomeTargetDomain' -TargetAddress 'SomeTargetAddress' -TargetPort 2222 -NetworkName 'SomeNetwork'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@SomeTargetAccount#SomeTargetDomain@SomeTargetAddress:2222#SomeNetwork@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

            }

            It 'Throws if TargetDomain provided without TargetAccount' {

                { New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetDomain 'SomeTargetDomain' -TargetAddress 'SomeTargetAddress' } |
                    Should -Throw

                Should -Invoke ssh -Times 0 -Exactly -Scope It

            }

        }

        Context 'SSH Arguments' {

            It 'Passes SSHArgument before connection string and Command after' {

                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAddress 'SomeTargetAddress' -SSHArgument '-L', '8080:SomeTargetAddress:80' -Command 'touch tmp.txt; cat tmp.txt'

                Should -Invoke ssh -ParameterFilter {

                    $args.Count -eq 4 -and
                    $args[0] -eq '-L' -and
                    $args[1] -eq '8080:SomeTargetAddress:80' -and
                    $args[2] -eq 'SomeUser@SomeSuffix#SomeSubdomain@SomeTargetAddress@SomeSubdomain.ssh.cyberark.cloud' -and
                    $args[3] -eq 'touch tmp.txt; cat tmp.txt'

                } -Times 1 -Exactly -Scope It

            }

            It 'Passes only connection string by default' {

                New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain' -TargetAddress 'SomeTargetAddress'

                Should -Invoke ssh -ParameterFilter {

                    $args.Count -eq 1

                } -Times 1 -Exactly -Scope It

            }

        }

        Context 'Pipeline' {

            It 'Connects once per piped object, resolving ZSP and Vaulted per object' {

                @(
                    [pscustomobject]@{ TargetAccount = 'AccountOne'; TargetDomain = 'DomainOne'; TargetAddress = 'AddressOne'; TargetPort = 2222 },
                    [pscustomobject]@{ TargetAddress = 'AddressTwo'; NetworkName = 'NetworkTwo' },
                    [pscustomobject]@{ TargetAccount = 'AccountThree'; TargetAddress = 'AddressThree' }
                ) | New-SIASession -User 'SomeUser@SomeSuffix' -Subdomain 'SomeSubdomain'

                Should -Invoke ssh -Times 3 -Exactly -Scope It

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@AccountOne#DomainOne@AddressOne:2222@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@AddressTwo#NetworkTwo@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeUser@SomeSuffix#SomeSubdomain@AccountThree@AddressThree@SomeSubdomain.ssh.cyberark.cloud'

                } -Times 1 -Exactly -Scope It

            }

        }

    }

}
