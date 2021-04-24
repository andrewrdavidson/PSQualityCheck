Import-Module -Name Pester -MinimumVersion 5.1.0
Import-Module -Name PSQualityCheck -MinimumVersion 1.3.0

$InformationPreference = 'Continue'

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

function Get-FunctionFileContent {
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $fileContent = Get-Content -Path $Path
        $parserErrors = $null
        if ([string]::IsNullOrEmpty($fileContent)) {
            $parsedFileFunctions = @()
        }
        else {
            $parsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$parserErrors)
        }
        $parsedFunctions = ($parsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })
        if ($parsedFunctions.Count -gt 1) {
            throw "Too many functions in file, file is invalid"
        }
        if ($parsedFunctions.Count -eq 1) {
            if ($fileContent.Count -gt 1) {
                foreach ($function in $parsedFunctions) {
                    $startLine = ($function.StartLine)
                    for ($line = $fileContent.Count; $line -gt $function.StartLine; $line--) {
                        if ($fileContent[$line] -like "*}*") {
                            $endLine = $line
                            break
                        }
                    }
                    for ($line = $startLine; $line -lt $endLine; $line++) {
                        $parsedFileContent += $fileContent[$line]
                        if ($line -ne ($fileContent.Count - 1)) {
                            $parsedFileContent += "`r`n"
                        }
                    }
                }
            }
            else {
                [int]$startBracket = $fileContent.IndexOf('{')
                [int]$endBracket = $fileContent.LastIndexOf('}')
                $parsedFileContent = $fileContent.substring($startBracket + 1, $endBracket - 1 - $startBracket)
            }
        }
        else {
            if ($fileContent.Count -gt 1) {
                for ($line = 0; $line -lt $fileContent.Count; $line++) {
                    $parsedFileContent += $fileContent[$line]
                    if ($line -ne ($fileContent.Count - 1)) {
                        $parsedFileContent += "`r`n"
                    }
                }
            }
            else {
                $parsedFileContent = $fileContent
            }
        }
    }
    catch {
        throw
    }
    return $parsedFileContent
}

# Project Based
# $qualityResult = Invoke-PSQualityCheck -ProjectPath '.\' -ScriptAnalyzerRulesPath $ScriptRules -HelpRulesPath '.\HelpRules.psd1' -Passthru -PesterConfiguration $PesterConfiguration

# if ($qualityResult.Script.FailedCount -eq 0 -and $qualityResult.Project.FailedCount -eq 0) {
if ($true) {

    $Modules = Get-ChildItem -Path ".\Source" -Directory

    $functionResults = @()

    foreach ($module in $Modules) {

        $functionFiles = @()
        # $privateFunctionFiles = @()

        $functionFiles += Get-ChildItem -Path (Join-Path -Path $Module.FullName -ChildPath "public")

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

            # Write-Host ".\tests\unit\$($module.BaseName)\$($function.BaseName).Tests.psd1" -ForegroundColor Yellow
            # Write-Host $function.FullName -ForegroundColor Yellow

            $fileContent = Get-FunctionFileContent -Path $function.FullName
            . "$($function.FullName)"

            $container = New-PesterContainer -Path ".\tests\unit\$($module.BaseName)\$($function.BaseName).Tests.ps1" -Data @{FileContent = $fileContent }
            $PesterConfiguration.Run.Container = $container

            $functionResults += Invoke-Pester -Configuration $PesterConfiguration

        }
    }
}
else {

    # Write-Information 'Functions not tested - there were project quality check errors'
    # Write-Warning -Message "Project Quality Check fails"
    Write-Error -Message "Project Quality Check fails"
    break

}

$failedCount = 0

foreach ($result in $functionResults) {
    $failedCount += $result.FailedCount
}

if ($failedCount -eq 0 ) {

    foreach ($module in $Modules) {

        $buildFile = ".\source\$($module.BaseName)\build.psd1"
        Write-Host $buildFile -ForegroundColor Yellow

        Build-Module -SourcePath $buildFile

    }
}
else {

    Write-Information 'Modules not build - there were errors'
    throw

}

# End of module build

# Script checks
$scriptFiles = Get-ChildItem -Path ".\Scripts" -Filter "*.ps1" -Recurse

$scriptResults = @()

foreach ($script in $scriptFiles) {

    $Result = Invoke-PSQualityCheck -File $script.FullName -ScriptAnalyzerRulesPath $ScriptRules -HelpRulesPath '.\HelpRules.psd1' -Passthru -PesterConfiguration $PesterConfiguration

    $folder = Split-Path -Path $script.DirectoryName -Leaf

    Write-Host ".\tests\scripts\$folder\$($script.BaseName).Tests.ps1"
    if ((Test-Path -Path ".\tests\scripts\$folder\$($script.BaseName).Tests.ps1") -and $result.Script.FailedCount -eq 0) {

        $fileContent = Get-FunctionFileContent -Path $script.FullName

        $container = New-PesterContainer -Path ".\tests\scripts\$folder\$($script.BaseName).Tests.ps1" -Data @{FileContent = $fileContent }
        $PesterConfiguration.Run.Container = $container

        $scriptResults += Invoke-Pester -Configuration $PesterConfiguration

    }

}




# $Result = Invoke-PSQualityCheck -Path @('.\Scripts') -recurse -ScriptAnalyzerRulesPath $ScriptRules -HelpRulesPath '.\HelpRules.psd1' -Passthru -PesterConfiguration $PesterConfiguration

# if ($Result.Script.FailedCount -eq 0) {

#     $Dest = ".\artifacts"
#     # Copy Script files to release folder
#     New-Item -ItemType Directory -Force -Path $Dest
#     Copy-Item ".\Scripts\*.*" -Destination $Dest -Recurse -Force
# }
# else {
#     Write-Information 'Scripts not exported - there were errors'
# }
