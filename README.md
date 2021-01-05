# PSQualityCheck

## Summary

This is a PowerShell module which runs a series of Pester 5 tests to validate code quality. It uses a combination of Pester tests, PSScriptAnalyzer and a set of quality standards to ensure consistent quality on PowerShell scripts and modules.

The standards are summarised here: [Quality Standards Summary](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Standards)

## Release 

#### PowerShell Gallery

[![psgallery version](https://img.shields.io/powershellgallery/v/psqualitycheck)](https://www.powershellgallery.com/packages/PSQualityCheck) [![dowloads](https://img.shields.io/powershellgallery/dt/PSQualityCheck)](https://www.powershellgallery.com/packages/PSQualityCheck)

#### GitHub

[![github tag](https://img.shields.io/github/v/tag/andrewrdavidson/psqualitycheck)](https://github.com/andrewrdavidson/PSQualityCheck/releases) [![release date](https://img.shields.io/github/release-date/andrewrdavidson/psqualitycheck)](https://github.com/andrewrdavidson/PSQualityCheck/releases)

#### Issues
[![open issues](https://img.shields.io/github/issues-raw/andrewrdavidson/psqualitycheck)](https://github.com/andrewrdavidson/PSQualityCheck/issues?q=is%3Aopen+is%3Aissue) [![closed](https://img.shields.io/github/issues-closed-raw/andrewrdavidson/psqualitycheck)](https://github.com/andrewrdavidson/PSQualityCheck/issues?q=is%3Aissue+is%3Aclosed)

### Plans

If you want to see the plans and the progress of the steps within, click [Release Plans](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Release-Plan)

### History

Is available here [Release History](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Release-History)

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

#### Import the module

`Import-Module -Name PSQualityCheck`

then run using the examples below as a guide:

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

#### PowerShell version/PSQualityCheck/Operating System testing matrix:

|PowerShell Version|PSQualityCheck Version|Operating System Result
|:---|:---|:---|
|7.1.0|1.0.9|![Pass](https://img.shields.io/badge/windows%2010-pass-brightgreen) ![Server 2019 Testing To Be Performed](https://img.shields.io/badge/server%202019-not%20run-lightgrey) ![Server 2016 Testing To Be Performed](https://img.shields.io/badge/server%202016-not%20run-lightgrey) ![Testing To Be Performed](https://img.shields.io/badge/linux-not%20run-lightgrey)|
|5.1|1.0.9|![Pass](https://img.shields.io/badge/windows%2010-pass-brightgreen) ![Server 2019 Testing To Be Performed](https://img.shields.io/badge/server%202019-not%20run-lightgrey) ![Server 2016 Testing To Be Performed](https://img.shields.io/badge/server%202016-not%20run-lightgrey)|n/a|

#### RuleSet/PowerShell version/PSQualityCheck testing matrix:

|RuleSet|PSQualityCheck Version|PowerShell Result|
|:---|:---|:---|
|None|1.0.9|![Pass](https://img.shields.io/badge/powershell%207.1.0-pass-brightgreen)|![Pass](https://img.shields.io/badge/powershell%205.1-pass-brightgreen)|
|[indented-automation](https://github.com/indented-automation/ScriptAnalyzerRules)<br/>(used by SonarQube)|1.0.9|![Pass](https://img.shields.io/badge/powershell%207.1.0-pass-brightgreen) ![Pass](https://img.shields.io/badge/powershell%205.1-pass-brightgreen)|
|[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer/tree/master/Tests/Engine/CommunityAnalyzerRules)<br/>(used by VSCode)|1.0.9|![Fail](https://img.shields.io/badge/powershell%207.1.0-fail-red) ![Futher Testing To Be Performed](https://img.shields.io/badge/powershell%205.1-not%20run-lightgrey)|
