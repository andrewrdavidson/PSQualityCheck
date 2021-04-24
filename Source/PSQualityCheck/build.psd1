# Use this file to override the default parameter values used by the `Build-Module`
# command when building the module (see `Get-Help Build-Module -Full` for details).
@{
    ModuleManifest           = "PSQualityCheck.psd1"
    # Subsequent relative paths are to the ModuleManifest
    OutputDirectory          = "../../artifacts/PSQualityCheck"
    VersionedOutputDirectory = $true
    CopyDirectories          = @('data', 'bin')
}

