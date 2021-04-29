InModuleScope PSQualityCheck {

    Describe "GetTokenComponent.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'ParsedContent'; 'Type' = 'Object[]' }
            @{ 'Name' = 'StartLine'; 'Type' = 'Int32' }
        ) {

            BeforeAll {
                $commandletUnderTest = "GetTokenComponent"
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
                $ParsedContent = @(
                    @{
                        "Content"     = "function"
                        "Type"        = "Keyword"
                        "Start"       = 0
                        "Length"      = 8
                        "StartLine"   = 1
                        "StartColumn" = 1
                        "EndLine"     = 1
                        "EndColumn"   = 9
                    },
                    @{
                        "Content"     = "GetFileContent"
                        "Type"        = "CommandArgument"
                        "Start"       = 9
                        "Length"      = 15
                        "StartLine"   = 1
                        "StartColumn" = 10
                        "EndLine"     = 1
                        "EndColumn"   = 25
                    },
                    @{
                        "Content"     = "{"
                        "Type"        = "GroupStart"
                        "Start"       = 25
                        "Length"      = 1
                        "StartLine"   = 1
                        "StartColumn" = 26
                        "EndLine"     = 1
                        "EndColumn"   = 27
                    },
                    @{
                        "Content"     = "}"
                        "Type"        = "GroupEnd"
                        "Start"       = 26
                        "Length"      = 1
                        "StartLine"   = 1
                        "StartColumn" = 27
                        "EndLine"     = 1
                        "EndColumn"   = 28
                    }
                )
            }

            It "should throw when passing null parameters" {

                {

                    GetTokenComponent -ParsedContent $null -StartLine $null

                } | Should -Throw

            }

            It "should find token where 'StartLine' is valid" {

                $token = GetTokenComponent -ParsedContent $ParsedContent -StartLine 1

                Compare-Object -ReferenceObject $token.Values -DifferenceObject $ParsedContent.values | Should -BeNullOrEmpty

            }

            It "should not find token where 'StartLine' is invalid" {

                $token = GetTokenComponent -ParsedContent $ParsedContent -StartLine 3
                $token | Should -BeNullOrEmpty

                $token = GetTokenComponent -ParsedContent $ParsedContent -StartLine $null
                $token | Should -BeNullOrEmpty

            }

        }

    }

}
