function Add-ArtifactsCredential {

    #Requires -Modules BetterCredentials

    <#
    .SYNOPSIS
    Azure Artifacts credentials creation
    .DESCRIPTION
    Adds the credentials required to add an Azure Artifacts feed as a repository. The credentials are stored in credential manager using the BetterCredentials module
    .PARAMETER PAT
    The PAT is generated within Azure DevOps. Is is best to create a new PAT with only read access to Package Management to prevent misuse of the credentials
    .EXAMPLE
    Add-ArtifactsCredential -PAT wdadmineig2u5ng8e3s6h
    .EXAMPLE
    Add-ArtifactsCredential -PAT wdadmineig2u5ng8e3s6h
    .NOTES
    This function also supports the -Verbose parameter to show more detailed console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $PAT
    )

    begin {

        $Username = "NodePAT"

    }

    process {

        # Creation of credentials in the Windows Credential Vault using BetterCredentials
        Write-Verbose -Message "Adding the credentials to the Credential Vault"
        try {
            BetterCredentials\Get-Credential -Username $Username -Password $PAT -Store -Force | Out-Null
        }
        catch {
            throw "Unable to create the credentials, please try the BetterCredentials creation manually"
        }

    }
}
