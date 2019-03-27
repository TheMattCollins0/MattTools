---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Start-TcPing

## SYNOPSIS
Run TcPing with -t specified as a default argument

## SYNTAX

```
Start-TcPing [-Address] <String> [-Port] <Int32> [<CommonParameters>]
```

## DESCRIPTION
This function wraps around TcPing supplying the-t argument to always ping non-stop

## EXAMPLES

### EXAMPLE 1
```
Start-TcPing test.domain.com 443
```

### EXAMPLE 2
```
tp 1.1.1.1 80
```

## PARAMETERS

### -Address
The -Address parameter is for supplying the IP address or hostname you wish to test

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

### -Port
The -Port parameter supplies the TCP port that you want to test

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Function supports the alias tp

## RELATED LINKS
