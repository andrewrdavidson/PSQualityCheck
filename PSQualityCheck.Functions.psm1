function Convert-Help {
    <#
        .SYNOPSIS
        Convert the help comment into an object

        .DESCRIPTION
        Convert the help comment into an object containing all the elements from the help comment

        .PARAMETER HelpComment
        A string containing the Help Comment

        .EXAMPLE
        $helpObject = Convert-Help -HelpComment $helpComment
    #>
    [CmdletBinding()]
    [OutputType([HashTable], [System.Exception])]
    param (
        [parameter(Mandatory = $true)]
        [string]$HelpComment
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
                $HelpComment.StartsWith("<#") -and
                $HelpComment.EndsWith("#>")
            )) {
            throw "Help does not appear to be a comment block"
        }

        # an array of string help elements to look for
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

        # Split the single comment string into it's line components
        $commentArray = ($HelpComment -split '\n').Trim()

        # initialise an empty HashTable ready for the found help elements to be stored
        $foundElements = @{}
        $numFound = 0

        # loop through all the 'lines' of the help comment
        for ($line = 0; $line -lt $commentArray.Count; $line++) {

            # get the first 'word' of the help comment. This is required so that we can
            # match '.PARAMETER' since it has a parameter name after it
            $helpElementName = ($commentArray[$line] -split " ")[0]

            # see whether the $helpElements array contains the first 'word'
            if ($helpElementsToFind -contains $helpElementName) {

                $numFound++

                if ($numFound -ge 2) {

                    # of it's the second element then we must set the help comment text of the
                    # previous element to the found text so far, then reset it

                    $lastElement = @($foundElements[$lastHelpElement])
                    $lastElement[$lastElement.Count - 1].Text = $help
                    $foundElements[$lastHelpElement] = $lastElement

                    $help = $null
                }

                # this should be an array of HashTables {LineNumber, Name & Text}
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

                # update the foundItems HashTable with the new found element
                $foundElements[$helpElementName] = $currentElement

                $lastHelpElement = $helpElementName

            }
            else {

                if ($numFound -ge 1 -and $line -ne ($commentArray.Count - 1)) {

                    $help += $commentArray[$line]

                }

            }

        }

        # process the very last one
        $currentElement = @($foundElements[$lastHelpElement])
        $currentElement[$currentElement.Count - 1].Text = $help
        $foundElements[$lastHelpElement] = $currentElement

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

        .PARAMETER FunctionExtractPath
        A string Path containing the full path to the extraction folder

        .EXAMPLE
        Export-FunctionsFromModule -Path 'c:\path.to\module.psm1' -FunctionExtractPath 'c:\extract'
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$FunctionExtractPath
    )

    # Get the file properties of our module
    $fileProperties = (Get-Item -LiteralPath $Path)
    $moduleName = $fileProperties.BaseName

    # Generate a new temporary output path for our extracted functions
    $FunctionOutputPath = Join-Path -Path $FunctionExtractPath -ChildPath $moduleName
    New-Item $FunctionOutputPath -ItemType 'Directory'

    # Get the plain content of the module file
    $ModuleFileContent = Get-Content -Path $Path -ErrorAction Stop

    # Parse the PowerShell module using PSParser
    $ParserErrors = $null
    $ParsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($ModuleFileContent, [ref]$ParserErrors)

    # Create an array of where each reference of the keyword 'function' is
    $ParsedFunctions = ($ParsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

    # Initialise the $parsedFunction tracking variable
    $parsedFunction = 0

    if ($ParsedFunctions.Count -ge 1) {

        foreach ($Function in $ParsedFunctions) {

            # Counter for the array $ParsedFunction to help find the 'next' function
            $parsedFunction++

            # Get the name of the current function
            # Cheat: Simply getting all properties with the same line number as the 'function' statement
            $FunctionProperties = $ParsedFileFunctions | Where-Object { $_.StartLine -eq $Function.StartLine }
            $FunctionName = ($FunctionProperties | Where-Object { $_.Type -eq "CommandArgument" }).Content

            # Establish the Start and End lines for the function in the main module file
            if ($parsedFunction -eq $ParsedFunctions.Count) {

                # This is the last function in the module so set the last line of this function to be the last line in the module file

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

                # EndLine needs to be where the last } is
                for ($line = $ParsedFunctions[$parsedFunction].StartLine; $line -gt $Function.StartLine; $line--) {
                    if ($ModuleFileContent[$line] -like "}") {
                        $EndLine = $line
                        break
                    }
                }

            }

            # Setup the FunctionOutputFile for the function file
            $FunctionOutputFileName = "{0}\{1}{2}" -f $FunctionOutputPath, $FunctionName, ".ps1"

            # If the file doesn't exist create an empty file so that we can Add-Content to it
            if (-not (Test-Path -Path $FunctionOutputFileName)) {
                Out-File -FilePath $FunctionOutputFileName
            }

            # Output the lines of the function to the FunctionOutputFile
            for ($line = $StartLine; $line -lt $EndLine; $line++) {
                Add-Content -Path $FunctionOutputFileName -Value $ModuleFileContent[$line]
            }

        }
    }
    else {
        Write-Warning "Module contains no functions, skipping"
    }

}

