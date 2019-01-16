---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Set-LocationGitHub

## SYNOPSIS
Set location to GitHub

## SYNTAX

```
Set-LocationGitHub [[-GitHub] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Function to check if my GitHub path exists then set the prompts location to the path.
Function can also be called by typing GitHub or Gh

## EXAMPLES

### EXAMPLE 1
```
Set-LocationGitHub
```

### EXAMPLE 2
```
Gh
```

### EXAMPLE 3
```
GitHub
```

## PARAMETERS

### -GitHub
The -GitHub parameter allows you to supply the path to your GitHub folder.
If the folder does not exist, you will see an error

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 1
Default value: C:\GitHub
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
