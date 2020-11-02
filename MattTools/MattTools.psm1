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
function Invoke-Fido {

    #
    # Fido v1.15 - Retail Windows ISO Downloader
    # Copyright © 2019 Pete Batard <pete@akeo.ie>
    # ConvertTo-ImageSource: Copyright © 2016 Chris Carter
    #
    # This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.
    #
    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.
    #
    # You should have received a copy of the GNU General Public License
    # along with this program.  If not, see <http://www.gnu.org/licenses/>.
    #

    # NB: You must have a BOM on your .ps1 if you want Powershell to actually
    # realise it should use Unicode for the UI rather than ISO-8859-1.

    #region Parameters
    param(
        # (Optional) The title to display on the application window.
        [string]$AppTitle = "Fido - Retail Windows ISO Downloader",
        # (Optional) '|' separated UI localization strings.
        [string]$LocData,
        # (Optional) Path to a file that should be used for the UI icon.
        [string]$Icon,
        # (Optional) Name of a pipe the download URL should be sent to.
        # If not provided, a browser window is opened instead.
        [string]$PipeName,
        # (Optional) Disable IE First Run Customize so that Invoke-WebRequest
        # doesn't throw an exception if the user has never launched IE.
        # Note that this requires the script to run elevated.
        [switch]$DisableFirstRunCustomize
    )
    #endregion

    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    }
    catch { }
    Write-Host Please Wait...

    #region Assembly Types
    $code = @"
[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = true, BestFitMapping = false, ThrowOnUnmappableChar = true)]
	internal static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
[DllImport("user32.dll")]
	public static extern bool ShowWindow(IntPtr handle, int state);
	// Extract an icon from a DLL
	public static Icon ExtractIcon(string file, int number, bool largeIcon)
	{
		IntPtr large, small;
		ExtractIconEx(file, number, out large, out small, 1);
		try {
			return Icon.FromHandle(largeIcon ? large : small);
		} catch {
			return null;
		}
	}
