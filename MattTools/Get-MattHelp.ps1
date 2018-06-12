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

    Write-Information ""
    Write-Information "Type Connect-EOnline to connect to a clients Office 365 or Azure AD"
    Write-Information "You need to supply Office 365 Global Admin credentials for each client you want to connect to"
    Write-Information ""
    Write-Information "Type Connect-Client to open a GUI showing a list of clients you can connect to Office 365 as"
    Write-Information "If you know the name of the client, you can type Connect-Client -ClientName ClientName or Connect-Client -Name ClientName"
    Write-Information ""
    Write-Information "Type Exit-EOnline to disconnect from Office 365 and close the PowerShell console"
    Write-Information ""
    Write-Information ""
    Write-Information "Commonly used commands:"
    Write-Information "UserA is always the sharing user. UserB is always the user requesting access"
    Write-Information "Always try to supply the users UserPrincipalName in any commands"
    Write-Information ""
    Write-Information "Add full access to mailbox without automapping"
    Write-Information 'Add-MailboxPermission -Identity "UserA" -User "UserB" -AccessRights FullAccess -AutoMapping:$false'
    Write-Information ""
    Write-Information "Set single users password to never expire"
    Write-Information 'Set-MsolUser -UserPrincipalName "" -PasswordNeverExpires:$true'
    Write-Information ""
    Write-Information "Assign calendar permissions to a user"
    Write-Information 'Add-MailboxFolderPermission -Identity "UserA:\Calendar" -AccessRights PublishingEditor -User "UserB"'
    Write-Information ""
    Write-Information "List the number of Office 365 licences in use"
    Write-Information "Get-MSOLAccountSku"
    Write-Information ""
    Write-Information "Update my Node Office365Connect PowerShell module"
    Write-Information 'Install-Module -Repository NodePowerShellRepository Office365Connect -Verbose -Scope CurrentUser -Force'
    Write-Information ""

}
