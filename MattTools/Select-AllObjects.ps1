function Select-AllObjects {

    <#
    .SYNOPSIS
    Select all properties
    .DESCRIPTION
    Function to select all properties from a command
    .EXAMPLE
    Select-AllObjects
    .EXAMPLE
    Sel
    #>

    Param ()

        Select-Object *


}

New-Alias -Name Sel -Value Select-AllObjects