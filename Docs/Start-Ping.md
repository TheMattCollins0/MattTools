---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Start-Ping

## SYNOPSIS
Run Ping with -t specified as a default argument

## SYNTAX

```
Start-Ping [-Address] <String> [<CommonParameters>]
```

## DESCRIPTION
This function wraps around Ping supplying the-t argument to always ping non-stop

## EXAMPLES

### EXAMPLE 1
```
Start-Ping test.domain.com
```

### EXAMPLE 2
```
P 1.1.1.1
```

## PARAMETERS

### -Address
The -Address parameter is for supplying the IP address or hostname you wish to ping

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Function supports the alias P

## RELATED LINKS
