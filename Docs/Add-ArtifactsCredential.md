---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Add-ArtifactsCredential

## SYNOPSIS
Azure Artifacts credentials creation

## SYNTAX

```
Add-ArtifactsCredential [-PAT] <String> [<CommonParameters>]
```

## DESCRIPTION
Adds the credentials required to add an Azure Artifacts feed as a repository.
The credentials are stored in credential manager using the BetterCredentials module

## EXAMPLES

### EXAMPLE 1
```
Add-ArtifactsCredential -PAT wdadmineig2u5ng8e3s6h
```

## PARAMETERS

### -PAT
The PAT is generated within Azure DevOps.
Is is best to create a new PAT with only read access to Package Management to prevent misuse of the credentials

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
