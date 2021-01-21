param(
    [parameter(Mandatory = $true)]
    [string[]]$Source,

    [parameter(Mandatory = $true)]
    [string[]]$ScriptAnalyzerRulesPath
)

BeforeDiscovery {

    $scriptFiles = @()

    $Source | ForEach-Object {

        $fileProperties = (Get-Item -Path $_)

        $scriptFiles += @{
            'FullName' = $_
            'Name' = $fileProperties.Name
            'Directory' = $fileProperties.Directory

        }

    }

    if ( -not ($ScriptAnalyzerRulesPath -is [Array])) {
        $ScriptAnalyzerRulesPath = @($ScriptAnalyzerRulesPath)
    }

    $rulesPath = @()

    $ScriptAnalyzerRulesPath | ForEach-Object {

        $rulesPath += @{
            'Path' = $_

        }

    }

}

Describe "Script Tests" -Tag "Script" {

    Context "Script: <File.Name> at <File.Directory>" -Foreach $scriptFiles {

        BeforeAll {

            $file = $_

        }

        BeforeEach {

            $scriptFile = $file.FullName
            $fileContent = Get-FileContent -Path $file.FullName

            if (-not([string]::IsNullOrEmpty($fileContent))) {
                ($ParsedFile, $ErrorCount) = Get-ParsedContent -Content $fileContent
            }
            else {
                Write-Warning "File is empty"
                $ParsedFile = $null
                $ErrorCount = 1
            }

        }

        It "check script has valid PowerShell syntax" -Tag "ValidSyntax" {

            $ErrorCount | Should -Be 0

        }

        It "check help must contain required elements" -Tag "HelpMustContainRequiredElements" {

            {

                $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                if ([string]::IsNullOrEmpty($helpComments)) {
                    throw "No help block found"
                }
                $helpTokens = Convert-Help -Help $helpComments.Content
                Test-RequiredToken -HelpTokens $helpTokens

            } |
                Should -Not -Throw

        }

        It "check help must not contain unspecified elements" -Tag "HelpMustContainUnspecifiedElements" {

            {

                $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                if ([string]::IsNullOrEmpty($helpComments)) {
                    throw "No help block found"
                }
                $helpTokens = Convert-Help -Help $helpComments.Content
                Test-UnspecifiedToken -HelpTokens $helpTokens

            } |
                Should -Not -Throw

        }

        It "check help elements text is not empty" -Tag "HelpElementsNotEmpty" {

            {

                $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                if ([string]::IsNullOrEmpty($helpComments)) {
                    throw "No help block found"
                }
                $helpTokens = Convert-Help -Help $helpComments.Content
                Test-HelpTokensTextIsValid -HelpTokens $helpTokens

            } | Should -Not -Throw

        }

        It "check help elements Min/Max counts are valid" -Tag "HelpElementsMinMaxCount" {

            {

                $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                if ([string]::IsNullOrEmpty($helpComments)) {
                    throw "No help block found"
                }
                $helpTokens = Convert-Help -Help $helpComments.Content
                Test-HelpTokensCountIsValid -HelpTokens $helpTokens

            } | Should -Not -Throw

        }

        It "check script contains [CmdletBinding] attribute" -Tag "ContainsCmdletBinding" {

            $cmdletBindingCount = (@(Get-TokenMarker -ParsedContent $ParsedFile -Type "Attribute" -Content "CmdletBinding")).Count

            $cmdletBindingCount | Should -Be 1

        }

        It "check script contains [OutputType] attribute" -Tag "ContainsOutputType" {

            $outputTypeCount = (@(Get-TokenMarker -ParsedContent $ParsedFile -Type "Attribute" -Content "OutputType")).Count

            $outputTypeCount | Should -Be 1

        }

        It "check script [OutputType] attribute is not empty" -Tag "OutputTypeNotEmpty" {

            $outputTypeToken = (Get-Token -ParsedContent $ParsedFile -Type "Attribute" -Content "OutputType")

            $outputTypeValue = @($outputTypeToken | Where-Object { $_.Type -eq "Type" })

            $outputTypeValue | Should -Not -BeNullOrEmpty

        }

        # Note: Disabled because I'm questioning the validity of the rule. So many function haven't got a need for params
        # It "check script contains param attribute"  -Tag "ContainsParam" {

        #     $paramCount = (@(Get-TokenMarker -ParsedContent $ParsedFile -Type "Keyword" -Content "param")).Count

        #     $paramCount | Should -Be 1

        # }

        It "check script param block variables have type" -Tag "ParamVariablesHaveType" {

            $parameterVariables = Get-ScriptParameter -Content $fileContent

            if ($parameterVariables.Count -eq 0) {

                Set-ItResult -Inconclusive -Because "No parameters found"

            }

            {

                Test-ParameterVariablesHaveType -ParameterVariables $parameterVariables

            } | Should -Not -Throw

        }

        It "check .PARAMETER help matches variables in param block" -Tag "HelpMatchesParamVariables" {

            {

                $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                if ([string]::IsNullOrEmpty($helpComments)) {
                    throw "No help block found"
                }
                $parameterVariables = Get-ScriptParameter -Content $fileContent
                $helpTokens = Convert-Help -Help $helpComments.Content

                Test-HelpTokensParamsMatch -HelpTokens $helpTokens -ParameterVariables $parameterVariables

            } | Should -Not -Throw

        }

        It "check script contains no PSScriptAnalyzer suppressions" -Tag "NoScriptAnalyzerSuppressions" {

            $suppressCount = (@(Get-TokenMarker -ParsedContent $ParsedFile -Type "Attribute" -Content "Diagnostics.CodeAnalysis.SuppressMessageAttribute")).Count
            $suppressCount | Should -Be 0

            $suppressCount = (@(Get-TokenMarker -ParsedContent $ParsedFile -Type "Attribute" -Content "Diagnostics.CodeAnalysis.SuppressMessage")).Count
            $suppressCount | Should -Be 0

        }

        It "check script contains no PSScriptAnalyzer failures" -Tag "NoScriptAnalyzerFailures" {

            $AnalyserFailures = @(Invoke-ScriptAnalyzer -Path $scriptFile)

            ($AnalyserFailures | ForEach-Object { $_.Message }) | Should -BeNullOrEmpty

        }

        It "check script contains no PSScriptAnalyser rule failures '<_.Path>" -Tag "NoScriptAnalyzerExtraRulesFailures" -TestCases $rulesPath {

            param($Path)

            if ( [string]::IsNullOrEmpty($Path)) {

                Set-ItResult -Inconclusive -Because "Empty ScriptAnalyzerRulesPath '$Path'"

            }

            if ( -not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {

                Set-ItResult -Inconclusive -Because "ScriptAnalyzerRulesPath path '$Path' not found"

            }

            $AnalyserFailures = @(Invoke-ScriptAnalyzer -Path $scriptFile -CustomRulePath $Path)

            $AnalyserFailures | ForEach-Object { $_.Message } | Should -BeNullOrEmpty

        }

        It "check Import-Module statements have valid format" -Tag "ValidImportModuleStatements" {

            $importModuleTokens = @($ParsedFile | Where-Object { $_.Type -eq "Command" -and $_.Content -eq "Import-Module" })

            if ($importModuleTokens.Count -eq 0) {

                Set-ItResult -Inconclusive -Because "No Import-Module statements found"

            }

            {

                Test-ImportModuleIsValid -ParsedContent $ParsedFile -ImportModuleTokens $importModuleTokens

            } | Should -Not -Throw

        }

    }

}
