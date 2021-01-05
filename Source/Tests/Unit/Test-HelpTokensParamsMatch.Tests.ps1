Describe "Test-HelpTokensParamsMatch.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpTokens'
            'ParameterVariables'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should HelpTokens type be HashTable" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters['HelpTokens'].ParameterType.Name | Should -Be 'HashTable'

        }

        It "should ParameterVariables type be PSCustomObject" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters['ParameterVariables'].ParameterType.Name | Should -Be 'PSObject'

        }

    }

    Context "Function tests" {

        It "should throw passing null parameters" {

            {

                Test-HelpTokensParamsMatch -HelpTokens $null -ParameterVariables $null

            } | Should -Throw

        }

        It "should not throw when single param block variables matches .PARAMETER help when valid" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterWithType'
                            "LineNumber" = 1
                            "Text" = "ParameterWithType description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterWithType" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Not -Throw

        }

        It "should throw when single param block variable does not match .PARAMETER help when invalid" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterUnmatched'
                            "LineNumber" = 1
                            "Text" = "ParameterUnmatched description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterWithType" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Throw

        }

        It "should not throw when multiple param block variables match .PARAMETER help when valid" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterOne'
                            "LineNumber" = 1
                            "Text" = "ParameterOne description"
                        },
                        @{
                            "Name" = 'ParameterTwo'
                            "LineNumber" = 1
                            "Text" = "ParameterTwo description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterOne" = '[string]'
                    "ParameterTwo" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Not -Throw

        }

        It "should throw when multiple param block variables do not match .PARAMETER help when one is invalid" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterA'
                            "LineNumber" = 1
                            "Text" = "ParameterA description"
                        },
                        @{
                            "Name" = 'ParameterTwo'
                            "LineNumber" = 1
                            "Text" = "ParameterTwo description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterOne" = '[string]'
                    "ParameterTwo" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Throw

        }

        It "should throw when multiple param block variables do not match .PARAMETER help when all are invalid" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterA'
                            "LineNumber" = 1
                            "Text" = "ParameterA description"
                        },
                        @{
                            "Name" = 'ParameterB'
                            "LineNumber" = 1
                            "Text" = "ParameterB description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterOne" = '[string]'
                    "ParameterTwo" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Throw

        }

        It "should throw when multiple param block variables do not match .PARAMETER help when one is missing" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterOne'
                            "LineNumber" = 1
                            "Text" = "ParameterOne description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterOne" = '[string]'
                    "ParameterTwo" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Throw

        }

        It "should throw when multiple param block variables do not match .PARAMETER help when all are missing" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = ''
                            "LineNumber" = 1
                            "Text" = "Description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterOne" = '[string]'
                    "ParameterTwo" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Throw

        }

        It "should throw when .PARAMETER help does not match param block variables when one is missing" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterOne'
                            "LineNumber" = 1
                            "Text" = "ParameterOne description"
                        },
                        @{
                            "Name" = 'ParameterTwo'
                            "LineNumber" = 1
                            "Text" = "ParameterTwo description"
                        }
                    )
                }
                $parameterVariable = @{
                    "ParameterTwo" = '[string]'
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Throw

        }

        It "should throw when .PARAMETER help does not match param block variables when all are missing" {

            {
                $help = @{
                    '.PARAMETER' = @(
                        @{
                            "Name" = 'ParameterOne'
                            "LineNumber" = 1
                            "Text" = "ParameterOne description"
                        },
                        @{
                            "Name" = 'ParameterTwo'
                            "LineNumber" = 1
                            "Text" = "ParameterTwo description"
                        }
                    )
                }
                $parameterVariable = @{
                }

                Test-HelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

            } | Should -Throw

        }

    }

}
