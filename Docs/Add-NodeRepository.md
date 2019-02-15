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
Add-NodeRepository [-RepositoryName] <Object> [-Username] <Object> [-FeedName] <Object> [<CommonParameters>]
```

## DESCRIPTION
Registers an Azure Package Management nuget feed to PowerShell as a repository.
This uses BetterCredentials to store the repository credentials in the Windows Credential Vault to make it easier to interact with the repository

## EXAMPLES

### EXAMPLE 1
```
Add-NodeRepository -RepositoryName TestRepository -Username UsernameHere -FeedName FeedName -Verbose
```

## PARAMETERS

### -RepositoryName
This is the name you want the repository to be registered with

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
The username parameter is not checked when the repository is registered, however the Username is used by BetterCredentials to store the authentication information and when interacting with the repository to install modules

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FeedName
This is the name of the Azure Artifacts feed for the repository

```yaml
Type: Object
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
