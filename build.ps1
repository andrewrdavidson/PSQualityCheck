Import-Module -Name Pester -MinimumVersion 5.1.0
Import-Module -Name Cofl.Util -MinimumVersion 1.2.2
Import-Module -Name ".\build-functions.psm1"

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
    New-Item -Path $artifactsFolder -ItemType "directory" -force
}
if (-not (Test-Path -Path $buildFolder -ErrorAction SilentlyContinue)) {
    New-Item -Path $buildFolder -ItemType "directory" -force
}

$modules = Get-ChildItem -Path $sourcePath -Directory

# Create a built version of the module (pre-testing)
# to allow us to use this module (PSQualityCheck) to test itself whist building
try {
    foreach ($module in $modules) {

        if ($module -in ((Get-Module) | Select-Object -Property Name)) {
            Remove-Module $module
        }

        $buildPropertiesFile = "$sourcePath\$($module.BaseName)\build.psd1"
        Write-Host $buildPropertiesFile
        Build-Module -SourcePath $buildPropertiesFile
    }
}
catch {
    throw "Build failed"
    break
}

if ("$moduleName-local" -in ((Get-PSRepository) | Select-Object -Property Name)) {
    unRegister-PSRepository -Name "$moduleName-local"
}

Publish-BuiltModule -Module $moduleName -ArtifactsFolder $artifactsFolder -BuildFolder $buildFolder -Clean

Install-BuiltModule -Module $moduleName

# Start of Project Based checks
$qualityCheckSplat = @{
    'ProjectPath'             = $projectPath
    'ScriptAnalyzerRulesPath' = $ScriptRules
    'HelpRulesPath'           = (Resolve-Path -Path '.\HelpRules.psd1')
    'Passthru'                = $true
    'PesterConfiguration'     = $PesterConfiguration
    'IgnoreFile'              = $ignoreFile
}
$qualityResult = Invoke-PSQualityCheck @qualityCheckSplat
# End of Project Based checks

# Running tests
if ($qualityResult.Script.FailedCount -eq 0 -and $qualityResult.Project.FailedCount -eq 0) {

    $testResults = @()

    # Run the unit tests for the public functions of any modules in the project

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

            $testResults += Invoke-Pester -Configuration $PesterConfiguration

        }
    }

    # TODO: Add integration tests here

}
else {
    # Write-Information 'Functions not tested - there were project quality check errors'
    # Write-Warning -Message "Project Quality Check fails"
    Write-Error -Message "Project quality check failed"
    break
}
# End of running tests

# Start of module build
# Build the module(s) only if there are no unit/integration test failures
$testFailedCount = 0

foreach ($result in $testResults) {
    $testFailedCount += $result.FailedCount
}

if ($testFailedCount -eq 0 ) {
    # foreach ($module in $modules) {
    #     $buildPropertiesFile = ".\source\$($module.BaseName)\build.psd1"
    #     Build-Module -SourcePath $buildPropertiesFile
    # }
}
else {
    Write-Error -Message 'One or more module were not built because there were function unit test errors'
    throw
}
# End of module build

# Run any available unit tests for files in Scripts folder
$scriptFiles = @()
$testResults = @()
$scriptFiles += Get-FilteredChildItem -Path $scriptsPath -IgnoreFileName $ignoreFile
foreach ($scriptFile in $scriptFiles) {

    $scriptFolder = $scriptFile.FullName -ireplace [regex]::Escape($scriptsPath.Path), ''
    $scriptFolder = $scriptFolder -ireplace [regex]::Escape($scriptFile.Name), ''

    $fileContent = Get-FunctionFileContent -Path $scriptFile.FullName

    $container = New-PesterContainer -Path "$testsPath\scripts$scriptFolder\$($scriptFile.BaseName).Tests.ps1" -Data @{FileContent = $fileContent }
    $PesterConfiguration.Run.Container = $container

    $testResults += Invoke-Pester -Configuration $PesterConfiguration

}

$testFailedCount = 0

foreach ($result in $testResults) {
    $testFailedCount += $result.FailedCount
}

# If there are no script failures then copy the scripts to the build folder and archive to the Artifacts folder
if ($testFailedCount -eq 0) {

    $builtScriptsFolder = Join-Path -Path $buildFolder -ChildPath "scripts"

    if (-not (Test-Path -Path $builtScriptsFolder -ErrorAction SilentlyContinue)) {
        New-Item -Path $buildFolder -Name "scripts" -ItemType "directory" -force
    }

    Copy-Item -Path "Scripts" -Destination $buildFolder -Recurse -Force -Container

    $compressSplat = @{
        Path             = $builtScriptsFolder
        CompressionLevel = "Fastest"
        DestinationPath  = "$artifactsFolder\scripts.zip"
    }
    Compress-Archive @compressSplat
}
else {
    Write-Error -Message "Scripts were not copied to artifacts folder because there were failed unit tests"
    break
}
# End of script copy

Uninstall-BuiltModule -Module $moduleName
Unpublish-BuiltModule -Module $moduleName

### END OF SCRIPT
