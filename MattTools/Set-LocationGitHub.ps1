function Set-LocationGitHub {

    <#
    .SYNOPSIS
    Set location to GitHub
    .DESCRIPTION
    Function to check if my GitHub path exists then create a PSDrive to the GitHub and set the location to Git:. Function can also be called by typing Git:
    .PARAMETER GitHub
    The -GitHub parameter allows you to supply the path to your GitHub folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationGitHub
    .EXAMPLE
    Git:
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $GitHub = "C:\GitHub"

    )

    # Validation of the GitHub variable
    try {
        # Validate if the GitHub location is valid
        Test-Path -Path $GitHub -ErrorAction Stop | Out-Null
    }
    catch {
        # Throws the script if the supplied GitHub location is not valid
        throw "The supplied GitHub path does not appear to exist"
    }


    if (Test-Path "$GitHub") {
        New-PSDrive -Name Git -PSProvider FileSystem -Root "$GitHub" -Description "Git" | Out-Null
        Set-Location Git:
    }

}

New-Alias -Name Git: -Value Set-LocationGitHub
