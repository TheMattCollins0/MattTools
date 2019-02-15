---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Update-NodeModules

## SYNOPSIS
Update Node Azure Artifacts based modules

## SYNTAX

```
Update-NodeModules [-NodeClients] [<CommonParameters>]
```

## DESCRIPTION
Update modules that are installed from an Azure Artifacts repository.
By default it checks NodePowerShell, using the -NodeClients parameter will check for updates to NodeClients modules

## EXAMPLES

### EXAMPLE 1
```
Update-NodeModules
```

### EXAMPLE 2
```
Update-NodeModules -NodeClients
```

## PARAMETERS

### -NodeClients
Checks for updates to modules installed from the NodeClients repository

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
