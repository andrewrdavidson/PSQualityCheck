function Convert-Help {
    <#
        .SYNOPSIS
        Convert the help comment into an object

        .DESCRIPTION
        Convert the help comment into an object containing all the elements from the help comment

        .PARAMETER Help
        A string containing the Help Comment

        .EXAMPLE
        $helpObject = Convert-Help -Help $Help
    #>
    [CmdletBinding()]
    [OutputType([HashTable], [System.Exception])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Help
    )

    # These are the possible Help Comment elements that the script will look for
    # .SYNOPSIS
    # .DESCRIPTION
    # .PARAMETER
    # .EXAMPLE
    # .INPUTS
    # .OUTPUTS
    # .NOTES
    # .LINK
    # .COMPONENT
    # .ROLE
    # .FUNCTIONALITY
    # .FORWARDHELPTARGETNAME
    # .FORWARDHELPCATEGORY
    # .REMOTEHELPRUNSPACE
    # .EXTERNALHELP

    # This function will go through the help and work out which elements are where and what text they contain

    try {

        if (-not(
                $Help.StartsWith("<#") -and
                $Help.EndsWith("#>")
            )) {
            throw "Help does not appear to be a comment block"
        }

        $helpElementsToFind =
        '.SYNOPSIS',
        '.DESCRIPTION',
        '.PARAMETER',
        '.EXAMPLE',
        '.INPUTS',
        '.OUTPUTS',
        '.NOTES',
        '.LINK',
        '.COMPONENT',
        '.ROLE',
        '.FUNCTIONALITY',
        '.FORWARDHELPTARGETNAME',
        '.FORWARDHELPCATEGORY',
        '.REMOTEHELPRUNSPACE',
        '.EXTERNALHELP'

        $commentArray = ($Help -split '\n').Trim()

        $foundElements = @{}
        $numFound = 0
        $lastHelpElement = $null

        for ($line = 0; $line -lt $commentArray.Count; $line++) {

            # get the first 'word' of the help comment. This is required so that we can
            # match '.PARAMETER' since it has a parameter name after it
            $helpElementName = ($commentArray[$line] -split " ")[0]

            if ($helpElementsToFind -contains $helpElementName) {

                $numFound++

                if ($numFound -ge 2) {

                    # if it's the second element then we must set the help comment text of the
                    # previous element to the found text so far, then reset it

                    $lastElement = @($foundElements[$lastHelpElement])
                    $lastElement[$lastElement.Count - 1].Text = $helpData
                    $foundElements[$lastHelpElement] = $lastElement

                    $helpData = $null
                }

                # this should be an array of HashTables
                # each hash table will contain the properties LineNumber, Name & Text
                $currentElement = @($foundElements[$helpElementName])

                $newElement = @{}
                $newElement.LineNumber = $line
                $newElement.Name = ($commentArray[$line] -split " ")[1]
                $newElement.Text = ""

                if ($null -eq $currentElement[0]) {

                    $currentElement = $newElement

                }
                else {
                    $currentElement += $newElement
                }

                $foundElements[$helpElementName] = $currentElement

                $lastHelpElement = $helpElementName

            }
            else {

                if ($numFound -ge 1 -and $line -lt ($commentArray.Count - 1)) {

                    $helpData += $commentArray[$line]

                }

            }

        }

        if ( -not ([string]::IsNullOrEmpty($lastHelpElement))) {
            $currentElement = @($foundElements[$lastHelpElement])
            $currentElement[$currentElement.Count - 1].Text = $helpData
            $foundElements[$lastHelpElement] = $currentElement
        }

        return $foundElements

    }
    catch {

        throw $_.Exception.Message

    }

}

