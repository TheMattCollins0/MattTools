function Invoke-ProfileBanner {

    <#
    .SYNOPSIS
    Show my PowerShell Profile banner
    .DESCRIPTION
    This function is purely used to write my PowerShell profile banner when I first open PowerShell
    .EXAMPLE
    Invoke-ProfileBanner
    #>

    $SessionStartTimeScriptBlock = {

        Write-Host " *                                                             " -NoNewLine
        Write-Host "Session started at $Time" -ForegroundColor Red -NoNewLine
        Write-Host "                                                          * " -NoNewLine

    }

    Write-Host " **************************************************************************************************************************************************** "
    Write-Host " *                                                                                                                                                  * "
    Write-Host " *                                                    Type Get-MattHelp to view help information                                                    * "
    Write-Host " *                                                                                                                                                  * "
    Write-Host ' *                                                     Type "Gh" to change to the GitHub folder                                                     * '
    Write-Host ' *                                                   Type "Ph" to change to the PowerShell folder                                                   * '
    Write-Host " *                                                                                                                                                  * "
    Write-Host " *                     Use Invoke-MattPlaster to create a Plaster Template, follow prompts for ModuleName and ModuleDescription                     * "
    Write-Host " *                                                                                                                                                  * "
    Write-Host " *                          Install-Module -Repository NodePowerShellRepository -Name ModuleName -Scope CurrentUser -Force                          * "
    Write-Host " *                                                                                                                                                  * "
    Write-Host " *                                                 Type Update-MattModules to update all my modules                                                 * "
    Write-Host " *                                                                                                                                                  * "
    Write-Host ""
    & $SessionStartTimeScriptBlock
    Write-Host " *                                                                                                                                                  * "
    Write-Host " **************************************************************************************************************************************************** "

}
