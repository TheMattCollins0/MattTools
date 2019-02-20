function Get-NugetExe {

    [CmdletBinding()]
    param ()

    # Function to download the NuGet executable to C:\ProgramData\Node\Nuget\nuget.exe

    $nugetPath = "C:\ProgramData\Node\Nuget"
    if (!(Test-Path -Path $nugetPath)) {
        Write-Verbose -Message "Creating directory $nugetPath"
        New-Item -Path $nugetPath -ItemType Directory | Out-Null
    }
    Write-Verbose -Message "Working Folder : $nugetPath"
    $NugetExe = "$nugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Verbose -Message "Cannot find nuget at $NugetExe"
        $NuGetInstallUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $sourceNugetExe = $NuGetInstallUri
        Write-Verbose -Message "$sourceNugetExe -OutFile $NugetExe"

        Invoke-WebRequest $sourceNugetExe -OutFile $NugetExe | Out-Null
        if (-not (Test-Path $NugetExe)) {
            Throw "Nuget download hasn't worked."
        }
        Else {Write-Verbose -Message "Nuget Downloaded!"}
    }
    Write-Verbose -Message "Add $nugetPath as %PATH%"
    $pathenv = [System.Environment]::GetEnvironmentVariable("path")
    $pathenv = $pathenv + ";" + $nugetPath
    [System.Environment]::SetEnvironmentVariable("path", $pathenv)

}
