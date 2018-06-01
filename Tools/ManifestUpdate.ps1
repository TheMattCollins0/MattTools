$ModuleName = $env:BUILD_DEFINITIONNAME
$FunctionPath = ".\" + $ModuleName + "\"
$ModulePath = ".\" + $ModuleName + "\" + $ModuleName + ".psd1"

# Create array containing all the functions
$Functions = @( Get-ChildItem -Path $FunctionPath\*.ps1 -ErrorAction SilentlyContinue )

# Create an empty collection
$FunctionsColl = @()

# Loop through all the functions and export them to a string split by commas
Foreach ($Function in @( $Functions )) {
    $FunctionString = "'" + $($Function.BaseName) + "',"
    $FunctionsColl += $FunctionString
}
if ($FunctionsColl) {
    $FunctionsString = $FunctionsColl -join " "
    $ExportedFunctionsString = $FunctionsString.TrimEnd([char]0x002C)
}

$Manifest = Import-PowerShellDataFile $ModulePath 
[version]$version = $Manifest.ModuleVersion
# Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
# Update the manifest file with the new version number and the string of functions to export
Update-ModuleManifest -Path $ModulePath -ModuleVersion $NewVersion -FunctionsToExport $ExportedFunctionsString -VariablesToExport "*" -AliasesToExport "*"
