function New-PSMPSession {
    <#
    .SYNOPSIS
    Formats PSMP connection string and connects to target using ssh.

    .DESCRIPTION
    Correctly formats PSMP ssh connection string based on the provided parameter values.
    Supports both local and domain account objects, including usernames in UPN format.
    Supports optional target and tunnel ports, and passing additional arguments or a command to the ssh client.
    Allows user to specify any non-default additional delimiters configured for PSMP.
    SSH client must be installed and available on your PATH.

    .PARAMETER VaultUser
    The Vault user with which to authenticate to CyberArk.
    Standard & UserPrincipalName formats are supported.

    .PARAMETER TargetAccount
    The Account in CyberArk to use to connect to a target.
    Standard & UserPrincipalName formats are supported.
    If UserPrincipalName format is used, TargetDomain value must be provided.

    .PARAMETER TargetDomain
    Optional Domain name of the target account.
    Must be provided if TargetAccount is in UserPrincipalName format.

    .PARAMETER TargetAddress
    The address of the target to connect to using the target account.

    .PARAMETER TargetMachine
    The CyberArk PSMP server to connect through.
    Alias: PSMPAddress

    .PARAMETER TargetPort
    Optional port of the target server, if the target does not listen on the default ssh port.

    .PARAMETER TunnelPort
    Optional tunnel target port, used for ssh tunneling via PSMP.
    TargetPort must also be provided.
    Use SSHArgument to supply the matching local port forward, e.g. -L 5432:127.0.0.1:5432

    .PARAMETER SSHArgument
    Optional arguments passed to the ssh client before the connection string.
    e.g. -t, -i private_key_file, -L localPort:127.0.0.1:tunnelPort

    .PARAMETER Command
    Optional command to execute on the target after connecting.

    .PARAMETER AdditionalDelimiter
    Specify the AdditionalDelimiter in use.
    If left blank, the default AdditionalDelimiter of % is used.
    If authenticating with or targeting an account in UserPrincipalName format, PSMP should be configured with an AdditionalDelimiter.

    .PARAMETER TargetAddressPortDelimiter
    The delimiter to separate the target domain and optional port values.
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
    New-PSMPSession -VaultUser admin -TargetAccount target@company.com -TargetDomain company.com -TargetAddress server.company.com -TargetMachine psmp

    Connect via PSM when target username is in UPN format.

    Resulting connection string:
    admin%target@company.com#company.com%server.company.com@psmp

    .EXAMPLE
    New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com

    Connect via PSM when both vault username and target username are in UPN format.

    Resulting connection string:
    admin@company.com%target@some.company.com#some.company.com%server.some.company.com@psmp.company.com

    .EXAMPLE
    New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com -AdditionalDelimiter '$'

    Connect via PSM when both vault username and target username are in UPN format, and an alternative additional delimiter is configured.

    Resulting connection string:
    admin@company.com$target@some.company.com#some.company.com$server.some.company.com@psmp.company.com

    .EXAMPLE
    New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com -TargetAddressPortDelimiter '$'

    Connect via PSM when both vault username and target username are in UPN format, and an alternative TargetAddressPortDelimiter is configured.

    Resulting connection string:
    admin@company.com%target@some.company.com$some.company.com%server.some.company.com@psmp.company.com

    .EXAMPLE
    New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetPort 2222 -PSMPAddress psmp

    Connect via PSM to a target listening on a non-default ssh port.

    Resulting connection string:
    pspete@root@server#2222@psmp

    .EXAMPLE
    New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetPort 22 -TunnelPort 5432 -TargetMachine psmp -SSHArgument '-L', '5432:127.0.0.1:5432'

    Connect via PSM and tunnel local port 5432 to port 5432 on the target.

    Resulting ssh command:
    ssh -L 5432:127.0.0.1:5432 pspete@root@server#22#5432@psmp

    .EXAMPLE
    New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetMachine psmp -SSHArgument '-t' -Command 'uptime'

    Connect via PSM, force pseudo-terminal allocation and run a command on the target.

    Resulting ssh command:
    ssh -t pspete@root@server@psmp uptime

    .EXAMPLE
    Import-Csv .\targets.csv | New-PSMPSession -VaultUser pspete -TargetMachine psmp

    Connect via PSM to each target in turn, using TargetAccount, TargetAddress and other values from the piped objects.

    .NOTES
	AUTHOR: Pete Maan

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
        [Alias('PSMPAddress')]
        [string]
        $TargetMachine,

        # Target ssh port
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(1, 65535)]
        [int]
        $TargetPort,

        # Tunnel target port
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(1, 65535)]
        [int]
        $TunnelPort,

        # Arguments passed to ssh before the connection string
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string[]]
        $SSHArgument,

        # Command to run on the target
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Command,

        # Additional Delimiter, default "%"
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string]
        $AdditionalDelimiter,

        # Optional Delimiter, default "#"
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

        if (($TargetAccount -like '*@*') -and (-not $TargetDomain)) {
            throw 'TargetDomain must be provided when TargetAccount is in UserPrincipalName format.'
        }

        if ($TunnelPort -and (-not $TargetPort)) {
            throw 'TargetPort must be provided when TunnelPort is specified.'
        }

        if ($TargetDomain) {
            #Target UPN
            #Domain Account Object
            $Account = "$TargetAccount$OptionalDelimiter$TargetDomain"
        } else {
            $Account = $TargetAccount
        }

        $Address = $TargetAddress
        if ($TargetPort) {
            $Address = "$Address$OptionalDelimiter$TargetPort"
        }
        if ($TunnelPort) {
            $Address = "$Address$OptionalDelimiter$TunnelPort"
        }

        if (($VaultUser -like '*@*') -or ($TargetAccount -like '*@*')) {
            #Vault UPN: Local Account Object
            #Vault UPN: Domain Account Object
            #Vault User: Target UPN
            #Vault UPN: Target UPN
            $ConnectionString = "$VaultUser$Delimiter$Account$Delimiter$Address@$TargetMachine"
        } Else {
            #Local Account Object
            #Domain Account Object
            $ConnectionString = "$VaultUser@$Account@$Address@$TargetMachine"
        }

        Write-Debug $ConnectionString

        $SSHArgs = @($SSHArgument | Where-Object { $_ }) + $ConnectionString
        if ($Command) {
            $SSHArgs += $Command
        }

        if ($PSCmdlet.ShouldProcess($ConnectionString, 'Connect SSH')) {

            #Invoke SSH client connection with PSMP formatted connection string
            ssh @SSHArgs

        }

    }

}
