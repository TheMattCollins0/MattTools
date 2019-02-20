function Get-NugetExe {

    # Function to download the NuGet executable to C:\ProgramData\Node\Nuget\nuget.exe

    $nugetPath = "C:\ProgramData\Node\Nuget"
    if (!(Test-Path -Path $nugetPath)) {
        Write-Verbose "Creating directory $nugetPath" -Verbose
        New-Item -Path $nugetPath -ItemType Directory
    }
    Write-Verbose "Working Folder : $nugetPath"
    $NugetExe = "$nugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Verbose "Cannot find nuget at $NugetExe" -Verbose
        $NuGetInstallUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $sourceNugetExe = $NuGetInstallUri
        Write-Verbose "$sourceNugetExe -OutFile $NugetExe" -Verbose

        Invoke-WebRequest $sourceNugetExe -OutFile $NugetExe
        if (-not (Test-Path $NugetExe)) {
            Throw "Nuget download hasn't worked."
        }
        Else {Write-Verbose "Nuget Downloaded!" -Verbose}
    }
    Write-Verbose "Add $nugetPath as %PATH%"
    $pathenv = [System.Environment]::GetEnvironmentVariable("path")
    $pathenv = $pathenv + ";" + $nugetPath
    [System.Environment]::SetEnvironmentVariable("path", $pathenv)

}
