function Invoke-PSQualityCheck {
    <#
        .SYNOPSIS
        Invoke the PSQualityCheck tests

        .DESCRIPTION
        Invoke a series of Pester-based quality tests on the passed files

        .PARAMETER Path
        A string array containing paths to check for testable files

        .PARAMETER File
        A string array containing testable files

        .PARAMETER SonarQubeRulesPath
        A path the the external PSScriptAnalyzer rules for SonarQube

        .PARAMETER ShowCheckResults
        Show a summary of the Check results at the end of processing

        .EXAMPLE
        Invoke-PSQualityCheck -Path 'C:\Scripts'

        This will call the quality checks on single path

        .EXAMPLE
        Invoke-PSQualityCheck -Path @('C:\Scripts', 'C:\MoreScripts')

        This will call the quality checks with multiple paths

        .EXAMPLE
        Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1'

        This will call the quality checks with single script file

        .EXAMPLE
        Invoke-PSQualityCheck -File 'C:\Scripts\Script.psm1'

        This will call the quality checks with single module file

        .EXAMPLE
        Invoke-PSQualityCheck -File 'C:\Scripts\Script.psd1'

        This will call the quality checks with single datafile file
        Note: The datafile test will fail as it is not a file that is accepted for testing

        .EXAMPLE
        Invoke-PSQualityCheck -File @('C:\Scripts\Script.ps1','C:\Scripts\Script2.ps1')

        This will call the quality checks with multiple files. Files can be either scripts or modules

        .EXAMPLE
        Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1' -SonarQubeRulesPath 'C:\SonarQubeRules'

        This will call the quality checks with single file and the extra PSScriptAnalyzer rules used by SonarQube

        .EXAMPLE
        Invoke-PSQualityCheck -Path 'C:\Scripts' -ShowCheckResults

        This will display a summary of the checks performed (example below uses sample data):

            Name                            Files Tested Total Passed Failed Skipped
            ----                            ------------ ----- ------ ------ -------
            Module Tests                               2    14     14      0       0
            Extracting functions                       2     2      2      0       0
            Extracted function script tests           22   330    309      0      21
            Total                                     24   346    325      0      21

        For those who have spotted that the Total files tested isn't a total of the rows above, this is because the Module Tests and Extracting function Tests operate on the same file and are then not counted twice

        .LINK
        Website: https://github.com/andrewrdavidson/PSQualityCheck
        SonarQube rules are available here: https://github.com/indented-automation/ScriptAnalyzerRules

    #>
    [CmdletBinding()]
    [OutputType([System.Void], [HashTable])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [String[]]$Path,
        [Parameter(Mandatory = $true, ParameterSetName = "File")]
        [String[]]$File,

        [Parameter(Mandatory = $false)]
        [String]$SonarQubeRulesPath,

        [switch]$ShowCheckResults
    )

    Set-StrictMode -Version Latest

    # External Modules
    Import-Module -Name "Pester" -MinimumVersion "5.1.0" -Force
    Import-Module -Name "PSScriptAnalyzer" -MinimumVersion "1.19.1" -Force

    $modulePath = (Get-Module -Name PSQualityCheck).ModuleBase

    # Analyse the incoming Path and File parameters and produce a list of Modules and Scripts

    $scriptsToTest = @()
    $modulesToTest = @()

    if ($PSBoundParameters.ContainsKey('Path')) {

        if ($Path -isnot [string[]]) {
            $Path = @($Path)
        }

        foreach ($item in $Path) {

            # Test whether the item is a directory (also tells us if it exists)
            if (Test-Path -Path $item -PathType Container) {

                $scriptsToTest += Get-FileList -Path $item -Extension ".ps1"
                $modulesToTest += Get-FileList -Path $item -Extension ".psm1"

            }
            else {

                Write-Warning -Message "$item is not a directory, skipping"

            }

        }

    }

    if ($PSBoundParameters.ContainsKey('File')) {

        if ($File -isnot [string[]]) {
            $File = @($File)
        }

        foreach ($item in $File) {

            # Test whether the item is a file (also tells us if it exists)
            if (Test-Path -Path $item -PathType Leaf) {

                $itemProperties = Get-ChildItem -Path $item

                switch ($itemProperties.Extension) {

                    '.psm1' {
                        $modulesToTest += $itemProperties
                    }

                    '.ps1' {
                        $scriptsToTest += $itemProperties
                    }

                }

            }
            else {

                Write-Warning -Message "$item is not a file, skipping"

            }

        }

    }

    # Default Pester Parameters
    $configuration = [PesterConfiguration]::Default
    $configuration.Run.Exit = $false
    $configuration.CodeCoverage.Enabled = $false
    $configuration.Output.Verbosity = "Detailed"
    $configuration.Run.PassThru = $true
    $configuration.Should.ErrorAction = 'Stop'

    $moduleResults = $null
    $extractionResults = $null
    $extractedScriptResults = $null
    $scriptResults = $null

    if ($modulesToTest.Count -ge 1) {

        # Location of files extracted from any passed modules
        $functionExtractPath = Join-Path -Path $Env:TEMP -ChildPath (New-Guid).Guid

        # Run the Module tests on all the valid module files found
        $container1 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath "Tests\Module.Tests.ps1") -Data @{ Source = $modulesToTest }
        $configuration.Run.Container = $container1
        $moduleResults = Invoke-Pester -Configuration $configuration

        # Extract all the functions from the modules into individual .ps1 files ready for testing
        $container2 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath "Tests\Function-Extraction.Tests.ps1") -Data @{ Source = $modulesToTest; FunctionExtractPath = $functionExtractPath }
        $configuration.Run.Container = $container2
        $extractionResults = Invoke-Pester -Configuration $configuration

        # Get a list of the 'extracted' function scripts .ps1 files
        $extractedScriptsToTest = Get-ChildItem -Path $functionExtractPath -Include '*.ps1' -Recurse

        # Run the Script tests against all the extracted functions .ps1 files
        $container3 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath "Tests\Script.Tests.ps1") -Data @{ Source = $extractedScriptsToTest; SonarQubeRules = $SonarQubeRulesPath }
        $configuration.Run.Container = $container3
        $extractedScriptResults = Invoke-Pester -Configuration $configuration

    }

    if ($scriptsToTest.Count -ge 1) {

        # Run the Script tests against all the valid script files found
        $container3 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath "Tests\Script.Tests.ps1") -Data @{ Source = $scriptsToTest; SonarQubeRules = $SonarQubeRulesPath }
        $configuration.Run.Container = $container3
        $scriptResults = Invoke-Pester -Configuration $configuration

    }

    if ($PSBoundParameters.ContainsKey('ShowCheckResults')) {

        $qualityCheckResults = @()
        $filesTested = $total = $passed = $failed = $skipped = 0

        if ($null -ne $moduleResults) {
            $qualityCheckResults +=
            @{
                'Test' = 'Module Tests'
                'Files Tested' = $ModulesToTestCount
                'Total' = $moduleResults.TotalCount
                'Passed' = $moduleResults.PassedCount
                'Failed' = $moduleResults.FailedCount
                'Skipped' = $moduleResults.SkippedCount
            }
            $filesTested += $ModulesToTestCount
            $total += $moduleResults.TotalCount
            $passed += $moduleResults.PassedCount
            $failed += $moduleResults.FailedCount
            $skipped += $moduleResults.SkippedCount
        }
        if ($null -ne $extractionResults) {
            $qualityCheckResults +=
            @{
                'Test' = 'Extracting functions'
                'Files Tested' = $ModulesToTestCount
                'Total' = $extractionResults.TotalCount
                'Passed' = $extractionResults.PassedCount
                'Failed' = $extractionResults.FailedCount
                'Skipped' = $extractionResults.SkippedCount
            }
            $total += $extractionResults.TotalCount
            $passed += $extractionResults.PassedCount
            $failed += $extractionResults.FailedCount
            $skipped += $extractionResults.SkippedCount
        }
        if ($null -ne $extractedScriptResults) {
            $qualityCheckResults +=
            @{
                'Test' = 'Extracted function script tests'
                'Files Tested' = $extractedScriptsToTestCount
                'Total' = $extractedScriptResults.TotalCount
                'Passed' = $extractedScriptResults.PassedCount
                'Failed' = $extractedScriptResults.FailedCount
                'Skipped' = $extractedScriptResults.SkippedCount
            }
            $filesTested += $extractedScriptsToTestCount
            $total += $extractedScriptResults.TotalCount
            $passed += $extractedScriptResults.PassedCount
            $failed += $extractedScriptResults.FailedCount
            $skipped += $extractedScriptResults.SkippedCount
        }
        if ($null -ne $scriptResults) {
            $qualityCheckResults +=
            @{
                'Test' = "Script Tests"
                'Files Tested' = $scriptsToTestCount
                'Total' = $scriptResults.TotalCount
                'Passed' = $scriptResults.PassedCount
                'Failed' = $scriptResults.FailedCount
                'Skipped' = $scriptResults.SkippedCount
            }
            $filesTested += $scriptsToTestCount
            $total += $scriptResults.TotalCount
            $passed += $scriptResults.PassedCount
            $failed += $scriptResults.FailedCount
            $skipped += $scriptResults.SkippedCount
        }
        $qualityCheckResults +=
        @{
            'Test' = "Total"
            'Files Tested' = $filesTested
            'Total' = $total
            'Passed' = $passed
            'Failed' = $failed
            'Skipped' = $skipped
        }

        # This works on PS5
        $qualityCheckResults | ForEach-Object {
            [PSCustomObject]@{
                'Test' = $_.Test
                'Files Tested' = $_.'Files Tested'
                'Total' = $_.total
                'Passed' = $_.passed
                'Failed' = $_.failed
                'Skipped' = $_.skipped
            } } | Format-Table -AutoSize

        # This works on PS7 not on PS5
        # $qualityCheckResults | Select-Object Name, 'Files Tested', Total, Passed, Failed, Skipped | Format-Table -AutoSize

    }

}
