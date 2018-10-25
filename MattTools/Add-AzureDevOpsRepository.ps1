function Add-AzureDevOpsRepository {

    #Requires -Modules BetterCredentials

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)]
        $RepositoryName,

        [Parameter(Mandatory = $true)]
        $Username,

        [Parameter(Mandatory = $true)]
        $PAT,

        [Parameter(Mandatory = $true)]
        $RepositoryURL
    )

    begin {
        # Creation of credentials in the Windows Credential Vault using BetterCredentials
        Write-Verbose -Message "Adding the credentials to the Credential Vault"
        BetterCredentials\Get-Credential -Username $Username -Password $PAT -Store -ErrorAction SilentlyContinue | Out-Null

        # Check that the credentials were created successfully
        try {
            Write-Verbose -Message "Testing if the credentials are available in the Credential Vault"
            $Credentials = BetterCredentials\Get-Credential -Username NodePAT -ErrorAction Stop
        }
        catch {
            throw "Unable to retrive the credentials, please check they were stored successfully. Try running BetterCredentials\Get-Credential again manually"
        }
        Write-Verbose -Message "The credentials appear to have been created successfully in the $Credentials variable. Checking for repository existence now"

        # Check to see if there is a repository already registered with the same name
        $RepositoryCheck = Get-PSRepository -Name $RepositoryName
        if (!$RepositoryCheck) {
            Write-Verbose -Message "There is not another repository with the same name, proceeding to the creation now"
        }
        else {
            throw "A repository with the same name is already registered, please remove the conflict then run this command again"
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
