function Get-NugetExe {

    [CmdletBinding()]
    param ()

    # Function to download the NuGet executable to C:\ProgramData\Node\Nuget\nuget.exe

    $nugetPath = "C:\ProgramData\Node\Nuget"
    if (!(Test-Path -Path $nugetPath)) {
        Write-Verbose -Message "Creating directory $nugetPath"
        New-Item -Path $nugetPath -ItemType Directory | Out-Null
    }
    Write-Verbose -Message "Working Folder : $nugetPath"
    $NugetExe = "$nugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Verbose -Message "Cannot find nuget at $NugetExe"
        $NuGetInstallUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $sourceNugetExe = $NuGetInstallUri
        Write-Verbose -Message "$sourceNugetExe -OutFile $NugetExe"

        Invoke-WebRequest $sourceNugetExe -OutFile $NugetExe | Out-Null
        if (-not (Test-Path $NugetExe)) {
            Throw "Nuget download hasn't worked."
        }
        Else {Write-Verbose -Message "Nuget Downloaded!"}
    }
    Write-Verbose -Message "Add $nugetPath as %PATH%"
    $pathenv = [System.Environment]::GetEnvironmentVariable("path")
    $pathenv = $pathenv + ";" + $nugetPath
    [System.Environment]::SetEnvironmentVariable("path", $pathenv)

}
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
function Add-NodeRepository {

    #Requires -Modules BetterCredentials

    <#
    .SYNOPSIS
    Registers Azure Nuget feed as a repository
    .DESCRIPTION
    Registers an Azure Package Management NuGet feed to PowerShell as a repository. This uses BetterCredentials access the repository credentials stored in the Windows Credential Vault
    .PARAMETER Repository
    The name of the repository being registered
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
        $RepositoryURL = "https://pkgs.dev.azure.com/NodeIT/_packaging/" + $Repository + "/nuget/v2"

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

        # Credentials variable creations
        $NuGetUsername = $Credentials.Username
        $NuGetPAT = $Credentials.Password

    }

    process {

        # Testing if the Nuget source is already registered and addition of the source if it doesn't exist
        $NugetSourceTesting = nuget sources List | Select-String -Pattern $Repository -Quiet
        if ( !$NugetSourceTesting ) {
            Nuget Sources Add -Name $Repository -Source $RepositoryURL -Username $NuGetUsername -Password $NuGetPAT | Out-Null
        }
        elseif ( $NugetSourceTesting ) {
            Write-Verbose -Message "The nuget source already exists, skipping the source addition step"
        }

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
function Compare-Items {

    <#
    .SYNOPSIS
    Compares contents of two .txt files
    .DESCRIPTION
    This function wraps around the Compare-Object file, to display differences between two files. It forces you to supply the two files as parameters. The function currently works best on text or csv files with only one column
    .PARAMETER OriginalFile
    This parameter specifies the location of the first file you want to compare
    .PARAMETER CompareFile
    This parameter specifies the location of the second file you want to compare
    .EXAMPLE
    Compare-Items -OriginalFile "C:\Scripts\Input\FileOne.txt" -CompareFile "C:\Scripts\Input\FileTwo.txt"
    .NOTES
    This function also supports the -Verbose parameter for more console output
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $OriginalFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $CompareFile
    )

    begin {

        # Running checks to test that the file extensions match and that they are both .txt files
        Write-Verbose "Getting the file information for the original file"
        $OriginalFileCheck = Get-ChildItem $OriginalFile | Select-Object *

        Write-Verbose "Getting the file information for the compare file"
        $CompareFileCheck = Get-ChildItem $CompareFile | Select-Object *

        # Comparing the file extensions to check that they match
        $FileExtensionComparison = Compare-Object $OriginalFileCheck.Extension $CompareFileCheck.Extension

        if ( $Null -ne $FileExtensionComparison) {
            throw "The file extensions do not match, ensure the file extensions match before attempting again"
        }
        else {
            Write-Verbose "Both file extensions match, continuing the file checks"
        }

        if ( $OriginalFileCheck.Extension -ne ".txt" -or $CompareFileCheck.Extension -ne ".txt" ) {
            throw "Supplied file extensions are not .txt, change to .txt and try the comparison again"
        }
        else {
            Write-Verbose "Both file extensions are .txt, continuing with the script now. Running the comparison now"
        }

    }

    process {
        Write-Verbose "Importing the content of the original file"
        $OriginalFileImport = Get-Content $OriginalFile

        Write-Verbose "Importing the content of the comparison file"
        $CompareFileImport = Get-Content $CompareFile

        $Comparison = Compare-Object -ReferenceObject $OriginalFileImport -DifferenceObject $CompareFileImport

    }

    end {

        # Write message to console if there are no differences, or show found differences
        if ( $Null -eq $Comparison ) {
            Write-Host "There are no differences in the specified text files"
        }
        elseif ( $Comparison ) {
            $Comparison
        }

    }
}
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
    Find-NodeModule
    .EXAMPLE
    Find-NodeModule -Repository REPOSITORYNAME
    .EXAMPLE
    Find-NodeModule -Name MODULENAME -Repository REPOSITORYNAME
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
function Get-LastCmdTime {

    <#
    .SYNOPSIS
    Outputs the execution time of the the last command in history.
    .DESCRIPTION
    Calculates and outputs the time difference of the last command in history.
    The difference will be outputted in a "human" format if the Humanizer module
    (https://www.powershellgallery.com/packages/PowerShellHumanizer/2.0) is
    installed.
    .EXAMPLE
    Outputs the execution time of the the last command in history.
    Get-LastCmdTime.
    .NOTES
    Returns $null if the history buffer is empty.
    Thanks go to - https://gist.github.com/kelleyma49/bd03dfa82c37438a01b1 - for this function
    #>
        $diffPromptTime = $null

        $lastCmd = Get-History -Count 1
        if ($lastCmd -ne $null) {
            $diff = $lastCmd.EndExecutionTime - $lastCmd.StartExecutionTime
            try {
                # assumes humanize has been installed:
                $diffPromptTime = $diff.Humanize()
            }
            catch {
                $diffPromptTime = $diff.ToString("hh\:mm\:ss")
            }
            $diffPromptTime
        }
}
function Get-MattHelp {

    <#
    .SYNOPSIS
    Help function
    .DESCRIPTION
    This function is purely used to write general help information to the PowerShell console
    .EXAMPLE
    Get-MattHelp
    #>

    [CmdletBinding()]
    param ()

    Write-Host ""
    Write-Host "Type Connect-EOnline to connect to a clients Office 365 or Azure AD"
    Write-Host "You need to supply Office 365 Global Admin credentials for each client you want to connect to"
    Write-Host ""
    Write-Host "Type Connect-Client to open a GUI showing a list of clients you can connect to Office 365 as"
    Write-Host "If you know the name of the client, you can type Connect-Client -ClientName ClientName or Connect-Client -Name ClientName"
    Write-Host ""
    Write-Host "Type Exit-EOnline to disconnect from Office 365 and close the PowerShell console"
    Write-Host ""
    Write-Host ""
    Write-Host "Commonly used commands:"
    Write-Host "UserA is always the sharing user. UserB is always the user requesting access"
    Write-Host "Always try to supply the users UserPrincipalName in any commands"
    Write-Host ""
    Write-Host "Add full access to mailbox without automapping"
    Write-Host 'Add-MailboxPermission -Identity "UserA" -User "UserB" -AccessRights FullAccess -AutoMapping:$false'
    Write-Host ""
    Write-Host "Set single users password to never expire"
    Write-Host 'Set-MsolUser -UserPrincipalName "" -PasswordNeverExpires:$true'
    Write-Host ""
    Write-Host "Assign calendar permissions to a user"
    Write-Host 'Add-MailboxFolderPermission -Identity "UserA:\Calendar" -AccessRights PublishingEditor -User "UserB"'
    Write-Host ""
    Write-Host "List the number of Office 365 licences in use"
    Write-Host "Get-MSOLAccountSku"
    Write-Host ""
    Write-Host "Update my Node Office365Connect PowerShell module"
    Write-Host 'Install-Module -Repository NodePowerShellRepository Office365Connect -Verbose -Scope CurrentUser -Force'
    Write-Host ""
    Write-Host ""
    Write-Host "Commands from MattTools:"
    Write-Host "Use Invoke-MattPlaster to create a Plaster Template, follow prompts for ModuleName and ModuleDescription"
    Write-Host ""
    Write-Host "Install-Module -Repository NodePowerShellRepository -Name ModuleName -Scope CurrentUser -Force"
    Write-Host ""
    Write-Host "Run either Start-PowerShellAsSystem or Sys from an elevated PowerShell console to open a new PowerShell console running as System"
    Write-Host "This command requires that PsExec is installed to the system path environmental variable. Install SysInternals using Chocolatey"
    Write-Host ""
    Write-Host "Run either Start-Ping or P and supply an IP address or hostname to ping continuously"
    Write-Host ""
    Write-Host "Run either Start-TcPing or TP and supply an IP address or hostname and a TCP port number to ping the TCP port continuously"
    Write-Host ""

}

New-Alias -Name GMH -Value Get-MattHelp
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
        $RepositoryCheck = Get-PSRepository -Name $Repository -ErrorAction Ignore
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
function Invoke-MattPlaster {

    <#
    .SYNOPSIS
    Module creation function
    .DESCRIPTION
    Function to automate the creation of new PowerShell modules. The module relies on Git-Scm being installed. It also replies on the Plaster and PSGitHub modules being installed from the PSGallery
    .PARAMETER GitHubUserName
    The -GitHubUserName parameter allows you to supply your GitHub username 
    .PARAMETER GitHubPath
    The -GitHubPath parameter allows you to supply the path to your GitHub folder. If the folder does not exist, You will see an error
    .PARAMETER ModuleName
    The -ModuleDescription parameter supplies the name of your new PowerShell module and GitHub repository
    .PARAMETER ModuleDescription
    The -ModuleDescription parameter supplies the description of your new PowerShell module and GitHub repository
    .EXAMPLE
    Invoke-MattPlaster -ModuleName "NameHere" -ModuleDescription "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -Name "NameHere" -Description "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -ModuleName "NameHere" -ModuleDescription "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -Name "NameHere" -Description "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -GitHubUserName YourUserNameHere -GitHubPath "C:\GitHubScripts" -ModuleName "NameHere" -ModuleDescription "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -UserName YourUserNameHere -Path "C:\GitHubScripts" -Name "NameHere" -Description "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -GitHubUserName YourUserNameHere -GitHubPath "C:\GitHubScripts" -ModuleName "NameHere" -ModuleDescription "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -UserName YourUserNameHere -Path "C:\GitHubScripts" -Name "NameHere" -Description "This is a module description"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Alias('UserName')]
        [string]
        $GitHubUserName = "TheMattCollins0",

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $GitHubPath = "C:\GitHub",

        [Parameter(Mandatory = $true, HelpMessage = "Please enter the name of the new module", ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string]
        $ModuleName,

        [Parameter(Mandatory = $true, HelpMessage = "Please provide a description for the module", ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Description')]
        [string]
        $ModuleDescription
    )
    
    # Validation of the GitHubPath variable
    try {
        # Validate if the GitHubPath location is valid
        Test-Path -Path $GitHubPath -ErrorAction Stop | Out-Null
    }
    catch {
        # Throws the script if the supplied GitHubPath location is not valid
        throw "The supplied GitHub path does not appear to exist"
    }

    # Test if the required modules are installed
    Try {
        # Testing if the PSGitHub and Plaster modules are installed
        Import-Module PSGitHub -ErrorAction Stop | Out-Null
        Import-Module Plaster -ErrorAction Stop | Out-Null
    }
    Catch {
        # Throws the script if the PSGitHub or Plaster modules are not installed
        throw "Please ensure that both the PSGitHub and Plaster modules are installed and configured"
    }

    # Test if git has been installed from git-scm.com
    Try {
        # Test if Git has been installed on the computer
        Test-Path -Path "C:\Program Files\Git" -ErrorAction Stop | Out-Null
        Test-Path -Path "C:\Program Files (x86)\Git" -ErrorAction Stop | Out-Null
    }
    Catch {
        # Launch a web browser that opens at the git-scm.com website
        Start-Process 'https://git-scm.com/download'
        # Throw the script Git cannot be found in either Program Files or Program Files x86
        throw "Please ensure that both the PSGitHub and Plaster modules are installed and configured"
    }

    # Prompt for the user to confirm if the GitHub repository will be public or private
    $RepositoryVisibilityCaption = "GitHub Repository Visibility"
    $RepositoryVisibilityMessage = "Does the GitHub repository need to be public or private?"
    $Public = new-Object System.Management.Automation.Host.ChoiceDescription "&Public", "Public"
    $Private = new-Object System.Management.Automation.Host.ChoiceDescription "p&Rivate", "Private"
    $RepositoryVisibilityChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Public, $Private)
    $RepositoryVisibility = $host.ui.PromptForChoice( $RepositoryVisibilityCaption, $RepositoryVisibilityMessage, $RepositoryVisibilityChoices, 1 )

    switch ( $RepositoryVisibility ) {
        0 { Write-Information "You entered Public"; break }
        1 { Write-Information "You entered Private"; break }
    }

    # Prompt for the user to confirm if they require a development branch creating on the GitHub repository
    $DevelopmentBranchCaption = "Development Branch Requirement"
    $DevelopmentBranchMessage = "Does the new GitHub repository require a development branch?"
    $Yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
    $No = new-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
    $DevelopmentBranchChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $DevelopmentBranch = $host.ui.PromptForChoice( $DevelopmentBranchCaption, $DevelopmentBranchMessage, $DevelopmentBranchChoices, 0 )

    switch ( $DevelopmentBranch ) {
        0 { Write-Information "A development branch is required"; break }
        1 { Write-Information "A development branch is not required"; break }
    }

    # Set current location to the path supplied in $GitHubPath
    Set-Location -Path $GitHubPath | Out-Null

    # Creation of the destination path
    $Destination = "C:\GitHub\" + $ModuleName

    # Creation of the $PlasterSplat splat
    $PlasterSplat = @{
        TemplatePath    = "C:\GitHub\PlasterTemplate"
        FullName        = "Matt Collins"
        DestinationPath = $Destination
        Version         = "0.0.1"
        ModuleName      = $ModuleName
        ModuleDesc      = $ModuleDescription
        CompanyName     = "Node IT Solutions Ltd."
    }

    # If statement to check if a Public repository was requested
    if ( $RepositoryVisibility -eq "0" ) {
        # Create the new public repository on GitHub
        New-GitHubRepository -Name $ModuleName -Description $ModuleDescription
    }

    # If statement to check if a Private repository was requested
    if ( $RepositoryVisibility -eq "1" ) {
        # Create a new private repository on GitHub
        New-GitHubRepository -Name $ModuleName -Description $ModuleDescription -Private $True
    }

    # Creation of the GitHub repository URL variable
    $GitHubRepository = "https://github.com/" + $GitHubUsername + "/" + $ModuleName + ".git"

    # Clone the GitHub repository to the local computer to the GitHub directory
    git clone $GitHubRepository

    # Initialise the GitHub repository
    git init

    # Add the GitHub remote
    git remote add origin $GitHubRepository

    # Invoke Plaster using the supplied splat
    Invoke-Plaster @PlasterSplat -Verbose

    # Change location to the newly created module directory
    Set-Location $Destination | Out-Null

    # Stage the changes made to the repository by Plaster ready to commit them
    git add --all

    # Commit the staged files up to GitHub
    git commit -m "Commit initialising the repository with files supplied by Plaster"

    # Push the commit up to the repository on GitHub
    git push origin HEAD:master

    # If statement to check if a development branch of the repository was requested
    if ( $DevelopmentBranch -eq "0" ) {    
        # Create a development branch
        git branch development

        # Checkout the development branch
        git checkout development
    }

}
function Invoke-ProfileBanner {

    <#
    .SYNOPSIS
    Show my PowerShell Profile banner
    .DESCRIPTION
    This function is purely used to write my PowerShell profile banner when I first open PowerShell
    .EXAMPLE
    Invoke-ProfileBanner
    #>

    Write-Host " **************************************************************************************************************************************************** "
    Write-Host " *                                                                                                                                                  * "
    Write-Host " *                                                    Type Get-MattHelp to view help information                                                    * "
    Write-Host " *                                                                                                                                                  * "
    Write-Host ' *                                                     Type "Gh" to change to the GitHub folder                                                     * '
    Write-Host ' *                                                   Type "Ph" to change to the PowerShell folder                                                   * '
    Write-Host " *                                                                                                                                                  * "
    Write-Host " *                                                 Type Update-MattModules to update all my modules                                                 * "
    Write-Host " *                                                                                                                                                  * "
    Write-Host " **************************************************************************************************************************************************** "

}
function New-RegistryPath {

    <#
    .SYNOPSIS
    Creates a new registry path
    .DESCRIPTION
    This function takes the supplied path and creates it in the registry
    .PARAMETER Path
    Specifies the path that you wish to create
    .EXAMPLE
    New-RegistryPath -Path "HKLM:\SOFTWARE\NodeIT"
    .NOTES
    This function does not currently show any output
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Path
    )

    begin {
        # Check that the $Path variable exists
        if ( $null -eq $Path ) {
            Write-Error -Message "Please specify the registry path for creation" -Category OperationStopped
        }
        # Check that the path starts with either HKLM or HKCU
        $HKCUCheck = $Path.StartsWith("HKCU:\")
        $HKLMCheck = $Path.StartsWith("HKLM:\")

        # Throw the script if both $HKCUCheck and $HKLMCheck are False
        if ( $HKCUCheck -eq "False" -and $HKLMCheck -eq "False" ) {
            Write-Error -Message "Please supply a path that begins with either HKLM:\ or HKCU:\ and try again" -Category OperationStopped
        }

        # Check if the path already exists
        if ((Test-Path $Path)) {
            Write-Error -Message "The specified path already exists, please supply an alternative path" -Category OperationStopped
        }
    }

    process {
        # Create the specified registry path
        New-Item -Path $Path -Force | Out-Null
    }
}
function New-RegistryProperty {
    <#
    .SYNOPSIS
    Creates a new registry property
    .DESCRIPTION
    This function takes the supplied path, name, values and property type then creates the corresponding property in the registry
    .PARAMETER Path
    Specifies the path that you wish to create
    .PARAMETER Name
    Specifies the name of the new property
    .PARAMETER Value
    Specifies the value of the new registry property
    .PARAMETER PropertyType
    Specifies the PropertyType of the property the following property types are available for use:
    
    String: Specifies a null-terminated string. Equivalent to REG_SZ.
    ExpandString: Specifies a null-terminated string that contains unexpanded references to environment variables that are expanded when the value is retrieved. Equivalent to REG_EXPAND_SZ.
    Binary: Specifies binary data in any form. Equivalent to REG_BINARY.
    DWord: Specifies a 32-bit binary number. Equivalent to REG_DWORD.
    MultiString: Specifies an array of null-terminated strings terminated by two null characters. Equivalent to REG_MULTI_SZ.
    Qword: Specifies a 64-bit binary number. Equivalent to REG_QWORD.
    .EXAMPLE
    New-RegistryProperty -Path "HKLM:\SOFTWARE\NodeIT" -Name Testing -Value "This is the property value" -PropertyType String
    .NOTES
    This function does not currently show any output
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Path,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Name,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Value,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "Qword")]
        $PropertyType
    )

    begin {
        ## Path parameter checking
        # Check that the $Path variable exists
        if ( $null -eq $Path ) {
            throw "Please specify the registry path for creation"
        }

        # Check that the path starts with either HKLM or HKCU
        $HKCUCheck = $Path.StartsWith("HKCU:\")
        $HKLMCheck = $Path.StartsWith("HKLM:\")

        # Throw the script if both $HKCUCheck and $HKLMCheck are False
        if ( $HKCUCheck -eq "False" -and $HKLMCheck -eq "False" ) {
            throw "Please supply a path that begins with either HKLM:\ or HKCU:\ and try again"
        }

        # Check if the path exists, if it does not the function will create it
        if ( !( Test-Path $Path ) ) {
            Write-Verbose -Message "The specified path does not exist, running New-RegistryPath to create it first"

            # Running New-RegistryPath to create the path supplied in the $Path variable
            New-RegistryPath -Path $Path
        }

        ## Name parameter checking
        # Check if a property with the same name already exists
        $NameChecking = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue

        # Throw function if a property with the same name is found
        if ( $NameChecking ) {
            throw "A property with the same name already exists in the specified location"
        }
    }

    process {
        # Create the specified registry property
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force | Out-Null
    }

}
function Remove-NodeRepository {

    <#
    .SYNOPSIS
    Removes a repository registered against an Azure Artifacts feed
    .DESCRIPTION
    Removes an Azure Package Management NuGet feed from PowerShell's repositories.
    .PARAMETER Repository
    This is the name of the repository you want to remove
    .EXAMPLE
    Remove-NodeRepository -Repository TestRepository
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

        Write-Verbose -Message 'Checking for repository existence now'

        # Check to see if there is a repository already registered with the same name
        $RepositoryCheck = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue
        if (!$RepositoryCheck) {
            throw "There is not a registered repository with the specified name, please check the spelling or availability of the repository"
        }
        else {
            Write-Verbose -Message  "The specified name is registered as a repository, proceeding with the removal now"
        }

    }

    process {

        # Addition of the NuGet source for the repository
        NuGet Sources Remove -Name $Repository | Out-Null

        Write-Verbose -Message "Beginning the repository registration process now"

        # Run the command to unregister the repository
        try {
        Unregister-PSRepository -Name $Repository
        }
        catch {
            throw "Unable to remove the repository, check that it is possible to remove it"
        }
    }
}
function Set-LocationGitHub {

    <#
    .SYNOPSIS
    Set location to GitHub
    .DESCRIPTION
    Function to check if my GitHub path exists then set the prompts location to the path. Function can also be called by typing GitHub or Gh
    .PARAMETER GitHub
    The -GitHub parameter allows you to supply the path to your GitHub folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationGitHub
    .EXAMPLE
    Gh
    .EXAMPLE
    GitHub
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $GitHub = "C:\GitHub"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $GitHub path successful")) {     
        # Test if the $GitHub path is valid
        if (Test-Path "$GitHub") {
            # Set console location to the GitHub drive
            Set-Location $GitHub
        }
        else {
            # Show error if the $GitHub path variable is either invalid or not accessible
            throw "Unable to move to the GitHub path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name Gh -Value Set-LocationGitHub
New-Alias -Name GitHub -Value Set-LocationGitHub
function Set-LocationInput {

    <#
    .SYNOPSIS
    Set location to Input
    .DESCRIPTION
    Function to check if my Input path exists then create a PSDrive to the Input and set the location to Input: Function can also be called by typing Input or In
    .PARAMETER Input
    The -Input parameter allows you to supply the path to your Input folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationInput
    .EXAMPLE
    Input
    .EXAMPLE
    In
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $InputPath = "C:\Scripts\Input"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $InputPath path successful")) {
        # Test if the $InputPath path is valid
        if (Test-Path "$InputPath") {
            # Set console location to the InputPath drive
            Set-Location $InputPath
        }
        else {
            # Show error if the $InputPath path variable is either invalid or not accessible
            throw "Unable to move to the Input path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name Input -Value Set-LocationInput
function Set-LocationOutput {

    <#
    .SYNOPSIS
    Set location to Output
    .DESCRIPTION
    Function to check if my Output path exists then create a PSDrive to the Output and set the location to Output:. Function can also be called by typing Output or Out
    .PARAMETER Output
    The -Output parameter allows you to supply the path to your Output folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationOutput
    .EXAMPLE
    Output
    .EXAMPLE
    Out
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $Output = "C:\Scripts\Output"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $Output path successful")) {     
        # Test if the $Output path is valid
        if (Test-Path "$Output") {
            # Set console location to the Output drive
            Set-Location $Output
        }
        else {
            # Show error if the $Output path variable is either invalid or not accessible
            throw "Unable to move to the Output path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name Out -Value Set-LocationOutput
New-Alias -Name Output -Value Set-LocationOutput
function Set-LocationPowerShell {

    <#
    .SYNOPSIS
    Set location to my PowerShell Path
    .DESCRIPTION
    Function to check if my PowerShell path exists then create a PSDrive to the PowerShell and set the location to PSH:. Function can also be called by typing PH
    .PARAMETER PowerShell
    The -PowerShell parameter allows you to supply the path to your PowerShell folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationPowerShell
    .EXAMPLE
    PH
    #>

    [CmdletBinding(SupportsShouldProcess=$True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $PowerShell = "C:\GitHub\PowerShell"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $PowerShell path successful")) {     
        # Test if the $PowerShell path is valid
        if (Test-Path "$PowerShell") {
            # Set console location to the PowerShell drive
            Set-Location $PowerShell
        }
        else {
            # Show error if the $PowerShell path variable is either invalid or not accessible
            throw "Unable to move to the PowerShell path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name PH -Value Set-LocationPowerShell
function Set-LocationRoot {

    <#
    .SYNOPSIS
    Set location to the root path
    .DESCRIPTION
    Function to check if the root path exists and sets the location to the root folder  Function can also be called by typing C
    .PARAMETER Root
    The -Root parameter allows you to supply the path to your root folder. If the folder does not exist, you will see an error
    .EXAMPLE
    Set-LocationRoot
    .EXAMPLE
    C
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    param (

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $Root = "C:\"

    )

    if ($PSCmdlet.ShouldProcess("Change of location to the $Root path successful")) {     
        # Test if the $Root path is valid
        if (Test-Path "$Root") {
            # Set console location to the Root drive
            Set-Location $Root
        }
        else {
            # Show error if the $Root path variable is either invalid or not accessible
            throw "Unable to move to the Root path, check that it exists and is accessible"
        }
    }
}

New-Alias -Name C -Value Set-LocationRoot
function Start-Ping {

    <#
    .SYNOPSIS
    Run Ping with -t specified as a default argument
    .DESCRIPTION
    This function wraps around Ping supplying the-t argument to always ping non-stop
    .PARAMETER Address
    The -Address parameter is for supplying the IP address or hostname you wish to ping
    .EXAMPLE
    Start-Ping test.domain.com
    .EXAMPLE
    P 1.1.1.1
    .NOTES
    Function supports the alias P
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Address
    )

    ping $Address -t

}

New-Alias -Name P -Value Start-Ping
function Start-PowerShellAsSystem {

    <#
    .SYNOPSIS
    Run PowerShell as system
    .DESCRIPTION
    This function uses PsExec to start a new PowerShell console as the system account
    .EXAMPLE
    Start-PowerShellAsSystem
    .EXAMPLE
    SYS
    .NOTES
    Function supports the alias Sys
    #>

    [CmdletBinding()]
    Param ()

    begin {}

    process {
        PsExec -i -s Powershell.exe
    }
}

New-Alias -Name Sys -Value Start-PowerShellAsSystem
function Start-TcPing {

    <#
    .SYNOPSIS
    Run TcPing with -t specified as a default argument
    .DESCRIPTION
    This function wraps around TcPing supplying the-t argument to always ping non-stop
    .PARAMETER Address
    The -Address parameter is for supplying the IP address or hostname you wish to test
    .PARAMETER Port
    The -Port parameter supplies the TCP port that you want to test
    .EXAMPLE
    Start-TcPing test.domain.com 443
    .EXAMPLE
    tp 1.1.1.1 80
    .NOTES
    Function supports the alias tp
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Address,
        [Parameter(Mandatory = $true)]
        [Int32]$Port

    )

    tcping -t $Address $Port


}

New-Alias -Name Tp -Value Start-TcPing
function Update-ChocolateyApplications {

    <#
    .SYNOPSIS
    Update Chocolatey installed applications
    .DESCRIPTION
    Update applications that were installed through the Chocolatey package management application
    .EXAMPLE
    Update-ChocolateyApplications
    .NOTES
    Function allows use of the alias UCA
    #>

    [CmdletBinding()]
    Param ()

    choco upgrade all -y

}

New-Alias -Name UCA -Value Update-ChocolateyApplications
function Update-MattModules {

    <#
    .SYNOPSIS
    Update Matt modules
    .DESCRIPTION
    Update modules that are stored in PSGallery and MattPersonal
    .PARAMETER PSGallery
    Checks for updates to modules installed from the PSGallery
    .EXAMPLE
    Update-MattModules
    .EXAMPLE
    Update-MattModules -PSGallery
    .NOTES
    This function also supports the -Verbose parameter to show more detailed console output
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $False)]
        [switch]$PSGallery
    )

    # Check if NDBHSV-DA-01 is running the function and for the version of PowerShell that's running
    if ( $env:COMPUTERNAME -eq "NDBHSV-DA-01" ) {
        $ModulePath = "C:\Program Files\WindowsPowerShell\Modules\*"
    }
    else {
        if ( $PSVersionTable.PSEdition -eq "Core" ) {
            $ModulePath = "$HOME\OneDrive - Node IT Solutions\Documents\PowerShell\Modules\*"
        }
        elseif ( $PSVersionTable.PSEdition -eq "Desktop" ) {
            $ModulePath = "$HOME\OneDrive - Node IT Solutions\Documents\WindowsPowerShell\Modules\*"
        }
    }
    if ( !$PSGallery ) {

        if ($PSCmdlet.ShouldProcess("Checked for updates to modules downloaded from MattPersonal successfully")) {

            # Create variable containing all modules installed from the MattPersonal
            $Modules = @( Get-Module -ListAvailable | Where-Object { $_.ModuleBase -like "$ModulePath" -and $_.RepositorySourceLocation -like "https://www.myget.org/*" } | Get-Unique -PipelineVariable Module )

            Write-Verbose "There are $($Modules.count) modules installed"

            # Create an empty collection to store the modules that need updating
            $Updates = @()

            ForEach ( $Module in @( $Modules )) {
                Write-Verbose "Currently selected module is - $($Module.Name)"
                $SelectModule = Find-Module -Name $($Module.Name) -Repository MattPersonal | Select-Object Name, Version
                Write-Verbose "$($SelectModule.Name) module has been found in the MattPersonal"
                $ObjectComparison = Compare-Object -ReferenceObject $SelectModule $Module -Property Name, Version | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -Property Name, Version
                if ( $ObjectComparison ) {
                    Write-Host "    An update for $($ObjectComparison.Name) has been found" -ForegroundColor White
                    $ModuleString = $($ObjectComparison.Name)
                    $Updates += $ModuleString
                }
            }

            if ( $Updates.count -ge 1 ) {
                Write-Verbose "There are $($Updates.count) modules to be updated"

                # Loop through all modules with updates available and install the latest version
                ForEach ( $Update in $Updates ) {
                    Write-Host "    Currently updating $Update to the latest version" -ForegroundColor White
                    Install-Module -Name $Update -Repository MattPersonal -Scope CurrentUser -Force
                    Write-Host "Completed updating the $Update module" -ForegroundColor Green
                }
            }
            else {
                Write-Host "There are no modules requiring updates" -ForegroundColor White
            }
        }
    }

    elseif ( $PSGallery ) {

        if ($PSCmdlet.ShouldProcess("Checked for updates to modules downloaded from PSGallery successfully")) {

            # Create variable containing all modules installed from the PSGallery
            $Modules = @( Get-Module -ListAvailable | Where-Object { $_.ModuleBase -like "$ModulePath" -and $_.RepositorySourceLocation -like "https://www.powershellgallery*" -and $_.Name -NotLike "BetterCredentials" -and $_.Name -NotLike "PSGitHub" } | Get-Unique -PipelineVariable Module )

            Write-Verbose "There are $($Modules.count) modules installed"

            # Create an empty collection to store the modules that need updating
            $Updates = @()

            ForEach ( $Module in @( $Modules )) {
                Write-Verbose "Currently selected module is - $($Module.Name)"
                $SelectModule = Find-Module -Name $($Module.Name) -Repository PSGallery | Select-Object Name, Version
                Write-Verbose "$($SelectModule.Name) module has been found in the PSGallery"
                $ObjectComparison = Compare-Object -ReferenceObject $SelectModule $Module -Property Name, Version | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -Property Name, Version
                if ( $ObjectComparison ) {
                    Write-Host "    An update for $($ObjectComparison.Name) has been found" -ForegroundColor White
                    $ModuleString = $($ObjectComparison.Name)
                    $Updates += $ModuleString
                }
            }

            if ( $Updates.count -ge 1 ) {
                Write-Verbose "There are $($Updates.count) modules to be updated"

                # Loop through all modules with updates available and install the latest version
                ForEach ( $Update in $Updates ) {
                    Write-Host "    Currently updating $Update to the latest version" -ForegroundColor White
                    Install-Module -Name $Update -Repository PSGallery -Scope CurrentUser -Force -SkipPublisherCheck
                    Write-Host "Completed updating the $Update module" -ForegroundColor Green
                }
            }
            else {
                Write-Host "There are no modules requiring updates" -ForegroundColor White
            }
        }
    }
}
Export-ModuleMember -Function Add-ArtifactsCredential, Add-NodeRepository, Compare-Items, Find-NodeModule, Get-LastCmdTime, Get-MattHelp, Install-NodeModule, Invoke-MattPlaster, Invoke-ProfileBanner, New-RegistryPath, New-RegistryProperty, Remove-NodeRepository, Set-LocationGitHub, Set-LocationInput, Set-LocationOutput, Set-LocationPowerShell, Set-LocationRoot, Start-Ping, Start-PowerShellAsSystem, Start-TcPing, Update-ChocolateyApplications, Update-MattModules -Alias *
