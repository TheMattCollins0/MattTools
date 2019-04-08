[cmdletbinding()]
param ()

# Set the global Error action preference to stop
# $ErrorActionPreference = 'stop'

$env:PSModulePath
$env:PSModulePath = $env:PSModulePath + ";C:\Windows\ServiceProfiles\NetworkService\Documents\WindowsPowerShell\Modules\"
$env:PSModulePath

# Checking for then installing the Nuget package provider and PSDepend packages for the build environment
$PSDependCheck = Import-Module PSDepend -ErrorAction SilentlyContinue

if ( !$PSDependCheck ) {
    Write-Verbose -Message "Installing Nuget and PSDepend"
    Install-PackageProvider -Name Nuget -Scope CurrentUser -Force
    Install-Module -Name PSDepend -Scope CurrentUser -Force
}

# Import the PSDepend module
Write-Verbose -Message "Importing the PSDepend module"
Import-Module PSDepend -Force

# Run Invoke-PSDepend to install or update the required modules to allow the build to run
Write-Verbose -Message "Invoking the PSDepend module to install the required modules"
Invoke-PSDepend -Force

# Create the results folder to contain the Pester test results
$Folder = ".\Results"
if (-not(Test-Path -Path $Folder -PathType Container)) {
    New-Item -Path $Folder -ItemType Directory | Out-Null
}

# Creation of result output file variables
$PesterResultsPath = ".\" + "Results" + "\" + "PesterResults" + ".xml"

# Run the Pester and PSScriptAnalyzer tests
Invoke-Pester -OutputFile $PesterResultsPath -OutputFormat 'NUnitXml' -Script '.\Tests*'

## Section for documentation updates
# Creation of docs path variable
$Docs = ".\Docs"

# Creation of the output path variable
$Output = ".\en-US"

# Creation of $ModuleName variable
$ModuleName = $env:BUILD_DEFINITIONNAME

# Module file path variable
$ModuleFile = ".\" + $ModuleName

# Creation and update of PlatyPS help if docs path does not exist
$DocsPathTest = Test-Path -Path $Docs -PathType Container

if ( !$DocsPathTest ) {

    # Create the docs folder
    if (-not(Test-Path -Path $Docs -PathType Container)) {
        New-Item -Path $Docs -ItemType Directory | Out-Null
    }

    # Create the output folder
    if (-not(Test-Path -Path $Output -PathType Container)) {
        New-Item -Path $Output -ItemType Directory | Out-Null
    }

    # Import the module
    Import-Module $ModuleFile

    # Create the new markdown help
    New-MarkdownHelp -Module $ModuleName -OutputFolder $Docs -Force

    # Create the external help
    New-ExternalHelp -Path $Docs -OutputPath $Output -Force
}

# Update of PlatyPS help of the docs path does exist
if ( $DocsPathTest ) {
    # Import the PowerShell module
    Import-Module $ModuleFile

    # Update the help files
    New-MarkdownHelp -Module $ModuleName -OutputFolder $Docs -Force

    # Update the external help
    New-ExternalHelp -Path $Docs -OutputPath $Output -Force
}
