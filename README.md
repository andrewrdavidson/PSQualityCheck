# PSQualityCheck

## Summary

This is a PowerShell module which runs a series of Pester 5 tests to validate code quality. It uses a combination of Pester tests, PSScriptAnalyzer and a set of quality standards to ensure consistent quality on PowerShell scripts and modules.

The standards are summarised here: [Quality Standards Summary](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Standards)

## Release Guide and Future Plans

If you want to see these, click [Release Guide and Future Plans](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Release-Guide-and-Future-Plans)

## Prerequisites

This module requires:

* PowerShell 5.1 or PowerShell 7.1 or later
* Pester 5.1 or later
* PSScriptAnalyzer 1.19.1 or later

Optional items:

* Extra PSScriptAnalyzer rules (used by SonarQube) are available here:<br/>https://github.com/indented-automation/ScriptAnalyzerRules
* Extra PSScriptAnalyzer rules (used by VSCode) are available here:<br/>https://github.com/PowerShell/PSScriptAnalyzer/tree/master/Tests/Engine/CommunityAnalyzerRules

## Installation

### __Preferred Method__

From the PSGallery:

`Install-Module -Name PSQualityCheck`

### __Manual Installation__

Copy the files to **one** of the available module folders:

__For PowerShell 5.x__

* `C:\Users\<username>\Documents\WindowsPowerShell\Modules\PSQualityCheck`

* `C:\Program Files\WindowsPowerShell\Modules\PSQualityCheck`

__For PowerShell 7.x__

* `C:\Users\<username>\Documents\PowerShell\Modules\PSQualityCheck`

* `C:\Program Files\PowerShell\7\Modules\PSQualityCheck`

## Usage

Import the module

`Import-Module -Name PSQualityCheck`

#### Check the folder C:\Scripts and all subfolders beneath it:

`Invoke-PSQualityCheck -Path 'C:\Scripts'`

#### Check the folders C:\Scripts and C:\MoreScripts' and all subfolders beneath both folders:

`Invoke-PSQualityCheck -Path @('C:\Scripts', 'C:\MoreScripts')`

#### Check the file C:\Scripts\Script.ps1:

`Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1'`

#### Check the files C:\Scripts\Script1.ps1, C:\Scripts\Script2.ps1:

`Invoke-PSQualityCheck -File @('C:\Scripts\Script.ps1', 'C:\Scripts\Script.ps1')`

#### Check the file C:\Scripts\Script.ps1 including the extra PSScriptAnalyzer rules used by SonarQube:

`Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1' -SonarQubeRulesPath 'C:\SonarQubeRules'`

#### Check the folder C:\Scripts and all subfolders beneath it and display a summary of the checks performed:

`Invoke-PSQualityCheck -Path 'C:\Scripts' -ShowCheckResults`

output below uses sample data:

    Test                            Files Tested Total Passed Failed Skipped
    ----                            ------------ ----- ------ ------ -------
    Module Tests                               3    21     20      1       0
    Extracting functions                       3     3      3      0       0
    Extracted function script tests           13   195     64    114      17
    Script Tests                              17   255     78    152      25
    Total                                     33   474    165    267      42

## Pester Tests

A quick description of the available Pester tests

* [Module Test Details](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Module-Tests)
* [Script Test Details](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Script-Tests)

## Tests

Testing matrix:

|PowerShell Version|OS|PSQualityCheck Version|Result|
|---|---|---|---|
|7.1.0|Windows 10|1.0.9|![Pass](https://img.shields.io/badge/tests-pass-brightgreen)|
|7.1.0|Windows Server 2019|n/a|![Testing To Be Performed](https://img.shields.io/badge/tests-to%20be%20performed-lightgrey)|
|7.1.0|Windows Server 2016|n/a|![Testing To Be Performed](https://img.shields.io/badge/tests-to%20be%20performed-lightgrey)|
|7.1.0|Linux|n/a|![Testing To Be Performed](https://img.shields.io/badge/tests-to%20be%20performed-lightgrey)|
|5.1|Windows 10|1.0.9|![Pass](https://img.shields.io/badge/tests-pass-brightgreen)|
|5.1|Windows Server 2019|n/a|![Testing To Be Performed](https://img.shields.io/badge/tests-to%20be%20performed-lightgrey)|
|5.1|Windows Server 2016|n/a|![Testing To Be Performed](https://img.shields.io/badge/tests-to%20be%20performed-lightgrey)|

Tested with:
|RuleSet|PowerShell Version|PSQualityCheck Version|Result|
|:---|---|---|---|
|None|7.1.0 on Windows 10|1.0.9|![Pass](https://img.shields.io/badge/tests-pass-brightgreen)|
|[indented-automation](https://github.com/indented-automation/ScriptAnalyzerRules)<br/>(used by SonarQube)|7.1.0 on Windows 10|1.0.9|![Pass](https://img.shields.io/badge/tests-pass-brightgreen)|
|[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer/tree/master/Tests/Engine/CommunityAnalyzerRules)<br/>(used by VSCode)|7.1.0 on Windows 10|1.0.7|![Fail](https://img.shields.io/badge/tests-fail-red)<br/>![Futher Testing To Be Performed](https://img.shields.io/badge/tests-to%20be%20performed-lightgrey)|
