[CmdletBinding()]
[OutputType([System.Void])]
param (
)

# Get the ModuleVersion and the GUID
$buildProperties = Get-Content -Path "Build.Properties.json" | ConvertFrom-Json

# Generate build location
$builtModuleLocation = (Split-Path -Path (Get-Location) -Parent)
Write-Verbose "Build Location: $builtModuleLocation"

# get all the directories in the modules folder which relates to each module to generate
$sourceScriptFolders = Get-ChildItem -Path $PSScriptRoot -Filter "PSQuality*" -Directory

foreach ($folder in $sourceScriptFolders) {

    # generate a module
    Write-Verbose "Processing folder: $($folder.Name)"

    # generate the name of the module
    $moduleName = "{0}{1}" -f $folder.Name, '.psm1'
    $moduleFileName = Join-Path -Path $builtModuleLocation -ChildPath $moduleName

    # remove the module if it exists
    if (Test-Path -Path $moduleFileName) {
        Remove-Item -Path $moduleFileName -Force
    }

    # now loop through each folder at get the files
    # these are the functions
    $functionFiles = Get-ChildItem -Path $folder -File
    $functionsToExport = @()

    Write-Verbose "Adding content to module"

    foreach ($function in $functionFiles) {

        # Add the content of the function file
        Get-Content -Path $function.FullName | Add-Content -Path $moduleFileName

        $functionsToExport += $function.BaseName

        # add a blank line between the functions
        "" | Add-Content -Path $moduleFileName

    }

    # generate a manifest
    Write-Verbose "Generating manifest"

    # generate the name of the module
    $manifestName = "{0}{1}" -f $folder.Name, '.psd1'
    $manifestFileName = Join-Path -Path $builtModuleLocation -ChildPath $manifestName

    # remove the module if it exists
    if (Test-Path -Path $manifestFileName) {
        Remove-Item -Path $manifestFileName -Force
    }

    $newModuleManifest = @{
        Path = $manifestFileName
        Guid = $buildProperties.Guid.($folder.Name)
        RootModule = ("{0}{1}" -f $folder.Name, '.psm1')

        ModuleVersion = $buildProperties.ModuleVersion
        PowerShellVersion = $buildProperties.PowerShellVersion

        FunctionsToExport = $functionsToExport
        CmdletsToExport = @()
        VariablesToExport = @()
        AliasesToExport = @()

        Author = $buildProperties.Author
        Company = $buildProperties.Company
        Copyright = $buildProperties.Copyright
        Description = $buildProperties.Description.($folder.Name)
        FileList = $buildProperties.FileList.($folder.Name)
        HelpInfoURI = $buildProperties.HelpInfoURI
        LicenseUri = $buildProperties.LicenseUri
        ProjectUri = $buildProperties.ProjectUri
        Tags = $buildProperties.Tags

        NestedModules = $buildProperties.NestedModules.($folder.Name)


    }

    New-ModuleManifest @newModuleManifest

}
