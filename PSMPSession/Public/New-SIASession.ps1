# .ExternalHelp PSMPSession-help.xml
function New-SIASession {
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
