Describe $($PSCommandPath -Replace '.Tests.ps1') {

    BeforeAll {

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

                Assert-MockCalled ssh -ParameterFilter {

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

                Assert-MockCalled ssh -ParameterFilter {

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

                Assert-MockCalled ssh -ParameterFilter {

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

                Assert-MockCalled ssh -ParameterFilter {

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

                Assert-MockCalled ssh -ParameterFilter {

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

                Assert-MockCalled ssh -ParameterFilter {

                    $args[0] -eq 'SomeVaultUser@SomeVaultDomain%SomeTargetAccount@SomeTargetDomain#SomeTargetDomain%SomeTargetAddress@SomeTargetMachine'

                } -Times 1 -Exactly -Scope It

            }

        }

    }

}