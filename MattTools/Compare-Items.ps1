function Compare-Items {

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $OriginalFile,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $CompareFile
    )

    Write-Verbose "Importing the content of the original file"
    $OriginalFileImport = Get-Content $OriginalFile

    Write-Verbose "Importing the content of the comparison file"
    $CompareFileImport = Get-Content $CompareFile

    Compare-Object $OriginalFileImport $CompareFileImport
}
