[CmdletBinding()]
[OutputType([System.Void])]
param (
    [switch]$Install
)

Import-Module -Name Pester -MinimumVersion 5.1.0
Import-Module -Name Cofl.Util -MinimumVersion 1.2.2
Import-Module -Name ".\build-functions.psm1" -Force

$InformationPreference = 'Continue'
$ErrorActionPreference = 'Stop'

# PesterConfiguration
$PesterConfiguration = [PesterConfiguration]::Default
$PesterConfiguration.Run.Exit = $false
$PesterConfiguration.CodeCoverage.Enabled = $false
$PesterConfiguration.Output.Verbosity = 'Detailed'
$PesterConfiguration.Run.PassThru = $true
$PesterConfiguration.Should.ErrorAction = 'Stop'

$ScriptRules = @(
    '../ScriptAnalyzerRules/Indented.CodingConventions/'
    #, './Analyzer/PSScriptAnalyzer/Tests/Engine/CommunityAnalyzerRules/'
    #, './Analyzer/InjectionHunter/'
)

$projectPath = Resolve-Path -Path ".\"
$sourcePath = Resolve-Path -Path "$projectPath\source"
$scriptsPath = Resolve-Path -Path "$projectPath\scripts"
$testsPath = Resolve-Path -Path "$projectPath\tests"
$ignoreFile = Resolve-Path -Path ".psqcignore"
$moduleName = "PSQualityCheck"

$buildFolder = Join-Path -Path "$projectPath" -ChildPath "build"
$artifactsFolder = Join-Path -Path "$projectPath" -ChildPath "artifacts"

if (-not (Test-Path -Path $artifactsFolder -ErrorAction SilentlyContinue)) {
    New-Item -Path $artifactsFolder -ItemType "directory" -Force
}
if (-not (Test-Path -Path $buildFolder -ErrorAction SilentlyContinue)) {
    New-Item -Path $buildFolder -ItemType "directory" -Force
}

$modules = Get-ChildItem -Path $sourcePath -Directory

Write-Host "BUILD> Build bootstrap version of PSQualityCheck" -ForegroundColor Black -BackgroundColor Gray

# Create a bootstrap built version of the module (pre-testing)
# to allow us to use this module (PSQualityCheck) to test itself whilst building
try {
    foreach ($module in $modules) {

        $repositoryName = "$module-local"
        # QUERY: Why not just do Remove-Module -Name $module ? It will do nothing if there is no module loaded ?
        if ($module -in ((Get-Module) | Select-Object -Property Name)) {
            Remove-Module $module
        }

        $buildPropertiesFile = "$sourcePath\$($module.BaseName)\build.psd1"
        Write-Host $buildPropertiesFile
        Build-Module -SourcePath $buildPropertiesFile

        if ($repositoryName -in ((Get-PSRepository) | Select-Object -Property Name)) {
            Unregister-PSRepository -Name $repositoryName
        }

        Publish-BuiltModule -Module $moduleName -ArtifactsFolder $artifactsFolder -BuildFolder $buildFolder -SourceFolder $sourcePath -Clean

        Install-BuiltModule -Module $moduleName

    }
}
catch {
    # try and tidy up?
    # foreach ($module in $modules) {
    #     Uninstall-BuiltModule -Module $module
    #     Unpublish-BuiltModule -Module $module -SourceFolder $sourcePath -ArtifactsFolder $artifactsFolder
    # }
    throw $_
    break
}

# Start of Project Based checks
Write-Host "BUILD> Running PSQualityCheck Project checks" -ForegroundColor Black -BackgroundColor Gray

$qualityCheckSplat = @{
    'ProjectPath'             = $projectPath
    'ScriptAnalyzerRulesPath' = $ScriptRules
    'HelpRulesPath'           = (Resolve-Path -Path '.\HelpRules.psd1')
    'Passthru'                = $true
    'PesterConfiguration'     = $PesterConfiguration
    'IgnoreFile'              = $ignoreFile
}
$qualityCheckResult = Invoke-PSQualityCheck @qualityCheckSplat
# End of Project Based checks

# unpublish and remove the bootstrap version of the modules
Write-Host "BUILD> Uninstall and Unpublish bootstrap modules" -ForegroundColor Black -BackgroundColor Gray
foreach ($module in $modules) {
    Uninstall-BuiltModule -Module $module.Name
    Unpublish-BuiltModule -Module $module.Name -SourceFolder $sourcePath -ArtifactsFolder $artifactsFolder
}

# Running tests
if ($qualityCheckResult.Script.FailedCount -ne 0 -or $qualityCheckResult.Project.FailedCount -ne 0) {

    Write-Error -Message "Project quality check failed"

}

# Run the unit tests for the public functions of any modules in the project
Write-Host "BUILD> Running unit tests for functions" -ForegroundColor Black -BackgroundColor Gray

$unitTestResults = @()

# Get the modules (the directories in the Source folder)
$modules = Get-ChildItem -Path $sourcePath -Directory

