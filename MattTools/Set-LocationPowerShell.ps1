function Set-LocationPowerShell {

    <#
    .SYNOPSIS
    Set location to my PowerShell Path
    .DESCRIPTION
    Function to check if my PowerShell path exists then create a PSDrive to the PowerShell and set the location to PSH:. Function can also be called by typing PSH or PSH:
    .PARAMETER PowerShell
    The -PowerShell parameter allows you to supply the path to your PowerShell folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationPowerShell
    .EXAMPLE
    PSH:
    .EXAMPLE
    PSH
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

    # Test if the $PowerShell path is valid
    if (Test-Path "$PowerShell") {

        # Create the PSH PSDrive
        New-PSDrive -Name PSH -PSProvider FileSystem -Root "$PowerShell" -Description "PSH" | Out-Null
        
        # Set the location to the PSH drive
        Set-Location PSH:
    
    }

}

New-Alias -Name PSH: -Value Set-LocationPowerShell
New-Alias -Name PSH -Value Set-LocationPowerShell
