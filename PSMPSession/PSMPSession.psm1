#region Loader
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.INPUTS

.OUTPUTS

.NOTES

.LINK

#>
[CmdletBinding()]
param(

	[bool]$DotSourceModule = $false

)

#Get function files
Get-ChildItem $PSScriptRoot\ -Recurse -Include "*.ps1" |

ForEach-Object {

	if ($DotSourceModule) {
		. $_.FullName
	} else {
		$ExecutionContext.InvokeCommand.InvokeScript(
			$false,
			(
				[scriptblock]::Create(
					[io.file]::ReadAllText(
						$_.FullName,
						[Text.Encoding]::UTF8
					)
				)
			),
			$null,
			$null
		)

	}

}
#endregion Loader
