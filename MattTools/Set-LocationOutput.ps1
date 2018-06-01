function Set-LocationOutput {

    <#
    .SYNOPSIS
    Set location to Output
    .DESCRIPTION
    Function to check if my Output path exists then create a PSDrive to the Output and set the location to Output:. Function can also be called by typing Output or Output:
    .PARAMETER Output
    The -Output parameter allows you to supply the path to your Output folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationOutput
    .EXAMPLE
    Output:
    .EXAMPLE
    Output
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $Output = "C:\Scripts\Output"

    )

    # Validation of the Output variable
    try {
        # Validate if the Output location is valid
        Test-Path -Path $Output -ErrorAction Stop | Out-Null
    }
    catch {
        # Throws the script if the supplied Output location is not valid
        throw "The supplied Output path does not appear to exist"
    }

    # Test if the $Output path is valid
    if (Test-Path "$Output") {
        
        # Create the Output PSDrive
        New-PSDrive -Name Output -PSProvider FileSystem -Root "$Output" -Description "Output" | Out-Null
        
        # Set the location to the Output drive
        Set-Location Output:

    }

}

New-Alias -Name Output: -Value Set-LocationOutput
New-Alias -Name Output -Value Set-LocationOutput
