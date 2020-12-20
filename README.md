# PSQualityCheck

## Summary

This is a PowerShell module which runs a series of Pester 5 tests to validate code quality against it's rules

## Prerequisites

This module requires:

* PowerShell 5.1 or later
* Pester 5.1 or later
* PSScriptAnalyzer 1.19.1 or later

Optional items:

* Extra PSScriptAnalyzer rules used by SonarQube rules are available here: https://github.com/indented-automation/ScriptAnalyzerRules

## Installation

Copy the files to one of the available module folders:

> `C:\Users\<username>\Documents\PowerShell\Modules` ^

> `C:\Users\<username>\Documents\WindowsPowerShell\Modules`

> `C:\Program Files\PowerShell\7\Modules` ^

> `C:\Program Files\WindowsPowerShell\Modules`

^ for PowerShell 7

## Usage

Basic usage:

Check the folder C:\Scripts:

> `Invoke-PSQualityCheck -Path 'C:\Scripts'`

Check the folders C:\Scripts and C:\MoreScripts':

> `Invoke-PSQualityCheck -Path @('C:\Scripts', 'C:\MoreScripts')`

Check the file C:\Scripts\Script.ps1:

> `Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1'`

Check the file C:\Scripts\Script.ps1 with the extra PSScriptAnalyzer rules used by SonarQube:

> `Invoke-PSQualityCheck -File 'C:\Scripts\Script.ps1' -SonarQubeRulesPath 'C:\SonarQubeRules'`

This will display a summary of the checks performed (example below uses sample data):

> `Invoke-PSQualityCheck -Path 'C:\Scripts' -ShowCheckResults`

    Name                            Files Tested Total Passed Failed Skipped
    ----                            ------------ ----- ------ ------ -------
    Module Tests                               2    14     14      0       0
    Extracting functions                       2     2      2      0       0
    Extracted function script tests           22   330    309      0      21
    Total                                     24   346    325      0      21

## Pester Tests

A list of the Pester tests is will be available shortly in the wiki

## Tests

Tested with:

* PowerShell 7.1.0 on Windows 10
* PowerShell 5.1 on Windows 10
