function Set-LocationPowerShell {

    <#
    .SYNOPSIS
    Set location to my PowerShell Path
    .DESCRIPTION
    Function to check if my PowerShell path exists then create a PSDrive to the PowerShell and set the location to PSH:. Function can also be called by typing PH
    .PARAMETER PowerShell
    The -PowerShell parameter allows you to supply the path to your PowerShell folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationPowerShell
    .EXAMPLE
    PH
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $PowerShell = "C:\GitHub\PowerShell"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $PowerShell path successful")) {     
        # Test if the $PowerShell path is valid
        if (Test-Path "$PowerShell") {
            # Set console location to the PowerShell drive
            Set-Location $PowerShell
        }
        else {
            # Show error if the $PowerShell path variable is either invalid or not accessible
            throw "Unable to move to the PowerShell path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name PH -Value Set-LocationPowerShell
