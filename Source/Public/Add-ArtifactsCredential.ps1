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
    .EXAMPLE
    Add-ArtifactsCredential -PAT wdadmineig2u5ng8e3s6h
    .EXAMPLE
    Add-ArtifactsCredential -Username UsernameHere -PAT wdadmineig2u5ng8e3s6h
    .NOTES
    This function also supports the -Verbose parameter to show more detailed console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Username = "NodePAT",
        [Parameter(Mandatory = $true)]
        [string] $PAT
    )

    begin {

        $CredentialCheck = BetterCredentials\Get-Credential -Username $Username -ErrorAction SilentlyContinue
        if ( !$CredentialCheck ) {
            Write-Verbose -Message "There are no credentials stored with the specified username, proceeding with the creation"
        }
        else {
            throw "An entry in Credential Manager already exists for the specified username. To recreate them, please delete the entry from Credential Manager"
        }
        Write-Verbose -Message 'The credential check has completed successfully, proceeding to the credential creations now'

    }

    process {

        # Creation of credentials in the Windows Credential Vault using BetterCredentials
        Write-Verbose -Message "Adding the credentials to the Credential Vault"
        try {
            BetterCredentials\Get-Credential -Username $Username -Password $PAT -Store -ErrorAction Stop
        }
        catch {
            throw "Unable to create the credentials, please try the BetterCredentials creation manually"
        }
    }
}