function Export-FunctionsFromModule {
    <#
        .SYNOPSIS
        Export functions from a PowerShell module (.psm1)

        .DESCRIPTION
        Takes a PowerShell module and outputs a single file for each function containing the code for that function

        .PARAMETER Path
        A string Path containing the full file name and path to the module

        .PARAMETER ExtractPath
        A string Path containing the full path to the extraction folder

        .EXAMPLE
        Export-FunctionsFromModule -Path 'c:\path.to\module.psm1' -ExtractPath 'c:\extract'
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$ExtractPath
    )

    try {

        $fileProperties = (Get-Item -LiteralPath $Path)

        if ($fileProperties.Extension -ne ".psm1") {
            throw "Passed file does not appear to be a PowerShell module"
        }

        $moduleName = $fileProperties.BaseName

        $ModuleFileContent = Get-Content -Path $Path -ErrorAction Stop

        $ParserErrors = $null
        $ParsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($ModuleFileContent, [ref]$ParserErrors)

        $ParsedFunctions = ($ParsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

        $parsedFunction = 0

        if ($ParsedFunctions.Count -ge 1) {

            $FunctionOutputPath = Join-Path -Path $ExtractPath -ChildPath $moduleName

            if (-not (Test-Path -Path $FunctionOutputPath)) {
                New-Item $FunctionOutputPath -ItemType 'Directory'
            }

            foreach ($Function in $ParsedFunctions) {

                $parsedFunction++

                $FunctionProperties = $ParsedFileFunctions | Where-Object { $_.StartLine -eq $Function.StartLine }
                $FunctionName = ($FunctionProperties | Where-Object { $_.Type -eq "CommandArgument" }).Content

                if ($parsedFunction -eq $ParsedFunctions.Count) {

                    $StartLine = ($Function.StartLine)
                    for ($line = $ModuleFileContent.Count; $line -gt $Function.StartLine; $line--) {
                        if ($ModuleFileContent[$line] -like "}") {
                            $EndLine = $line
                            break
                        }
                    }

                }
                else {

                    $StartLine = ($Function.StartLine)

                    for ($line = $ParsedFunctions[$parsedFunction].StartLine; $line -gt $Function.StartLine; $line--) {
                        if ($ModuleFileContent[$line] -like "}") {
                            $EndLine = $line
                            break
                        }
                    }

                }

                $FunctionOutputFileName = "{0}\{1}{2}" -f $FunctionOutputPath, $FunctionName, ".ps1"

                if (-not (Test-Path -Path $FunctionOutputFileName)) {
                    Out-File -FilePath $FunctionOutputFileName
                }

                for ($line = $StartLine; $line -lt $EndLine; $line++) {
                    Add-Content -Path $FunctionOutputFileName -Value $ModuleFileContent[$line]
                }

            }
        }
        else {
            throw "File contains no functions"
        }
    }
    catch {
        throw
    }
}

function Get-FileContent {
    <#
        .SYNOPSIS
        Gets the content of a script file

        .DESCRIPTION
        Gets the content of the file or the content of the function inside the file

        .PARAMETER Path
        A file name to parse

        .EXAMPLE
        $fileContent = Get-FileContent -Path 'c:\file.txt'
    #>
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    try {

        $fileContent = Get-Content -Path $Path

        $parserErrors = $null

        if ([string]::IsNullOrEmpty($fileContent)) {
            $parsedFileFunctions = @()
        }
        else {
            $parsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$parserErrors)
        }

        $parsedFunctions = ($parsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

        if ($parsedFunctions.Count -gt 1) {
            throw "Too many functions in file, file is invalid"
        }

        if ($parsedFunctions.Count -eq 1) {

            if ($fileContent.Count -gt 1) {

                foreach ($function in $parsedFunctions) {

                    $startLine = ($function.StartLine)

                    for ($line = $fileContent.Count; $line -gt $function.StartLine; $line--) {

                        if ($fileContent[$line] -like "*}*") {

                            $endLine = $line
                            break

                        }

                    }

                    for ($line = $startLine; $line -lt $endLine; $line++) {

                        $parsedFileContent += $fileContent[$line]

                        if ($line -ne ($fileContent.Count - 1)) {
                            $parsedFileContent += "`r`n"
                        }

                    }

                }

            }
            else {

                [int]$startBracket = $fileContent.IndexOf('{')
                [int]$endBracket = $fileContent.LastIndexOf('}')

                $parsedFileContent = $fileContent.substring($startBracket + 1, $endBracket - 1 - $startBracket)

            }
        }
        else {

            if ($fileContent.Count -gt 1) {

                for ($line = 0; $line -lt $fileContent.Count; $line++) {

                    $parsedFileContent += $fileContent[$line]

                    if ($line -ne ($fileContent.Count - 1)) {
                        $parsedFileContent += "`r`n"
                    }

                }

            }
            else {

                $parsedFileContent = $fileContent

            }

        }

    }
    catch {
        throw
    }

    return $parsedFileContent

}

