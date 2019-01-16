---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Get-LastCmdTime

## SYNOPSIS
Outputs the execution time of the the last command in history.

## SYNTAX

```
Get-LastCmdTime
```

## DESCRIPTION
Calculates and outputs the time difference of the last command in history.
The difference will be outputted in a "human" format if the Humanizer module
(https://www.powershellgallery.com/packages/PowerShellHumanizer/2.0) is
installed.

## EXAMPLES

### EXAMPLE 1
```
Outputs the execution time of the the last command in history.
```

Get-LastCmdTime.

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
Returns $null if the history buffer is empty.
Thanks go to - https://gist.github.com/kelleyma49/bd03dfa82c37438a01b1 - for this function

## RELATED LINKS
