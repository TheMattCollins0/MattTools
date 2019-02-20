---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Unregister-NodeRepository

## SYNOPSIS
Removes a repository registered against an Azure Artifacts feed

## SYNTAX

```
Unregister-NodeRepository [-Repository] <String> [<CommonParameters>]
```

## DESCRIPTION
Removes an Azure Package Management NuGet feed from PowerShell's repositories.

## EXAMPLES

### EXAMPLE 1
```
Unregister-NodeRepository -Repository TestRepository -Verbose
```

## PARAMETERS

### -Repository
This is the name of the repository you want to remove

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
