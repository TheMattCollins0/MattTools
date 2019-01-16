---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# New-RegistryPath

## SYNOPSIS
Creates a new registry path

## SYNTAX

```
New-RegistryPath [[-Path] <Object>] [<CommonParameters>]
```

## DESCRIPTION
This function takes the supplied path and creates it in the registry

## EXAMPLES

### EXAMPLE 1
```
New-RegistryPath -Path "HKLM:\SOFTWARE\NodeIT"
```

## PARAMETERS

### -Path
Specifies the path that you wish to create

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function does not currently show any output

## RELATED LINKS
