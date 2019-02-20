function Add-NodeRepository {

    #Requires -Modules BetterCredentials

    <#
    .SYNOPSIS
    Registers Azure Nuget feed as a repository
    .DESCRIPTION
    Registers an Azure Package Management NuGet feed to PowerShell as a repository. This uses BetterCredentials access the repository credentials stored in the Windows Credential Vault
    .PARAMETER Repository
    This is the name you want the repository to be registered with
    .EXAMPLE
    Add-NodeRepository -Repository TestRepository -Verbose
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

        # Creation of the RepositoryURL variable from the Repository parameter
        $RepositoryURL = "https://pkgs.dev.azure.com/MattNodeIT/_packaging/" + $Repository + "/nuget/v2"

        # Username variable generation
        $Username = "NodePAT"

        # Check that the credentials were created successfully
        try {
            Write-Verbose -Message "Testing if the credentials are available in the Credential Vault"
            $Credentials = BetterCredentials\Get-Credential -Username $Username -ErrorAction Stop
        }
        catch {
            throw "Unable to retrive the credentials, please check they were stored successfully using the Add-ArtifactsCredential function"
        }

        Write-Verbose -Message 'The credentials have been stored successfully in the $Credentials variable. Checking for repository existence now'

        # Check to see if there is a repository already registered with the same name
        $RepositoryCheck = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue
        if (!$RepositoryCheck) {
            Write-Verbose -Message "There is not another repository with the same name, proceeding to the creation now"
        }
        else {
            throw "A repository with the same name is already registered, please remove the conflict then run this command again"
        }

        # Test for then install the Nuget PowerShell Package Provider
        try {
            Write-Verbose -Message "Trying to get the Nuget package provider"
            Get-PackageProvider -Name NuGet -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Verbose -Message "Installing the Nuget package provider in the CurrentUser scope"
            Install-PackageProvider -Name NuGet -MinimumVersion 3.0.0.1 -Force -Scope:CurrentUser | Out-Null
        }

        # Variable creations
        $NugetUsername = $Credentials.Username
        $PAT = $Credentials.Password

    }

    process {

        # Addition of the NuGet source for the repository
        NuGet Sources Add -Name $Repository -Source $RepositoryURL -Username $NugetUsername -Password $PAT | Out-Null

        Write-Verbose -Message "Beginning the repository registration process now"

        $RepositoryRegistrationSplat = @{
            Name                      = $Repository
            SourceLocation            = $RepositoryURL
            PublishLocation           = $RepositoryURL
            InstallationPolicy        = 'Trusted'
            PackageManagementProvider = 'Nuget'
            Credential                = $Credentials
        }

        Register-PSRepository @RepositoryRegistrationSplat
    }
}
