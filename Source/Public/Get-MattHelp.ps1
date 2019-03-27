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
