function Start-TcPing {

    <#
    .SYNOPSIS
    Run TcPing with -t specified as a default argument
    .DESCRIPTION
    This function wraps around TcPing supplying the-t argument to always ping non-stop
    .PARAMETER Address
    The -Address parameter is for supplying the IP address or hostname you wish to test
    .PARAMETER Port
    The -Port parameter supplies the TCP port that you want to test
    .EXAMPLE
    Start-TcPing test.domain.com 443
    .EXAMPLE
    tp 1.1.1.1 80
    .NOTES
    Function supports the alias tp
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Address,
        [Parameter(Mandatory = $true)]
        [Int32]$Port

    )

    tcping -4 -t $Address $Port


}

New-Alias -Name Tp -Value Start-TcPing
