function Set-LocationGitHub {

    <#
    .SYNOPSIS
    Set location to GitHub
    .DESCRIPTION
    Function to check if my GitHub path exists then create a PSDrive to the GitHub and set the location to Git:. Function can also be called by typing Git or Git:
    .PARAMETER GitHub
    The -GitHub parameter allows you to supply the path to your GitHub folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationGitHub
    .EXAMPLE
    Git:
    .EXAMPLE
    Git
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $GitHub = "C:\GitHub"

    )

    if ($PSCmdlet.ShouldProcess("Creation of PSDrive pointing to $GitHub successful")) {     

        # Test if the $GitHub path is valid
        if (Test-Path "$GitHub") {
            # Set the location to the GitHub  drive
            Set-Location $GitHub
        }
        
        if (!Test-Path "$GitHub") {
            throw "Unable to move to the GitHub path, checkthat it exists and is accessible"

        }
    }
}

New-Alias -Name Git: -Value Set-LocationGitHub
# New-Alias -Name Git -Value Set-LocationGitHub
