---
external help file: PSMPSession-help.xml
Module Name: PSMPSession
online version:
schema: 2.0.0
title: Save-SIASSHKey
---

# Save-SIASSHKey

## SYNOPSIS
Downloads an SIA MFA caching SSH key using sftp.

## SYNTAX

```
Save-SIASSHKey [-User] <String> [-Subdomain] <String> [-Path] <String> [[-Format] <String>]
 [[-Gateway] <String>] [[-SFTPArgument] <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Formats the SIA sftp command to generate and download an MFA caching SSH key, and saves the key to the specified path.
The key can then be used with New-SIASession to connect to targets without repeating MFA, for the period configured in SIA.
Access to the saved key file is restricted to the current user, as required by the OpenSSH client.
SIA only accepts the key from the IP address of the machine which downloaded it.
SFTP client must be installed and available on your PATH.

## EXAMPLES

### EXAMPLE 1
```
Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete
```

Download an MFA caching key in OpenSSH format.

Resulting sftp command:
sftp pete@pspete.dev#acme@key@acme.ssh.cyberark.cloud:/key C:\Users\pete\.ssh\acme_pete

### EXAMPLE 2
```
Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete.ppk -Format PPK
```

Download an MFA caching key in PuTTY Private Key format.

Resulting sftp command:
sftp pete@pspete.dev#acme@key_ppk@acme.ssh.cyberark.cloud:/key C:\Users\pete\.ssh\acme_pete.ppk

### EXAMPLE 3
```
$Key = Save-SIASSHKey -User pete@pspete.dev -Subdomain acme -Path ~\.ssh\acme_pete
New-SIASession -User pete@pspete.dev -Subdomain acme -TargetAddress 10.0.0.5 -SSHArgument '-i', $Key.FullName
```

Download an MFA caching key, then use it to connect to a target without repeating MFA.

## PARAMETERS

### -User
Your username as defined in your organization's directory service.
Typically in the format username@login_suffix.

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

### -Subdomain
Your organization's tenant subdomain, as shown in your portal URL (https://subdomain.cyberark.cloud).

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

### -Path
The file path to save the key to.
If the path is an existing directory, the key is saved to a file named key in that directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Format
The format of the key.
OpenSSH (default) for use with OpenSSH clients, or PPK for use with PuTTY.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: OpenSSH
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
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SFTPArgument
Optional arguments passed to the sftp client before the connection string.
Specify each switch and value as a separate array element, e.g. -SFTPArgument '-P', '2222'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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

### System.IO.FileInfo
## NOTES
AUTHOR: Pete Maan

## RELATED LINKS