function Get-FileContent {
    <#
        .SYNOPSIS
        Gets the content of a script file

        .DESCRIPTION
        Gets the content of the file or the content of the function inside the file

        .PARAMETER File
        A file name to parse

        .EXAMPLE
        $fileContent = Get-FileContent -File 'c:\file.txt'
    #>
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$File
    )

    $fileContent = Get-Content -Path $File

    $parserErrors = $null

    # If the file content is null (an empty file) then generate an empty parsedFileFunctions array to allow the function to complete
    if ([string]::IsNullOrEmpty($fileContent)) {
        $parsedFileFunctions = @()
    }
    else {
        $parsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$parserErrors)
    }

    # Create an array of where each reference of the keyword 'function' is
    $parsedFunctions = ($parsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

    if ($parsedFunctions) {

        foreach ($function in $parsedFunctions) {

            $startLine = ($function.StartLine)

            for ($line = $fileContent.Count; $line -gt $function.StartLine; $line--) {

                if ($fileContent[$line] -like "}") {

                    $endLine = $line
                    break

                }

            }

            # Output the lines of the function to the FunctionOutputFile
            for ($line = $startLine; $line -lt $endLine; $line++) {
                $parsedFileContent += $fileContent[$line]
                $parsedFileContent += "`n"
            }

        }

    }
    else {

        for ($line = 0; $line -lt $fileContent.Count; $line++) {
            $parsedFileContent += $fileContent[$line]
            $parsedFileContent += "`n"
        }

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

        .EXAMPLE
        $files = Get-FileList -Path 'c:\folder' -Extension ".ps1"
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$Extension
    )

    $Extension = $Extension

    $FileNameArray = @()

    if (Test-Path -Path $Path) {

        # Get the list of files
        $SelectedFilesArray = Get-ChildItem -Path $Path -Recurse -Exclude "*.Tests.*" | Where-Object { $_.Extension -eq $Extension } | Select-Object -Property FullName
        # Convert to a string array of filenames
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

        .PARAMETER ModuleFile
        A string containing the Module filename

        .PARAMETER ManifestFile
        A string containing the Manifest filename

        .EXAMPLE
        ($ExportedCommandsCount, $CommandFoundInModuleCount, $CommandInModuleCount, $CommandFoundInManifestCount) = Get-FunctionCount -ModuleFile $moduleFile -ManifestFile $manifestFile

    #>
    [CmdletBinding()]
    [OutputType([Int[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$ModuleFile,
        [parameter(Mandatory = $true)]
        [string]$ManifestFile
    )

    try {
        if (Test-Path -Path $ManifestFile) {
            $ExportedCommands = (Test-ModuleManifest -Path $ManifestFile -ErrorAction Stop).ExportedCommands
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
        if (Test-Path -Path $ModuleFile) {
            ($ParsedModule, $ParserErrors) = Get-ParsedFile -Path $ModuleFile
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

function Get-ScriptParameters {
    <#
        .SYNOPSIS
        Get a list of the parameters in the param block

        .DESCRIPTION
        Create a list of the parameters, and their type (if available) from the param block

        .PARAMETER Content
        A string containing the text of the script

        .EXAMPLE
        $parameterVariables = Get-ScriptParameters -Content $Content
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [HashTable])]
    param
    (
        [parameter(Mandatory = $true)]
        [String]$Content
    )

    try {

        $parsedScript = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref]$null, [ref]$null)

        [string]$paramBlock = $parsedScript.ParamBlock

        ($ParsedContent, $ParserErrorCount) = Get-ParsedContent -Content $paramBlock

        $paramBlockArray = ($paramBlock -split '\n').Trim()

        $parametersFound = @{}

        for ($line = 0; $line -le $paramBlockArray.Count; $line++) {

            $paramToken = @($ParsedContent | Where-Object { $_.StartLine -eq $line })

            foreach ($token in $paramToken) {

                if ($token.Type -eq 'Attribute' -and $token.Content -eq "Parameter") {

                    # break the inner loop because this token doesn't contain a variable for definite
                    break
                }

                if ($token.Type -eq 'Type') {

                    # Found a type for a parameter
                    $foundType = $token.Content

                }

                if ($token.Type -eq 'Variable') {

                    # Found a variable
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

function Get-Token {
    <#
        .SYNOPSIS
        Get token(s) from the tokenized output

        .DESCRIPTION
        Get token(s) from the tokenized output matching the passed Type and Content

        .PARAMETER ParsedFileContent
        A string array containing the Tokenized data

        .PARAMETER Type
        The token type to be found

        .PARAMETER Content
        The token content (or value) to be found

        .EXAMPLE
        $outputTypeToken = (Get-Token -ParsedFileContent $ParsedFile -Type "Attribute" -Content "OutputType")
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedFileContent,
        [parameter(Mandatory = $true)]
        [string]$Type,
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    $token = Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type $Type -Content $Content

    $tokens = Get-TokenComponent -ParsedFileContent $ParsedFileContent -StartLine $token.StartLine

    return $tokens

}

function Get-TokenComponent {
    <#
        .SYNOPSIS
        Get all the tokens components from a single line

        .DESCRIPTION
        Get all the tokens components from a single line in the tokenized content

        .PARAMETER ParsedFileContent
        A string array containing the tokenized content

        .PARAMETER StartLine
        A integer of the starting line to parse

        .EXAMPLE
        $tokens = Get-TokenComponent -ParsedFileContent $ParsedFileContent -StartLine 10
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedFileContent,
        [parameter(Mandatory = $true)]
        [int]$StartLine
    )

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $StartLine = $StartLine

    $tokenComponents = @($ParsedFileContent | Where-Object { $_.StartLine -eq $StartLine })

    return $tokenComponents

}

function Get-TokenMarker {
    <#
        .SYNOPSIS
        Gets token from the tokenized output

        .DESCRIPTION
        Gets single token from the tokenized output matching the passed Type and Content

        .PARAMETER ParsedFileContent
        A string array containing the Tokenized data

        .PARAMETER Type
        The token type to be found

        .PARAMETER Content
        The token content (or value) to be found

        .EXAMPLE
        $token = Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type $Type -Content $Content
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedFileContent,
        [parameter(Mandatory = $true)]
        [string]$Type,
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $Type = $Type
    $Content = $Content

    $token = @($ParsedFileContent | Where-Object { $_.Type -eq $Type -and $_.Content -eq $Content })

    return $token

}

function Test-HelpForRequiredTokens {
    <#
        .SYNOPSIS
        Check that help tokens contain required tokens

        .DESCRIPTION
        Check that the help comments contain tokens that are specified in the external verification data file

        .PARAMETER HelpTokens
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpForRequiredTokens -HelpTokens $HelpTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens
    )

    try {

        $module = Get-Module -Name PSQualityCheck

        if (Test-Path -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1")) {

            $helpElementRules = (Import-PowerShellDataFile -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1"))

        }
        else {

            throw "Unable to load Checks\HelpElementRules.psd1"

        }

        $tokenErrors = @()

        for ($order = 1; $order -le $helpElementRules.Count; $order++) {

            $token = $helpElementRules."$order"

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

function Test-HelpForUnspecifiedTokens {
    <#
        .SYNOPSIS
        Check that help tokens do not contain unspecified tokens

        .DESCRIPTION
        Check that the help comments do not contain tokens that are not specified in the external verification data file

        .PARAMETER HelpTokens
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpForUnspecifiedTokens -HelpTokens $HelpTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens
    )

    try {

        $module = Get-Module -Name PSQualityCheck

        if (Test-Path -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1")) {

            $helpElementRules = (Import-PowerShellDataFile -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1"))

        }
        else {

            throw "Unable to load Checks\HelpElementRules.psd1"

        }

        $tokenErrors = @()
        $helpTokensKeys = @()

        # Create an array of the help element rules elements
        for ($order = 1; $order -le $helpElementRules.Count; $order++) {

            $token = $helpElementRules."$order"

            $helpTokensKeys += $token.key

        }

        # search through the found tokens and match them against the rules
        foreach ($key in $HelpTokens.Keys) {

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

function Test-HelpTokensCountIsValid {
    <#
        .SYNOPSIS
        Check that help tokens count is valid

        .DESCRIPTION
        Check that the help tokens count is valid by making sure that they appear between Min and Max times

        .PARAMETER HelpTokens
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpTokensCountIsValid -HelpTokens $HelpTokens

        .NOTES
        This function will only check the Min/Max counts of required help tokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens
    )

    try {

        $module = Get-Module -Name PSQualityCheck

        if (Test-Path -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1")) {

            $helpElementRules = (Import-PowerShellDataFile -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1"))

        }
        else {

            throw "Unable to load Checks\HelpElementRules.psd1"

        }

        # create a HashTable for tracking whether the element has been found
        $tokenFound = @{}
        for ($order = 1; $order -le $helpElementRules.Count; $order++) {
            $token = $helpElementRules."$order".Key
            $tokenFound[$token] = $false
        }

        $tokenErrors = @()

        # loop through all the found tokens
        foreach ($key in $HelpTokens.Keys) {

            # loop through all the help element rules
            for ($order = 1; $order -le $helpElementRules.Count; $order++) {

                $token = $helpElementRules."$order"

                # if the found token matches against a rule
                if ( $token.Key -eq $key ) {

                    $tokenFound[$key] = $true

                    # if the count is not between min and max AND is required
                    # that's an error
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
        A string containing the text of the Help Comment

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

        # Loop through each of the parameters from the param block looking for that variable in the PARAMETER help
        foreach ($key in $ParameterVariables.Keys) {

            $foundInHelp = $false

            foreach ($token in $HelpTokens.".PARAMETER") {

                if ($key -eq $token.Name) {

                    # If we find a match, exit out from the loop
                    $foundInHelp = $true
                    break

                }

            }

            if ($foundInHelp -eq $false) {

                $foundInHelpErrors += "Parameter block variable '$key' was not found in help. "

            }

        }

        # Loop through each of the PARAMETER from the help looking for parameters from the param block
        foreach ($token in $HelpTokens.".PARAMETER") {

            $foundInParams = $false

            foreach ($key in $ParameterVariables.Keys) {

                if ($key -eq $token.Name) {

                    # If we find a match, exit out from the loop
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
        A string containing the text of the Help Comment

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

        # Check that the help blocks aren't empty
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

        .PARAMETER ParsedFile
        An object containing the source file parsed into its Tokenizer components

        .PARAMETER ImportModuleTokens
        An object containing the Import-Module calls found

        .EXAMPLE
        TestImportModuleIsValid -ParsedFile $parsedFile -ImportModuleTokens $importModuleTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param(
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedFile,
        [parameter(Mandatory = $true)]
        [System.Object[]]$ImportModuleTokens
    )

    try {

        $errString = ""

        # loop through each token found looking for the -Name and one of RequiredVersion, MinimumVersion or MaximumVersion
        foreach ($token in $importModuleTokens) {

            # Get the full details of the command
            $importModuleStatement = Get-TokenComponent -ParsedFileContent $ParsedFile -StartLine $token.StartLine

            # Get the name of the module to be imported (for logging only)
            $name = ($importModuleStatement | Where-Object { $_.Type -eq "String" } | Select-Object -First 1).Content

            # if the -Name parameter is not found
            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and $_.Content -eq "-Name" })) {

                $errString += "Import-Module for '$name' : Missing -Name parameter keyword. "

            }

            # if one of RequiredVersion, MinimumVersion or MaximumVersion is not found
            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and ( $_.Content -eq "-RequiredVersion" -or $_.Content -eq "-MinimumVersion" -or $_.Content -eq "-MaximumVersion" ) })) {

                $errString += "Import-Module for '$name' : Missing -RequiredVersion, -MinimumVersion or -MaximumVersion parameter keyword. "

            }

        }

        # If there are any problems throw to fail the test
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
    param
    (
        [parameter(Mandatory = $true)]
        [HashTable]$ParameterVariables
    )

    $variableErrors = @()

    try {

        foreach ($key in $ParameterVariables.Keys) {

            if ([string]::IsNullOrEmpty($ParameterVariables.$key)) {

                $variableErrors += "Parameter '$key' does not have a type defined. "

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

