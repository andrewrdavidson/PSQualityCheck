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
Get-ChildItem -Path "..\PSQualityCheck.Functions" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

$result = Invoke-Pester -Configuration $configuration
