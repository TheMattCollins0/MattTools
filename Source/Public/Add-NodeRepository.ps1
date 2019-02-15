function Add-NodeRepository {

    #Requires -Modules BetterCredentials

    <#
    .SYNOPSIS
    Registers Azure Nuget feed as a repository
    .DESCRIPTION
    Registers an Azure Package Management nuget feed to PowerShell as a repository. This uses BetterCredentials access the repository credentials stored in the Windows Credential Vault
    .PARAMETER RepositoryName
    This is the name you want the repository to be registered with
    .PARAMETER Username
    This is the username that the Azure Artifacts PAT is stored in Credential Manager using. This is to allow retrieval of the credentials using BetterCredentials
    .PARAMETER FeedName
    This is the name of the Azure Artifacts feed for the repository
    .EXAMPLE
    Add-NodeRepository -RepositoryName TestRepository -Username UsernameHere -FeedName FeedName -Verbose
    .NOTES
    This function also supports the -Verbose parameter to show more detailed console output
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)]
        $RepositoryName,
        [Parameter(Mandatory = $true)]
        $Username,
        [Parameter(Mandatory = $true)]
        $FeedName
    )

    begin {

        # Creation of the RepositoryURL variable from the FeedName parameter
        $RepositoryURL = "https://pkgs.dev.azure.com/MattNodeIT/_packaging/" + $FeedName + "/nuget/v2"

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
        $RepositoryCheck = Get-PSRepository -Name $RepositoryName -ErrorAction SilentlyContinue
        if (!$RepositoryCheck) {
            Write-Verbose -Message "There is not another repository with the same name, proceeding to the creation now"
        }
        else {
            throw "A repository with the same name is already registered, please remove the conflict then run this command again"
        }

        # Test for then install the Nuget PowerShell Package Provider
        try {
            Write-Verbose -Message "Trying to get the Nuget package provider"
            Get-PackageProvider -Name NuGet -ErrorAction Stop
        }
        catch {
            Write-Verbose -Message "Installing the Nuget package provider in the CurrentUser scope"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope:CurrentUser | Out-Null
        }

    }

    process {

        Write-Verbose -Message "Beginning the repository registration process now"

        $RepositoryRegistrationSplat = @{
            Name                      = $RepositoryName
            SourceLocation            = $RepositoryURL
            PublishLocation           = $RepositoryURL
            InstallationPolicy        = 'Trusted'
            PackageManagementProvider = 'Nuget'
            Credential                = $Credentials
            Verbose                   = $true
        }

        Register-PSRepository @RepositoryRegistrationSplat
    }
}
