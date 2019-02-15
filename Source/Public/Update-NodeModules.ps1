function Update-NodeModules {

    <#
    .SYNOPSIS
    Update Node Azure Artifacts based modules
    .DESCRIPTION
    Update modules that are installed from an Azure Artifacts repository. By default it checks NodePowerShell, using the -NodeClients parameter will check for updates to NodeClients modules
    .PARAMETER NodeClients
    Checks for updates to modules installed from the NodeClients repository
    .EXAMPLE
    Update-NodeModules
    .EXAMPLE
    Update-NodeModules -NodeClients
    .NOTES
    This function also supports the -Verbose parameter to show more detailed console output
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [switch]$NodeClients
    )

    if ( !$NodeClients ) {
        # Create variable containing all modules installed from the NodePowerShell repository
        $Modules = @( Get-Module -ListAvailable | Where-Object { $_.ModuleBase -like "$HOME\*" -and $_.RepositorySourceLocation -like "https://pkgs.dev.azure.com/MattNodeIT/_packaging/NodePowerShell/*" } | Get-Unique -PipelineVariable Module )

        Write-Verbose "There are $($Modules.count) modules installed"

        # Create an empty collection to store the modules that need updating
        $Updates = @()

        ForEach ( $Module in @( $Modules )) {
            Write-Verbose "Currently selected module is - $($Module.Name)"
            $SelectModule = Find-Module -Name $($Module.Name) -Repository NodePowerShell -Credential ( BetterCredentials\Get-Credential -Username NodePAT ) | Select-Object Name, Version
            Write-Verbose "$($SelectModule.Name) module has been found in the NodePowerShell repository"
            $ObjectComparison = Compare-Object -ReferenceObject $SelectModule $Module -Property Name, Version | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -Property Name, Version
            if ( $ObjectComparison ) {
                Write-Host "    An update for $($ObjectComparison.Name) has been found" -ForegroundColor White
                $ModuleString = $($ObjectComparison.Name)
                $Updates += $ModuleString
            }
            else {
                Write-Host "An update for $($Module.Name) has not been found"  -ForegroundColor Yellow
            }
        }

        if ( $Updates.count -ge 1 ) {
            Write-Verbose "There are $($Updates.count) modules to be updated"

            # Loop through all modules with updates available and install the latest version
            ForEach ( $Update in $Updates ) {
                Write-Host "    Currently updating $Update to the latest version" -ForegroundColor White
                Install-Module -Name $Update -Repository NodePowerShell -Credential ( BetterCredentials\Get-Credential -Username NodePAT ) -Force
                Write-Host "Completed updating the $Update module" -ForegroundColor Green
            }
        }
        else {
            Write-Host "There are no modules requiring updates" -ForegroundColor White
        }
    }
    elseif ( $NodeClients ) {

        # Create variable containing all modules installed from the NodeClients repository
        $Modules = @( Get-Module -ListAvailable | Where-Object { $_.ModuleBase -like "$HOME\*" -and $_.RepositorySourceLocation -like "https://pkgs.dev.azure.com/MattNodeIT/_packaging/NodeClients/*" } | Get-Unique -PipelineVariable Module )

        Write-Verbose "There are $($Modules.count) modules installed"

        # Create an empty collection to store the modules that need updating
        $Updates = @()

        ForEach ( $Module in @( $Modules )) {
            Write-Verbose "Currently selected module is - $($Module.Name)"
            $SelectModule = Find-Module -Name $($Module.Name) -Repository NodeClients -Credential ( BetterCredentials\Get-Credential -Username NodePAT ) | Select-Object Name, Version
            Write-Verbose "$($SelectModule.Name) module has been found in the NodeClients repository"
            $ObjectComparison = Compare-Object -ReferenceObject $SelectModule $Module -Property Name, Version | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -Property Name, Version
            if ( $ObjectComparison ) {
                Write-Host "    An update for $($ObjectComparison.Name) has been found" -ForegroundColor White
                $ModuleString = $($ObjectComparison.Name)
                $Updates += $ModuleString
            }
            else {
                Write-Host "An update for $($Module.Name) has not been found"  -ForegroundColor Yellow
            }
        }

        if ( $Updates.count -ge 1 ) {
            Write-Verbose "There are $($Updates.count) modules to be updated"

            # Loop through all modules with updates available and install the latest version
            ForEach ( $Update in $Updates ) {
                Write-Host "    Currently updating $Update to the latest version" -ForegroundColor White
                Install-Module -Name $Update -Repository NodeClients -Credential ( BetterCredentials\Get-Credential -Username NodePAT ) -Force
                Write-Host "Completed updating the $Update module" -ForegroundColor Green
            }
        }
        else {
            Write-Host "There are no modules requiring updates" -ForegroundColor White
        }

    }

}
