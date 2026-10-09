---
external help file: PSMPSession-help.xml
Module Name: PSMPSession
online version:
schema: 2.0.0
title: New-PSMPSession
---

# New-PSMPSession

## SYNOPSIS
Formats PSMP connection string and connects to target using ssh.

## SYNTAX

```
New-PSMPSession [-VaultUser] <String> [-TargetAccount] <String> [[-TargetDomain] <String>]
 [-TargetAddress] <String> [-TargetMachine] <String> [[-TargetPort] <Int32>] [[-TunnelPort] <Int32>]
 [[-SSHArgument] <String[]>] [[-Command] <String>] [[-AdditionalDelimiter] <String>]
 [[-TargetAddressPortDelimiter] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Correctly formats PSMP ssh connection string based on the provided parameter values.
Supports both local and domain account objects, including usernames in UPN format.
Supports optional target and tunnel ports, and passing additional arguments or a command to the ssh client.
Allows user to specify any non-default additional delimiters configured for PSMP.
SSH client must be installed and available on your PATH.

## EXAMPLES

### EXAMPLE 1
```
New-PSMPSession -VaultUser pspete -TargetAccount someaccount -TargetAddress 1.2.3.4 -TargetMachine PSMP
```

Connect via PSM when target account is a local account object.

Resulting connection string:
pspete@someaccount@1.2.3.4@PSMP

### EXAMPLE 2
```
New-PSMPSession -VaultUser pspete -TargetAccount pspete_ADM -TargetDomain domain.com -TargetAddress server -TargetMachine psmp.domain.com
```

Connect via PSM when target account is a domain account object.

Resulting connection string:
pspete@pspete_ADM#domain.com@server@psmp.domain.com

### EXAMPLE 3
```
New-PSMPSession -VaultUser pspete@pspete.dev -TargetAccount localuser -TargetAddress someserver -TargetMachine somepsmp
```

Connect via PSM when vault username is in UPN format, and target account is a local account object.

Resulting connection string:
pspete@pspete.dev%localuser%someserver@somepsmp

### EXAMPLE 4
```
New-PSMPSession -VaultUser pete@pspete.dev -TargetAccount SomeAccount -TargetDomain SomeDomain -TargetAddress SomeServer -TargetMachine SomePSMP
```

Connect via PSM when vault username is in UPN format, and target account is a domain account.

Resulting connection string:
pete@pspete.dev%SomeAccount#SomeDomain%SomeServer@SomePSMP

### EXAMPLE 5
```
New-PSMPSession -VaultUser admin -TargetAccount target@company.com -TargetDomain company.com -TargetAddress server.company.com -TargetMachine psmp
```

Connect via PSM when target username is in UPN format.

Resulting connection string:
admin%target@company.com#company.com%server.company.com@psmp

### EXAMPLE 6
```
New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com
```

Connect via PSM when both vault username and target username are in UPN format.

Resulting connection string:
admin@company.com%target@some.company.com#some.company.com%server.some.company.com@psmp.company.com

### EXAMPLE 7
```
New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com -AdditionalDelimiter '$'
```

Connect via PSM when both vault username and target username are in UPN format, and an alternative additional delimiter is configured.

Resulting connection string:
admin@company.com$target@some.company.com#some.company.com$server.some.company.com@psmp.company.com

### EXAMPLE 8
```
New-PSMPSession -VaultUser admin@company.com -TargetAccount target@some.company.com -TargetDomain some.company.com -TargetAddress server.some.company.com -TargetMachine psmp.company.com -TargetAddressPortDelimiter '$'
```

Connect via PSM when both vault username and target username are in UPN format, and an alternative TargetAddressPortDelimiter is configured.

Resulting connection string:
admin@company.com%target@some.company.com$some.company.com%server.some.company.com@psmp.company.com

### EXAMPLE 9
```
New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetPort 2222 -PSMPAddress psmp
```

Connect via PSM to a target listening on a non-default ssh port.

Resulting connection string:
pspete@root@server#2222@psmp

### EXAMPLE 10
```
New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetPort 22 -TunnelPort 5432 -TargetMachine psmp -SSHArgument '-L', '5432:127.0.0.1:5432'
```

Connect via PSM and tunnel local port 5432 to port 5432 on the target.

Resulting ssh command:
ssh -L 5432:127.0.0.1:5432 pspete@root@server#22#5432@psmp

### EXAMPLE 11
```
New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetMachine psmp -SSHArgument '-t' -Command 'uptime'
```

Connect via PSM, force pseudo-terminal allocation and run a command on the target.

Resulting ssh command:
ssh -t pspete@root@server@psmp uptime

### EXAMPLE 12
```
New-PSMPSession -VaultUser pspete -TargetAccount root -TargetAddress server -TargetMachine psmp -SSHArgument '-i', 'C:\keys\psmp_key'
```

Connect via PSM, authenticating to PSMP with an SSH key, such as an MFA caching key.

Resulting ssh command:
ssh -i C:\keys\psmp_key pspete@root@server@psmp

### EXAMPLE 13
```
Import-Csv .\targets.csv | New-PSMPSession -VaultUser pspete -TargetMachine psmp
```

Connect via PSM to each target in turn, using TargetAccount, TargetAddress and other values from the piped objects.

## PARAMETERS

### -VaultUser
The Vault user with which to authenticate to CyberArk.
Standard & UserPrincipalName formats are supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetAccount
The Account in CyberArk to use to connect to a target.
Standard & UserPrincipalName formats are supported.
If UserPrincipalName format is used, TargetDomain value must be provided.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetDomain
Optional Domain name of the target account.
Must be provided if TargetAccount is in UserPrincipalName format.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetAddress
The address of the target to connect to using the target account.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetMachine
The CyberArk PSMP server to connect through.
Alias: PSMPAddress

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSMPAddress

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetPort
Optional port of the target server, if the target does not listen on the default ssh port.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TunnelPort
Optional tunnel target port, used for ssh tunneling via PSMP.
TargetPort must also be provided.
Use SSHArgument to supply the matching local port forward, e.g. -L 5432:127.0.0.1:5432

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SSHArgument
Optional arguments passed to the ssh client before the connection string.
e.g. -t, -i private_key_file, -L localPort:127.0.0.1:tunnelPort
Specify each switch and value as a separate array element, e.g. -SSHArgument '-i', 'C:\keys\id_rsa'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Command
Optional command to execute on the target after connecting.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AdditionalDelimiter
Specify the AdditionalDelimiter in use.
If left blank, the default AdditionalDelimiter of % is used.
If authenticating with or targeting an account in UserPrincipalName format, PSMP should be configured with an AdditionalDelimiter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetAddressPortDelimiter
The delimiter to separate the target domain and optional port values.
A TargetAddressPortDelimiter must have been configured for PSMP.
If left blank, the default TargetAddressPortDelimiter of # is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
AUTHOR: Pete Maan

## RELATED LINKS
