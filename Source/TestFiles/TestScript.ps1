<#
.SYNOPSIS

Adds a file name extension to a supplied name.

.DESCRIPTION

Adds a file name extension to a supplied name.
Takes any strings for the file name or extension.

.PARAMETER Message

A string containing the message

.INPUTS

None. You cannot pipe objects to Add-Extension.

.OUTPUTS

System.String. Add-Extension returns a string with the extension
or file name.

.EXAMPLE

PS> extension -name "File"
File.txt

.EXAMPLE

PS> extension -name "File" -extension "doc"
File.doc

.EXAMPLE

PS> extension "File" "doc"
File.doc

.LINK

http://www.fabrikam.com/extension.html

.LINK

Set-Item

#>

<#
.DESCRIPTION
Description of TestScript

.SYNOPSIS
A detailed synopsis of the function of the script

.PARAMETER Message
A string containing the message

.EXAMPLE
Get-TestFunction -Message 'This is a test message'

.INPUTS
Get-TestFunction -Message 'This is a test message'

.OUTPUTS
Get-TestFunction -Message 'This is a test message'

.NOTES
Get-TestFunction -Message 'This is a test message'

.LINK
Get-TestFunction -Message 'This is a test message'


#>

[CmdletBinding()]
[OutputType([System.Void])]
# Should trip [OutputType] empty test
# [OutputType()]
param (
    [string]$Message = "Test Message"
)

# Should trip Import-Module Test
# Import-Module "test1.psm1"
# Import-Module "test2.psd1"
# Import-Module -Name "test3.psd1"

# Should pass Import-Module Test
Import-Module -Name "test4" -RequiredVersion "1.0.0"
Import-Module -Name test5 -MinimumVersion "1.0.0"
Import-Module -Name test6 -MaximumVersion "1.0.0"
# Import-Module -Name "test7.psd1" -RequiredVersion "1.0.0"
# Import-Module -Name "test8.psd1" -MinimumVersion "1.0.0"
# Import-Module -Name "test9.psd1" -MaximumVersion "1.0.0"
# Import-Module -Name "testA.psd1" -RequiredVersion 1.0.0
# Import-Module -Name "testB.psd1" -MinimumVersion 1.0.0
# Import-Module -Name "testC.psd1" -MaximumVersion 1.0.0

# Shouldn't trip anything
Write-Output $Message

# should trip PSScriptAnalyzer test
# Write-Host "String"
