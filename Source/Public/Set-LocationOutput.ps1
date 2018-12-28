function Set-LocationOutput {

    <#
    .SYNOPSIS
    Set location to Output
    .DESCRIPTION
    Function to check if my Output path exists then create a PSDrive to the Output and set the location to Output:. Function can also be called by typing Output or Out
    .PARAMETER Output
    The -Output parameter allows you to supply the path to your Output folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationOutput
    .EXAMPLE
    Output
    .EXAMPLE
    Out
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $Output = "C:\Scripts\Output"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $Output path successful")) {     
        # Test if the $Output path is valid
        if (Test-Path "$Output") {
            # Set console location to the Output drive
            Set-Location $Output
        }
        else {
            # Show error if the $Output path variable is either invalid or not accessible
            throw "Unable to move to the Output path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name Out -Value Set-LocationOutput
New-Alias -Name Output -Value Set-LocationOutput
