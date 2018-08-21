function Update-MattModules {

    <#
    .SYNOPSIS
    Update Matt modules
    .DESCRIPTION
    Update modules that are stored in PSGallery and NodePowerShellRepository
    .PARAMETER PSGallery
    Checks for updates to modules installed from the PSGallery
    .EXAMPLE
    Update-MattModules
    .EXAMPLE
    Update-MattModules -PSGallery
    .NOTES
    Can also be called by running Update-NodeModules
    #>

    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $False)]
        [switch]$PSGallery)

    if ( !$PSGallery ) {

        if ($PSCmdlet.ShouldProcess("Checked for updates to modules downloaded from NodePowerShellRepository successfully")) {

            # Create variable containing all modules installed from the NodePowerShellRepository
            $Modules = @( Get-Module -ListAvailable | Where-Object { $_.ModuleBase -like "$env:HOME\*" -and $_.RepositorySourceLocation -like "https://www.myget.org/*" } | Sort-Object -Property Name, Version -Descending | Get-Unique -PipelineVariable Module )

            Write-Verbose "There are $($Modules.count) modules installed"

            # Create an empty collection to store the modules that need updating
            $ModulesToUpdate = @()

            ForEach ( $Module in @( $Modules )) {
                Write-Verbose "Currently selected module is - $($Module.Name)"
                $SelectModule = Find-Module -Name $($Module.Name) -Repository NodePowerShellRepository | Select-Object Name, Version
                Write-Verbose "$($SelectModule.Name) module has been found in the NodePowerShellRepository"
                $ObjectComparison = Compare-Object -ReferenceObject $SelectModule $Module -Property Name, Version | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -Property Name, Version
                if ( $ObjectComparison ) {
                    Write-Information "    An update for $($ObjectComparison.Name) has been found"
                    $ModuleString = $($ObjectComparison.Name)
                    $ModulesToUpdate += $ModuleString
                }
                else {
                    Write-Information "    An update for $($Module.Name) has not been found"
                }
            }

            if ( $ModulesToUpdate.count -ge 1 ) {
                Write-Verbose "There are $($ModulesToUpdate.count) modules to be updated"

                # Loop through all modules with updates available and install the latest version
                ForEach ( $Module in $ModulesToUpdate) {
                    Write-Information "Currently updating $ModuleName to the latest version"
                    Install-Module -Name $($Module.Name) -Repository NodePowerShellRepository -Scope CurrentUser -Force
                }
            }
            else {
                Write-Information "There are no modules that require updates"
            }
        }
    }

    elseif ( $PSGallery ) {

        if ($PSCmdlet.ShouldProcess("Checked for updates to modules downloaded from PSGallery successfully")) {

            # Create variable containing all modules installed from the PSGallery
            $Modules = @( Get-Module -ListAvailable | Where-Object { $_.ModuleBase -like "$env:HOME\*" -and $_.RepositorySourceLocation -like "https://www.powershellgallery" } | Sort-Object -Property Name, Version -Descending | Get-Unique -PipelineVariable Module )

            Write-Verbose "There are $($Modules.count) modules installed"

            # Create an empty collection to store the modules that need updating
            $ModulesToUpdate = @()

            ForEach ( $Module in @( $Modules )) {
                Write-Verbose "Currently selected module is - $($Module.Name)"
                $SelectModule = Find-Module -Name $($Module.Name) -Repository PSGallery | Select-Object Name, Version
                Write-Verbose "$($SelectModule.Name) module has been found in the PSGallery"
                $ObjectComparison = Compare-Object -ReferenceObject $SelectModule $Module -Property Name, Version | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -Property Name, Version
                if ( $ObjectComparison ) {
                    Write-Information "    An update for $($ObjectComparison.Name) has been found"
                    $ModuleString = $($ObjectComparison.Name)
                    $ModulesToUpdate += $ModuleString
                }
                else {
                    Write-Information "    An update for $($Module.Name) has not been found"
                }
            }

            if ( $ModulesToUpdate.count -ge 1 ) {
                Write-Verbose "There are $($ModulesToUpdate.count) modules to be updated"

                # Loop through all modules with updates available and install the latest version
                ForEach ( $Module in $ModulesToUpdate) {
                    Write-Information "Currently updating $ModuleName to the latest version"
                    Install-Module -Name $($Module.Name) -Repository PSGallery -Scope CurrentUser -Force
                }
            }
            else {
                Write-Information "There are no modules that require updates"
            }
        }

    }

}

New-Alias -Name Update-NodeModules -Value Update-MattModules
