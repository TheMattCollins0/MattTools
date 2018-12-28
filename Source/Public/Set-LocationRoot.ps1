function Set-LocationRoot {

    <#
    .SYNOPSIS
    Set location to the root path
    .DESCRIPTION
    Function to check if the root path exists and sets the location to the root folder  Function can also be called by typing C
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
