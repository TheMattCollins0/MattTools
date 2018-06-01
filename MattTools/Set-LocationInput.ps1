function Set-LocationInput {

    <#
    .SYNOPSIS
    Set location to Input
    .DESCRIPTION
    Function to check if my Input path exists then create a PSDrive to the Input and set the location to Input:. Function can also be called by typing Input or Input:
    .PARAMETER Input
    The -Input parameter allows you to supply the path to your Input folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationInput
    .EXAMPLE
    Input:
    .EXAMPLE
    Input
    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $Input = "C:\Scripts\Input"

    )

    # Validation of the Input variable
    try {
        # Validate if the Input location is valid
        Test-Path -Path $Input -ErrorAction Stop | Out-Null
    }
    catch {
        # Throws the script if the supplied Input location is not valid
        throw "The supplied Input path does not appear to exist"
    }

    # Test if the $Input path is valid
    if (Test-Path "$Input") {
        
        # Create the Input PSDrive
        New-PSDrive -Name Input -PSProvider FileSystem -Root "$Input" -Description "Input" | Out-Null
        
        # Set the location to the Input drive
        Set-Location Input:

    }

}

New-Alias -Name Input: -Value Set-LocationInput
New-Alias -Name Input -Value Set-LocationInput
