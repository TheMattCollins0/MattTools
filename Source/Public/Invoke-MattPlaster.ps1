function Invoke-MattPlaster {

    <#
    .SYNOPSIS
    Module creation function
    .DESCRIPTION
    Function to automate the creation of new PowerShell modules. The module relies on Git-Scm being installed. It also replies on the Plaster and PowerShellForGitHub modules being installed from the PSGallery
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
        $GitHubUserName = 'TheMattCollins0',

        [Parameter(Mandatory = $false)]
        [Alias('Path')]
        [string]
        $GitHubPath = 'C:\GitHub',

        [Parameter(Mandatory = $true, HelpMessage = 'Please enter the name of the new module', ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string]
        $ModuleName,

        [Parameter(Mandatory = $true, HelpMessage = 'Please provide a description for the module', ValueFromPipeline = $true)]
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
        throw 'The supplied GitHub path does not appear to exist'
    }

    # Test if the required modules are installed
    Try {
        # Testing if the PowerShellForGitHub and Plaster modules are installed
        Import-Module PowerShellForGitHub -ErrorAction Stop | Out-Null
        Import-Module Plaster -ErrorAction Stop | Out-Null
    }
    Catch {
        # Throws the script if the PowerShellForGitHub or Plaster modules are not installed
        throw 'Please ensure that both the PowerShellForGitHub and Plaster modules are installed and configured'
    }

    # Test if git has been installed from git-scm.com
    Try {
        # Test if Git has been installed on the computer
        Test-Path -Path 'C:\Program Files\Git' -ErrorAction Stop | Out-Null
        Test-Path -Path 'C:\Program Files (x86)\Git' -ErrorAction Stop | Out-Null
    }
    Catch {
        # Launch a web browser that opens at the git-scm.com website
        Start-Process 'https://git-scm.com/download'
        # Throw the script Git cannot be found in either Program Files or Program Files x86
        throw 'Please ensure that both the PowerShellForGitHub and Plaster modules are installed and configured'
    }

    # Prompt for the user to confirm if the GitHub repository will be public or private
    $RepositoryVisibilityCaption = 'GitHub Repository Visibility'
    $RepositoryVisibilityMessage = 'Does the GitHub repository need to be public or private?'
    $Public = New-Object System.Management.Automation.Host.ChoiceDescription '&Public', 'Public'
    $Private = New-Object System.Management.Automation.Host.ChoiceDescription 'p&Rivate', 'Private'
    $RepositoryVisibilityChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Public, $Private)
    $RepositoryVisibility = $host.ui.PromptForChoice( $RepositoryVisibilityCaption, $RepositoryVisibilityMessage, $RepositoryVisibilityChoices, 1 )

    switch ( $RepositoryVisibility ) {
        0 { Write-Information 'You entered Public'; break }
        1 { Write-Information 'You entered Private'; break }
    }

    # Prompt for the user to confirm if they require a development branch creating on the GitHub repository
    $DevelopmentBranchCaption = 'Development Branch Requirement'
    $DevelopmentBranchMessage = 'Does the new GitHub repository require a development branch?'
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes'
    $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No'
    $DevelopmentBranchChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $DevelopmentBranch = $host.ui.PromptForChoice( $DevelopmentBranchCaption, $DevelopmentBranchMessage, $DevelopmentBranchChoices, 0 )

    switch ( $DevelopmentBranch ) {
        0 { Write-Information 'A development branch is required'; break }
        1 { Write-Information 'A development branch is not required'; break }
    }

    # Prompt for the user to confirm if the repository is personal or for Node
    $NodeOrPersonalCaption = 'Node or Personal Repository'
    $NodeOrPersonalMessage = 'Is the new GitHub repository a Node or Personal repository?'
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Yes'
    $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'No'
    $NodeOrPersonalChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $NodeOrPersonal = $host.ui.PromptForChoice( $NodeOrPersonalCaption, $NodeOrPersonalMessage, $NodeOrPersonalChoices, 0 )

    switch ( $NodeOrPersonal ) {
        0 { Write-Information 'This is a personal repository'; break }
        1 { Write-Information 'This is a Node repository'; break }
    }

    # Set current location to the path supplied in $GitHubPath
    Set-Location -Path $GitHubPath | Out-Null

    # Creation of the destination path
    $Destination = 'C:\GitHub\' + $ModuleName

    # Creation of the $PlasterSplat splat
    $PlasterSplat = @{
        TemplatePath    = 'C:\GitHub\PlasterTemplate'
        FullName        = 'Matt Collins'
        DestinationPath = $Destination
        Version         = '0.0.1'
        ModuleName      = $ModuleName
        ModuleDesc      = $ModuleDescription
        CompanyName     = 'Node IT Solutions Ltd.'
    }

    # If statement to check if a personal public repository was requested
    if ( $RepositoryVisibility -eq '0' -and $NodeOrPersonal -eq '0' ) {
        # Create the new personal public repository on GitHub
        New-GitHubRepository -RepositoryName $ModuleName -Description $ModuleDescription
    }

    # If statement to check if a Node Private repository was requested
    if ( $RepositoryVisibility -eq '1' -and $NodeOrPersonal -eq '1' ) {
        # Create a new private repository on GitHub
        New-GitHubRepository -RepositoryName $ModuleName -Description $ModuleDescription -Private $True -OrganizationName 'NodeITSolutionsLtd'
    }

    # If statement to check if a personal private repository was requested
    if ( $RepositoryVisibility -eq '1' -and $NodeOrPersonal -eq '0' ) {
        # Create the new personal private repository on GitHub
        New-GitHubRepository -RepositoryName $ModuleName -Description $ModuleDescription -Private $True
    }

    # If statement to check if a Node public repository was requested
    if ( $RepositoryVisibility -eq '0' -and $NodeOrPersonal -eq '1' ) {
        # Create the new Node public repository on GitHub
        New-GitHubRepository -RepositoryName $ModuleName -Description $ModuleDescription  -OrganizationName 'NodeITSolutionsLtd'
    }

    # Creation of the GitHub repository URL variable
    if ( $NodeOrPersonal -eq '0' ) {

        $GitHubRepository = 'https://github.com/' + $GitHubUsername + '/' + $ModuleName + '.git'

    }
    elseif ( $NodeOrPersonal -eq '1' ) {

        $GitHubRepository = 'https://github.com/NodeITSolutionsLtd/' + $ModuleName + '.git'

    }

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
    git commit -m 'Commit initialising the repository with files supplied by Plaster'

    # Push the commit up to the repository on GitHub
    git push origin HEAD:master

    # If statement to check if a development branch of the repository was requested
    if ( $DevelopmentBranch -eq '0' ) {
        # Create a development branch
        git branch development

        # Checkout the development branch
        git checkout development
    }

}
