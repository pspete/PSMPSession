# .ExternalHelp PSMPSession-help.xml
function Save-SIASSHKey {
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
