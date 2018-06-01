function Set-LocationPowerShell {

    <#
    .SYNOPSIS
    Set location to my PowerShell Path
    .DESCRIPTION
    Function to check if my PowerShell path exists then create a PSDrive to the PowerShell and set the location to PS:. Function can also be called by typing PS:
    .PARAMETER PowerShell
    The -PowerShell parameter allows you to supply the path to your PowerShell folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationPowerShell
    .EXAMPLE
    PS:
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $PowerShell = "C:\GitHub\PowerShell"

    )

    # Validation of the PowerShell variable
    try {
        # Validate if the PowerShell location is valid
        Test-Path -Path $PowerShell -ErrorAction Stop | Out-Null
    }
    catch {
        # Throws the script if the supplied PowerShell location is not valid
        throw "The supplied PowerShell path does not appear to exist"
    }

    if (Test-Path "$PowerShell") {
        New-PSDrive -Name PS -PSProvider FileSystem -Root "$PowerShell" -Description "PS" | Out-Null
        Set-Location PS:
    }

}

New-Alias -Name PS: -Value Set-LocationPowerShell
