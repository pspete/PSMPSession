function New-PSMPSession {
    <#
    .SYNOPSIS
    Formats PSMP connection string and connects to target using ssh.

    .DESCRIPTION
    Correctly formats PSMP connection sting based on the provided parameter values.
    Supports both local and domain account objects, including usernames in UPN format.
    Allows user to specify any non-default additional delimiters configured for PSMP.
    SSH client must be installed and available on your PATH.

    .PARAMETER VaultUser
    The Vault user with which to authenticate to CyberArk.
    Standard & UserPrincipalName formats are supported.

    .PARAMETER TargetAccount
    The Account in CyberArk to use to connect to a target
    Standard & UserPrincipalName formats are supported.
    if UserPrincipalName format is used, TargetDomain value must be provided.

    .PARAMETER TargetDomain
    Optional Domain name of the target account.
    Must be provided if TargetAccount is in UserPrincipalName format.

    .PARAMETER TargetAddress
    The address of the target to connect to using the target account.

    .PARAMETER TargetMachine
    The CyberArk PSMP server to connect through

    .PARAMETER AdditionalDelimiter
    Specify the AdditionalDelimiter in use.
    If left blank, the default AdditionalDelimiter of % is used.
    If Authenticating with or targetting an account in UserPrincipalName format, PSMP should be configured with an AdditionalDelimiter.

    .PARAMETER TargetAddressPortDelimiter
    The delimiter to seaparate optional connection parameters.
    A TargetAddressPortDelimiter must have been configured for PSMP.
    If left blank, the default TargetAddressPortDelimiter of # is used.

    .EXAMPLE
    New-PSMPSession -VaultUser pspete -TargetAccount someaccount -TargetAddress 1.2.3.4 -TargetMachine PSMP

    Connect via PSM when target account is a local account object.

    Resulting connection string:
    pspete@someaccount@1.2.3.4@PSMP

    .EXAMPLE
    New-PSMPSession -VaultUser pspete -TargetAccount pspete_ADM -TargetDomain domain.com -TargetAddress server -TargetMachine psmp.domain.com

    Connect via PSM when target account is a domain account object.

    Resulting connection string:
    pspete@pspete_ADM#domain.com@server@psmp.domain.com

    .EXAMPLE
    New-PSMPSession -VaultUser pspete@pspete.dev -TargetAccount localuser -TargetAddress someserver -TargetMachine somepsmp

    Connect via PSM when vault username is in UPN format, and target account is a local account object.

    Resulting connection string:
    pspete@pspete.dev%localuser%someserver@somepsmp

    .EXAMPLE
    New-PSMPSession -VaultUser pete@pspete.dev -TargetAccount SomeAccount -TargetDomain SomeDomain -TargetAddress SomeServer -TargetMachine SomePSMP

    Connect via PSM when vault username is in UPN format, and target account is a domain account.

    Resulting connection string:
    pete@pspete.dev%SomeAccount#SomeDomain%SomeServer@SomePSMP

    .EXAMPLE
    New-PSMPSession -VaultUser -TargetAccount -TargetDomain -TargetAddress -TargetMachine

    Connect via PSM when target username is in UPN format.

    Resulting connection string:
    admin%target@company.com#company.com%TargetMachine.company.com@psmp

    .EXAMPLE
    New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com

    Connect via PSM when both vault username and target username are in UPN format.

    Resulting connection string:
    admin@company.com%target@some.company.com#some.company.com%server.some.company.com@psmp.company.com

    .EXAMPLE
    New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com -AdditionalDelimiter "$"

    Connect via PSM when both vault username and target username are in UPN format, and an alternative additional delimiter is configured

    Resulting connection string:
    admin$target@company.com#company.com$TargetMachine.company.com@psmp

    .EXAMPLE
    New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine -AdditionalDelimiter psmp.company.com -TargetAddressPortDelimiter "$"

    Connect via PSM when both vault username and target username are in UPN format, and an alternative optional delimiter is configured

    Resulting connection string:
    admin@company.com%target@some.company.com$some.company.com%server.some.company.com@psmp.company.com

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Vault Logon Username
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $VaultUser,

        # Target Account Username
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TargetAccount,

        # Domain of the Target Account
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TargetDomain,

        # Target to connect to
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TargetAddress,

        # PSMP to connect through
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TargetMachine,

        # Additional Delimiter, default "%"
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string]
        $AdditionalDelimiter,

        # Optioanl Delimiter, default "#"
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string]
        $TargetAddressPortDelimiter
    )

    begin {

        if ($PSBoundParameters.ContainsKey('AdditionalDelimiter')) {
            $Delimiter = $AdditionalDelimiter
        } else { $Delimiter = '%' }
        if ($PSBoundParameters.ContainsKey('TargetAddressPortDelimiter')) {
            $OptionalDelimiter = $TargetAddressPortDelimiter
        } else { $OptionalDelimiter = '#' }

    }

    process {

        if ($PSBoundParameters.ContainsKey('TargetDomain')) {
            #Target UPN
            #Domain Account Object
            $Account = "$TargetAccount$OptionalDelimiter$TargetDomain"
        } else {
            $Account = $TargetAccount
        }

        if (($VaultUser -like '*@*') -or ($TargetAccount -like '*@*')) {
            #Vault UPN: Local Account Object
            #Vault UPN: Domain Account Object
            #Vault User: Target UPN
            #Vault UPN: Target UPN
            $ConnectionString = "$VaultUser$Delimiter$Account$Delimiter$TargetAddress@$TargetMachine"
        } Else {
            #Local Account Object
            #Domain Account Object
            $ConnectionString = "$VaultUser@$Account@$TargetAddress@$TargetMachine"
        }

        Write-Debug $ConnectionString

    }

    end {

        if ($PSCmdlet.ShouldProcess($ConnectionString, 'Connect SSH')) {

            #Invoke SSH client connection with PSMP formated connection string
            ssh $ConnectionString

        }

    }

}