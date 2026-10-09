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

    AfterAll {}

    InModuleScope $(Split-Path (Split-Path (Split-Path -Parent $PSCommandPath) -Parent) -Leaf ) {

        Context 'The Basics' {

            BeforeEach {

                <#
            VU = Vault User
            VD = Vault User Domain
            TU = Target Account
            TA = Target Address
            TD = Target Domain
            TM = Target Machine
            #>

                Mock ssh -MockWith {}

            }

            It 'Generates expected command for Local Account Object' {
                $VaultUser = 'SomeVaultUser'
                $TargetAccount = 'SomeTargetAccount'
                $TargetAddress = 'SomeTargetAddress'
                $TargetMachine = 'SomeTargetMachine'
                #VU@TU@TA@TM
                New-PSMPSession -VaultUser $VaultUser -TargetAccount $TargetAccount -TargetAddress $TargetAddress -TargetMachine $TargetMachine

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeTargetAccount@SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Domain Account Object' {
                $VaultUser = 'SomeVaultUser'
                $TargetAccount = 'SomeTargetAccount'
                $TargetAddress = 'SomeTargetAddress'
                $TargetDomain = 'SomeTargetDomain'
                $TargetMachine = 'SomeTargetMachine'
                #VU@TU#TD@TA@TM
                New-PSMPSession -VaultUser $VaultUser -TargetAccount $TargetAccount -TargetDomain $TargetDomain -TargetAddress $TargetAddress -TargetMachine $TargetMachine

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeTargetAccount#SomeTargetDomain@SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Vault UPN: Local Account Object' {
                $VaultUser = 'SomeVaultUser@SomeDomain'
                $TargetAccount = 'SomeTargetAccount'
                $TargetAddress = 'SomeTargetAddress'
                $TargetMachine = 'SomeTargetMachine'
                #VU@VD%TU%TA@TM
                #Additional Delimiter "%"
                New-PSMPSession -VaultUser $VaultUser -TargetAccount $TargetAccount -TargetAddress $TargetAddress -TargetMachine $TargetMachine

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeDomain%SomeTargetAccount%SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Vault UPN: Domain Account Object' {
                $VaultUser = 'SomeVaultUser@SomeVaultDomain'
                $TargetAccount = 'SomeTargetAccount'
                $TargetAddress = 'SomeTargetAddress'
                $TargetDomain = 'SomeTargetDomain'
                $TargetMachine = 'SomeTargetMachine'
                #VU@VD%TU#TD%TA@TM
                #Additional Delimiter "%"
                New-PSMPSession -VaultUser $VaultUser -TargetAccount $TargetAccount -TargetDomain $TargetDomain -TargetAddress $TargetAddress -TargetMachine $TargetMachine

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeVaultDomain%SomeTargetAccount#SomeTargetDomain%SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Vault User: Target UPN' {
                $VaultUser = 'SomeVaultUser'
                $TargetAccount = 'SomeTargetAccount@SomeTargetDomain'
                $TargetAddress = 'SomeTargetAddress'
                $TargetDomain = 'SomeTargetDomain'
                $TargetMachine = 'SomeTargetMachine'
                #VU%TU@TD#TD%TA@TM
                #Additional Delimiter "%"
                #ca_admin%ted@mycompany.com#mycompany.com%TargetMachine@PSMP
                New-PSMPSession -VaultUser $VaultUser -TargetAccount $TargetAccount -TargetDomain $TargetDomain -TargetAddress $TargetAddress -TargetMachine $TargetMachine

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser%SomeTargetAccount@SomeTargetDomain#SomeTargetDomain%SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Vault UPN: Target UPN' {
                $VaultUser = 'SomeVaultUser@SomeVaultDomain'
                $TargetAccount = 'SomeTargetAccount@SomeTargetDomain'
                $TargetAddress = 'SomeTargetAddress'
                $TargetDomain = 'SomeTargetDomain'
                $TargetMachine = 'SomeTargetMachine'
                #VU@VD%TA@TD#TD%TA@TM
                #Additional Delimiter "%"
                #ca_admin@mycompany.com%ted@mycompany.com#mycompany.com%TargetMachine@PSMP
                New-PSMPSession -VaultUser $VaultUser -TargetAccount $TargetAccount -TargetDomain $TargetDomain -TargetAddress $TargetAddress -TargetMachine $TargetMachine

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeVaultDomain%SomeTargetAccount@SomeTargetDomain#SomeTargetDomain%SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Throws if Target UPN provided without TargetDomain' {

                { New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount@SomeTargetDomain' -TargetAddress 'SomeTargetAddress' -TargetMachine 'SomeTargetMachine' } |
                    Should -Throw 'TargetDomain must be provided when TargetAccount is in UserPrincipalName format.'

                Should -Invoke ssh -Times 0 -Exactly -Scope It

            }

            It 'Accepts PSMPAddress alias for TargetMachine' {

                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -PSMPAddress 'SomePSMP'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeTargetAccount@SomeTargetAddress@SomePSMP'

                } -Times 1 -Exactly -Scope It

            }

        }

        Context 'Ports' {

            BeforeEach {

                Mock ssh -MockWith {}

            }

            It 'Generates expected command with Target Port' {
                #VU@TU@TA#TP@TM
                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TargetPort 2222 -TargetMachine 'SomeTargetMachine'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeTargetAccount@SomeTargetAddress#2222@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command with Target Port and Tunnel Port' {
                #VU@TU@TA#TP#TunnelPort@TM
                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TargetPort 22 -TunnelPort 5432 -TargetMachine 'SomeTargetMachine'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeTargetAccount@SomeTargetAddress#22#5432@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Domain Account Object with Target Port' {
                #VU@TU#TD@TA#TP@TM
                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetDomain 'SomeTargetDomain' -TargetAddress 'SomeTargetAddress' -TargetPort 2222 -TargetMachine 'SomeTargetMachine'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeTargetAccount#SomeTargetDomain@SomeTargetAddress#2222@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Generates expected command for Vault UPN with Target Port' {
                #VU@VD%TU%TA#TP@TM
                New-PSMPSession -VaultUser 'SomeVaultUser@SomeDomain' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TargetPort 2222 -TargetMachine 'SomeTargetMachine'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeDomain%SomeTargetAccount%SomeTargetAddress#2222@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Uses TargetAddressPortDelimiter for ports' {

                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TargetPort 22 -TunnelPort 5432 -TargetMachine 'SomeTargetMachine' -TargetAddressPortDelimiter '$'

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeTargetAccount@SomeTargetAddress$22$5432@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Throws if Tunnel Port provided without Target Port' {

                { New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TunnelPort 5432 -TargetMachine 'SomeTargetMachine' } |
                    Should -Throw 'TargetPort must be provided when TunnelPort is specified.'

                Should -Invoke ssh -Times 0 -Exactly -Scope It

            }

        }

        Context 'SSH Arguments' {

            BeforeEach {

                Mock ssh -MockWith {}

            }

            It 'Passes SSHArgument before connection string' {

                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TargetMachine 'SomeTargetMachine' -SSHArgument '-i', 'key_file', '-L', '5432:127.0.0.1:5432'

                Should -Invoke ssh -ParameterFilter {

                    $args.Count -eq 5 -and
                    $args[0] -eq '-i' -and
                    $args[1] -eq 'key_file' -and
                    $args[2] -eq '-L' -and
                    $args[3] -eq '5432:127.0.0.1:5432' -and
                    $args[4] -eq 'SomeVaultUser@SomeTargetAccount@SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

            It 'Passes Command after connection string' {

                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TargetMachine 'SomeTargetMachine' -SSHArgument '-t' -Command 'uptime'

                Should -Invoke ssh -ParameterFilter {

                    $args.Count -eq 3 -and
                    $args[0] -eq '-t' -and
                    $args[1] -eq 'SomeVaultUser@SomeTargetAccount@SomeTargetAddress@SomeTargetMachine' -and
                    $args[2] -eq 'uptime'

                } -Times 1 -Exactly -Scope It

            }

            It 'Passes only connection string by default' {

                New-PSMPSession -VaultUser 'SomeVaultUser' -TargetAccount 'SomeTargetAccount' -TargetAddress 'SomeTargetAddress' -TargetMachine 'SomeTargetMachine'

                Should -Invoke ssh -ParameterFilter {

                    $args.Count -eq 1

                } -Times 1 -Exactly -Scope It

            }

        }

        Context 'Pipeline' {

            BeforeEach {

                Mock ssh -MockWith {}

            }

            It 'Connects once per piped object' {

                @(
                    [pscustomobject]@{ TargetAccount = 'AccountOne'; TargetDomain = 'DomainOne'; TargetAddress = 'AddressOne'; TargetPort = 2222 },
                    [pscustomobject]@{ TargetAccount = 'AccountTwo'; TargetAddress = 'AddressTwo' }
                ) | New-PSMPSession -VaultUser 'SomeVaultUser' -TargetMachine 'SomeTargetMachine'

                Should -Invoke ssh -Times 2 -Exactly -Scope It

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@AccountOne#DomainOne@AddressOne#2222@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

                Should -Invoke ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@AccountTwo@AddressTwo@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

        }

    }

}