Describe "Test-HelpTokensCountIsValid.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpTokens'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-HelpTokensCountIsValid').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-HelpTokensCountIsValid').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should HelpTokens type be HashTable" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpTokensCountIsValid').Parameters['HelpTokens'].ParameterType.Name | Should -Be 'HashTable'

        }

    }

    Context "Function tests" {

        BeforeAll {
            New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'module') -ItemType Directory
            New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'module\checks') -ItemType Directory

            '@{
                ''1'' = @{
                    Key = ''.SYNOPSIS''
                    Required = $true
                    MinOccurrences = 1
                    MaxOccurrences = 1
                }
                ''2'' = @{
                    Key = ''.DESCRIPTION''
                    Required = $true
                    MinOccurrences = 1
                    MaxOccurrences = 1
                }
                ''3'' = @{
                    Key = ''.PARAMETER''
                    Required = $false
                    MinOccurrences = 0
                    MaxOccurrences = 0
                }
                ''4'' = @{
                    Key = ''.EXAMPLE''
                    Required = $true
                    MinOccurrences = 1
                    MaxOccurrences = 100
                }
                ''5'' = @{
                    Key = ''.INPUTS''
                    Required = $false
                    MinOccurrences = 0
                    MaxOccurrences = 0
                }
                ''6'' = @{
                    Key = ''.OUTPUTS''
                    Required = $false
                    MinOccurrences = 0
                    MaxOccurrences = 0
                }
                ''7'' = @{
                    Key = ''.NOTES''
                    Required = $false
                    MinOccurrences = 0
                    MaxOccurrences = 0
                }
                ''8'' = @{
                    Key = ''.LINK''
                    Required = $false
                    MinOccurrences = 0
                    MaxOccurrences = 0
                }
            }' | Set-Content -Path (Join-Path -Path $TestDrive -ChildPath 'module\checks\HelpElementRules.psd1')
        }

        BeforeEach {
            Mock Get-Module -ParameterFilter { $Name -eq "PSQualityCheck" } {
                return @{'ModuleBase' = Join-Path -Path $TestDrive -ChildPath 'module' }
            }
        }

        It "should throw when passing null parameters" {

            {

                Test-HelpTokensCountIsValid -HelpTokens $null

            } | Should -Throw

        }

        It "should not throw when checking required help tokens count" {

            {
                $helpTokens = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = ""
                        }
                    )
                }

                Test-HelpTokensCountIsValid -HelpTokens $helpTokens

                Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

            } | Should -Not -Throw

        }

        It "should throw when required help token is out of min/max range" {

            {
                $helpTokens = @{
                    '.SYNOPSIS' = @(
                        @{
                            "Name" = $null
                            "LineNumber" = 1
                            "Text" = ""
                        },
                        @{
                            "Name" = $null
                            "LineNumber" = 2
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

                Test-HelpTokensCountIsValid -HelpTokens $helpTokens

                Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

            } | Should -Throw

        }


        It "should not throw when optional help token is out of min/max range" {

            {
                $helpTokens = @{
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
                    '.NOTES' = @(
                        @{
                            "Name" = ""
                            "LineNumber" = 10
                            "Text" = "This is a note"
                        },
                        @{
                            "Name" = ""
                            "LineNumber" = 10
                            "Text" = "This is a note"
                        }
                    )
                }

                Test-HelpTokensCountIsValid -HelpTokens $helpTokens

                Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

            } | Should -Not -Throw

        }

    }

}
