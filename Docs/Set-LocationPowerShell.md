---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Set-LocationPowerShell

## SYNOPSIS
Set location to my PowerShell Path

## SYNTAX

```
Set-LocationPowerShell [[-PowerShell] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Function to check if my PowerShell path exists then create a PSDrive to the PowerShell and set the location to PSH:.
Function can also be called by typing PH

## EXAMPLES

### EXAMPLE 1
```
Set-LocationPowerShell
```

### EXAMPLE 2
```
PH
```

## PARAMETERS

### -PowerShell
The -PowerShell parameter allows you to supply the path to your PowerShell folder.
If the folder does not exist, you will see an error

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 1
Default value: C:\GitHub\PowerShell
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
