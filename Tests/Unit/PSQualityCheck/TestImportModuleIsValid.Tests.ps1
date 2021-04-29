InModuleScope PSQualityCheck {

    Describe "TestImportModuleIsValid.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'ParsedContent'; 'Type' = 'Object[]' }
            @{ 'Name' = 'ImportModuleTokens'; 'Type' = 'Object[]' }
        ) {

            BeforeAll {
                $commandletUnderTest = "TestImportModuleIsValid"
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

            It "should throw when passing null parameter values" {

                {

                    TestImportModuleIsValid -ParsedContent $null -ImportModuleTokens $null

                } | Should -Throw

            }

            It "should pass when passed a valid Import-Module command" {

                {

                    $ParsedContent = @(
                        @{
                            "Content"     = "Import-Module"
                            "Type"        = "Command"
                            "Start"       = 0
                            "Length"      = 13
                            "StartLine"   = 1
                            "StartColumn" = 1
                            "EndLine"     = 1
                            "EndColumn"   = 14
                        },
                        @{
                            "Content"     = "-Name"
                            "Type"        = "CommandParameter"
                            "Start"       = 14
                            "Length"      = 5
                            "StartLine"   = 1
                            "StartColumn" = 15
                            "EndLine"     = 1
                            "EndColumn"   = 20
                        },
                        @{
                            "Content"     = "ModuleName"
                            "Type"        = "CommandArgument"
                            "Start"       = 20
                            "Length"      = 10
                            "StartLine"   = 1
                            "StartColumn" = 21
                            "EndLine"     = 1
                            "EndColumn"   = 31
                        },
                        @{
                            "Content"     = "-RequiredVersion"
                            "Type"        = "CommandParameter"
                            "Start"       = 31
                            "Length"      = 16
                            "StartLine"   = 1
                            "StartColumn" = 32
                            "EndLine"     = 1
                            "EndColumn"   = 48
                        },
                        @{
                            "Content"     = "1.0.0"
                            "Type"        = "String"
                            "Start"       = 48
                            "Length"      = 7
                            "StartLine"   = 1
                            "StartColumn" = 49
                            "EndLine"     = 1
                            "EndColumn"   = 56
                        }
                    )

                    $importModuleTokens = $ParsedContent

                    TestImportModuleIsValid -ParsedContent $ParsedContent -ImportModuleTokens $importModuleTokens

                } | Should -Not -Throw

            }

            It "should throw when passed a valid Import-Module command missing all required parameters" {

                {

                    $ParsedContent = @(
                        @{
                            "Content"     = "Import-Module"
                            "Type"        = "Command"
                            "Start"       = 0
                            "Length"      = 13
                            "StartLine"   = 1
                            "StartColumn" = 1
                            "EndLine"     = 1
                            "EndColumn"   = 14
                        },
                        @{
                            "Content"     = "ModuleName"
                            "Type"        = "CommandArgument"
                            "Start"       = 14
                            "Length"      = 10
                            "StartLine"   = 1
                            "StartColumn" = 15
                            "EndLine"     = 1
                            "EndColumn"   = 25
                        }
                    )

                    $importModuleTokens = $ParsedContent

                    TestImportModuleIsValid -ParsedContent $ParsedContent -ImportModuleTokens $importModuleTokens

                } | Should -Throw

            }

            It "should throw when passed a valid Import-Module command missing -Name only" {

                {

                    $ParsedContent = @(
                        @{
                            "Content"     = "Import-Module"
                            "Type"        = "Command"
                            "Start"       = 0
                            "Length"      = 13
                            "StartLine"   = 1
                            "StartColumn" = 1
                            "EndLine"     = 1
                            "EndColumn"   = 14
                        },
                        @{
                            "Content"     = "ModuleName"
                            "Type"        = "CommandArgument"
                            "Start"       = 14
                            "Length"      = 10
                            "StartLine"   = 1
                            "StartColumn" = 15
                            "EndLine"     = 1
                            "EndColumn"   = 25
                        },
                        @{
                            "Content"     = "-RequiredVersion"
                            "Type"        = "CommandParameter"
                            "Start"       = 25
                            "Length"      = 16
                            "StartLine"   = 1
                            "StartColumn" = 26
                            "EndLine"     = 1
                            "EndColumn"   = 42
                        },
                        @{
                            "Content"     = "1.0.0"
                            "Type"        = "String"
                            "Start"       = 42
                            "Length"      = 7
                            "StartLine"   = 1
                            "StartColumn" = 43
                            "EndLine"     = 1
                            "EndColumn"   = 50
                        }
                    )

                    $importModuleTokens = $ParsedContent

                    TestImportModuleIsValid -ParsedContent $ParsedContent -ImportModuleTokens $importModuleTokens

                } | Should -Throw

            }

            It "should throw when passed a valid Import-Module command missing -RequiredVersion, -MinimumVersion or -MaximumVersion" {

                {

                    $ParsedContent = @(
                        @{
                            "Content"     = "Import-Module"
                            "Type"        = "Command"
                            "Start"       = 0
                            "Length"      = 13
                            "StartLine"   = 1
                            "StartColumn" = 1
                            "EndLine"     = 1
                            "EndColumn"   = 14
                        },
                        @{
                            "Content"     = "-Name"
                            "Type"        = "CommandParameter"
                            "Start"       = 14
                            "Length"      = 5
                            "StartLine"   = 1
                            "StartColumn" = 15
                            "EndLine"     = 1
                            "EndColumn"   = 20
                        },
                        @{
                            "Content"     = "ModuleName"
                            "Type"        = "CommandArgument"
                            "Start"       = 20
                            "Length"      = 10
                            "StartLine"   = 1
                            "StartColumn" = 21
                            "EndLine"     = 1
                            "EndColumn"   = 31
                        }
                    )

                    $importModuleTokens = $ParsedContent

                    TestImportModuleIsValid -ParsedContent $ParsedContent -ImportModuleTokens $importModuleTokens

                } | Should -Throw

            }

        }

    }

}
