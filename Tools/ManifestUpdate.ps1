$ModuleName = $env:BUILD_DEFINITIONNAME
$ModulePath = ".\" + $ModuleName + "\" + $ModuleName + ".psd1"
$Manifest = Import-PowerShellDataFile $ModulePath 
[version]$version = $Manifest.ModuleVersion
# Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
# Update the manifest file with the new version number
Update-ModuleManifest -Path $ModulePath -ModuleVersion $NewVersion

