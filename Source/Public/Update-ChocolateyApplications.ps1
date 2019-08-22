function Update-ChocolateyApplications {

    <#
    .SYNOPSIS
    Update Chocolatey installed applications
    .DESCRIPTION
    Update applications that were installed through the Chocolatey package management application
    .EXAMPLE
    Update-ChocolateyApplications
    .NOTES
    Function allows use of the alias UCA
    #>

    [CmdletBinding()]
    Param ()

    choco upgrade all -y

}

New-Alias -Name UCA -Value Update-ChocolateyApplications
