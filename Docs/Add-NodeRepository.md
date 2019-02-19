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
Add-NodeRepository [-RepositoryName] <String> [[-Username] <String>] [-FeedName] <String> [<CommonParameters>]
```

## DESCRIPTION
Registers an Azure Package Management nuget feed to PowerShell as a repository.
This uses BetterCredentials access the repository credentials stored in the Windows Credential Vault

## EXAMPLES

### EXAMPLE 1
```
Add-NodeRepository -RepositoryName TestRepository -Username UsernameHere -FeedName FeedName -Verbose
```

## PARAMETERS

### -RepositoryName
This is the name you want the repository to be registered with

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

### -Username
This is the username that the Azure Artifacts PAT is stored in Credential Manager using.
This is to allow retrieval of the credentials using BetterCredentials.
The default username is set to NodePAT

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: NodePAT
Accept pipeline input: False
Accept wildcard characters: False
```

### -FeedName
This is the name of the Azure Artifacts feed for the repository

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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