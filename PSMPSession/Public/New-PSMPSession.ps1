# .ExternalHelp PSMPSession-help.xml
function New-PSMPSession {
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
