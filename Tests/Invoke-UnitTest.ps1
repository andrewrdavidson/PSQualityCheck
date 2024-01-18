<#
    .SYNOPSIS
    Test the functions of PSQualityCheck

    .DESCRIPTION
    Run the unit tests for the functions of PSQualityCheck

    .EXAMPLE
    Invoke-UnitTest
#>
[CmdletBinding()]
[OutputType([HashTable], [System.Void])]
param (
)

Import-Module -Name Pester -MinimumVersion 5.1.0

$configuration = [PesterConfiguration]::Default
$configuration.Run.Path = ".\Unit"
$configuration.Run.Exit = $true
$configuration.CodeCoverage.Enabled = $false
$configuration.TestResult.Enabled = $false
$configuration.Output.Verbosity = "Detailed"
$configuration.Run.PassThru = $false
$configuration.Should.ErrorAction = 'Stop'

# Dot load all the module ready to test
Get-ChildItem -Path "..\Source\PSQualityCheck\Public" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

Get-ChildItem -Path "..\Source\PSQualityCheck\Private" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

Invoke-Pester -Configuration $configuration
