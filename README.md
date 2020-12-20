# PSQualityCheck

## Summary

This is a PowerShell module which runs a series of Pester 5 tests to validate code quality against rules

## Prerequisites

This module requires:

* PowerShell 5.1 or later
* Pester 5.1 or later
* PSScriptAnalyzer 1.19.1 or later

Optional items:

* Extra PSScriptAnalyzer rules (used by SonarQube) are available here: https://github.com/indented-automation/ScriptAnalyzerRules

## Installation

Copy the files to one of the available module folders:

* `C:\Users\<username>\Documents\PowerShell\Modules\PSQualityCheck` ^

* `C:\Users\<username>\Documents\WindowsPowerShell\Modules\PSQualityCheck`

* `C:\Program Files\PowerShell\7\Modules\PSQualityCheck` ^

* `C:\Program Files\WindowsPowerShell\Modules\PSQualityCheck`

^ for PowerShell 7

## Usage

Basic usage:

Check the folder C:\Scripts:

`Invoke-PSQualityCheck -Path 'C:\Scripts'`

Check the folders C:\Scripts and C:\MoreScripts':

`Invoke-PSQualityCheck -Path @('C:\Scripts', 'C:\MoreScripts')`

Check the file C:\Scripts\Script.ps1:

`Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1'`

Check the file C:\Scripts\Script.ps1 with the extra PSScriptAnalyzer rules used by SonarQube:

`Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1' -SonarQubeRulesPath 'C:\SonarQubeRules'`

This will display a summary of the checks performed (example below uses sample data):

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