"@

    Add-Type -MemberDefinition $code -Namespace Gui -UsingNamespace "System.IO", "System.Text", "System.Drawing", "System.Globalization" -ReferencedAssemblies System.Drawing -Name Utils -ErrorAction Stop
    Add-Type -AssemblyName PresentationFramework
    # Hide the powershell window: https://stackoverflow.com/a/27992426/1069307
    [Gui.Utils]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0) | Out-Null
    #endregion

    #region Data
    $zh = 0x10000
    $ko = 0x20000
    $WindowsVersions = @(
        @(
            @("Windows 10", "Windows10ISO"),
            @(
                "19H2 (Build 18363.418 - 2019.11)",
                @("Windows 10 Home/Pro", 1429),
                @("Windows 10 Education", 1431),
                @("Windows 10 Home China ", ($zh + 1430))
            ),
            @(
                "19H1 (Build 18362.356 - 2019.09)",
                @("Windows 10 Home/Pro", 1384),
                @("Windows 10 Education", 1386),
                @("Windows 10 Home China ", ($zh + 1385))
            ),
            @(
                "19H1 (Build 18362.30 - 2019.05)",
                @("Windows 10 Home/Pro", 1214),
                @("Windows 10 Education", 1216),
                @("Windows 10 Home China ", ($zh + 1215))
            ),
            @(
                "1809 R2 (Build 17763.107 - 2018.10)",
                @("Windows 10 Home/Pro", 1060),
                @("Windows 10 Education", 1056),
                @("Windows 10 Home China ", ($zh + 1061))
            ),
            @(
                "1809 R1 (Build 17763.1 - 2018.09)",
                @("Windows 10 Home/Pro", 1019),
                @("Windows 10 Education", 1021),
                @("Windows 10 Home China ", ($zh + 1020))
            ),
            @(
                "1803 (Build 17134.1 - 2018.04)",
                @("Windows 10 Home/Pro", 651),
                @("Windows 10 Education", 655),
                @("Windows 10 1803", 637),
                @("Windows 10 Home China", ($zh + 652))
            ),
            @(
                "1709 (Build 16299.15 - 2017.09)",
                @("Windows 10 Home/Pro", 484),
                @("Windows 10 Education", 488),
                @("Windows 10 Home China", ($zh + 485))
            ),
            @(
                "1703 [Redstone 2] (Build 15063.0 - 2017.03)",
                @("Windows 10 Home/Pro", 361),
                @("Windows 10 Home/Pro N", 362),
                @("Windows 10 Single Language", 363),
                @("Windows 10 Education", 423),
                @("Windows 10 Education N", 424),
                @("Windows 10 Home China", ($zh + 364))
            ),
            @(
                "1607 [Redstone 1] (Build 14393.0 - 2016.07)",
                @("Windows 10 Home/Pro", 244),
                @("Windows 10 Home/Pro N", 245),
                @("Windows 10 Single Language", 246),
                @("Windows 10 Education", 242),
                @("Windows 10 Education N", 243),
                @("Windows 10 China Get Genuine", ($zh + 247))
            ),
            @(
                "1511 R3 [Threshold 2] (Build 10586.164 - 2016.04)",
                @("Windows 10 Home/Pro", 178),
                @("Windows 10 Home/Pro N", 183),
                @("Windows 10 Single Language", 184),
                @("Windows 10 Education", 179),
                @("Windows 10 Education N", 181),
                @("Windows 10 KN", ($ko + 182)),
                @("Windows 10 Education KN", ($ko + 180)),
                @("Windows 10 China Get Genuine", ($zh + 185))
            ),
            @(
                "1511 R2 [Threshold 2] (Build 10586.104 - 2016.02)",
                @("Windows 10 Home/Pro", 109),
                @("Windows 10 Home/Pro N", 115),
                @("Windows 10 Single Language", 116),
                @("Windows 10 Education", 110),
                @("Windows 10 Education N", 112),
                @("Windows 10 KN", ($ko + 114)),
                @("Windows 10 Education KN", ($ko + 111)),
                @("Windows 10 China Get Genuine", ($zh + 113))
            ),
            @(
                "1511 R1 [Threshold 2] (Build 10586.0 - 2015.11)",
                @("Windows 10 Home/Pro", 99),
                @("Windows 10 Home/Pro N", 105),
                @("Windows 10 Single Language", 106),
                @("Windows 10 Education", 100),
                @("Windows 10 Education N", 102),
                @("Windows 10 KN", ($ko + 104)),
                @("Windows 10 Education KN", ($ko + 101)),
                @("Windows 10 China Get Genuine", ($zh + 103))
            ),
            @(
                "1507 [Threshold 1] (Build 10240.16384 - 2015.07)",
                @("Windows 10 Home/Pro", 79),
                @("Windows 10 Home/Pro N", 81),
                @("Windows 10 Single Language", 82),
                @("Windows 10 Education", 75)
                @("Windows 10 Education N", 77),
                @("Windows 10 KN", ($ko + 80)),
                @("Windows 10 Education KN", ($ko + 76)),
                @("Windows 10 China Get Genuine", ($zh + 78))
            )
        ),
        @(
            @("Windows 8.1", "windows8ISO"),
            @(
                "Update 3 (build 9600)",
                @("Windows 8.1", 52),
                @("Windows 8.1 N", 55)
                @("Windows 8.1 Single Language", 48),
                @("Windows 8.1 K", ($ko + 61)),
                @("Windows 8.1 KN", ($ko + 62))
            )
        )
    )
    #endregion

    #region Functions
    function Select-Language([string]$LangName) {
        # Use the system locale to try select the most appropriate language
        [string]$SysLocale = [System.Globalization.CultureInfo]::CurrentUICulture.Name
        if (($SysLocale.StartsWith("ar") -and $LangName -like "*Arabic*") -or `
            ($SysLocale -eq "pt-BR" -and $LangName -like "*Brazil*") -or `
            ($SysLocale.StartsWith("ar") -and $LangName -like "*Bulgar*") -or `
            ($SysLocale -eq "zh-CN" -and $LangName -like "*Chinese*" -and $LangName -like "*simp*") -or `
            ($SysLocale -eq "zh-TW" -and $LangName -like "*Chinese*" -and $LangName -like "*trad*") -or `
            ($SysLocale.StartsWith("hr") -and $LangName -like "*Croat*") -or `
            ($SysLocale.StartsWith("cz") -and $LangName -like "*Czech*") -or `
            ($SysLocale.StartsWith("da") -and $LangName -like "*Danish*") -or `
            ($SysLocale.StartsWith("nl") -and $LangName -like "*Dutch*") -or `
            ($SysLocale -eq "en-US" -and $LangName -eq "English") -or `
            ($SysLocale.StartsWith("en") -and $LangName -like "*English*" -and $LangName -like "*inter*") -or `
            ($SysLocale.StartsWith("et") -and $LangName -like "*Eston*") -or `
            ($SysLocale.StartsWith("fi") -and $LangName -like "*Finn*") -or `
            ($SysLocale -eq "fr-CA" -and $LangName -like "*French*" -and $LangName -like "*Canad*") -or `
            ($SysLocale.StartsWith("fr") -and $LangName -eq "French") -or `
            ($SysLocale.StartsWith("de") -and $LangName -like "*German*") -or `
            ($SysLocale.StartsWith("el") -and $LangName -like "*Greek*") -or `
            ($SysLocale.StartsWith("he") -and $LangName -like "*Hebrew*") -or `
            ($SysLocale.StartsWith("hu") -and $LangName -like "*Hungar*") -or `
            ($SysLocale.StartsWith("id") -and $LangName -like "*Indones*") -or `
            ($SysLocale.StartsWith("it") -and $LangName -like "*Italia*") -or `
            ($SysLocale.StartsWith("ja") -and $LangName -like "*Japan*") -or `
            ($SysLocale.StartsWith("ko") -and $LangName -like "*Korea*") -or `
            ($SysLocale.StartsWith("lv") -and $LangName -like "*Latvia*") -or `
            ($SysLocale.StartsWith("lt") -and $LangName -like "*Lithuania*") -or `
            ($SysLocale.StartsWith("ms") -and $LangName -like "*Malay*") -or `
            ($SysLocale.StartsWith("nb") -and $LangName -like "*Norw*") -or `
            ($SysLocale.StartsWith("fa") -and $LangName -like "*Persia*") -or `
            ($SysLocale.StartsWith("pl") -and $LangName -like "*Polish*") -or `
            ($SysLocale -eq "pt-PT" -and $LangName -eq "Portuguese") -or `
            ($SysLocale.StartsWith("ro") -and $LangName -like "*Romania*") -or `
            ($SysLocale.StartsWith("ru") -and $LangName -like "*Russia*") -or `
            ($SysLocale.StartsWith("sr") -and $LangName -like "*Serbia*") -or `
            ($SysLocale.StartsWith("sk") -and $LangName -like "*Slovak*") -or `
            ($SysLocale.StartsWith("sl") -and $LangName -like "*Slovenia*") -or `
            ($SysLocale -eq "es-ES" -and $LangName -eq "Spanish") -or `
            ($SysLocale.StartsWith("es") -and $Locale -ne "es-ES" -and $LangName -like "*Spanish*") -or `
            ($SysLocale.StartsWith("sv") -and $LangName -like "*Swed*") -or `
            ($SysLocale.StartsWith("th") -and $LangName -like "*Thai*") -or `
            ($SysLocale.StartsWith("tr") -and $LangName -like "*Turk*") -or `
            ($SysLocale.StartsWith("uk") -and $LangName -like "*Ukrain*") -or `
            ($SysLocale.StartsWith("vi") -and $LangName -like "*Vietnam*")) {
            return $True
        }
        return $False
    }

    function Add-Entry([int]$pos, [string]$Name, [array]$Items, [string]$DisplayName) {
        $Title = New-Object System.Windows.Controls.TextBlock
        $Title.FontSize = $WindowsVersionTitle.FontSize
        $Title.Height = $WindowsVersionTitle.Height;
        $Title.Width = $WindowsVersionTitle.Width;
        $Title.HorizontalAlignment = "Left"
        $Title.VerticalAlignment = "Top"
        $Margin = $WindowsVersionTitle.Margin
        $Margin.Top += $pos * $dh
        $Title.Margin = $Margin
        $Title.Text = Get-Translation($Name)
        $XMLGrid.Children.Insert(2 * $Stage + 2, $Title)

        $Combo = New-Object System.Windows.Controls.ComboBox
        $Combo.FontSize = $WindowsVersion.FontSize
        $Combo.Height = $WindowsVersion.Height;
        $Combo.Width = $WindowsVersion.Width;
        $Combo.HorizontalAlignment = "Left"
        $Combo.VerticalAlignment = "Top"
        $Margin = $WindowsVersion.Margin
        $Margin.Top += $pos * $script:dh
        $Combo.Margin = $Margin
        $Combo.SelectedIndex = 0
        if ($Items) {
            $Combo.ItemsSource = $Items
            if ($DisplayName) {
                $Combo.DisplayMemberPath = $DisplayName
            }
            else {
                $Combo.DisplayMemberPath = $Name
            }
        }
        $XMLGrid.Children.Insert(2 * $Stage + 3, $Combo)

        $XMLForm.Height += $dh;
        $Margin = $Continue.Margin
        $Margin.Top += $dh
        $Continue.Margin = $Margin
        $Margin = $Back.Margin
        $Margin.Top += $dh
        $Back.Margin = $Margin

        return $Combo
    }

    function Refresh-Control([object]$Control) {
        $Control.Dispatcher.Invoke("Render", [Windows.Input.InputEventHandler] { $Continue.UpdateLayout() }, $null, $null)
    }

    function Send-Message([string]$PipeName, [string]$Message) {
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8
        $Pipe = New-Object -TypeName System.IO.Pipes.NamedPipeClientStream -ArgumentList ".", $PipeName, ([System.IO.Pipes.PipeDirection]::Out), ([System.IO.Pipes.PipeOptions]::None), ([System.Security.Principal.TokenImpersonationLevel]::Impersonation)
        try {
            $Pipe.Connect(1000)
        }
        catch {
            Write-Host $_.Exception.Message
        }
        $bRequest = $Encoding.GetBytes($Message)
        $cbRequest = $bRequest.Length;
        $Pipe.Write($bRequest, 0, $cbRequest);
        $Pipe.Dispose()
    }

    # From https://www.powershellgallery.com/packages/IconForGUI/1.5.2
    # Copyright © 2016 Chris Carter. All rights reserved.
    # License: https://creativecommons.org/licenses/by-sa/4.0/
    function ConvertTo-ImageSource {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
            [System.Drawing.Icon]$Icon
        )

        Process {
            foreach ($i in $Icon) {
                [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
                    $i.Handle,
                    (New-Object System.Windows.Int32Rect -Args 0, 0, $i.Width, $i.Height),
                    [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
                )
            }
        }
    }

    function Throw-Error([object]$Req, [string]$Alt) {
        $Err = $(GetElementById -Request $r -Id "errorModalMessage").innerText
        if (-not $Err) {
            $Err = $Alt
        }
        else {
            $Err = [System.Text.Encoding]::UTF8.GetString([byte[]][char[]]$Err)
        }
        throw $Err
    }

    # Translate a message string
    function Get-Translation([string]$Text) {
        if (-not $English -contains $Text) {
            Write-Host "Error: '$Text' is not a translatable string"
            return "(Untranslated)"
        }
        if ($Localized) {
            if ($Localized.Length -ne $English.Length) {
                Write-Host "Error: '$Text' is not a translatable string"
            }
            for ($i = 0; $i -lt $English.Length; $i++) {
                if ($English[$i] -eq $Text) {
                    if ($Localized[$i]) {
                        return $Localized[$i]
                    }
                    else {
                        return $Text
                    }
                }
            }
        }
        return $Text
    }

    # Some PowerShells don't have Microsoft.mshtml assembly (comes with MS Office?)
    # so we can't use ParsedHtml or IHTMLDocument[2|3] features there...
    function GetElementById([object]$Request, [string]$Id) {
        try {
            return $Request.ParsedHtml.IHTMLDocument3_GetElementByID($Id)
        }
        catch {
            return $Request.AllElements | ? { $_.id -eq $Id }
        }
    }

    function Error([string]$ErrorMessage) {
        Write-Host Error: $ErrorMessage
        $XMLForm.Title = $(Get-Translation("Error")) + ": " + $ErrorMessage
        Refresh-Control($XMLForm)
        $Continue.Content = Get-Translation("Close")
        Refresh-Control($Continue)
        $UserInput = [System.Windows.MessageBox]::Show($XMLForm.Title, $(Get-Translation("Error")), "OK", "Error")
        $script:ExitCode = $Stage
        $script:Stage = -1
        $Continue.IsEnabled = $True
    }

    function Get-RandomDate() {
        [DateTime]$Min = "1/1/2008"
        [DateTime]$Max = [DateTime]::Now

        $RandomGen = New-Object random
        $RandomTicks = [Convert]::ToInt64( ($Max.ticks * 1.0 - $Min.Ticks * 1.0 ) * $RandomGen.NextDouble() + $Min.Ticks * 1.0 )
        $Date = New-Object DateTime($RandomTicks)
        return $Date.ToString("yyyyMMdd")
    }
    #endregion

    #region Form
    [xml]$XAML = @"
<Window xmlns = "http://schemas.microsoft.com/winfx/2006/xaml/presentation" Height = "162" Width = "384" ResizeMode = "NoResize">
	<Grid Name = "XMLGrid">
		<Button Name = "Continue" FontSize = "16" Height = "26" Width = "160" HorizontalAlignment = "Left" VerticalAlignment = "Top" Margin = "14,78,0,0"/>
		<Button Name = "Back" FontSize = "16" Height = "26" Width = "160" HorizontalAlignment = "Left" VerticalAlignment = "Top" Margin = "194,78,0,0"/>
		<TextBlock Name = "WindowsVersionTitle" FontSize = "16" Width="340" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="16,8,0,0"/>
		<ComboBox Name = "WindowsVersion" FontSize = "14" Height = "24" Width = "340" HorizontalAlignment = "Left" VerticalAlignment="Top" Margin = "14,34,0,0" SelectedIndex = "0"/>
		<CheckBox Name = "Check" FontSize = "14" Width = "340" HorizontalAlignment = "Left" VerticalAlignment="Top" Margin = "14,0,0,0" Visibility="Collapsed" />
	</Grid>
</Window>
"@
    #endregion

    #region Globals
    $ErrorActionPreference = "Stop"
    $dh = 58;
    $Stage = 0
    $ltrm = "‎"
    $MaxStage = 4
    $SessionId = [guid]::NewGuid()
    $ExitCode = 100
    $Locale = "en-US"
    $DFRCKey = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\"
    $DFRCName = "DisableFirstRunCustomize"
    $DFRCAdded = $False
    $RequestData = @{ }
    $RequestData["GetLangs"] = @("a8f8f489-4c7f-463a-9ca6-5cff94d8d041", "getskuinformationbyproductedition" )
    $RequestData["GetLinks"] = @("cfa9e580-a81e-4a4b-a846-7b21bf4e2e5b", "GetProductDownloadLinksBySku" )
    # Create a semi-random Linux User-Agent string
    $FirefoxVersion = Get-Random -Minimum 30 -Maximum 60
    $FirefoxDate = Get-RandomDate
    $UserAgent = "Mozilla/5.0 (X11; Linux i586; rv:$FirefoxVersion.0) Gecko/$FirefoxDate Firefox/$FirefoxVersion.0"
    #endregion

    # Localization
    $EnglishMessages = "en-US|Version|Release|Edition|Language|Architecture|Download|Continue|Back|Close|Cancel|Error|Please wait...|" +
    "Download using a browser|Temporarily banned by Microsoft for requesting too many downloads - Please try again later...|" +
    "PowerShell 3.0 or later is required to run this script.|Do you want to go online and download it?"
    [string[]]$English = $EnglishMessages.Split('|')
    [string[]]$Localized = $null
    if ($LocData -and (-not $LocData.StartsWith("en-US"))) {
        $Localized = $LocData.Split('|')
        if ($Localized.Length -ne $English.Length) {
            Write-Host "Error: Missing or extra translated messages provided ($($Localized.Length)/$($English.Length))"
            exit 101
        }
        $Locale = $Localized[0]
    }
    $QueryLocale = $Locale

    # Make sure PowerShell 3.0 or later is used (for Invoke-WebRequest)
    if ($PSVersionTable.PSVersion.Major -lt 3) {
        Write-Host Error: PowerShell 3.0 or later is required to run this script.
        $Msg = "$(Get-Translation($English[15]))`n$(Get-Translation($English[16]))"
        if ([System.Windows.MessageBox]::Show($Msg, $(Get-Translation("Error")), "YesNo", "Error") -eq "Yes") {
            Start-Process -FilePath https://www.microsoft.com/download/details.aspx?id=34595
        }
        exit 102
    }

    # If asked, disable IE's first run customize prompt as it interferes with Invoke-WebRequest
    if ($DisableFirstRunCustomize) {
        try {
            # Only create the key if it doesn't already exist
            Get-ItemProperty -Path $DFRCKey -Name $DFRCName
        }
        catch {
            if (-not (Test-Path $DFRCKey)) {
                New-Item -Path $DFRCKey -Force | Out-Null
            }
            Set-ItemProperty -Path $DFRCKey -Name $DFRCName -Value 1
            $DFRCAdded = $True
        }
    }

    # Form creation
    $XMLForm = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $XAML))
    $XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $XMLForm.FindName($_.Name) -Scope Script }
    $XMLForm.Title = $AppTitle
    if ($Icon) {
        $XMLForm.Icon = $Icon
    }
    else {
        $XMLForm.Icon = [Gui.Utils]::ExtractIcon("shell32.dll", -41, $true) | ConvertTo-ImageSource
    }
    if ($Locale.StartsWith("ar") -or $Locale.StartsWith("fa") -or $Locale.StartsWith("he")) {
        $XMLForm.FlowDirection = "RightToLeft"
    }
    $WindowsVersionTitle.Text = Get-Translation("Version")
    $Continue.Content = Get-Translation("Continue")
    $Back.Content = Get-Translation("Close")

    # Populate the Windows versions
    $i = 0
    $array = @()
    foreach ($Version in $WindowsVersions) {
        $array += @(New-Object PsObject -Property @{ Version = $Version[0][0]; PageType = $Version[0][1]; Index = $i })
        $i++
    }
    $WindowsVersion.ItemsSource = $array
    $WindowsVersion.DisplayMemberPath = "Version"

    # Button Action
    $Continue.add_click( {
            if ($script:Stage++ -lt 0) {
                Get-Process -Id $pid | ForEach-Object { $_.CloseMainWindow() | Out-Null }
                return
            }

            $XMLGrid.Children[2 * $Stage + 1].IsEnabled = $False
            $Continue.IsEnabled = $False
            $Back.IsEnabled = $False
            Refresh-Control($Continue)
            Refresh-Control($Back)

            switch ($Stage) {

                1 {
                    # Windows Version selection
                    $XMLForm.Title = Get-Translation($English[12])
                    Refresh-Control($XMLForm)
                    # Check if the locale we want is available - Fall back to en-US otherwise
                    try {
                        $url = "https://www.microsoft.com/" + $QueryLocale + "/software-download/"
                        Write-Host Querying $url
                        Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 -UserAgent $UserAgent $url | Out-Null
                    }
                    catch {
                        $script:QueryLocale = "en-US"
                    }

                    $i = 0
                    $array = @()
                    foreach ($Version in $WindowsVersions[$WindowsVersion.SelectedValue.Index]) {
                        if (($i -ne 0) -and ($Version -is [array])) {
                            $array += @(New-Object PsObject -Property @{ Release = $ltrm + $Version[0].Replace(")", ")" + $ltrm); Index = $i })
                        }
                        $i++
                    }

                    $script:WindowsRelease = Add-Entry $Stage "Release" $array
                    $Back.Content = Get-Translation($English[8])
                    $XMLForm.Title = $AppTitle
                }

                2 {
                    # Windows Release selection => Populate Product Edition
                    $array = @()
                    foreach ($Release in  $WindowsVersions[$WindowsVersion.SelectedValue.Index][$WindowsRelease.SelectedValue.Index]) {
                        if ($Release -is [array]) {
                            if (($Release[1] -lt 0x10000) -or ($Locale.StartsWith("ko") -and ($Release[1] -band $ko)) -or ($Locale.StartsWith("zh") -and ($Release[1] -band $zh))) {
                                $array += @(New-Object PsObject -Property @{ Edition = $Release[0]; Id = $($Release[1] -band 0xFFFF) })
                            }
                        }
                    }
                    $script:ProductEdition = Add-Entry $Stage "Edition" $array
                }

                3 {
                    # Product Edition selection => Request and populate Languages
                    $XMLForm.Title = Get-Translation($English[12])
                    Refresh-Control($XMLForm)
                    $url = "https://www.microsoft.com/" + $QueryLocale + "/api/controls/contentinclude/html"
                    $url += "?pageId=" + $RequestData["GetLangs"][0]
                    $url += "&host=www.microsoft.com"
                    $url += "&segments=software-download," + $WindowsVersion.SelectedValue.PageType
                    $url += "&query=&action=" + $RequestData["GetLangs"][1]
                    $url += "&sessionId=" + $SessionId
                    $url += "&productEditionId=" + [Math]::Abs($ProductEdition.SelectedValue.Id)
                    $url += "&sdVersion=2"
                    Write-Host Querying $url

                    $array = @()
                    $i = 0
                    $SelectedIndex = 0
                    try {
                        $r = Invoke-WebRequest -UserAgent $UserAgent -WebSession $Session $url
                        # Go through an XML conversion to keep all PowerShells happy...
                        if (-not $($r.AllElements | ? { $_.id -eq "product-languages" })) {
                            throw "Unexpected server response"
                        }
                        $html = $($r.AllElements | ? { $_.id -eq "product-languages" }).InnerHTML
                        $html = $html.Replace("selected value", "value")
                        $html = $html.Replace("&", "&amp;")
                        $html = "<options>" + $html + "</options>"
                        $xml = [xml]$html
                        foreach ($var in $xml.options.option) {
                            $json = $var.value | ConvertFrom-Json;
                            if ($json) {
                                $array += @(New-Object PsObject -Property @{ DisplayLanguage = $var.InnerText; Language = $json.language; Id = $json.id })
                                if (Select-Language($json.language)) {
                                    $SelectedIndex = $i
                                }
                                $i++
                            }
                        }
                        if ($array.Length -eq 0) {
                            Throw-Error -Req $r -Alt "Could not parse languages"
                        }
                    }
                    catch {
                        Error($_.Exception.Message)
                        return
                    }
                    $script:Language = Add-Entry $Stage "Language" $array "DisplayLanguage"
                    $Language.SelectedIndex = $SelectedIndex
                    $XMLForm.Title = $AppTitle
                }

                4 {
                    # Language selection => Request and populate Arch download links
                    $XMLForm.Title = Get-Translation($English[12])
                    Refresh-Control($XMLForm)
                    $url = "https://www.microsoft.com/" + $QueryLocale + "/api/controls/contentinclude/html"
                    $url += "?pageId=" + $RequestData["GetLinks"][0]
                    $url += "&host=www.microsoft.com"
                    $url += "&segments=software-download," + $WindowsVersion.SelectedValue.PageType
                    $url += "&query=&action=" + $RequestData["GetLinks"][1]
                    $url += "&sessionId=" + $SessionId
                    $url += "&skuId=" + $Language.SelectedValue.Id
                    $url += "&language=" + $Language.SelectedValue.Language
                    $url += "&sdVersion=2"
                    Write-Host Querying $url

                    $i = 0
                    $SelectedIndex = 0
                    $array = @()
                    try {
                        $Is64 = [Environment]::Is64BitOperatingSystem
                        $r = Invoke-WebRequest -UserAgent $UserAgent -WebSession $Session $url
                        if (-not $($r.AllElements | ? { $_.id -eq "expiration-time" })) {
                            Throw-Error -Req $r -Alt Get-Translation($English[14])
                        }
                        $html = $($r.AllElements | ? { $_.tagname -eq "input" }).outerHTML
                        # Need to fix the HTML and JSON data so that it is well-formed
                        $html = $html.Replace("class=product-download-hidden", "")
                        $html = $html.Replace("type=hidden", "")
                        $html = $html.Replace(">", "/>")
                        $html = $html.Replace("&nbsp;", " ")
                        $html = $html.Replace("IsoX86", """x86""")
                        $html = $html.Replace("IsoX64", """x64""")
                        $html = "<inputs>" + $html + "</inputs>"
                        $xml = [xml]$html
                        foreach ($var in $xml.inputs.input) {
                            $json = $var.value | ConvertFrom-Json;
                            if ($json) {
                                if (($Is64 -and $json.DownloadType -eq "x64") -or (-not $Is64 -and $json.DownloadType -eq "x86")) {
                                    $SelectedIndex = $i
                                }
                                $array += @(New-Object PsObject -Property @{ Type = $json.DownloadType; Link = $json.Uri })
                                $i++
                            }
                        }
                        if ($array.Length -eq 0) {
                            Throw-Error -Req $r -Alt "Could not retrieve ISO download links"
                        }
                    }
                    catch {
                        Error($_.Exception.Message)
                        return
                    }

                    $script:Arch = Add-Entry $Stage "Architecture" $array "Type"
                    if ($PipeName) {
                        $XMLForm.Height += $dh / 2;
                        $Margin = $Continue.Margin
                        $top = $Margin.Top
                        $Margin.Top += $dh / 2
                        $Continue.Margin = $Margin
                        $Margin = $Back.Margin
                        $Margin.Top += $dh / 2
                        $Back.Margin = $Margin
                        $Margin = $Check.Margin
                        $Margin.Top = $top - 2
                        $Check.Margin = $Margin
                        $Check.Content = Get-Translation($English[13])
                        $Check.Visibility = "Visible"
                    }
                    $Arch.SelectedIndex = $SelectedIndex
                    $Continue.Content = Get-Translation("Download")
                    $XMLForm.Title = $AppTitle
                }

                5 {
                    # Arch selection => Return selected download link
                    if ($PipeName -and -not $Check.IsChecked) {
                        Send-Message -PipeName $PipeName -Message $Arch.SelectedValue.Link
                    }
                    else {
                        Write-Host Download Link: $Arch.SelectedValue.Link
                        Start-Process -FilePath $Arch.SelectedValue.Link
                    }
                    $script:ExitCode = 0
                    $XMLForm.Close()
                }
            }
            $Continue.IsEnabled = $True
            if ($Stage -ge 0) {
                $Back.IsEnabled = $True;
            }
        })

    $Back.add_click( {
            if ($Stage -eq 0) {
                $XMLForm.Close()
            }
            else {
                $XMLGrid.Children.RemoveAt(2 * $Stage + 3)
                $XMLGrid.Children.RemoveAt(2 * $Stage + 2)
                $XMLGrid.Children[2 * $Stage + 1].IsEnabled = $True
                $dh2 = $dh
                if ($Stage -eq 4 -and $PipeName) {
                    $Check.Visibility = "Collapsed"
                    $dh2 += $dh / 2
                }
                $XMLForm.Height -= $dh2;
                $Margin = $Continue.Margin
                $Margin.Top -= $dh2
                $Continue.Margin = $Margin
                $Margin = $Back.Margin
                $Margin.Top -= $dh2
                $Back.Margin = $Margin
                $script:Stage = $Stage - 1
                if ($Stage -eq 0) {
                    $Back.Content = Get-Translation("Close")
                }
                elseif ($Stage -eq 3) {
                    $Continue.Content = Get-Translation("Continue")
                }
            }
        })

    # Display the dialog
    $XMLForm.Add_Loaded( { $XMLForm.Activate() } )
    $XMLForm.ShowDialog() | Out-Null

    # Clean up & exit
    if ($DFRCAdded) {
        Remove-ItemProperty -Path $DFRCKey -Name $DFRCName
    }
    exit $ExitCode

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
    Invoke-MattPlaster -GitHubPath "C:\GitHubScripts" -ModuleName "NameHere" -ModuleDescription "This is a module description"
    .EXAMPLE
    Invoke-MattPlaster -Path "C:\GitHubScripts" -Name "NameHere" -Description "This is a module description"
    #>

    [CmdletBinding()]
    param (
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

    # Prompt for the user to confirm if the GitHub repository is my own or Node's
    $AccountSelectionCaption = "GitHub Account Selection"
    $AccountSelectionMessage = "Does the GitHub repository need to be stored under TheMattCollins0 or NodeITSolutionsLtd?"
    $TheMattCollins0 = New-Object System.Management.Automation.Host.ChoiceDescription "&TheMattCollins0", "TheMattCollins0"
    $NodeITSolutionsLtd = New-Object System.Management.Automation.Host.ChoiceDescription "&NodeITSolutionsLtd", "NodeITSolutionsLtd"
    $AccountSelectionChoices = [System.Management.Automation.Host.ChoiceDescription[]]($TheMattCollins0, $NodeITSolutionsLtd)
    $AccountSelection = $host.ui.PromptForChoice( $AccountSelectionCaption, $AccountSelectionMessage, $AccountSelectionChoices, 0 )

    switch ( $AccountSelection ) {
        0 { Write-Information "You entered TheMattCollins0"; break }
        1 { Write-Information "You entered NodeITSolutionsLtd"; break }
    }

    # Prompt for the user to confirm if the GitHub repository will be public or private
    $RepositoryVisibilityCaption = "GitHub Repository Visibility"
    $RepositoryVisibilityMessage = "Does the GitHub repository need to be public or private?"
    $Public = New-Object System.Management.Automation.Host.ChoiceDescription "&Public", "Public"
    $Private = New-Object System.Management.Automation.Host.ChoiceDescription "p&Rivate", "Private"
    $RepositoryVisibilityChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Public, $Private)
    $RepositoryVisibility = $host.ui.PromptForChoice( $RepositoryVisibilityCaption, $RepositoryVisibilityMessage, $RepositoryVisibilityChoices, 1 )

    switch ( $RepositoryVisibility ) {
        0 { Write-Information "You entered Public"; break }
        1 { Write-Information "You entered Private"; break }
    }

    # Prompt for the user to confirm if they require a development branch creating on the GitHub repository
    $DevelopmentBranchCaption = "Development Branch Requirement"
    $DevelopmentBranchMessage = "Does the new GitHub repository require a development branch?"
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
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

    # If statement to check if the repository needs to be created as my personal account or as Node's account
    if ( $RepositoryVisibility -eq "0" ) {

        $GitHubUsername = "TheMattCollins0"

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

    }
    elseif ( $RepositoryVisibility -eq "1" ) {

        $GitHubUsername = "NodeITSolutionsLtd"

        # If statement to check if a Public repository was requested
        if ( $RepositoryVisibility -eq "0" ) {
            # Create the new public repository on GitHub
            New-GitHubRepository -Name $ModuleName -Description $ModuleDescription -Organization "NodeITSolutionsLtd"
        }

        # If statement to check if a Private repository was requested
        if ( $RepositoryVisibility -eq "1" ) {
            # Create a new private repository on GitHub
            New-GitHubRepository -Name $ModuleName -Description $ModuleDescription -Private $True -Organization "NodeITSolutionsLtd"
        }

        # Creation of the GitHub repository URL variable
        $GitHubRepository = "https://github.com/" + $GitHubUsername + "/" + $ModuleName + ".git"

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

        # Removal of the NuGet source for the repository
        NuGet Sources Remove -Name $Repository

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
            $Modules = @( Get-Module -ListAvailable | Where-Object { $_.ModuleBase -like "$ModulePath" -and $_.RepositorySourceLocation -like "https://www.powershellgallery*" -and $_.Name -NotLike "BetterCredentials" -and $_.Name -NotLike "PSGitHub" -and $_.Name -NotLike "Microsoft.PowerShell.SecretManagement" } | Get-Unique -PipelineVariable Module )

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
Export-ModuleMember -Function Add-ArtifactsCredential, Add-NodeRepository, Compare-Items, Find-NodeModule, Get-LastCmdTime, Get-MattHelp, Install-NodeModule, Invoke-Fido, Invoke-MattPlaster, Invoke-ProfileBanner, New-RegistryPath, New-RegistryProperty, Remove-NodeRepository, Set-LocationGitHub, Set-LocationInput, Set-LocationOutput, Set-LocationPowerShell, Set-LocationRoot, Start-Ping, Start-PowerShellAsSystem, Start-TcPing, Update-ChocolateyApplications, Update-MattModules -Alias *
