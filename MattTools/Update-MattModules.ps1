function Update-MattModules {

    <#
    .SYNOPSIS
    Update Matt modules
    .DESCRIPTION
    Update modules that are stored in the NodePowerShellRepository
    .EXAMPLE
    Update-MattModules
    #>

    Get-Module -ListAvailable |
        Where-Object { $_.ModuleBase -like "$env:HOME\*" -and $_.RepositorySourceLocation -like "https://www.myget.org/*" } |
        Sort-Object -Property Name, Version -Descending |
        Get-Unique -PipelineVariable Module |
        ForEach-Object {
        Find-Module -Name $_.Name -Repository NodePowerShellRepository -OutVariable Repo -ErrorAction SilentlyContinue |
            Compare-Object -ReferenceObject $_ -Property Name, Version |
            Where-Object { $_.SideIndicator -eq "=>" } |
            Select-Object -Property Name, Version,
        @{ label = 'Repository'; expression = { $Repo.Repository }},
        @{ label = 'InstalledVersion'; expression = { $Module.Version }}
    } | ForEach-Object { Install-Module -Name $_.Name -Repository NodePowerShellRepository -Scope CurrentUser -Force }

}
