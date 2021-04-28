InModuleScope PSQualityCheck {

    Describe "TestHelpTokensCountIsValid.Tests" {

        Context "Parameter Tests" -Foreach @(
            @{ 'Name' = 'HelpTokens'; 'Type' = 'HashTable' }
        ) {

            BeforeAll {
                $commandletUnderTest = "TestHelpTokensCountIsValid"
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

            BeforeAll {
                New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'module') -ItemType Directory
                New-Item -Path (Join-Path -Path $TestDrive -ChildPath 'module\Data') -ItemType Directory

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
            }' | Set-Content -Path (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')
            }

            BeforeEach {
                Mock Get-Module -ParameterFilter { $Name -eq "PSQualityCheck" } {
                    return @{'ModuleBase' = Join-Path -Path $TestDrive -ChildPath 'module' }
                }
            }

            It "should throw when passing null parameters" {

                {

                    TestHelpTokensCountIsValid -HelpTokens $null -HelpRulesPath $null

                } | Should -Throw

            }

            It "should not throw when checking required help tokens count" {

                {
                    $helpTokens = @{
                        '.SYNOPSIS' = @(
                            @{
                                "Name"       = $null
                                "LineNumber" = 1
                                "Text"       = ""
                            }
                        )
                    }

                    TestHelpTokensCountIsValid -HelpTokens $helpTokens -HelpRulesPath (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')

                    Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

                } | Should -Not -Throw

            }

            It "should throw when required help token is out of min/max range" {

                {
                    $helpTokens = @{
                        '.SYNOPSIS'    = @(
                            @{
                                "Name"       = $null
                                "LineNumber" = 1
                                "Text"       = ""
                            },
                            @{
                                "Name"       = $null
                                "LineNumber" = 2
                                "Text"       = ""
                            }
                        )
                        '.DESCRIPTION' = @(
                            @{
                                "Name"       = $null
                                "LineNumber" = 3
                                "Text"       = ""
                            }
                        )
                        '.PARAMETER'   = @(
                            @{
                                "Name"       = "Path"
                                "LineNumber" = 5
                                "Text"       = ""
                            }
                        )
                    }

                    TestHelpTokensCountIsValid -HelpTokens $helpTokens -HelpRulesPath (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')

                    Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

                } | Should -Throw

            }


            It "should not throw when optional help token is out of min/max range" {

                {
                    $helpTokens = @{
                        '.SYNOPSIS'    = @(
                            @{
                                "Name"       = $null
                                "LineNumber" = 1
                                "Text"       = ""
                            }
                        )
                        '.DESCRIPTION' = @(
                            @{
                                "Name"       = $null
                                "LineNumber" = 3
                                "Text"       = ""
                            }
                        )
                        '.PARAMETER'   = @(
                            @{
                                "Name"       = "Path"
                                "LineNumber" = 5
                                "Text"       = ""
                            }
                        )
                        '.NOTES'       = @(
                            @{
                                "Name"       = ""
                                "LineNumber" = 10
                                "Text"       = "This is a note"
                            },
                            @{
                                "Name"       = ""
                                "LineNumber" = 10
                                "Text"       = "This is a note"
                            }
                        )
                    }

                    TestHelpTokensCountIsValid -HelpTokens $helpTokens -HelpRulesPath (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')

                    Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

                } | Should -Not -Throw

            }

        }

    }

}
