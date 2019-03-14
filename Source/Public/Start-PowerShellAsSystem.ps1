function Start-PowerShellAsSystem {

    <#
    .SYNOPSIS
    Run PowerShell as system
    .DESCRIPTION
    This function uses PsExec to start a new PowerShell console as the system account
    .EXAMPLE
    Start-PowerShellAsSystem
    .EXAMPLE
    SYS
    .NOTES
    Function supports the alias Sys
    #>

    [CmdletBinding()]
    Param ()

    begin {}

    process {
        PsExec -i -s Powershell.exe
    }
}

New-Alias -Name Sys -Value Start-PowerShellAsSystem