function Get-FileList {
    <#
        .SYNOPSIS
        Return a list of files

        .DESCRIPTION
        Return a list of files from the specified path matching the passed extension

        .PARAMETER Path
        A string containing the path

        .PARAMETER Extension
        A string containing the extension

        .PARAMETER Recurse
        A switch specifying whether or not to recursively search the path specified

        .EXAMPLE
        $files = Get-FileList -Path 'c:\folder' -Extension ".ps1"

        .EXAMPLE
        $files = Get-FileList -Path 'c:\folder' -Extension ".ps1" -Recurse
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$Extension,
        [parameter(Mandatory = $false)]
        [switch]$Recurse
    )

    $Extension = $Extension

    $FileNameArray = @()

    if (Test-Path -Path $Path) {

        $gciSplat = @{
            'Path' = $Path
            'Exclude' = "*.Tests.*"
        }
        if ($PSBoundParameters.ContainsKey('Recurse')) {
            $gciSplat.Add('Recurse', $true)
        }

        $SelectedFilesArray = Get-ChildItem @gciSplat | Where-Object { $_.Extension -eq $Extension } | Select-Object -Property FullName
        $SelectedFilesArray | ForEach-Object { $FileNameArray += [string]$_.FullName }

    }

    return $FileNameArray

}

function Get-FunctionCount {
    <#
        .SYNOPSIS
        Return the count of functions within Module and its Manifest

        .DESCRIPTION
        Return the count of functions in the Module and Manifest and whether they appear in their counterpart.
        e.g. Whether the functions in the manifest appear in the module and vice versa

        .PARAMETER ModulePath
        A string containing the Module filename

        .PARAMETER ManifestPath
        A string containing the Manifest filename

        .EXAMPLE
        ($ExportedCommandsCount, $CommandFoundInModuleCount, $CommandInModuleCount, $CommandFoundInManifestCount) = Get-FunctionCount -ModulePath $ModulePath -ManifestPath $ManifestPath

    #>
    [CmdletBinding()]
    [OutputType([Int[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$ModulePath,
        [parameter(Mandatory = $true)]
        [string]$ManifestPath
    )

    try {
        if (Test-Path -Path $ManifestPath) {
            $ExportedCommands = (Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop).ExportedCommands
            $ExportedCommandsCount = $ExportedCommands.Count
        }
        else {
            throw "Manifest file doesn't exist"
        }
    }
    catch {
        $ExportedCommands = @()
        $ExportedCommandsCount = 0
    }

    try {
        if (Test-Path -Path $ModulePath) {
            ($ParsedModule, $ParserErrors) = Get-ParsedFile -Path $ModulePath
        }
        else {
            throw "Module file doesn't exist"
        }
    }
    catch {
        $ParsedModule = @()
        $ParserErrors = 1
    }

    $CommandFoundInModuleCount = 0
    $CommandFoundInManifestCount = 0
    $CommandInModuleCount = 0

    if ( -not ([string]::IsNullOrEmpty($ParsedModule))) {

        foreach ($ExportedCommand in $ExportedCommands.Keys) {

            if ( ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.Content -eq $ExportedCommand })) {

                $CommandFoundInModuleCount++

            }

        }

        $functionNames = @()

        $functionKeywords = ($ParsedModule | Where-Object { $_.Type -eq "Keyword" -and $_.Content -eq "function" })
        $functionKeywords | ForEach-Object {

            $functionLineNo = $_.StartLine
            $functionNames += ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.StartLine -eq $functionLineNo })

        }
    }

    if ($ExportedCommandsCount -ge 1) {

        foreach ($function in $functionNames) {

            $CommandInModuleCount++
            if ($ExportedCommands.ContainsKey($function.Content)) {

                $CommandFoundInManifestCount++

            }

        }

    }

    return ($ExportedCommandsCount, $CommandFoundInModuleCount, $CommandInModuleCount, $CommandFoundInManifestCount)

}

