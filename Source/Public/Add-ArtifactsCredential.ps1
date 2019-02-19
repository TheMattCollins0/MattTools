function Add-ArtifactsCredential {

    #Requires -Modules BetterCredentials

    <#
    .SYNOPSIS
    Azure Artifacts credentials creation
    .DESCRIPTION
    Adds the credentials required to add an Azure Artifacts feed as a repository. The credentials are stored in credential manager using the BetterCredentials module
    .PARAMETER Username
    The username parameter is used when storing the credentials. The default value is NodePAT
    .PARAMETER PAT
    The PAT is generated within Azure DevOps. Is is best to create a new PAT with only read access to Package Management to prevent misuse of the credentials
    .PARAMETER RepositoryName
    Supply the repository name to initialise the NuGet Package Source
    .EXAMPLE
    Add-ArtifactsCredential -PAT wdadmineig2u5ng8e3s6h
    .EXAMPLE
    Add-ArtifactsCredential -Username UsernameHere -PAT wdadmineig2u5ng8e3s6h
    .EXAMPLE
    Add-ArtifactsCredential -PAT wdadmineig2u5ng8e3s6h -RepositoryName RepositoryName
    .NOTES
    This function also supports the -Verbose parameter to show more detailed console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Username = "NodePAT",
        [Parameter(Mandatory = $true)]
        [string] $PAT,
        [Parameter(Mandatory = $false)]
        [string] $RepositoryName
    )

    begin {
        <#
        if ( $RepositoryName ) {
            $PackageSourceUrl = "https://pkgs.dev.azure.com/MattNodeIT/_packaging/" + $RepositoryName + "/nuget/v2"
        }
        #>
    }

    process {

        # Creation of credentials in the Windows Credential Vault using BetterCredentials
        Write-Verbose -Message "Adding the credentials to the Credential Vault"
        try {
            BetterCredentials\Get-Credential -Username $Username -Password $PAT -Store -Force
        }
        catch {
            throw "Unable to create the credentials, please try the BetterCredentials creation manually"
        }

        <#
        # Trying to add the NuGet package source
        if ( $RepositoryName ) {
            NuGet Sources Add -Name $RepositoryName -Source $PackageSourceUrl -Username $Username -Password $PAT
        }
        #>
    }
}
