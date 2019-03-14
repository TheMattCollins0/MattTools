---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Update-MattModules

## SYNOPSIS
Update Matt modules

## SYNTAX

```
Update-MattModules [-PSGallery] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Update modules that are stored in PSGallery and NodePowerShellRepository

## EXAMPLES

### EXAMPLE 1
```
Update-MattModules
```

### EXAMPLE 2
```
Update-MattModules -PSGallery
```

## PARAMETERS

### -PSGallery
Checks for updates to modules installed from the PSGallery

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function also supports the -Verbose parameter to show more detailed console output

## RELATED LINKS
