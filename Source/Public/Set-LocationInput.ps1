function Set-LocationInput {

    <#
    .SYNOPSIS
    Set location to Input
    .DESCRIPTION
    Function to check if my Input path exists then create a PSDrive to the Input and set the location to Input: Function can also be called by typing Input or In
    .PARAMETER Input
    The -Input parameter allows you to supply the path to your Input folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationInput
    .EXAMPLE
    Input
    .EXAMPLE
    In
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $InputPath = "C:\Scripts\Input"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $InputPath path successful")) {
        # Test if the $InputPath path is valid
        if (Test-Path "$InputPath") {
            # Set console location to the InputPath drive
            Set-Location $InputPath
        }
        else {
            # Show error if the $InputPath path variable is either invalid or not accessible
            throw "Unable to move to the Input path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name Input -Value Set-LocationInput
