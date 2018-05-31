function Update-CodeCoveragePercent {  
    [cmdletbinding(supportsshouldprocess)]
    param(
        [int]
        $CodeCoverage = 0,

        [string]
        $TextFilePath = ".\Readme.md"
    )

    $BadgeColor = switch ($CodeCoverage) {
        {$_ -in 90..100} { 'brightgreen' }
        {$_ -in 75..89} { 'yellow' }
        {$_ -in 60..74} { 'orange' }
        default { 'red' }
    }

    if ($PSCmdlet.ShouldProcess($TextFilePath)) {
        $ReadmeContent = (Get-Content $TextFilePath)
        $ReadmeContent = $ReadmeContent -replace "!\[Test Coverage\].+\)", "![Test Coverage](https://img.shields.io/badge/coverage-$CodeCoverage%25-$BadgeColor.svg?maxAge=60)" 
        $ReadmeContent | Set-Content -Path $TextFilePath
    }
}

# Set the global Error action preference to stop
$ErrorActionPreference = 'stop'

# Install the Nuget package provider, Pester and PSScriptAnalyzer packages for testing
Install-PackageProvider -Name Nuget -Scope CurrentUser -Force -Confirm:$false
Install-Module -Name Pester -Scope CurrentUser -Force -SkipPublisherCheck -Confirm:$false
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -Confirm:$false
Install-Module -Name PlatyPS -Scope CurrentUser -Force -Confirm:$false

# Install third party modules required for the module 
Install-Module -Name PSGitHub -Scope CurrentUser -Force -Confirm:$false
Install-Module -Name Plaster -Scope CurrentUser -Force -Confirm:$false

# Import the Pester, PSScriptAnalyzer and PlatyPS
Import-Module Pester -Force
Import-Module PSScriptAnalyzer -Force
Import-Module PlatyPS -Force
Import-Module PSGitHub -Force
Import-Module Plaster -Force

# Creation of module path variable
$ModulePath = $env:BUILD_DEFINITIONNAME

# Populate the $CodeFiles variable with the FullName of all script files within the module path
$CodeFiles = (Get-ChildItem $ModulePath -Recurse -Include "*.psm1", "*.ps1").FullName

# Create the results folder to contain the Pester test results
$Folder = ".\Results"
if (-not(Test-Path -Path $Folder -PathType Container)) {
    New-Item -Path $Folder -ItemType Directory | Out-Null
}

# Creation of result output file variables
$PesterResultsPath = ".\" + "Results" + "\" + "PesterResults" + ".xml"
$PSSAResultsPath = ".\" + "Results" + "\" + "PSSAResults" + ".xml"

# Run the Pester and PSScriptAnalyzer tests
Invoke-Pester -OutputFile $PesterResultsPath -OutputFormat 'NUnitXml' -Script '.\Tests\ModuleImport.tests.ps1'
Invoke-Pester -OutputFile $PSSAResultsPath -OutputFormat 'NUnitXml' -Script '.\Tests\PSSA.tests.ps1'

# Creation of path variable
$Path = ".\Tests"

# Run the code coverage test
$Script:TestResults = Invoke-Pester -Path $Path -CodeCoverage $CodeFiles -PassThru -OutputFormat 'NUnitXml' -OutputFile ".\Results\CodeCoverageResults.xml"

# Calculate the code coverage percentage
$CoveragePercent = [math]::floor(100 - (($Script:TestResults.CodeCoverage.NumberOfCommandsMissed / $Script:TestResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))

# Update the code coverage badge in the README.md file
Update-CodeCoveragePercent -CodeCoverage $CoveragePercent

<#
# Creation of docs path variable
$Docs = ".\Docs"

# Creation of the output path variable
$Output = $Docs + "\en-US\"

# Module file path variable
$ModuleFile = $ModulePath + "\" + $ModulePath + ".psm1"

# Creation of $ModuleName variable
$ModuleName = $env:BUILD_DEFINITIONNAME

# Creation of PSScriptRoot variable
$PSScriptRoot = $env:BUILD_DEFINITIONNAME

# Creation and update of PlatyPS help if docs path does not exist
if (!$Docs) {
    # Import the module
    Import-Module $ModuleFile

    # Create the new markdown help
    New-MarkdownHelp -Module $ModuleName -OutputFolder .\docs

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
