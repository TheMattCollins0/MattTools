@{
    PSDependOptions  = @{
    Target = 'CurrentUser'
    }

    PesterInstall = @{
        Name           = 'Pester'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Version        = 'latest'
    }

    PSScriptAnalyzer = 'latest'
    PlatyPS          = 'latest'
    PSGitHub         = 'latest'
    Plaster          = 'latest'
    BetterCredentials = '4.3'
}
