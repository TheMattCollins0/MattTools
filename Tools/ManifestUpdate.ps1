$ModuleName = $env:BUILD_DEFINITIONNAME
$FunctionPath = ".\Source\Public\"
# $ModulePath = ".\" + $ModuleName + "\" + $ModuleName + ".psd1"
$ModulePath = ".\Source\" + $ModuleName + ".psd1"

# Create array containing all the functions
$Functions = @( Get-ChildItem -Path $FunctionPath\*.ps1 -ErrorAction SilentlyContinue )

# Create an empty collection
$ExportedFunctions = @()

# Loop through all the functions and export them to a string split by commas
foreach ($Function in @( $Functions )) {
    $FunctionString = $($Function.BaseName)
    $ExportedFunctions += $FunctionString
}


$Manifest = Import-PowerShellDataFile $ModulePath
[version]$version = $Manifest.ModuleVersion
# Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)
# Update the manifest file with the new version number and the string of functions to export
# Update-ModuleManifest -Path $ModulePath -ModuleVersion $NewVersion -FunctionsToExport $ExportedFunctions -VariablesToExport "*" -AliasesToExport "*"
Update-ModuleManifest -Path $ModulePath -ModuleVersion $NewVersion
