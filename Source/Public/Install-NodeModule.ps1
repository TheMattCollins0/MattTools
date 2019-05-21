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
    This parameter specifies the name of the Repository that you want to install the module from. This parameter defaults to the value NodePowerShell
    .EXAMPLE
    Install-NodeModule -Name MODULENAME -Repository REPOSITORYNAME
    .NOTES
    This function also supports the -Verbose parameter for more console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $false)]
        [string] $Repository = "NodePowerShell"
    )

    begin {

        # Username variable generation
        $Username = "NodePAT"

        # Import the Azure Artifacts feed credentials using BetterCredentials
        # Check that the credentials were created successfully
        try {
            Write-Verbose -Message "Testing if the credentials are available in the Credential Vault"
            $Credentials = BetterCredentials\Get-Credential -Username $Username -ErrorAction Stop
        }
        catch {
            throw "Unable to retrieve the credentials, please check they were stored successfully using the Add-ArtifactsCredential function"
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
            Install-Module -Name $Name -Repository $Repository -Credential $Credentials -Scope CurrentUser -Force -ErrorAction Stop
        }
        catch {
            throw "Unable to install the application, please run the command again manually"
        }


    }
}
