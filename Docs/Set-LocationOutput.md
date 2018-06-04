---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Set-LocationOutput

## SYNOPSIS
Set location to Output

## SYNTAX

```
Set-LocationOutput [[-Output] <String>] [<CommonParameters>]
```

## DESCRIPTION
Function to check if my Output path exists then create a PSDrive to the Output and set the location to Output:.
Function can also be called by typing Output or Output:

## EXAMPLES

### EXAMPLE 1
```
Set-LocationOutput
```

### EXAMPLE 2
```
Output:
```

### EXAMPLE 3
```
Output
```

## PARAMETERS

### -Output
The -Output parameter allows you to supply the path to your Output folder.
If the folder does not exist, you will see an error

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 1
Default value: C:\Scripts\Output
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
