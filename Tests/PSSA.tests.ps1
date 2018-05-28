Describe 'Testing against PSSA rules' {
    Context 'PSSA Standard Rules' {
        # Creation of module pah variable
        $ModulePath = $env:BUILD_DEFINITIONNAME

        # Populate an array containing all of the function names
        $Scripts = @( Get-ChildItem -Path $ModulePath\*.ps1 -ErrorAction SilentlyContinue )

        # Loop to run the PSScriptAnalyser tests on all functions
        Foreach ($Script in @( $Scripts )) {
            $ScriptLocation = ".\" + $ModulePath + "\" + $Script.Name
            $analysis = Invoke-ScriptAnalyzer -Path $ScriptLocation
            $scriptAnalyzerRules = Get-ScriptAnalyzerRule
            forEach ($rule in $scriptAnalyzerRules) {
                It "Should pass $rule" {
                    If ($analysis.RuleName -contains $rule) {
                        $analysis |
                            Where-Object RuleName -EQ $rule -outvariable failures |
                            Out-Default
                        $failures.Count | Should Be 0
                    }
                }
            }
        }    
    }
}

