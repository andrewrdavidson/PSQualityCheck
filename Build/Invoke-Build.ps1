<#
    .SYNOPSIS
    Build the PSMoxu module and its sub-modules

    .DESCRIPTION
    Build the PSMoxu module and its sub-modules

    .EXAMPLE
    Invoke-Build.ps1 -BuildProperties "Build.Properties.json"
#>
[CmdletBinding()]
[OutputType([System.Void])]
param (
    $BuildProperties = "Build.Properties.json"
)

# Build the Moxu modules
Write-Verbose "Loading Build Properties"
try {
    $buildProperties = Get-Content -Path $BuildProperties | ConvertFrom-Json
}
catch {
    throw "Error loading the Build Properties file"
}

# Check that the build pre-requisites are available
Write-Verbose "Verifying pre-requisites are available"

try {

    foreach ($preReq in $buildProperties.PreRequisites.PSObject.Properties) {

        Import-Module -Name $preReq.Name -MinimumVersion $preReq.Value -Verbose:$false

        if ( -not (Get-Module -Name $preReq.Name -ListAvailable -Verbose:$false) ) {
            throw "Module '$($preReq.Name)' version '$($preReq.Value)' is not available"
        }
        else {
            Write-Verbose "Module '$($preReq.Name)' version '$($preReq.Value)' is available"
        }

    }

}
catch {

    throw

}

# Generate build location
$builtModuleLocation = Split-Path -Path $PSScriptRoot -Parent
$sourceModuleLocation = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "Source"
Write-Verbose "Build Location: $builtModuleLocation"

$PSQualityCheckSplat = @{}
if (-not ([string]::IsNullOrEmpty($buildProperties.Support.PSQualityCheck.ScriptAnalyzerRulesPath))) {
    $PSQualityCheckSplat.Add("ScriptAnalyzerRulesPath", $buildProperties.Support.PSQualityCheck.ScriptAnalyzerRulesPath)
}

$PesterConfiguration = [PesterConfiguration]::Default
$PesterConfiguration.Run.Exit = $false
$PesterConfiguration.CodeCoverage.Enabled = $false
$PesterConfiguration.Output.Verbosity = 'None'
$PesterConfiguration.Run.PassThru = $false
$PesterConfiguration.Should.ErrorAction = 'Stop'
$PSQualityCheckSplat.Add("PesterConfiguration", $PesterConfiguration)

$manifestsToTest = @()

