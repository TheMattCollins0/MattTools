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
