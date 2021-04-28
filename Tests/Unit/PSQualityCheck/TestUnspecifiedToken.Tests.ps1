InModuleScope PSQualityCheck {

    Describe "TestUnspecifiedToken.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'HelpTokens'; 'Type' = 'HashTable' }
        ) {

            BeforeAll {
                $commandletUnderTest = "TestUnspecifiedToken"
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

                    TestUnspecifiedToken -HelpTokens $null -HelpRulesPath (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')

                } | Should -Throw

            }

            It "should not throw when checking required help tokens" {

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
                        '.EXAMPLE'     = @(
                            @{
                                "Name"       = ""
                                "LineNumber" = 7
                                "Text"       = "This is example text"
                            }
                        )
                    }

                    TestUnspecifiedToken -HelpTokens $helpTokens -HelpRulesPath (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')

                    Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

                } | Should -Not -Throw

            }

            It "should not throw when checking required help tokens plus optional help tokens" {

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
                        '.EXAMPLE'     = @(
                            @{
                                "Name"       = ""
                                "LineNumber" = 7
                                "Text"       = "This is example text"
                            }
                        )
                        '.NOTES'       = @(
                            @{
                                "Name"       = ""
                                "LineNumber" = 10
                                "Text"       = "This is a note"
                            }
                        )

                    }

                    TestUnspecifiedToken -HelpTokens $helpTokens -HelpRulesPath (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')

                    Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

                } | Should -Not -Throw

            }

            It "should throw when unspecified help token is present" {

                {
                    $helpTokens = @{
                        '.DUMMY' = @(
                            @{
                                "Name"       = $null
                                "LineNumber" = 1
                                "Text"       = ""
                            }
                        )
                    }

                    TestUnspecifiedToken -HelpTokens $helpTokens -HelpRulesPath (Join-Path -Path $TestDrive -ChildPath 'module\Data\HelpRules.psd1')

                    Assert-MockCalled -CommandName Get-Module -Times 1 -ParameterFilter { $Name -eq "PSQualityCheck" }

                } | Should -Throw

            }

        }

    }

}