# Loop through the modules
foreach ($module in $buildProperties.Module.Version.PSObject.Properties) {

    Write-Verbose "Building module : $($module.Name)"

    Write-Verbose "Getting Public modules"
    $functionPublicPath = Join-Path -Path (Join-Path -Path $sourceModuleLocation -ChildPath $module.Name) -ChildPath "public"
    $sourcePublicFiles = Get-ChildItem -Path $functionPublicPath -Recurse

    Write-Verbose "Getting Private modules"
    $functionPrivatePath = Join-Path -Path (Join-Path -Path $sourceModuleLocation -ChildPath $module.Name) -ChildPath "private"
    $sourcePrivateFiles = Get-ChildItem -Path $functionPrivatePath -Recurse

    Write-Verbose "Generating module file name"
    $moduleName = "{0}{1}" -f $module.Name, '.psm1'
    $moduleFileName = Join-Path -Path $builtModuleLocation -ChildPath $moduleName

    # # remove the module if it exists
    if (Test-Path -Path $moduleFileName) {
        Write-Verbose "Removing existing module file name"
        Remove-Item -Path $moduleFileName -Force
    }

    Write-Verbose "Generating manifest file name"
    $manifestName = "{0}{1}" -f $module.Name, '.psd1'
    $manifestFileName = Join-Path -Path $builtModuleLocation -ChildPath $manifestName
    $manifestsToTest += $manifestFileName

    # remove the module if it exists
    if (Test-Path -Path $manifestFileName) {
        Write-Verbose "Removing existing manifest file name"
        Remove-Item -Path $manifestFileName -Force
    }

    # Run the Quality Checks
    Write-Verbose "Invoking PSQualityCheck"
    Import-Module -Name PSQualityCheck -MinimumVersion "1.2.0"

    foreach ($function in $sourcePublicFiles) {

        Write-Verbose "Public function $($function.Name)"
        Invoke-PSQualityCheck -File $function.FullName @PSQualityCheckSplat

    }

    foreach ($function in $sourcePrivateFiles) {

        Write-Verbose "Private function $($function.Name)"
        Invoke-PSQualityCheck -File $function.FullName @PSQualityCheckSplat

    }

    Remove-Module -Name PSQualityCheck

    # Run the Unit Tests
    # Write-Verbose "Invoking Unit tests"

    # $configuration = [PesterConfiguration]::Default
    # $configuration.Run.Exit = $true
    # $configuration.CodeCoverage.Enabled = $false
    # $configuration.TestResult.Enabled = $false
    # $configuration.Output.Verbosity = "Detailed"
    # $configuration.Run.PassThru = $false
    # $configuration.Should.ErrorAction = 'Stop'

    # foreach ($function in $sourcePublicFiles) {

    #     . $function.FullName
    #     $script = "..\Tests\Unit\$($module.Name)\$($function.BaseName).Tests.ps1"
    #     Write-Verbose "Executing test $script"

    #     $configuration.Run.Path = $script
    #     Invoke-Pester -Configuration $configuration

    # }

    # foreach ($function in $sourcePrivateFiles) {

    #     . $function.FullName
    #     $script = "..\Tests\Unit\$($module.Name)\$($function.BaseName).Tests.ps1"
    #     Write-Verbose "Executing test $script"

    #     $configuration.Run.Path = $script
    #     Invoke-Pester -Configuration $configuration

    # }

    $functionsToExport = @()

    # Build up the module from public and private functions
    Write-Verbose "Generating Module"
    foreach ($function in $sourcePublicFiles) {

        Write-Verbose "Adding function $($function.Name)"
        Get-Content -Path $function.FullName | Add-Content -Path $moduleFileName

        $functionsToExport += $function.BaseName

        "" | Add-Content -Path $moduleFileName

    }

    foreach ($function in $sourcePrivateFiles) {

        Write-Verbose "Adding function $($function.Name)"
        Get-Content -Path $function.FullName | Add-Content -Path $moduleFileName

        "" | Add-Content -Path $moduleFileName

    }

    if (-not (Test-Path -Path $moduleFileName)) {
        continue
    }

    $newModuleManifest = @{
        Path = $manifestFileName
        Guid = $buildProperties.Module.Guid.($module.Name)
        RootModule = ("{0}{1}" -f $module.Name, '.psm1')

        ModuleVersion = $buildProperties.Module.Version.($module.Name)
        PowerShellVersion = $buildProperties.Module.PowerShellVersion

        FunctionsToExport = $functionsToExport
        CmdletsToExport = @()
        VariablesToExport = @()
        AliasesToExport = @()

        Author = $buildProperties.Module.Author
        Company = $buildProperties.Module.Company
        Copyright = $buildProperties.Module.Copyright
        Description = $buildProperties.Module.Description.($module.Name)
        FileList = $buildProperties.Module.FileList.($module.Name)
        HelpInfoURI = $buildProperties.Module.HelpInfoURI
        LicenseUri = $buildProperties.Module.LicenseUri
        ProjectUri = $buildProperties.Module.ProjectUri
        Tags = $buildProperties.Module.Tags

        NestedModules = $buildProperties.Module.NestedModules.($module.Name)

    }

    try {
        Write-Verbose "Generating Manifest"
        $manifest = New-ModuleManifest @newModuleManifest
    }
    catch {
        Write-Error "Error generating manifest $_"
    }

    $functionsToExport = $null

}

foreach ($manifest in $manifestsToTest) {
    try {
        Write-Verbose "Testing Manifest $manifest"
        $result = Test-ModuleManifest -Path $manifest
        Write-Verbose "Pass"
    }
    catch {
        Write-Error "Fail"
    }
}
