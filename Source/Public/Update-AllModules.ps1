function Update-AllModules {

    <#
    .SYNOPSIS
    Update all PowerShell modules
    .DESCRIPTION
    This function runs all of the Node PowerShell module update commands one after the other to ensure all modules are updated
    .EXAMPLE
    Update-AllModules
    #>

    Update-NodeModules
    Update-MattModules
    Update-MattModules -PSGallery

}
