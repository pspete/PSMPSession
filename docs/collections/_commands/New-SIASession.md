---
external help file: PSMPSession-help.xml
Module Name: PSMPSession
online version:
schema: 2.0.0
title: New-SIASession
---

# New-SIASession

## SYNOPSIS
Formats SIA connection string and connects to target using ssh.

## SYNTAX

### ZSP (Default)
```
New-SIASession -User <String> -Subdomain <String> -TargetAddress <String> [-TargetPort <Int32>]
 [-NetworkName <String>] [-Gateway <String>] [-SSHArgument <String[]>] [-Command <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Vaulted
```
New-SIASession -User <String> -Subdomain <String> -TargetAddress <String> -TargetAccount <String>
 [-TargetDomain <String>] [-TargetPort <Int32>] [-NetworkName <String>] [-Gateway <String>]
 [-SSHArgument <String[]>] [-Command <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Correctly formats CyberArk Secure Infrastructure Access (SIA) ssh connection string based on the provided parameter values.
Supports zero standing privileges (ZSP) access, and vaulted access using local or domain accounts.
Supports optional target port and network name, and passing additional arguments or a command to the ssh client.
SSH client must be installed and available on your PATH.

## EXAMPLES

### EXAMPLE 1
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5
```

Connect via SIA using zero standing privileges.

Resulting connection string:
pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud

### EXAMPLE 2
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -TargetPort 2222 -NetworkName Net1
```

Connect via SIA using zero standing privileges, to a target on a non-default port in a named network.

Resulting connection string:
pete@pspete.dev#acme@10.0.0.5:2222#Net1@acme.ssh.cyberark.cloud

### EXAMPLE 3
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAccount root -TargetAddress server.pspete.dev
```

Connect via SIA using vaulted access with a local account.

Resulting connection string:
pete@pspete.dev#acme@root@server.pspete.dev@acme.ssh.cyberark.cloud

### EXAMPLE 4
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAccount admin -TargetDomain pspete.dev -TargetAddress server.pspete.dev
```

Connect via SIA using vaulted access with a domain account.

Resulting connection string:
pete@pspete.dev#acme@admin#pspete.dev@server.pspete.dev@acme.ssh.cyberark.cloud

### EXAMPLE 5
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -Gateway ssh.vanity.example.com
```

Connect via SIA through a non-default gateway address.

Resulting connection string:
pete@pspete.dev#acme@10.0.0.5@ssh.vanity.example.com

### EXAMPLE 6
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-L', '8080:10.0.0.5:80'
```

Connect via SIA and forward local port 8080 to port 80 on the target.

Resulting ssh command:
ssh -L 8080:10.0.0.5:80 pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud

### EXAMPLE 7
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -Command 'touch tmp.txt; cat tmp.txt'
```

Connect via SIA and run inline commands on the target.

Resulting ssh command:
ssh pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud 'touch tmp.txt; cat tmp.txt'

### EXAMPLE 8
```
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-i', 'C:\keys\sia_key'
```

Connect via SIA, authenticating to the SSH gateway with an SSH key, such as an MFA caching key.

Resulting ssh command:
ssh -i C:\keys\sia_key pete@pspete.dev#acme@10.0.0.5@acme.ssh.cyberark.cloud

### EXAMPLE 9
```
Import-Csv .\targets.csv | New-SIASession -User pete@pspete.dev -Subdomain acme
```

Connect via SIA to each target in turn, using TargetAddress, TargetAccount and other values from the piped objects.

## PARAMETERS

### -User
Your username as defined in your organization's directory service.
Typically in the format username@login_suffix.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Subdomain
Your organization's tenant subdomain, as shown in your portal URL (https://subdomain.cyberark.cloud).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetAddress
The target to connect to.
FQDN, IP address, or cloud instance ID (ZSP only).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetAccount
The user name on the target machine, as defined in Privilege Cloud.
Specifying a TargetAccount uses vaulted access.
Standard & UserPrincipalName formats are supported.

```yaml
Type: String
Parameter Sets: Vaulted
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetDomain
The address of the domain account as defined in Privilege Cloud.
Only provide for domain accounts used with vaulted access.

```yaml
Type: String
Parameter Sets: Vaulted
Aliases:

Required: False
Position: Named
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
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NetworkName
Optional network name, as defined on the connector pool.
Mandatory in SIA for vaulted accounts defined with an IP address.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Gateway
The SIA SSH gateway address.
If left blank, the default gateway of \<Subdomain\>.ssh.cyberark.cloud is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SSHArgument
Optional arguments passed to the ssh client before the connection string.
e.g. -t, -i private_key_file, -L clientPort:target:targetPort
Specify each switch and value as a separate array element, e.g. -SSHArgument '-i', 'C:\keys\id_rsa'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Command
Optional inline commands to execute on the target after connecting, separated by semicolons.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
