---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Add-NodeRepository

## SYNOPSIS
Registers Azure Nuget feed as a repository

## SYNTAX

```
Add-NodeRepository [-Repository] <String> [<CommonParameters>]
```

## DESCRIPTION
Registers an Azure Package Management NuGet feed to PowerShell as a repository.
This uses BetterCredentials access the repository credentials stored in the Windows Credential Vault

## EXAMPLES

### EXAMPLE 1
```
Add-NodeRepository -Repository TestRepository -Verbose
```

## PARAMETERS

### -Repository
The name of the repository being registered

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function also supports the -Verbose parameter to show more detailed console output

## RELATED LINKS
