function Connect-AzureDevOpsRepository {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false)]
        $ModuleFolderPath = $env:AGENT_RELEASEDIRECTORY + "\output\s\Output",

        [Parameter(Mandatory = $false)]
        $RepositoryName,

        [Parameter(Mandatory = $false)]
        $FeedUsername,

        [Parameter(Mandatory = $false)]
        $PAT
    )


    # Variables
    $packageSourceUrl = "https://pkgs.dev.azure.com/MattNodeIT/_packaging/$RepositoryName/nuget/v2" # Enter your VSTS AccountName (note: v2 Feed)

    # This is downloaded during Step 3, but could also be "C:\Users\USERNAME\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe"
    # if not running script as Administrator.
    $nugetPath = 'C:\ProgramData\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe'

    # Create credential
    $password = ConvertTo-SecureString -String $PAT -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($feedUsername, $password)


    # Step 1
    # Upgrade PowerShellGet
    # Install-Module PowerShellGet -Force
    # Remove-Module PowerShellGet -Force
    Import-Module PowerShellGet -Force


    # Step 2
    # Check NuGet is listed
    Get-PackageProvider -Name 'NuGet' -ForceBootstrap


    # Step 3
    # THIS WILL FAIL first time, so don't panic!
    # Try to Publish a PowerShell module - this will prompt and download NuGet.exe, and fail publishing the module (we publish at the end)
    $publishParams = @{
        Path        = $moduleFolderPath
        Repository  = $repositoryName
        NugetApiKey = 'VSTS'
        Verbose     = $true
        Confirm     = $false
        Force       = $true
    }
    Publish-Module @publishParams | Out-Null


    # Step 4
    # Register NuGet Package Source
    & $nugetPath Sources Add -Name $repositoryName -Source $packageSourceUrl -Username $feedUsername -Password $PAT

    # Check new NuGet Source is registered
    & $nugetPath Sources List


    # Step 5
    # Register feed
    $registerParams = @{
        Name                      = $repositoryName
        SourceLocation            = $packageSourceUrl
        PublishLocation           = $packageSourceUrl
        InstallationPolicy        = 'Trusted'
        PackageManagementProvider = 'Nuget'
        Credential                = $credential
        Verbose                   = $true
    }
    Register-PSRepository @registerParams

    # Check new PowerShell Repository is registered
    Get-PSRepository -Name $repositoryName

}
