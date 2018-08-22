function Compare-Items {

    <#
    .SYNOPSIS
    Compares contents of two .txt files
    .DESCRIPTION
    This function wraps around the Compare-Object file, to display differences between two files. It forces you to supply the two files as parameters. The function currently works best on text or csv files with only one column
    .PARAMETER OriginalFile
    This parameter specifies the location of the first file you want to compare
    .PARAMETER CompareFile
    This parameter specifies the location of the second file you want to compare
    .EXAMPLE
    Compare-Items -OriginalFile "C:\Scripts\Input\FileOne.txt" -CompareFile "C:\Scripts\Input\FileTwo.txt"
    .NOTES
    This function also supports the -Verbose parameter for more console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $OriginalFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $CompareFile
    )

    begin {

        # Running checks to test that the file extensions match and that they are both .txt files
        Write-Verbose "Getting the file information for the original file"
        $OriginalFileCheck = Get-ChildItem $OriginalFile | Select-Object *

        Write-Verbose "Getting the file information for the compare file"
        $CompareFileCheck = Get-ChildItem $CompareFile | Select-Object *

        # Comparing the file extensions to check that they match
        $FileExtensionComparison = Compare-Object $OriginalFileCheck.Extension $CompareFileCheck.Extension

        if ( $Null -ne $FileExtensionComparison) {
            throw "The file extensions do not match, ensure the file extensions match before attempting again"
        }
        else {
            Write-Verbose "Both file extensions match, continuing the file checks"
        }

        if ( $OriginalFileCheck.Extension -ne ".txt" -or $CompareFileCheck.Extension -ne ".txt" ) {
            throw "Supplied file extensions are not .txt, change to .txt and try the comparison again"
        }
        else {
            Write-Verbose "Both file extensions are .txt, continuing with the script now. Running the comparison now"
        }

    }

    process {
        Write-Verbose "Importing the content of the original file"
        $OriginalFileImport = Get-Content $OriginalFile

        Write-Verbose "Importing the content of the comparison file"
        $CompareFileImport = Get-Content $CompareFile

        Compare-Object -ReferenceObject $OriginalFileImport -DifferenceObject $CompareFileImport

    }
}
