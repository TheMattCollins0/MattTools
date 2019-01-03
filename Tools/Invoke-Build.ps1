[cmdletbinding()]
param ()

# Set the global Error action preference to stop
$ErrorActionPreference = 'stop'

# Checking for then installing the Nuget package provider and PSDepend packages for the build environment
$PSDependCheck = Import-Module PSDepend -ErrorAction Continue

if ( !$PSDependCheck ) {
    Write-Verbose -Message "Installing Nuget and PSDepend"
    Install-PackageProvider -Name Nuget -Scope CurrentUser -Force -Confirm:$false
    Install-Module -Name PSDepend -Scope CurrentUser -Force -Confirm:$false
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

<#
# Creation of docs path variable
$Docs = ".\Docs"

# Creation of the output path variable
$Output = .\en-US"

# Module file path variable
$ModuleFile = $ModulePath + "\" + $ModulePath + ".psm1"

# Creation of $ModuleName variable
$ModuleName = $env:BUILD_DEFINITIONNAME

# Creation of PSScriptRoot variable
$PSScriptRoot = $env:BUILD_DEFINITIONNAME

# Creation and update of PlatyPS help if docs path does not exist
if (!$Docs) {

    # Creation of the Docs path
    if (-not(Test-Path -Path $Docs -PathType Container)) {
    New-Item -Path $Docs -ItemType Directory | Out-Null
    }

    # Import the module
    Import-Module $ModuleFile

    # Create the new markdown help
    New-MarkdownHelp -Module $ModuleName -OutputFolder .\docs

    # Creation of the en-US External help path
    if (-not(Test-Path -Path $Output -PathType Container)) {
    New-Item -Path $Output -ItemType Directory | Out-Null
    }

    # Create the external help
    New-ExternalHelp $Docs -OutputPath $Output
}

# Update of PlatyPS help of the docs path does exist
if ($Docs) {
    # Import the PowerShell module
    Import-Module $ModuleName -Force

    # Update the help files
    Update-MarkdownHelp $Docs
}
#>
