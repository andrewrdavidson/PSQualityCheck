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

        .PARAMETER Recurse
        A switch specifying whether or not to recursively search the path specified

        .PARAMETER ScriptAnalyzerRulesPath
        A path the the external PSScriptAnalyzer rules

        .PARAMETER ShowCheckResults
        Show a summary of the Check results at the end of processing

        .PARAMETER ExportCheckResults
        Exports the Check results at the end of processing to file

        .PARAMETER Passthru
        Returns the Check results objects back to the caller

        .PARAMETER PesterConfiguration
        A Pester configuration object to allow configuration of Pester

        .PARAMETER Include
        An array of test tags to run

        .PARAMETER Exclude
        An array of test tags to not run

        .EXAMPLE
        Invoke-PSQualityCheck -Path 'C:\Scripts'

        This will call the quality checks on single path

        .EXAMPLE
        Invoke-PSQualityCheck -Path 'C:\Scripts' -Recurse

        This will call the quality checks on single path and sub folders

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
        Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1' -ScriptAnalyzerRulesPath 'C:\ScriptAnalyzerRulesPath'

        This will call the quality checks with single file and the extra PSScriptAnalyzer rules

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
    [OutputType([System.Void], [HashTable], [System.Object[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [String[]]$Path,
        [Parameter(Mandatory = $true, ParameterSetName = "File")]
        [String[]]$File,

        [Parameter(Mandatory = $false, ParameterSetName = "Path")]
        [switch]$Recurse,

        [Parameter(Mandatory = $false)]
        [String[]]$ScriptAnalyzerRulesPath,

        [switch]$ShowCheckResults,

        [switch]$ExportCheckResults,

        [switch]$Passthru,

        [Parameter(Mandatory = $false)]
        [System.Object]$PesterConfiguration,

        [Parameter(Mandatory = $false)]
        [String[]]$Include,

        [Parameter(Mandatory = $false)]
        [String[]]$Exclude

    )

    Set-StrictMode -Version Latest

    # External Modules
    Import-Module -Name 'Pester' -MinimumVersion '5.1.0' -Force
    Import-Module -Name 'PSScriptAnalyzer' -MinimumVersion '1.19.1' -Force

    $modulePath = (Get-Module -Name 'PSQualityCheck').ModuleBase

    # Analyse the incoming Path and File parameters and produce a list of Modules and Scripts

    $scriptsToTest = @()
    $modulesToTest = @()

    Write-Verbose "Starting" -Verbose

    if ($PSBoundParameters.ContainsKey('Path')) {

        Write-Verbose 'Found Path in $PSBoundParameters' -Verbose

        if ($Path -isnot [string[]]) {
            $Path = @($Path)
        }

        foreach ($item in $Path) {

            # Test whether the item is a directory (also tells us if it exists)
            if (Test-Path -Path $item -PathType Container) {

                $getFileListSplat = @{
                    'Path' = $item
                }
                if ($PSBoundParameters.ContainsKey('Recurse')) {
                    $getFileListSplat.Add('Recurse', $true)
                }

                $scriptsToTest += Get-FileList @getFileListSplat -Extension '.ps1'
                $modulesToTest += Get-FileList @getFileListSplat -Extension '.psm1'

            }
            else {

                Write-Warning -Message "$item is not a directory, skipping"

            }

        }

    }

    if ($PSBoundParameters.ContainsKey('File')) {

        Write-Verbose 'Found File in $PSBoundParameters' -Verbose

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

    if ($PSBoundParameters.ContainsKey('PesterConfiguration') -and $PesterConfiguration -is [PesterConfiguration]) {

        # left here so that we can over-ride passed in object with values we require

    }
    else {
        # Default Pester Parameters
        $PesterConfiguration = [PesterConfiguration]::Default
        $PesterConfiguration.Run.Exit = $false
        $PesterConfiguration.CodeCoverage.Enabled = $false
        $PesterConfiguration.Output.Verbosity = 'Detailed'
        $PesterConfiguration.Run.PassThru = $true
        $PesterConfiguration.Should.ErrorAction = 'Stop'
    }

    # Get the list of test tags from the checks files
    if ($PSBoundParameters.ContainsKey('Include') -or
        $PSBoundParameters.ContainsKey('Exclude')) {

        Write-Verbose 'Getting Tags' -Verbose

        ($moduleTags, $scriptTags) = Get-TagList
        $moduleTagsToInclude = @()
        $moduleTagsToExclude = @()
        $scriptTagsToInclude = @()
        $scriptTagsToExclude = @()
        $runModuleCheck = $false
        $runScriptCheck = $false

        Write-Verbose "Got ModuleTags: $ModuleTags" -Verbose
        Write-Verbose "Got scriptTags: $scriptTags" -Verbose

    }
    else {
        $runModuleCheck = $true
        $runScriptCheck = $true
    }

    if ($PSBoundParameters.ContainsKey('Include')) {

        Write-Verbose 'Processing -Include' -Verbose
        if ($Include -eq 'All') {
            $moduleTagsToInclude = $moduleTags
            $scriptTagsToInclude = $scriptTags
            $runModuleCheck = $true
            $runScriptCheck = $true
        }
        else {
            # Validate tests to include from $Include
            $Include | ForEach-Object {
                if ($_ -in $moduleTags) {
                    $moduleTagsToInclude += $_
                    $runModuleCheck = $true
                    #* To satisfy PSScriptAnalyzer
                    $runModuleCheck = $runModuleCheck
                    $runScriptCheck = $runScriptCheck
                }
            }
            $Include | ForEach-Object {
                if ($_ -in $scriptTags) {
                    $scriptTagsToInclude += $_
                    $runScriptCheck = $true
                    #* To satisfy PSScriptAnalyzer
                    $runModuleCheck = $runModuleCheck
                    $runScriptCheck = $runScriptCheck
                }
            }
        }
        $PesterConfiguration.Filter.Tag = $moduleTagsToInclude + $scriptTagsToInclude

    }

    if ($PSBoundParameters.ContainsKey('Exclude')) {

        Write-Verbose 'Processing -Exclude' -Verbose
        # Validate tests to exclude from $Exclude
        $Exclude | ForEach-Object {
            if ($_ -in $moduleTags) {
                $moduleTagsToExclude += $_
                $runModuleCheck = $true
                #* To satisfy PSScriptAnalyzer
                $runModuleCheck = $runModuleCheck
                $runScriptCheck = $runScriptCheck
            }
        }
        $Exclude | ForEach-Object {
            if ($_ -in $scriptTags) {
                $scriptTagsToExclude += $_
                $runScriptCheck = $true
                #* To satisfy PSScriptAnalyzer
                $runModuleCheck = $runModuleCheck
                $runScriptCheck = $runScriptCheck
            }
        }
        $PesterConfiguration.Filter.ExcludeTag = $moduleTagsToExclude + $scriptTagsToExclude

    }

    # Need to work out which of the checks files can be run
    if ($PSBoundParameters.ContainsKey('Include') -or
        $PSBoundParameters.ContainsKey('Exclude')) {

        Write-Verbose "moduleTagsToInclude $moduleTagsToInclude" -Verbose
        Write-Verbose "scriptTagsToInclude $scriptTagsToInclude" -Verbose
        Write-Verbose "moduleTagsToExclude $moduleTagsToExclude" -Verbose
        Write-Verbose "scriptTagsToExclude $scriptTagsToExclude" -Verbose

    }
    Write-Verbose "runModuleCheck $runModuleCheck" -Verbose
    Write-Verbose "runScriptCheck $runScriptCheck" -Verbose

    $moduleResults = $null
    $extractionResults = $null
    $extractedScriptResults = $null
    $scriptResults = $null

    if ($modulesToTest.Count -ge 1) {

        # Location of files extracted from any passed modules
        $extractPath = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath (New-Guid).Guid

        if ($runModuleCheck -eq $true) {

            # Run the Module tests on all the valid module files found
            $container1 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath 'Checks\Module.Tests.ps1') -Data @{ Source = $modulesToTest }
            $PesterConfiguration.Run.Container = $container1
            $moduleResults = Invoke-Pester -Configuration $PesterConfiguration

            # Extract all the functions from the modules into individual .ps1 files ready for testing
            $container2 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath 'Checks\Function-Extraction.Tests.ps1') -Data @{ Source = $modulesToTest; ExtractPath = $extractPath }
            $PesterConfiguration.Run.Container = $container2
            $extractionResults = Invoke-Pester -Configuration $PesterConfiguration

        }

        if ($runScriptCheck -eq $true -and (Test-Path -Path $extractPath -ErrorAction SilentlyContinue)) {

            # Get a list of the 'extracted' function scripts .ps1 files
            $extractedScriptsToTest = Get-ChildItem -Path $extractPath -Include '*.ps1' -Recurse

            # Run the Script tests against all the extracted functions .ps1 files
            $container3 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath 'Checks\Script.Tests.ps1') -Data @{ Source = $extractedScriptsToTest; ScriptAnalyzerRulesPath = $ScriptAnalyzerRulesPath }
            $PesterConfiguration.Run.Container = $container3
            $extractedScriptResults = Invoke-Pester -Configuration $PesterConfiguration
        }

    }

    if ($scriptsToTest.Count -ge 1 -and $runScriptCheck -eq $true) {

        # Run the Script tests against all the valid script files found
        $container3 = New-PesterContainer -Path (Join-Path -Path $modulePath -ChildPath 'Checks\Script.Tests.ps1') -Data @{ Source = $scriptsToTest; ScriptAnalyzerRulesPath = $ScriptAnalyzerRulesPath }
        $PesterConfiguration.Run.Container = $container3
        $scriptResults = Invoke-Pester -Configuration $PesterConfiguration

    }

    if ($PSBoundParameters.ContainsKey('ShowCheckResults')) {

        $qualityCheckResults = @()
        $filesTested = $total = $passed = $failed = $skipped = 0

        if ($null -ne $moduleResults) {
            $qualityCheckResults +=
            @{
                'Test' = 'Module Tests'
                'Files Tested' = $ModulesToTest.Count
                'Total' = $moduleResults.TotalCount
                'Passed' = $moduleResults.PassedCount
                'Failed' = $moduleResults.FailedCount
                'Skipped' = $moduleResults.SkippedCount
            }
            $filesTested += $ModulesToTest.Count
            $total += $moduleResults.TotalCount
            $passed += $moduleResults.PassedCount
            $failed += $moduleResults.FailedCount
            $skipped += $moduleResults.SkippedCount
        }

        if ($null -ne $extractionResults) {
            $qualityCheckResults +=
            @{
                'Test' = 'Extracting functions'
                'Files Tested' = $ModulesToTest.Count
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
                'Files Tested' = $extractedScriptsToTest.Count
                'Total' = $extractedScriptResults.TotalCount
                'Passed' = $extractedScriptResults.PassedCount
                'Failed' = $extractedScriptResults.FailedCount
                'Skipped' = $extractedScriptResults.SkippedCount
            }
            $filesTested += $extractedScriptsToTest.Count
            $total += $extractedScriptResults.TotalCount
            $passed += $extractedScriptResults.PassedCount
            $failed += $extractedScriptResults.FailedCount
            $skipped += $extractedScriptResults.SkippedCount
        }

        if ($null -ne $scriptResults) {
            $qualityCheckResults +=
            @{
                'Test' = "Script Tests"
                'Files Tested' = $scriptsToTest.Count
                'Total' = $scriptResults.TotalCount
                'Passed' = $scriptResults.PassedCount
                'Failed' = $scriptResults.FailedCount
                'Skipped' = $scriptResults.SkippedCount
            }
            $filesTested += $scriptsToTest.Count
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

        # This works on PS5 and PS7
        $qualityCheckResults | ForEach-Object {
            [PSCustomObject]@{
                'Test' = $_.Test
                'Files Tested' = $_.'Files Tested'
                'Total' = $_.total
                'Passed' = $_.passed
                'Failed' = $_.failed
                'Skipped' = $_.skipped
            }
        } | Format-Table -AutoSize

        # This works on PS7 not on PS5
        # $qualityCheckResults | Select-Object Name, 'Files Tested', Total, Passed, Failed, Skipped | Format-Table -AutoSize

    }

    if ($PSBoundParameters.ContainsKey('ExportCheckResults')) {

        $moduleResults | Export-Clixml -Path "moduleResults.xml"
        $extractionResults | Export-Clixml -Path "extractionResults.xml"
        $scriptsToTest | Export-Clixml -Path "scriptsToTest.xml"
        $extractedScriptResults | Export-Clixml -Path "extractedScriptResults.xml"

    }

    if ($PSBoundParameters.ContainsKey('Passthru')) {

        if ($PesterConfiguration.Run.PassThru.Value -eq $true) {
            return $moduleResults, $extractionResults, $scriptsToTest, $extractedScriptResults
        }
        else {
            Write-Error "Unable to pass back result objects. Passthru not enabled in Pester Configuration object"
        }

    }

}

