#Requires -Modules Pester

#region variables

$ModulePath = ".\" + $env:BUILD_DEFINITIONNAME

#endregion
Write-output "Module Path: '$ModulePath'"

Describe "PowerShell Module Import Test" {

    It 'Module Path should exist' {
        Test-Path $ModulePath -ErrorAction SilentlyContinue | should Be $true
    }

    It 'Should be imported successfully' {
        Import-Module -Name $ModulePath -ErrorVariable ImportError
        $ImportError | Should Be $Null
    }
}
