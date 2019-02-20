function Find-NodeModule {

    #Requires -Modules BetterCredentials

    <#
    .SYNOPSIS
    Find module or modules in an Azure Artifacts repository
    .DESCRIPTION
    This function wraps around the Find-Module function. It uses BetterCredentials module to secure authentication to the feed and reduce installation effort
    .PARAMETER Name
    This parameter specifies the name of the module you wish to find
    .PARAMETER Repository
    This parameter specifies the name of the Repository that you want to search. This parameter defaults to NodePowerShell
    .EXAMPLE
    Find-NodeModule -Name MODULENAME -Repository REPOSITORYNAME
    .EXAMPLE
    Find-NodeModule
    .EXAMPLE
    Find-NodeModule -Repository REPOSITORYNAME
    .NOTES
    This function also supports the -Verbose parameter for more console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Name,
        [Parameter(Mandatory = $false)]
        [string] $Repository = "NodePowerShell"
    )

    begin {

        if ( $Name ) {

            Write-Verbose -Message "A module name has been specified, finding this module in the specified repository"

        }
        elseif ( !$Name ) {

            Write-Verbose -Message "A module name has not been specified, searching for all available modules in the specified repository"

        }

        # Username variable generation
        $Username = "NodePAT"

        # Import the Azure Artifacts feed credentials using BetterCredentials
        # Check that the credentials were created successfully
        try {
            Write-Verbose -Message "Testing if the credentials are available in the Credential Vault"
            $Credentials = BetterCredentials\Get-Credential -Username $Username -ErrorAction Stop
        }
        catch {
            throw "Unable to retrive the credentials, please check they were stored successfully using the Add-ArtifactsCredential function"
        }

        Write-Verbose -Message 'The credentials have been imported by BetterCredentials successfully. Checking for repository existence now'

        # Check to see if the repository already exists
        $RepositoryCheck = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue
        if ($RepositoryCheck) {
            Write-Verbose -Message "The repository exists, it is possible to find modules in this location"
        }
        else {
            throw "The specified repository has not been added to PowerShell, please add the repository then try again."
        }

    }

    process {

        if ( $Name ) {
            # Search for specific module
            try {
                Write-Verbose -Message "Finding the module now"
                Find-Module -Name $Name -Repository $Repository -Credential $Credentials -ErrorAction Stop
            }
            catch {
                throw "Unable to find the module, please check that the module and repository names are correct"
            }
        }
        elseif ( !$Name ) {
            # Search for all modules in a repository
            try {
                Write-Verbose -Message "Finding any modules"
                Find-Module -Repository $Repository -Credential $Credentials -ErrorAction Stop
            }
            catch {
                throw "Unable to find any modules, please check that there are modules published to this repository"
            }
        }

    }
}
