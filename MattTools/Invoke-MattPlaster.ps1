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
    .PARAMETER TemplatePath
    The -TemplatePath parameter allows an alternate path to be specified for the template path
    .EXAMPLE
    Invoke-MattPlaster -ModuleName "NameHere" -ModuleDescription "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -Name "NameHere" -Description "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -ModuleName "NameHere" -ModuleDescription "This is a module description" -TemplatePath "TemplatePathHere"
    .EXAMPLE
    Invoke-MattPlaster -Name "NameHere" -Description "This is a module description" -TemplatePath "TemplatePathHere"
    .EXAMPLE
    Invoke-MattPlaster -GitHubUserName YourUserNameHere -GitHubPath "C:\GitHubScripts" -ModuleName "NameHere" -ModuleDescription "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -UserName YourUserNameHere -Path "C:\GitHubScripts" -Name "NameHere" -Description "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -GitHubUserName YourUserNameHere -GitHubPath "C:\GitHubScripts" -ModuleName "NameHere" -ModuleDescription "This is a module description" -TemplatePath "TemplatePathHere"
    .EXAMPLE
    Invoke-MattPlaster -UserName YourUserNameHere -Path "C:\GitHubScripts" -Name "NameHere" -Description "This is a module description" -TemplatePath "TemplatePathHere"
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

        [Parameter(Mandatory = $false)]
        [Alias('Template')]
        [string]
        $TemplatePath = "C:\GitHub\PlasterTemplate",

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
        Invoke-Expression -Command 'explorer https://git-scm.com/download'
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
        0 { "You entered Public"; break }
        1 { "You entered Private"; break }
    }

    # Prompt for the user to confirm if they require a development branch creating on the GitHub repository
    $DevelopmentBranchCaption = "Development Branch Requirement"
    $DevelopmentBranchMessage = "Does the new GitHub repository require a development branch?"
    $Yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
    $No = new-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
    $DevelopmentBranchChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $DevelopmentBranch = $host.ui.PromptForChoice( $DevelopmentBranchCaption, $DevelopmentBranchMessage, $DevelopmentBranchChoices, 0 )

    switch ( $DevelopmentBranch ) {
        0 { "A development branch is required"; break }
        1 { "A development branch is not required"; break }
    }

    # Set current location to the path supplied in $GitHubPath
    Set-Location -Path $GitHubPath | Out-Null

    # Creation of the destination path
    $Destination = "C:\GitHub\" + $ModuleName

    # Creation of the $PlasterSplat splat
    $PlasterSplat = @{
        TemplatePath    = $TemplatePath
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
    Invoke-Plaster @PlasterSplat

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
