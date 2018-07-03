function Invoke-ProfileBanner {

    <#
    .SYNOPSIS
    Show my PowerShell Profile banner
    .DESCRIPTION
    This function is purely used to write my PowerShell profile banner when I first open PowerShell
    .EXAMPLE
    Invoke-ProfileBanner
    #>

    Write-Information " **************************************************************************************************************************************************** "
    Write-Information " *                                                                                                                                                  * "
    Write-Information " *                                                    Type Get-MattHelp to view help information                                                    * "
    Write-Information " *                                                                                                                                                  * "
    Write-Information ' *                                                     Type "Gh" to change to the GitHub folder                                                     * '
    Write-Information ' *                                                   Type "Ph" to change to the PowerShell folder                                                   * '
    Write-Information " *                                                                                                                                                  * "
    Write-Information " *                     Use Invoke-MattPlaster to create a Plaster Template, follow prompts for ModuleName and ModuleDescription                     * "
    Write-Information " *                                                                                                                                                  * "
    Write-Information " *                          Install-Module -Repository NodePowerShellRepository -Name ModuleName -Scope CurrentUser -Force                          * "
    Write-Information " *                                                                                                                                                  * "
    Write-Information " *                                                             "
    Write-Information "Session started at $Time" -NoNewLine -ForegroundColor Red
    Write-Information "                                                          * " -NoNewLine
    Write-Information " *                                                                                                                                                  * "
    Write-Information " **************************************************************************************************************************************************** "

}
