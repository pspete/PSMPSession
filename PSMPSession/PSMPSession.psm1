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
    Specify each switch and value as a separate array element, e.g. -SSHArgument '-i', 'C:\keys\id_rsa'

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
    New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetMachine psmp -SSHArgument '-i', 'C:\keys\psmp_key'

    Connect via PSM, authenticating to PSMP with an SSH key, such as an MFA caching key.

    Resulting ssh command:
    ssh -i C:\keys\psmp_key pspete@root@server@psmp

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

function New-SIASession {
    <#
    .SYNOPSIS
    Formats SIA connection string and connects to target using ssh.

    .DESCRIPTION
    Correctly formats CyberArk Secure Infrastructure Access (SIA) ssh connection string based on the provided parameter values.
    Supports zero standing privileges (ZSP) access, and vaulted access using local or domain accounts.
    Supports optional target port and network name, and passing additional arguments or a command to the ssh client.
    SSH client must be installed and available on your PATH.

    .PARAMETER User
    Your username as defined in your organization's directory service.
    Typically in the format username@login_suffix.

    .PARAMETER Subdomain
    Your organization's tenant subdomain, as shown in your portal URL (https://subdomain.cyberark.cloud).

    .PARAMETER TargetAddress
    The target to connect to.
    FQDN, IP address, or cloud instance ID (ZSP only).

    .PARAMETER TargetAccount
    The user name on the target machine, as defined in Privilege Cloud.
    Specifying a TargetAccount uses vaulted access.
    Standard & UserPrincipalName formats are supported.

    .PARAMETER TargetDomain
    The address of the domain account as defined in Privilege Cloud.
    Only provide for domain accounts used with vaulted access.

    .PARAMETER TargetPort
    Optional port of the target server, if the target does not listen on the default ssh port.

    .PARAMETER NetworkName
    Optional network name, as defined on the connector pool.
    Mandatory in SIA for vaulted accounts defined with an IP address.

    .PARAMETER Gateway
    The SIA SSH gateway address.
    If left blank, the default gateway of <Subdomain>.ssh.cyberark.cloud is used.

    .PARAMETER SSHArgument
    Optional arguments passed to the ssh client before the connection string.
    e.g. -t, -i private_key_file, -L clientPort:target:targetPort
    Specify each switch and value as a separate array element, e.g. -SSHArgument '-i', 'C:\keys\id_rsa'

    .PARAMETER Command
    Optional inline commands to execute on the target after connecting, separated by semicolons.

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5

    Connect via SIA using zero standing privileges.

    Resulting connection string:
    pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -TargetPort 2222 -NetworkName Net1

    Connect via SIA using zero standing privileges, to a target on a non-default port in a named network.

    Resulting connection string:
    pete@pspete.dev#acme@10.0.0.5:2222#Net1@acme.ssh.cyberark.cloud

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAccount root -TargetAddress server.pspete.dev

    Connect via SIA using vaulted access with a local account.

    Resulting connection string:
    pete@pspete.dev#acme@root@server.pspete.dev@acme.ssh.cyberark.cloud

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAccount admin -TargetDomain pspete.dev -TargetAddress server.pspete.dev

    Connect via SIA using vaulted access with a domain account.

    Resulting connection string:
    pete@pspete.dev#acme@admin#pspete.dev@server.pspete.dev@acme.ssh.cyberark.cloud

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -Gateway ssh.vanity.example.com

    Connect via SIA through a non-default gateway address.

    Resulting connection string:
    pete@pspete.dev#acme@10.0.0.5@ssh.vanity.example.com

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-L', '8080:10.0.0.5:80'

    Connect via SIA and forward local port 8080 to port 80 on the target.

    Resulting ssh command:
    ssh -L 8080:10.0.0.5:80 pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -Command 'touch tmp.txt; cat tmp.txt'

    Connect via SIA and run inline commands on the target.

    Resulting ssh command:
    ssh pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud 'touch tmp.txt; cat tmp.txt'

    .EXAMPLE
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-i', 'C:\keys\sia_key'

    Connect via SIA, authenticating to the SSH gateway with an SSH key, such as an MFA caching key.

    Resulting ssh command:
    ssh -i C:\keys\sia_key pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud

    .EXAMPLE
    Import-Csv .\targets.csv | New-SIASession -User pete@pspete.dev -Subdomain acme

    Connect via SIA to each target in turn, using TargetAddress, TargetAccount and other values from the piped objects.

    .NOTES
	AUTHOR: Pete Maan

    #>
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'ZSP')]
    param (
        # Identity Username
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $User,

        # Tenant Subdomain
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Subdomain,

        # Target to connect to
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TargetAddress,

        # Target Account Username
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Vaulted',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TargetAccount,

        # Domain of the Target Account
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Vaulted',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $TargetDomain,

        # Target ssh port
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange(1, 65535)]
        [int]
        $TargetPort,

        # Connector pool network name
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $NetworkName,

        # SIA SSH gateway
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Gateway,

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
        $Command
    )

    process {

        $ConnectionString = "$User#$Subdomain"

        if ($PSCmdlet.ParameterSetName -eq 'Vaulted') {
            if ($TargetDomain) {
                #Vaulted: Domain Account
                $ConnectionString = "$ConnectionString@$TargetAccount#$TargetDomain"
            } else {
                #Vaulted: Local Account
                $ConnectionString = "$ConnectionString@$TargetAccount"
            }
        }

        $ConnectionString = "$ConnectionString@$TargetAddress"
        if ($TargetPort) {
            $ConnectionString = "$ConnectionString`:$TargetPort"
        }
        if ($NetworkName) {
            $ConnectionString = "$ConnectionString#$NetworkName"
        }

        if ($Gateway) {
            $SSHGateway = $Gateway
        } else { $SSHGateway = "$Subdomain.ssh.cyberark.cloud" }

        $ConnectionString = "$ConnectionString@$SSHGateway"

        Write-Debug $ConnectionString

        $SSHArgs = @($SSHArgument | Where-Object { $_ }) + $ConnectionString
        if ($Command) {
            $SSHArgs += $Command
        }

        if ($PSCmdlet.ShouldProcess($ConnectionString, 'Connect SSH')) {

            #Invoke SSH client connection with SIA formatted connection string
            ssh @SSHArgs

        }

    }

}

