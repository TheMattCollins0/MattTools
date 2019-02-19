---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Find-NodeModule

## SYNOPSIS
Find module or modules in an Azure Artifacts repository

## SYNTAX

```
Find-NodeModule [[-Name] <String>] [[-Repository] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function wraps around the Find-Module function.
It uses BetterCredentials module to secure authentication to the feed and reduce installation effort

## EXAMPLES

### EXAMPLE 1
```
Find-NodeModule -Name MODULENAME -Repository REPOSITORYNAME
```

### EXAMPLE 2
```
Find-NodeModule
```

### EXAMPLE 3
```
Find-NodeModule -Repository REPOSITORYNAME
```

## PARAMETERS

### -Name
This parameter specifies the name of the module you wish to find

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository
This parameter specifies the name of the Repository that you want to search.
This parameter defaults to NodePowerShell

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: NodePowerShell
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function also supports the -Verbose parameter for more console output

## RELATED LINKS
