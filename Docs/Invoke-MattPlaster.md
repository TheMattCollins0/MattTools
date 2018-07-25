---
external help file: MattTools-help.xml
Module Name: MattTools
online version:
schema: 2.0.0
---

# Invoke-MattPlaster

## SYNOPSIS
Module creation function

## SYNTAX

```
Invoke-MattPlaster [[-GitHubUserName] <String>] [[-GitHubPath] <String>] [-ModuleName] <String>
 [-ModuleDescription] <String> [<CommonParameters>]
```

## DESCRIPTION
Function to automate the creation of new PowerShell modules.
The module relies on Git-Scm being installed.
It also replies on the Plaster and PSGitHub modules being installed from the PSGallery

## EXAMPLES

### EXAMPLE 1
```
Invoke-MattPlaster -ModuleName "NameHere" -ModuleDescription "This is a module description"
```

### EXAMPLE 2
```
Invoke-MattPlaster -Name "NameHere" -Description "This is a module description"
```

### EXAMPLE 3
```
Invoke-MattPlaster -ModuleName "NameHere" -ModuleDescription "This is a module description"
```

### EXAMPLE 4
```
Invoke-MattPlaster -Name "NameHere" -Description "This is a module description"
```

### EXAMPLE 5
```
Invoke-MattPlaster -GitHubUserName YourUserNameHere -GitHubPath "C:\GitHubScripts" -ModuleName "NameHere" -ModuleDescription "This is a module description"
```

### EXAMPLE 6
```
Invoke-MattPlaster -UserName YourUserNameHere -Path "C:\GitHubScripts" -Name "NameHere" -Description "This is a module description"
```

### EXAMPLE 7
```
Invoke-MattPlaster -GitHubUserName YourUserNameHere -GitHubPath "C:\GitHubScripts" -ModuleName "NameHere" -ModuleDescription "This is a module description"
```

### EXAMPLE 8
```
Invoke-MattPlaster -UserName YourUserNameHere -Path "C:\GitHubScripts" -Name "NameHere" -Description "This is a module description"
```

## PARAMETERS

### -GitHubUserName
The -GitHubUserName parameter allows you to supply your GitHub username

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserName

Required: False
Position: 1
Default value: TheMattCollins0
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubPath
The -GitHubPath parameter allows you to supply the path to your GitHub folder.
If the folder does not exist, You will see an error

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 2
Default value: C:\GitHub
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
The -ModuleDescription parameter supplies the name of your new PowerShell module and GitHub repository

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ModuleDescription
The -ModuleDescription parameter supplies the description of your new PowerShell module and GitHub repository

```yaml
Type: String
Parameter Sets: (All)
Aliases: Description

Required: True
Position: 4
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

## RELATED LINKS
