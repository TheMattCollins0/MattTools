[cmdletbinding()]
param ()

$SourceFolder = ".\Source\"
$ModulePath = $env:BUILD_DEFINITIONNAME

Write-Verbose -Message "Working in $SourceFolder" -verbose

$Module = Get-ChildItem -Path $SourceFolder -Filter *.psd1 -Recurse | Select-Object -First 1

$OutputFolder = Join-Path -Path $($Module.Directory.FullName) -ChildPath "..\$ModulePath\"
$null = New-Item -Path $OutputFolder -ItemType Directory -Force -Confirm:$false
$DestinationModule = Join-Path -Path $($Module.Directory.FullName) -ChildPath "..\$ModulePath\$($Module.BaseName).psm1"
$OutputManifest = Join-Path -Path $($Module.Directory.FullName) -ChildPath "..\$ModulePath\$($Module.BaseName).psd1"
Copy-Item -Path $Module.FullName -Destination $OutputManifest -Force

Write-Verbose -Message "Attempting to work with $DestinationModule" -verbose

if (Test-Path -Path $DestinationModule ) {
    Remove-Item -Path $DestinationModule -Confirm:$False -force
}

$PublicFunctions = Get-ChildItem -Path $SourceFolder -Include 'Public', 'External', 'Functions' -Recurse -Directory | Get-ChildItem -Include *.ps1 -File
$PrivateFunctions = Get-ChildItem -Path $SourceFolder -Include 'Private', 'Internal' -Recurse -Directory | Get-ChildItem -Include *.ps1 -File

if ($PublicFunctions -or $PrivateFunctions) {
    Write-Verbose -message "Found Private or Public functions. Will compile these into the psm1 and only export public functions."

    Foreach ($PrivateFunction in $PrivateFunctions) {
        Get-Content -Path $PrivateFunction.FullName | Add-Content -Path $DestinationModule
    }
    Write-Verbose -Message "Found $($PrivateFunctions.Count) Private functions and added them to the psm1."
}
else {
    Write-Verbose -Message "Didn't find any Private or Public functions, will assume all functions should be made public."

    $PublicFunctions = Get-ChildItem -Path $SourceFolder -Include *.ps1 -Recurse -File
}

Foreach ($PublicFunction in $PublicFunctions) {
    Get-Content -Path $PublicFunction.FullName | Add-Content -Path $DestinationModule
}
Write-Verbose -Message "Found $($PublicFunctions.Count) Public functions and added them to the psm1."

# Create an empty collection to store the public function names in
$PublicFunctionNames = @()

# Loop through all the functions and export them to a string split by commas
foreach ( $PublicFunction in $PublicFunctions ) {
    $PublicFunctionString = $PublicFunction.BaseName
    $PublicFunctionNames += $PublicFunctionString
}

Write-Verbose -Message "Making $($PublicFunctionNames.Count) public functions available via Export-ModuleMember"

"Export-ModuleMember -Function $($PublicFunctionNames -join ',')" | Add-Content -Path $DestinationModule
