# PSQualityCheck

## Summary

This is a PowerShell module which runs a series of Pester 5 tests to validate code quality. It uses a combination of Pester tests, PSScriptAnalyzer and a set of quality standards to ensure consistent quality on PowerShell scripts and modules.

For more information please see the wiki here [Wiki](https://github.com/andrewrdavidson/PSQualityCheck/wiki)

## Releases

### PowerShell Gallery

[![psgallery version](https://img.shields.io/powershellgallery/v/psqualitycheck)](https://www.powershellgallery.com/packages/PSQualityCheck/1.3.0) [![downloads](https://img.shields.io/powershellgallery/dt/PSQualityCheck)](https://www.powershellgallery.com/packages/PSQualityCheck/1.3.0)

### GitHub

#### Release Version

[![github tag](https://img.shields.io/github/v/tag/andrewrdavidson/psqualitycheck?sort=semver)](https://github.com/andrewrdavidson/PSQualityCheck/releases?sort=semver) [![release date](https://img.shields.io/github/release-date/andrewrdavidson/psqualitycheck)](https://github.com/andrewrdavidson/PSQualityCheck/releases)

#### Development

[![devtag](https://img.shields.io/badge/branch-1.4.0-blue)](https://github.com/andrewrdavidson/PSQualityCheck/tree/release-1.4.0)
[![commits since 1.3.0](https://img.shields.io/github/commits-since/andrewrdavidson/psqualitycheck/1.3.0/main?include_prereleases)](https://github.com/andrewrdavidson/PSQualityCheck/releases/1.3.0)

## Plans

If you want to see the plans and the progress of the steps within, click [Release Plans](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Release-Plan)

## History

Is available here [Release History](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Release-History)

## Prerequisites

This module requires:

* PowerShell 5.1 or PowerShell 7.1 or later
* Pester 5.1 or later
* PSScriptAnalyzer 1.19.1 or later

Optional items:

* Extra PSScriptAnalyzer rules (used by SonarQube) are available here:<br/>[https://github.com/indented-automation/ScriptAnalyzerRules](https://github.com/indented-automation/ScriptAnalyzerRules)
* Extra PSScriptAnalyzer rules (used by VSCode) are available here:<br/>[https://github.com/PowerShell/PSScriptAnalyzer/tree/master/Tests/Engine/CommunityAnalyzerRules](https://github.com/PowerShell/PSScriptAnalyzer/tree/master/Tests/Engine/CommunityAnalyzerRules)

## Installation

From the PSGallery:

`Install-Module -Name PSQualityCheck`

## Usage

See the [Usage](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Usage) page

## Tests Results

See the [Test Results](https://github.com/andrewrdavidson/PSQualityCheck/wiki/Test-Results) page