function Get-ParsedContent {
    <#
        .SYNOPSIS
        Get the tokenized content of the passed data

        .DESCRIPTION
        Get and return the tokenized content of the passed PowerShell script content

        .PARAMETER Content
        A string containing PowerShell script content

        .EXAMPLE
        ($ParsedModule, $ParserErrorCount) = Get-ParsedContent -Content $fileContent
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    if (-not ([string]::IsNullOrEmpty($Content))) {
        $ParserErrors = $null
        $ParsedModule = [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$ParserErrors)

        return $ParsedModule, ($ParserErrors.Count)
    }

}

function Get-ParsedFile {
    <#
        .SYNOPSIS
        Get the tokenized content of the passed file

        .DESCRIPTION
        Get and return the tokenized content of the passed PowerShell file

        .PARAMETER Path
        A string containing PowerShell filename

        .EXAMPLE
        ($ParsedModule, $ParserErrors) = Get-ParsedFile -Path $ModuleFile

    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        if (-not(Test-Path -Path $Path)) {
            throw "$Path doesn't exist"
        }
    }
    catch {
        throw $_
    }

    $fileContent = Get-Content -Path $Path -Raw

    ($ParsedModule, $ParserErrorCount) = Get-ParsedContent -Content $fileContent

    return $ParsedModule, $ParserErrorCount

}

function Get-ScriptParameter {
    <#
        .SYNOPSIS
        Get a list of the parameters in the param block

        .DESCRIPTION
        Create a list of the parameters, and their type (if available) from the param block

        .PARAMETER Content
        A string containing the text of the script

        .EXAMPLE
        $parameterVariables = Get-ScriptParameter -Content $Content
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [HashTable])]
    param (
        [parameter(Mandatory = $true)]
        [String]$Content
    )

    try {

        $parsedScript = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref]$null, [ref]$null)

        if ([string]::IsNullOrEmpty($parsedScript.ParamBlock)) {
            throw "No parameters found"
        }

        [string]$paramBlock = $parsedScript.ParamBlock

        ($ParsedContent, $ParserErrorCount) = Get-ParsedContent -Content $paramBlock

        $paramBlockArray = ($paramBlock -split '\n').Trim()

        $parametersFound = @{}

        for ($line = 0; $line -le $paramBlockArray.Count; $line++) {

            $paramToken = @($ParsedContent | Where-Object { $_.StartLine -eq $line })

            foreach ($token in $paramToken) {

                if ($token.Type -eq 'Attribute' -and $token.Content -eq "Parameter") {

                    break
                }

                if ($token.Type -eq 'Type') {

                    $foundType = $token.Content

                }

                if ($token.Type -eq 'Variable') {

                    $parametersFound[$token.Content] = $foundType
                    $foundType = $null
                    break

                }

            }

        }

        return $parametersFound

    }
    catch {

        throw $_.Exception.Message

    }

}

function Get-TagList {
    <#
        .SYNOPSIS
        Return a list of test tags

        .DESCRIPTION
        Return a list of test tags from the module and script checks file

        .EXAMPLE
        ($moduleTags, $scriptTags) = Get-TagList

    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
    )

    $moduleTags = @()
    $scriptTags = @()

    $modulePath = (Get-Module -Name 'PSQualityCheck').ModuleBase

    $checksPath = (Join-Path -Path $modulePath -ChildPath "Checks")

    Get-Content -Path (Join-Path -Path $checksPath -ChildPath "Module.Tests.ps1") -Raw | ForEach-Object {
        $ast = [Management.Automation.Language.Parser]::ParseInput($_, [ref]$null, [ref]$null)
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "Describe" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $moduleTags += $_.CommandElements[3].Value
        }
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "It" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $moduleTags += $_.CommandElements[3].Value
        }
    }

    Get-Content -Path (Join-Path -Path $checksPath -ChildPath "Script.Tests.ps1") -Raw | ForEach-Object {
        $ast = [Management.Automation.Language.Parser]::ParseInput($_, [ref]$null, [ref]$null)
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "Describe" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $scriptTags += $_.CommandElements[3].Value
        }
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "It" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tag"
            }, $true) | ForEach-Object {
            $scriptTags += $_.CommandElements[3].Value
        }
    }

    return $moduleTags, $scriptTags

}

