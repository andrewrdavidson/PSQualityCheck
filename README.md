# PSQualityCheck

## Summary

This is a PowerShell module which runs a series of Pester 5 tests to validate code quality against rules

It uses a combination of Pester tests, PSScriptAnalyzer and a set of standards to apply consistent quality checks on PowerShell scripts and modules.

The standards are summarised here: [Quality Standards Summary](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Standards)

## Prerequisites

This module requires:

* PowerShell 5.1 or later
* Pester 5.1 or later
* PSScriptAnalyzer 1.19.1 or later

Optional items:

* Extra PSScriptAnalyzer rules (used by SonarQube) are available here: https://github.com/indented-automation/ScriptAnalyzerRules

## Installation

__Preferred Method__

From the PSGallery:

`Install-Module -Name PSQualityCheck`

__Manual Installation__

Copy the files to **one** of the available module folders:

__For PowerShell 5.x__

* `C:\Users\<username>\Documents\WindowsPowerShell\Modules\PSQualityCheck`

* `C:\Program Files\WindowsPowerShell\Modules\PSQualityCheck`

__For PowerShell 7.x__

* `C:\Users\<username>\Documents\PowerShell\Modules\PSQualityCheck`

* `C:\Program Files\PowerShell\7\Modules\PSQualityCheck`

## Usage

#### Check the folder C:\Scripts and all subfolders beneath it:

`Invoke-PSQualityCheck -Path 'C:\Scripts'`

#### Check the folders C:\Scripts and C:\MoreScripts' and all subfolders beneath both folders

`Invoke-PSQualityCheck -Path @('C:\Scripts', 'C:\MoreScripts')`

#### Check the file C:\Scripts\Script.ps1:

`Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1'`

#### Check the files C:\Scripts\Script1.ps1, C:\Scripts\Script2.ps1:

`Invoke-PSQualityCheck -File @('C:\Scripts\Script.ps1', 'C:\Scripts\Script.ps1')`

#### Check the file C:\Scripts\Script.ps1 including the extra PSScriptAnalyzer rules used by SonarQube:

`Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1' -SonarQubeRulesPath 'C:\SonarQubeRules'`

#### Check the folder C:\Scripts and all subfolders beneath it and display a summary of the checks performed (example below uses sample data):

`Invoke-PSQualityCheck -Path 'C:\Scripts' -ShowCheckResults`

    Test                            Files Tested Total Passed Failed Skipped
    ----                            ------------ ----- ------ ------ -------
    Module Tests                               3    21     20      1       0
    Extracting functions                       3     3      3      0       0
    Extracted function script tests           13   195     64    114      17
    Script Tests                              17   255     78    152      25
    Total                                     33   474    165    267      42

## Pester Tests

A quick description of the available Pester tests

[Module Test Details](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Module-Tests)

[Script Test Details](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Script-Tests)

## Tests

Tested on:

* PowerShell 7.1.0 on Windows 10
* PowerShell 5.1 on Windows 10

## Source

Source is currently available here: [source](https://github.com/andrewrdavidson/powershell-quality-checks)
