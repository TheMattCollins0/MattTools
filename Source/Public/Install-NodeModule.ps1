function Install-NodeModule {

    #Requires -Modules BetterCredentials

    <#
    .SYNOPSIS
    Install a module from an Azure Artifacts repository
    .DESCRIPTION
    This function wraps around the Install-Module function and uses BetterCredentials to secure authentication to the feed and reduce installation effort
    .PARAMETER Name
    This parameter specifies the name of the module you wish to install
    .PARAMETER Repository
    This parameter specifies the name of the Repository that you want to
    .EXAMPLE
    Install-NodeModule -Name MODULENAME -Repository REPOSITORYNAME
    .NOTES
    This function also supports the -Verbose parameter for more console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [string] $Repository
    )

    begin {

        # Import the Azure Artifacts feed credentials using BetterCredentials
        $CredentialCheck = BetterCredentials\Get-Credential -Username NodePAT -ErrorAction SilentlyContinue
        if ($CredentialCheck) {
            Write-Verbose -Message "The credentials were imported by BetterCredentials successfully"
        }
        else {
            throw "Unable to retrive the credentials, please check that they have been created"
        }
        Write-Verbose -Message 'The credentials have been imported by BetterCredentials successfully. Checking for repository existence now'

        # Check to see if the repository already exists
        $RepositoryCheck = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue
        if ($RepositoryCheck) {
            Write-Verbose -Message "The repository exists, it is possible to install the module from this location"
        }
        else {
            throw "The specified repository has not been added to PowerShell, please add the repository then try again."
        }

    }

    process {

        # Module installation
        try {
            Write-Verbose -Message "Installing the module now"
            Install-Module -Name $Name -Repository $Repository -Credential ( BetterCredentials\Get-Credential -Username NodePAT ) -Force -ErrorAction Stop
        }
        catch {
            throw "Unable to install the application, please run the command again manually"
        }


    }
}
