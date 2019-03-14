---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# New-RegistryProperty

## SYNOPSIS
Creates a new registry property

## SYNTAX

```
New-RegistryProperty [[-Path] <Object>] [[-Name] <Object>] [[-Value] <Object>] [-PropertyType] <Object>
 [<CommonParameters>]
```

## DESCRIPTION
This function takes the supplied path, name, values and property type then creates the corresponding property in the registry

## EXAMPLES

### EXAMPLE 1
```
New-RegistryProperty -Path "HKLM:\SOFTWARE\NodeIT" -Name Testing -Value "This is the property value" -PropertyType String
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

### -Name
Specifies the name of the new property

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Value
Specifies the value of the new registry property

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PropertyType
Specifies the PropertyType of the property the following property types are available for use:

String: Specifies a null-terminated string.
Equivalent to REG_SZ.
ExpandString: Specifies a null-terminated string that contains unexpanded references to environment variables that are expanded when the value is retrieved.
Equivalent to REG_EXPAND_SZ.
Binary: Specifies binary data in any form.
Equivalent to REG_BINARY.
DWord: Specifies a 32-bit binary number.
Equivalent to REG_DWORD.
MultiString: Specifies an array of null-terminated strings terminated by two null characters.
Equivalent to REG_MULTI_SZ.
Qword: Specifies a 64-bit binary number.
Equivalent to REG_QWORD.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function does not currently show any output

## RELATED LINKS
