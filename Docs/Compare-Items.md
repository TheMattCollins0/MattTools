---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Compare-Items

## SYNOPSIS
Compares contents of two .txt files

## SYNTAX

```
Compare-Items [-OriginalFile] <String> [-CompareFile] <String> [<CommonParameters>]
```

## DESCRIPTION
This function wraps around the Compare-Object file, to display differences between two files.
It forces you to supply the two files as parameters.
The function currently works best on text or csv files with only one column

## EXAMPLES

### EXAMPLE 1
```
Compare-Items -OriginalFile "C:\Scripts\Input\FileOne.txt" -CompareFile "C:\Scripts\Input\FileTwo.txt"
```

## PARAMETERS

### -OriginalFile
This parameter specifies the location of the first file you want to compare

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

### -CompareFile
This parameter specifies the location of the second file you want to compare

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This function also supports the -Verbose parameter for more console output

## RELATED LINKS