function Save-SIASSHKey {
    <#
    .SYNOPSIS
    Downloads an SIA MFA caching SSH key using sftp.

    .DESCRIPTION
    Formats the SIA sftp command to generate and download an MFA caching SSH key, and saves the key to the specified path.
    The key can then be used with New-SIASession to connect to targets without repeating MFA, for the period configured in SIA.
    Access to the saved key file is restricted to the current user, as required by the OpenSSH client.
    SIA only accepts the key from the IP address of the machine which downloaded it.
    SFTP client must be installed and available on your PATH.

    .PARAMETER User
    Your username as defined in your organization's directory service.
    Typically in the format username@login_suffix.

    .PARAMETER Subdomain
    Your organization's tenant subdomain, as shown in your portal URL (https://subdomain.cyberark.cloud).

    .PARAMETER Path
    The file path to save the key to.
    If the path is an existing directory, the key is saved to a file named key in that directory.

    .PARAMETER Format
    The format of the key.
    OpenSSH (default) for use with OpenSSH clients, or PPK for use with PuTTY.

    .PARAMETER Gateway
    The SIA SSH gateway address.
    If left blank, the default gateway of <Subdomain>.ssh.cyberark.cloud is used.

    .PARAMETER SFTPArgument
    Optional arguments passed to the sftp client before the connection string.
    Specify each switch and value as a separate array element, e.g. -SFTPArgument '-P', '2222'

    .EXAMPLE
    Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete

    Download an MFA caching key in OpenSSH format.

    Resulting sftp command:
    sftp pete@pspete.dev#acme@key@acme.ssh.cyberark.cloud:/key C:\Users\pete\.ssh\acme_pete

    .EXAMPLE
    Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete.ppk -Format PPK

    Download an MFA caching key in PuTTY Private Key format.

    Resulting sftp command:
    sftp pete@pspete.dev#acme@key_ppk@acme.ssh.cyberark.cloud:/key C:\Users\pete\.ssh\acme_pete.ppk

    .EXAMPLE
    $Key = Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete
    New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-i', $Key.FullName

    Download an MFA caching key, then use it to connect to a target without repeating MFA.

    .NOTES
	AUTHOR: Pete Maan

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.IO.FileInfo])]
    param (
        # Identity Username
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $User,

        # Tenant Subdomain
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Subdomain,

        # Key file path
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Path,

        # Key format
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateSet('OpenSSH', 'PPK')]
        [string]
        $Format = 'OpenSSH',

        # SIA SSH gateway
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Gateway,

        # Arguments passed to sftp before the connection string
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string[]]
        $SFTPArgument
    )

    process {

        if ($Format -eq 'PPK') {
            $KeyType = 'key_ppk'
        } else { $KeyType = 'key' }

        if ($Gateway) {
            $SSHGateway = $Gateway
        } else { $SSHGateway = "$Subdomain.ssh.cyberark.cloud" }

        $ConnectionString = "$User#$Subdomain@$KeyType@$SSHGateway`:/key"

        $Destination = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        if (Test-Path -Path $Destination -PathType Container) {
            $Destination = Join-Path -Path $Destination -ChildPath 'key'
        }

        Write-Debug "$ConnectionString $Destination"

        $SFTPArgs = @($SFTPArgument | Where-Object { $_ }) + $ConnectionString + $Destination

        if ($PSCmdlet.ShouldProcess($Destination, "Save SIA SSH key from $SSHGateway")) {

            #Invoke SFTP client with SIA formatted key retrieval string
            sftp @SFTPArgs

            if (-not (Test-Path -Path $Destination -PathType Leaf)) {
                throw "SSH key was not saved to $Destination"
            }

            #Restrict key file access to the current user
            if (($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows) {
                $Acl = New-Object -TypeName System.Security.AccessControl.FileSecurity
                $Acl.SetAccessRuleProtection($true, $false)
                $Rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList @(
                    [System.Security.Principal.WindowsIdentity]::GetCurrent().User,
                    'FullControl',
                    'Allow'
                )
                $Acl.AddAccessRule($Rule)
                Set-Acl -Path $Destination -AclObject $Acl
            } else {
                chmod 600 $Destination
            }

            Get-Item -Path $Destination

        }

    }

}
