# NOTE: follow nuget syntax for versions: https://docs.microsoft.com/en-us/nuget/reference/package-versioning#version-ranges-and-wildcards
@{
    PSDependOptions  = @{
        Target = 'CurrentUser'
    }
    Configuration    = 'Latest'
    Pester           = @{
        Name       = 'Pester'
        Version    = '5.1.1'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    ModuleBuilder    = 'Latest'
    PowerShellGet    = 'Latest'
    PSScriptAnalyzer = 'Latest'
    PSQualityCheck   = 'Latest'
    InvokeBuild      = 'Latest'
    "Cofl.Util"      = 'Latest'
}