foreach ($module in $modules) {

    # Get the public functions (minus any excluded by the ignore file)
    $functionFiles = @()
    $functionFiles += Get-FilteredChildItem -Path (Join-Path -Path $module.FullName -ChildPath "public") -IgnoreFileName $ignoreFile

    # If there are any scripts in the private folder with corresponding tests then run those too
    # $privateFunctionFiles += Get-ChildItem -Path (Join-Path -Path $Module.FullName -ChildPath "private")
    # Write-Host $privateFunctionFiles.Count -ForegroundColor Yellow
    # foreach ($function in $privateFunctionFiles) {
    #     Write-Host $function.FullName -ForegroundColor Yellow
    #     if (Test-Path -Path ".\tests\unit\$($module.BaseName)\$($function.BaseName).Tests.ps1") {
    #         $functionFiles += (Get-ChildItem -Path ".\tests\unit\$($module.BaseName)\$($function.BaseName).Tests.ps1")
    #     }
    # }

    foreach ($function in $functionFiles) {

        $fileContent = Get-FunctionFileContent -Path $function.FullName
        . "$($function.FullName)"

        $container = New-PesterContainer -Path "$testsPath\unit\$($module.BaseName)\$($function.BaseName).Tests.ps1" -Data @{FileContent = $fileContent }
        $PesterConfiguration.Run.Container = $container

        $unitTestResults += Invoke-Pester -Configuration $PesterConfiguration

    }
}

$unitTestFailedCount = 0
foreach ($result in $unitTestResults) {
    $unitTestFailedCount += $result.FailedCount
}

# Check to see whether the unit tests have failed
if ($unitTestFailedCount -ne 0 ) {
    Write-Error -Message 'One or more module were not built because there were function unit test errors'
    throw $_
}

# TODO: Add integration tests here


# End of running tests

# Run any available unit tests for files in Scripts folder
Write-Host "BUILD> Running unit tests for scripts" -ForegroundColor Black -BackgroundColor Gray

$scriptFiles = @()
$scriptTestResults = @()
$scriptTestFailedCount = 0
$scriptFiles = Get-FilteredChildItem -Path $scriptsPath -IgnoreFileName $ignoreFile
foreach ($scriptFile in $scriptFiles) {

    $scriptFolder = $scriptFile.FullName -ireplace [regex]::Escape($scriptsPath.Path), ''
    $scriptFolder = $scriptFolder -ireplace [regex]::Escape($scriptFile.Name), ''

    $fileContent = Get-FunctionFileContent -Path $scriptFile.FullName
    try {
        $testFile = Resolve-Path -Path "$testsPath\scripts$scriptFolder\$($scriptFile.BaseName).Tests.ps1"

        $container = New-PesterContainer -Path $testFile -Data @{FileContent = $fileContent }
        $PesterConfiguration.Run.Container = $container

        $scriptTestResults += Invoke-Pester -Configuration $PesterConfiguration
    }
    catch {
        Write-Output "No test file"
    }

}

foreach ($result in $scriptTestResults) {
    $scriptTestFailedCount += $result.FailedCount
}
if ($scriptTestFailedCount -ne 0 ) {
    Write-Error -Message 'One or more scripts failed unit test'
    throw $_
}
## End of bootstrap build and tests

# Start of final module build
# Build the module(s) only if there are no unit/integration test failures

Write-Host "BUILD> Building final version of module" -ForegroundColor Black -BackgroundColor Gray
try {
    foreach ($module in $modules) {

        # QUERY: Why not just do Remove-Module -Name $module ? It will do nothing if there is no module loaded ?
        if ($module -in ((Get-Module) | Select-Object -Property Name)) {
            Remove-Module $module
        }

        $buildPropertiesFile = "$sourcePath\$($module.BaseName)\build.psd1"
        Write-Host $buildPropertiesFile
        Build-Module -SourcePath $buildPropertiesFile
    }
}
catch {
    throw $_
    break
}

# If there are no script failures then copy the scripts to the build folder and archive to the Artifacts folder
Write-Host "BUILD> Building script archive" -ForegroundColor Black -BackgroundColor Gray
$builtScriptsFolder = Join-Path -Path $buildFolder -ChildPath "scripts"

if (-not (Test-Path -Path $builtScriptsFolder -ErrorAction SilentlyContinue)) {
    New-Item -Path $buildFolder -Name "scripts" -ItemType 'Directory' -Force
}

Copy-Item -Path "Scripts" -Destination $buildFolder -Recurse -Force -Container
# End of script copy

$archiveFile = "$artifactsFolder\scripts.zip"

if (Test-Path -Path $archiveFile) {
    Remove-Item -Path $archiveFile -Force
}
# Create archive of scripts into artifacts
$compressSplat = @{
    Path             = $builtScriptsFolder
    CompressionLevel = "Fastest"
    DestinationPath  = "$artifactsFolder\scripts.zip"
}
Compress-Archive @compressSplat
# End of create archive

# End of final module build

# Publish the final built modules
foreach ($module in $modules) {
    Write-Host "BUILD> Publish final built module: $module" -ForegroundColor Black -BackgroundColor Gray
    $repositoryName = "$module-local"

    Publish-BuiltModule -Module $module.Name -ArtifactsFolder $artifactsFolder -BuildFolder $buildFolder -SourceFolder $sourcePath -Clean

    # Optionally install
    if ($PSBoundParameters.ContainsKey('Install')) {
        Write-Host "BUILD> Install final built module: $module" -ForegroundColor Black -BackgroundColor Gray
        Install-BuiltModule -Module $module.Name
    }

}

### END OF SCRIPT
