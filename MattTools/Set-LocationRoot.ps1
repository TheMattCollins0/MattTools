function Set-LocationRoot {

    <#
    .SYNOPSIS
    Set location to my Root Path
    .DESCRIPTION
    Function to check if my Root path exists then create a PSDrive to the root folder and set the location to C:\. Function can also be called by typing C
    .PARAMETER Root
    The -Root parameter allows you to supply the path to your root folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationRoot
    .EXAMPLE
    C
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $Root = "C:\"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $Root path successful")) {     
        # Test if the $Root path is valid
        if (Test-Path "$Root") {
            # Set console location to the Root drive
            Set-Location $Root
        }
        else {
            # Show error if the $Root path variable is either invalid or not accessible
            throw "Unable to move to the Root path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name C -Value Set-LocationRoot
