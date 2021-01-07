param(
    [parameter(Mandatory = $true)]
    [string[]]$Source,

    [parameter(Mandatory = $false)]
    [string]$SonarQubeRules
)

Describe "Script Tests" {

    foreach ($scriptFile in $Source) {

        $scriptProperties = (Get-Item -Path $scriptFile)

        Context "Script : $($scriptProperties.Name) at $($scriptProperties.Directory)" {

            # This needs to get the content of the file or the content of the function inside the file
            $fileContent = Get-FileContent -Path $scriptFile

            if (-not([string]::IsNullOrEmpty($fileContent))) {
                ($ParsedFile, $ErrorCount) = Get-ParsedContent -Content $fileContent
            }
            else {
                Write-Warning "File is empty"
                $ParsedFile = $null
                $ErrorCount = 1
            }

            It "check script has valid PowerShell syntax" -TestCases @{ 'ErrorCount' = $ErrorCount } {

                $ErrorCount | Should -Be 0

            }

            It "check help must contain required elements" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                {

                    $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                    if ([string]::IsNullOrEmpty($helpComments)) {
                        throw "No help block found"
                    }
                    $helpTokens = Convert-Help -HelpComment $helpComments.Content
                    Test-HelpForRequiredTokens -HelpTokens $helpTokens

                } |
                    Should -Not -Throw

            }
            It "check help must not contain unspecified elements" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                {

                    $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                    if ([string]::IsNullOrEmpty($helpComments)) {
                        throw "No help block found"
                    }
                    $helpTokens = Convert-Help -HelpComment $helpComments.Content
                    Test-HelpForUnspecifiedTokens -HelpTokens $helpTokens

                } |
                    Should -Not -Throw

            }

            It "check help elements text is not empty" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                {

                    $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                    if ([string]::IsNullOrEmpty($helpComments)) {
                        throw "No help block found"
                    }
                    $helpTokens = Convert-Help -HelpComment $helpComments.Content
                    Test-HelpTokensTextIsValid -HelpTokens $helpTokens

                } | Should -Not -Throw

            }

            It "check help elements Min/Max counts are valid" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                {

                    $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                    if ([string]::IsNullOrEmpty($helpComments)) {
                        throw "No help block found"
                    }
                    $helpTokens = Convert-Help -HelpComment $helpComments.Content
                    Test-HelpTokensCountIsValid -HelpTokens $helpTokens

                } | Should -Not -Throw

            }

            It "check script contains [CmdletBinding] attribute" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                $cmdletBindingCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Attribute" -Content "CmdletBinding")).Count

                $cmdletBindingCount | Should -Be 1

            }

            It "check script contains [OutputType] attribute" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                $outputTypeCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Attribute" -Content "OutputType")).Count

                $outputTypeCount | Should -Be 1

            }

            It "check script [OutputType] attribute is not empty" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                $outputTypeToken = (Get-Token -ParsedFileContent $ParsedFile -Type "Attribute" -Content "OutputType")

                $outputTypeValue = @($outputTypeToken | Where-Object { $_.Type -eq "Type" })

                $outputTypeValue | Should -Not -BeNullOrEmpty

            }

            It "check script contains param attribute" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                $paramCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Keyword" -Content "param")).Count

                $paramCount | Should -Be 1

            }

            It "check script param block variables have type" -TestCases @{ 'ParsedFile' = $ParsedFile; 'fileContent' = $fileContent } {

                $parameterVariables = Get-ScriptParameters -Content $fileContent

                if ($parameterVariables.Count -eq 0) {

                    Set-ItResult -Inconclusive -Because "No parameters found"

                }

                {

                    Test-ParameterVariablesHaveType -ParameterVariables $parameterVariables

                } | Should -Not -Throw

            }

            It "check .PARAMETER help matches variables in param block" -TestCases @{ 'ParsedFile' = $ParsedFile; 'fileContent' = $fileContent } {

                {

                    $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)
                    if ([string]::IsNullOrEmpty($helpComments)) {
                        throw "No help block found"
                    }
                    $parameterVariables = Get-ScriptParameters -Content $fileContent
                    $helpTokens = Convert-Help -HelpComment $helpComments.Content

                    Test-HelpTokensParamsMatch -HelpTokens $helpTokens -ParameterVariables $parameterVariables

                } | Should -Not -Throw

            }

            It "check script contains no PSScriptAnalyzer suppressions" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                $suppressCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Attribute" -Content "Diagnostics.CodeAnalysis.SuppressMessageAttribute")).Count

                $suppressCount | Should -Be 0

            }

            It "check script contains no PSScriptAnalyzer failures" -TestCases @{ 'scriptFile' = $scriptProperties.FullName } {

                $AnalyserFailures = @(Invoke-ScriptAnalyzer -Path $scriptFile)

                ($AnalyserFailures | ForEach-Object { $_.Message }) | Should -BeNullOrEmpty

            }

            It "check script contains no PSScriptAnalyser SonarQube rule failures" -TestCases @{ 'scriptFile' = $scriptProperties.FullName } {

                if ( [string]::IsNullOrEmpty($SonarQubeRules) ) {

                    Set-ItResult -Inconclusive -Because "No SonarQube PSScriptAnalyzer rules folder specified"

                }

                if ( -not (Test-Path -Path $SonarQubeRules -ErrorAction SilentlyContinue)) {

                    Set-ItResult -Inconclusive -Because "SonarQube PSScriptAnalyzer rules not found"

                }

                $AnalyserFailures = @(Invoke-ScriptAnalyzer -Path $scriptFile -CustomRulePath $SonarQubeRules)

                $AnalyserFailures | ForEach-Object { $_.Message } | Should -BeNullOrEmpty

            }

            It "check Import-Module statements have valid format" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                $importModuleTokens = @($ParsedFile | Where-Object { $_.Type -eq "Command" -and $_.Content -eq "Import-Module" })

                if ($importModuleTokens.Count -eq 0) {

                    Set-ItResult -Inconclusive -Because "No Import-Module statements found"

                }

                {

                    Test-ImportModuleIsValid -ParsedFile $ParsedFile -ImportModuleTokens $importModuleTokens

                } | Should -Not -Throw

            }

        }

    }

}
