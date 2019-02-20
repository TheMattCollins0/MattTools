function Remove-NodeRepository {

    <#
    .SYNOPSIS
    Removes a repository registered against an Azure Artifacts feed
    .DESCRIPTION
    Removes an Azure Package Management NuGet feed from PowerShell's repositories.
    .PARAMETER Repository
    This is the name of the repository you want to remove
    .EXAMPLE
    Remove-NodeRepository -Repository TestRepository
    .NOTES
    This function also supports the -Verbose parameter to show more detailed console output
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Repository
    )

    begin {

        # Download the Nuget executable using the Get-NugetExe function
        Get-NugetExe

        Write-Verbose -Message 'Checking for repository existence now'

        # Check to see if there is a repository already registered with the same name
        $RepositoryCheck = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue
        if (!$RepositoryCheck) {
            throw "There is not a registered repository with the specified name, please check the spelling or availability of the repository"
        }
        else {
            Write-Verbose -Message  "The specified name is registered as a repository, proceeding with the removal now"
        }

    }

    process {

        # Addition of the NuGet source for the repository
        NuGet Sources Remove -Name $Repository | Out-Null

        Write-Verbose -Message "Beginning the repository registration process now"

        # Run the command to unregister the repository
        try {
        Unregister-PSRepository -Name $Repository
        }
        catch {
            throw "Unable to remove the repository, check that it is possible to remove it"
        }
    }
}
