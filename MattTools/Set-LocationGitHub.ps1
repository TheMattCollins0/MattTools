function Set-LocationGitHub {

    <#
    .SYNOPSIS
    Set location to GitHub
    .DESCRIPTION
    Function to check if my GitHub path exists then set the prompts location to the path. Function can also be called by typing Git:
    .PARAMETER GitHub
    The -GitHub parameter allows you to supply the path to your GitHub folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationGitHub
    .EXAMPLE
    Git:
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $GitHub = "C:\GitHub"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $GitHub path successful")) {     

        # Test if the $GitHub path is valid
        if (Test-Path "$GitHub") {
            # Set console location to the GitHub drive
            Set-Location $GitHub
        }

        if (!Test-Path "$GitHub") {
            # Show error if the $GitHub path variable is either invalid or not accessible
            throw "Unable to move to the GitHub path, checkthat it exists and is accessible"
        }
    }
}

New-Alias -Name Git: -Value Set-LocationGitHub
