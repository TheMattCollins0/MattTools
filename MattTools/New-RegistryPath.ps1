function New-RegistryPath {

    <#
    .SYNOPSIS
    Creates a new registry path
    .DESCRIPTION
    This function takes the supplied path and creates it in the registry
    .PARAMETER Path
    Specifies the path that you wish to create
    .EXAMPLE
    New-RegistryPath -Path "HKLM:\SOFTWARE\NodeIT"
    .NOTES
    This function does not currently show any output
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Path
    )

    begin {
        # Check that the $Path variable exists
        if ( $null -eq $Path ) {
            Write-Error -Message "Please specify the registry path for creation" -Category OperationStopped
        }
        # Check that the path starts with either HKLM or HKCU
        $HKCUCheck = $Path.StartsWith("HKCU:\")
        $HKLMCheck = $Path.StartsWith("HKLM:\")

        # Throw the script if both $HKCUCheck and $HKLMCheck are False
        if ( $HKCUCheck -eq "False" -and $HKLMCheck -eq "False" ) {
            Write-Error -Message "Please supply a path that begins with either HKLM:\ or HKCU:\ and try again" -Category OperationStopped
        }

        # Check if the path already exists
        if ((Test-Path $Path)) {
            Write-Error -Message "The specified path already exists, please supply an alternative path" -Category OperationStopped
        }
    }

    process {
        # Create the specified registry path
        New-Item -Path $Path -Force | Out-Null
    }
}
