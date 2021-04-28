InModuleScope PSQualityCheck {

    Describe "TestHelpTokensParamsMatch.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'HelpTokens'; 'Type' = 'HashTable' }
            @{ 'Name' = 'ParameterVariables'; 'Type' = 'PSObject' }
        ) {

            BeforeAll {
                $commandletUnderTest = "TestHelpTokensParamsMatch"
            }

            It "should have $Name as a mandatory parameter" {

                (Get-Command -Name $commandletUnderTest).Parameters[$Name].Name | Should -BeExactly $Name
                (Get-Command -Name $commandletUnderTest).Parameters[$Name].Attributes.Mandatory | Should -BeTrue

            }

            It "should $Name not belong to a parameter set" {

                (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterSets.Keys | Should -Be '__AllParameterSets'

            }

            It "should $Name type be $Type" {

                (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterType.Name | Should -Be $Type

            }

        }

        Context "Function tests" {

            It "should throw when passing null parameters" {

                {

                    TestHelpTokensParamsMatch -HelpTokens $null -ParameterVariables $null

                } | Should -Throw

            }

            It "should not throw when single param block variables matches .PARAMETER help when valid" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterWithType'
                                "LineNumber" = 1
                                "Text"       = "ParameterWithType description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterWithType" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Not -Throw

            }

            It "should throw when single param block variable does not match .PARAMETER help when invalid" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterUnmatched'
                                "LineNumber" = 1
                                "Text"       = "ParameterUnmatched description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterWithType" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Throw

            }

            It "should not throw when multiple param block variables match .PARAMETER help when valid" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterOne'
                                "LineNumber" = 1
                                "Text"       = "ParameterOne description"
                            },
                            @{
                                "Name"       = 'ParameterTwo'
                                "LineNumber" = 1
                                "Text"       = "ParameterTwo description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterOne" = '[string]'
                        "ParameterTwo" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Not -Throw

            }

            It "should throw when multiple param block variables do not match .PARAMETER help when one is invalid" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterA'
                                "LineNumber" = 1
                                "Text"       = "ParameterA description"
                            },
                            @{
                                "Name"       = 'ParameterTwo'
                                "LineNumber" = 1
                                "Text"       = "ParameterTwo description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterOne" = '[string]'
                        "ParameterTwo" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Throw

            }

            It "should throw when multiple param block variables do not match .PARAMETER help when all are invalid" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterA'
                                "LineNumber" = 1
                                "Text"       = "ParameterA description"
                            },
                            @{
                                "Name"       = 'ParameterB'
                                "LineNumber" = 1
                                "Text"       = "ParameterB description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterOne" = '[string]'
                        "ParameterTwo" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Throw

            }

            It "should throw when multiple param block variables do not match .PARAMETER help when one is missing" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterOne'
                                "LineNumber" = 1
                                "Text"       = "ParameterOne description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterOne" = '[string]'
                        "ParameterTwo" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Throw

            }

            It "should throw when multiple param block variables do not match .PARAMETER help when all are missing" {

                {
                    $help = @{
                        '.SYNOPSIS' = @(
                            @{
                                "Name"       = ''
                                "LineNumber" = 1
                                "Text"       = "Description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterOne" = '[string]'
                        "ParameterTwo" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Throw

            }

            It "should throw when .PARAMETER help does not match param block variables when one is missing" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterOne'
                                "LineNumber" = 1
                                "Text"       = "ParameterOne description"
                            },
                            @{
                                "Name"       = 'ParameterTwo'
                                "LineNumber" = 1
                                "Text"       = "ParameterTwo description"
                            }
                        )
                    }
                    $parameterVariable = @{
                        "ParameterTwo" = '[string]'
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Throw

            }

            It "should throw when .PARAMETER help does not match param block variables when all are missing" {

                {
                    $help = @{
                        '.PARAMETER' = @(
                            @{
                                "Name"       = 'ParameterOne'
                                "LineNumber" = 1
                                "Text"       = "ParameterOne description"
                            },
                            @{
                                "Name"       = 'ParameterTwo'
                                "LineNumber" = 1
                                "Text"       = "ParameterTwo description"
                            }
                        )
                    }
                    $parameterVariable = @{
                    }

                    TestHelpTokensParamsMatch -HelpTokens $help -ParameterVariables $parameterVariable

                } | Should -Throw

            }

        }

    }

}
