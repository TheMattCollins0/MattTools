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
Set-LocationGitHub [[-GitHub] <String>] [<CommonParameters>]
```

## DESCRIPTION
Function to check if my GitHub path exists then create a PSDrive to the GitHub and set the location to Git:.
Function can also be called by typing Git or Git:

## EXAMPLES

### EXAMPLE 1
```
Set-LocationGitHub
```

### EXAMPLE 2
```
Git:
```

### EXAMPLE 3
```
Git
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
