function Start-Ping {

    <#
    .SYNOPSIS
    Run Ping with -t specified as a default argument
    .DESCRIPTION
    This function wraps around Ping supplying the-t argument to always ping non-stop and the -4 argument to always use IP V4
    .PARAMETER Address
    The -Address parameter is for supplying the IP address or hostname you wish to ping
    .EXAMPLE
    Start-Ping test.domain.com
    .EXAMPLE
    P 1.1.1.1
    .NOTES
    Function supports the alias P
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Address
    )

    ping $Address -t -4

}

New-Alias -Name P -Value Start-Ping
