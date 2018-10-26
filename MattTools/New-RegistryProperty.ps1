function New-RegistryProperty {
    <#
    .SYNOPSIS
    Creates a new registry property
    .DESCRIPTION
    This function takes the supplied path, name, values and property type then creates the corresponding property in the registry
    .PARAMETER Path
    Specifies the path that you wish to create
    .PARAMETER Name
    Specifies the name of the new property
    .PARAMETER Value
    Specifies the value of the new registry property
    .PARAMETER PropertyType
    Specifies the PropertyType of the property
    .EXAMPLE
    New-RegistryProperty -Path "HKLM:\SOFTWARE\NodeIT" -Name Testing -Value "This is the property value" -PropertyType String
    .NOTES
    This function does not currently show any output
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string[]]$Path,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string[]]$Name,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string[]]$Value,
        
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "Qword")]
        [string[]]$PropertyType
    )

    begin {
        ## Path parameter checking
        # Check that the $Path variable exists
        if ( $null -eq $Path ) {
            throw "Please specify the registry path for creation"
        }

        # Check that the path starts with either HKLM or HKCU
        $HKCUCheck = $Path.StartsWith("HKCU:\")
        $HKLMCheck = $Path.StartsWith("HKLM:\")

        # Throw the script if both $HKCUCheck and $HKLMCheck are False
        if ( $HKCUCheck -eq "False" -and $HKLMCheck -eq "False" ) {
            throw "Please supply a path that begins with either HKLM:\ or HKCU:\ and try again"
        }

        # Check if the path already exists
        if ((Test-Path $Path)) {
            throw "The specified path already exists, please supply an alternative path"
        }

        ## Name parameter checking
        # Check if a property with the same name already exists
        $NameChecking = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue

        # Throw function if a property with the same name is found
        if ( $NameChecking ) {
            throw "A property with the same name already exists in the specified location"
        }
    }

    process {
        # Create the specified registry property
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force | Out-Null
    }

}
