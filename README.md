# PSQualityCheck

## Summary

### **NEW** PSQualityCheck v2.0.0 and **COMING SOON!** its companion module PSQualityTempate

This is a PowerShell module which runs a series of Pester 5 tests to validate code quality. It uses a combination of Pester tests, PSScriptAnalyzer and a set of quality standards to ensure consistent quality on PowerShell scripts and modules.

For more information please see the wiki here [Wiki](https://github.com/andrewrdavidson/PSQualityCheck/wiki)

## Releases

### PowerShell Gallery

[![psgallery version](https://img.shields.io/powershellgallery/v/psqualitycheck)](https://www.powershellgallery.com/packages/PSQualityCheck/2.0.0) [![downloads](https://img.shields.io/powershellgallery/dt/PSQualityCheck)](https://www.powershellgallery.com/packages/PSQualityCheck/2.0.0)

### GitHub

#### Release Version

[![github tag](https://img.shields.io/github/v/tag/andrewrdavidson/psqualitycheck?sort=semver)](https://github.com/andrewrdavidson/PSQualityCheck/releases?sort=semver) [![release date](https://img.shields.io/github/release-date/andrewrdavidson/psqualitycheck)](https://github.com/andrewrdavidson/PSQualityCheck/releases)

## Plans

If you want to see the plans and the progress of the steps within, click [Release Plans](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Release-Plan)

## History

Is available here [Release History](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Release-History)

## Prerequisites

This module requires:

* PowerShell 5.1 or PowerShell 7.1 or later
* Pester 5.1 or later
* PSScriptAnalyzer 1.19.1 or later
* ModuleBuilder 2.0.0 or  later (to build)
* PowerShellGet 2.2.5 or later (to build)
* InvokeBuild 5.8.0 pr later (to build)
* Cofl.Util 1.2.2 or later (to build)

Optional items:

* Extra PSScriptAnalyzer rules (used by SonarQube) are available here:<br/>[https://github.com/indented-automation/ScriptAnalyzerRules](https://github.com/indented-automation/ScriptAnalyzerRules)
* Extra PSScriptAnalyzer rules (used by VSCode) are available here:<br/>[https://github.com/PowerShell/PSScriptAnalyzer/tree/master/Tests/Engine/CommunityAnalyzerRules](https://github.com/PowerShell/PSScriptAnalyzer/tree/master/Tests/Engine/CommunityAnalyzerRules)
* InjectionHunter rules are available here:<br/>[https://www.powershellgallery.com/packages/InjectionHunter](https://www.powershellgallery.com/packages/InjectionHunter)<br/>
[https://github.com/matt2005/InjectionHunter](https://github.com/matt2005/InjectionHunter)

## Installation

From the PSGallery:

`Install-Module -Name PSQualityCheck`

## Usage

See the [Usage](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Usage) page

## Tests Results

See the [Test Results](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Test-Results) page