function Get-Token {
    <#
        .SYNOPSIS
        Get token(s) from the tokenized output

        .DESCRIPTION
        Get token(s) from the tokenized output matching the passed Type and Content

        .PARAMETER ParsedContent
        A string array containing the Tokenized data

        .PARAMETER Type
        The token type to be found

        .PARAMETER Content
        The token content (or value) to be found

        .EXAMPLE
        $outputTypeToken = (Get-Token -ParsedContent $ParsedFile -Type "Attribute" -Content "OutputType")
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedContent,
        [parameter(Mandatory = $true)]
        [string]$Type,
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    $token = Get-TokenMarker -ParsedContent $ParsedContent -Type $Type -Content $Content

    $tokens = Get-TokenComponent -ParsedContent $ParsedContent -StartLine $token.StartLine

    return $tokens

}

function Get-TokenComponent {
    <#
        .SYNOPSIS
        Get all the tokens components from a single line

        .DESCRIPTION
        Get all the tokens components from a single line in the tokenized content

        .PARAMETER ParsedContent
        A string array containing the tokenized content

        .PARAMETER StartLine
        A integer of the starting line to parse

        .EXAMPLE
        $tokens = Get-TokenComponent -ParsedContent $ParsedContent -StartLine 10
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedContent,
        [parameter(Mandatory = $true)]
        [int]$StartLine
    )

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $StartLine = $StartLine

    $tokenComponents = @($ParsedContent | Where-Object { $_.StartLine -eq $StartLine })

    return $tokenComponents

}

function Get-TokenMarker {
    <#
        .SYNOPSIS
        Gets token from the tokenized output

        .DESCRIPTION
        Gets single token from the tokenized output matching the passed Type and Content

        .PARAMETER ParsedContent
        A string array containing the Tokenized data

        .PARAMETER Type
        The token type to be found

        .PARAMETER Content
        The token content (or value) to be found

        .EXAMPLE
        $token = Get-TokenMarker -ParsedContent $ParsedContent -Type $Type -Content $Content
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedContent,
        [parameter(Mandatory = $true)]
        [string]$Type,
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $Type = $Type
    $Content = $Content

    $token = @($ParsedContent | Where-Object { $_.Type -eq $Type -and $_.Content -eq $Content })

    return $token

}

