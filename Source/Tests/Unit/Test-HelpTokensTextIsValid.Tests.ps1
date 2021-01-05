Describe "Test-HelpTokensTextIsValid.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpTokens'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-HelpTokensTextIsValid').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-HelpTokensTextIsValid').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should HelpTokens type be HashTable" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpTokensTextIsValid').Parameters['HelpTokens'].ParameterType.Name | Should -Be 'HashTable'

        }

    }

    Context "Function tests" {

        It "should throw passing null parameters" {

            {

                Test-HelpTokensTextIsValid -HelpTokens $null

            } | Should -Throw

        }

        It "should not throw when checking help element text where it exists" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = "Convert the help comment into an object"
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Not -Throw

        }

        It "should throw when checking help element text where it is empty" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = ""
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking help element text where it is missing" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = $null
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should not throw when checking multiple valid help element text values" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = "The SYNOPSIS property"
                        }
                    )
                    '.DESCRIPTION' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 3
                            "Text" = "The DESCRIPTION property"
                        }
                    )
                    '.PARAMETER' = @(
                        @{
                            "Name" = "Path"
                            "LineNumber" = 5
                            "Text" = "The Path property"
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Not -Throw

        }

        It "should throw when checking multiple help element text values where one is empty" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = ""
                        }
                    )
                    '.DESCRIPTION' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 3
                            "Text" = "The DESCRIPTION property"
                        }
                    )
                    '.PARAMETER' = @(
                        @{
                            "Name" = "Path"
                            "LineNumber" = 5
                            "Text" = "The Path property"
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking multiple help element text values where one is missing" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = $null
                        }
                    )
                    '.DESCRIPTION' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 3
                            "Text" = "The DESCRIPTION property"
                        }
                    )
                    '.PARAMETER' = @(
                        @{
                            "Name" = "Path"
                            "LineNumber" = 5
                            "Text" = "The Path property"
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking multiple help element text values where all are empty" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = ""
                        }
                    )
                    '.DESCRIPTION' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 3
                            "Text" = ""
                        }
                    )
                    '.PARAMETER' = @(
                        @{
                            "Name" = "Path"
                            "LineNumber" = 5
                            "Text" = ""
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking multiple help element text values where all are missing" {

            {
                $help = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = $null
                        }
                    )
                    '.DESCRIPTION' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 3
                            "Text" = $null
                        }
                    )
                    '.PARAMETER' = @(
                        @{
                            "Name" = "Path"
                            "LineNumber" = 5
                            "Text" = $null
                        }
                    )
                }

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

    }

}