function Test-HelpTokensCountIsValid {
    <#
        .SYNOPSIS
        Check that help tokens count is valid

        .DESCRIPTION
        Check that the help tokens count is valid by making sure that they appear between Min and Max times

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER HelpRulesPath
        Path to the HelpRules file

        .EXAMPLE
        Test-HelpTokensCountIsValid -HelpTokens $HelpTokens -HelpRulesPath "C:\HelpRules"

        .NOTES
        This function will only check the Min/Max counts of required help tokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens,

        [parameter(Mandatory = $true)]
        [string]$HelpRulesPath
    )

    try {

        $helpRules = Import-PowerShellDataFile -Path $HelpRulesPath

        $tokenFound = @{}
        for ($order = 1; $order -le $HelpRules.Count; $order++) {
            $helpRuleIndex = [string]$order
            $token = $HelpRules.$helpRuleIndex.Key
            $tokenFound[$token] = $false
        }

        $tokenErrors = @()

        foreach ($key in $HelpTokens.Keys) {

            for ($order = 1; $order -le $HelpRules.Count; $order++) {

                $helpRuleIndex = [string]$order
                $token = $HelpRules.$helpRuleIndex

                if ( $token.Key -eq $key ) {

                    $tokenFound[$key] = $true

                    if ($HelpTokens.$key.Count -lt $token.MinOccurrences -or
                        $HelpTokens.$key.Count -gt $token.MaxOccurrences -and
                        $token.Required -eq $true) {

                        $tokenErrors += "Found $(($HelpTokens.$key).Count) occurrences of '$key' which is not between $($token.MinOccurrences) and $($token.MaxOccurrences). "

                    }

                }

            }

        }

        if ($tokenErrors.Count -ge 1) {

            throw $tokenErrors

        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-HelpTokensParamsMatch {
    <#
        .SYNOPSIS
        Checks to see whether the parameters and help PARAMETER statements match

        .DESCRIPTION
        Checks to see whether the parameters in the param block and in the help PARAMETER statements exist in both locations

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER ParameterVariables
        A object containing the parameters from the param block

        .EXAMPLE
        Test-HelpTokensParamsMatch -HelpTokens $HelpTokens -ParameterVariables $ParameterVariables
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.String[]])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens,
        [parameter(Mandatory = $true)]
        [PSCustomObject]$ParameterVariables
    )

    try {

        $foundInHelpErrors = @()
        $foundInParamErrors = @()

        foreach ($key in $ParameterVariables.Keys) {

            $foundInHelp = $false

            foreach ($token in $HelpTokens.".PARAMETER") {

                if ($key -eq $token.Name) {

                    $foundInHelp = $true
                    break

                }

            }

            if ($foundInHelp -eq $false) {

                $foundInHelpErrors += "Parameter block variable '$key' was not found in help. "

            }

        }

        foreach ($token in $HelpTokens.".PARAMETER") {

            $foundInParams = $false

            foreach ($key in $ParameterVariables.Keys) {

                if ($key -eq $token.Name) {

                    $foundInParams = $true
                    break

                }

            }

            if ($foundInParams -eq $false) {

                $foundInParamErrors += "Help defined variable '$($token.Name)' was not found in parameter block definition. "

            }

        }

        if ($foundInHelpErrors.Count -ge 1 -or $foundInParamErrors.Count -ge 1) {

            $allErrors = $foundInHelpErrors + $foundInParamErrors
            throw $allErrors

        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-HelpTokensTextIsValid {
    <#
        .SYNOPSIS
        Check that Help Tokens text is valid

        .DESCRIPTION
        Check that the Help Tokens text is valid by making sure that they its not empty

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .EXAMPLE
        Test-HelpTokensTextIsValid -HelpTokens $HelpTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens
    )

    try {

        $tokenErrors = @()

        foreach ($key in $HelpTokens.Keys) {

            $tokenCount = @($HelpTokens.$key)

            for ($loop = 0; $loop -lt $tokenCount.Count; $loop++) {

                $token = $HelpTokens.$key[$loop]

                if ([string]::IsNullOrWhitespace($token.Text)) {

                    $tokenErrors += "Found '$key' does not have any text. "

                }

            }

        }

        if ($tokenErrors.Count -ge 1) {

            throw $tokenErrors

        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-ImportModuleIsValid {
    <#
        .SYNOPSIS
        Test that the Import-Module commands are valid

        .DESCRIPTION
        Test that the Import-Module commands contain a -Name parameter, and one of RequiredVersion, MinimumVersion or MaximumVersion

        .PARAMETER ParsedContent
        An object containing the source file parsed into its Tokenizer components

        .PARAMETER ImportModuleTokens
        An object containing the Import-Module tokens found

        .EXAMPLE
        TestImportModuleIsValid -ParsedContent $ParsedContent -ImportModuleTokens $importModuleTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedContent,
        [parameter(Mandatory = $true)]
        [System.Object[]]$ImportModuleTokens
    )

    try {

        $errString = ""

        foreach ($token in $importModuleTokens) {

            $importModuleStatement = Get-TokenComponent -ParsedContent $ParsedContent -StartLine $token.StartLine

            $name = ($importModuleStatement | Where-Object { $_.Type -eq "CommandArgument" } | Select-Object -First 1).Content
            if ($null -eq $name) {

                $name = ($importModuleStatement | Where-Object { $_.Type -eq "String" } | Select-Object -First 1).Content

            }

            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and $_.Content -eq "-Name" })) {

                $errString += "Import-Module for '$name' : Missing -Name parameter keyword. "

            }

            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and
                        ( $_.Content -eq "-RequiredVersion" -or $_.Content -eq "-MinimumVersion" -or $_.Content -eq "-MaximumVersion" )
                    })) {

                $errString += "Import-Module for '$name' : Missing -RequiredVersion, -MinimumVersion or -MaximumVersion parameter keyword. "

            }

        }

        if (-not ([string]::IsNullOrEmpty($errString))) {

            throw $errString

        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-ParameterVariablesHaveType {
    <#
        .SYNOPSIS
        Check that all the passed parameters have a type variable set.

        .DESCRIPTION
        Check that all the passed parameters have a type variable set.

        .PARAMETER ParameterVariables
        A HashTable containing the parameters from the param block

        .EXAMPLE
        Test-ParameterVariablesHaveType -ParameterVariables $ParameterVariables
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$ParameterVariables
    )

    $variableErrors = @()

    try {

        foreach ($key in $ParameterVariables.Keys) {

            if ([string]::IsNullOrEmpty($ParameterVariables.$key)) {

                $variableErrors += "Parameter '$key' does not have a type defined."

            }

        }

        if ($variableErrors.Count -ge 1) {

            throw $variableErrors
        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-RequiredToken {
    <#
        .SYNOPSIS
        Check that help tokens contain required tokens

        .DESCRIPTION
        Check that the help comments contain tokens that are specified in the external verification data file

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER HelpRulesPath
        Path to the HelpRules file

        .EXAMPLE
        Test-RequiredToken -HelpTokens $HelpTokens -HelpRulesPath "C:\HelpRules"
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens,

        [parameter(Mandatory = $true)]
        [string]$HelpRulesPath
    )

    try {

        $helpRules = Import-PowerShellDataFile -Path $HelpRulesPath

        $tokenErrors = @()

        for ($order = 1; $order -le $HelpRules.Count; $order++) {

            $helpRuleIndex = [string]$order
            $token = $HelpRules.$helpRuleIndex

            if ($token.Key -notin $HelpTokens.Keys ) {

                if ($token.Required -eq $true) {

                    $tokenErrors += $token.Key

                }

            }

        }

        if ($tokenErrors.Count -ge 1) {
            throw "Missing required token(s): $tokenErrors"
        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-UnspecifiedToken {
    <#
        .SYNOPSIS
        Check that help tokens do not contain unspecified tokens

        .DESCRIPTION
        Check that the help comments do not contain tokens that are not specified in the external verification data file

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER HelpRulesPath
        Path to the HelpRules file

        .EXAMPLE
        Test-UnspecifiedToken -HelpTokens $HelpTokens -HelpRulesPath "C:\HelpRules"
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens,

        [parameter(Mandatory = $true)]
        [string]$HelpRulesPath
    )

    try {

        $helpRules = Import-PowerShellDataFile -Path $HelpRulesPath

        $tokenErrors = @()
        $helpTokensKeys = @()

        # Create an array of the help element rules elements
        for ($order = 1; $order -le $helpRules.Count; $order++) {

            $helpRuleIndex = [string]$order
            $token = $helpRules.$helpRuleIndex

            $helpTokensKeys += $token.key

        }

        # search through the found tokens and match them against the rules
        foreach ($key in $helpTokens.Keys) {

            if ( $key -notin $helpTokensKeys ) {

                $tokenErrors += $key

            }

        }

        if ($tokenErrors.Count -ge 1) {
            throw "Found extra, non-specified, token(s): $tokenErrors"
        }

    }
    catch {

        throw $_.Exception.Message

    }

}

