InModuleScope PSQualityCheck {

    Describe "GetToken.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'ParsedContent'; 'Type' = 'Object[]' }
            @{ 'Name' = 'Type'; 'Type' = 'String' }
            @{ 'Name' = 'Content'; 'Type' = 'String' }
        ) {

            BeforeAll {
                $commandletUnderTest = "GetToken"
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

        # TODO Broken Test, requires GetTokenMarker and GetTokenComponent mocking out

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

                    GetToken -ParsedContent $null -Type $null -Content $null

                } | Should -Throw

            }

            It "should find token where parameters are valid" {

                $token = GetToken -ParsedContent $ParsedContent -Type "Keyword" -Content "Function"

                for ($x = 0; $x -lt $parsedModule.Count; $x++) {

                    (
                        ($token[$x].StartLine -eq $ParsedContent[$x].StartLine) -and
                        ($token[$x].Content -eq $ParsedContent[$x].Content) -and
                        ($token[$x].Type -eq $ParsedContent[$x].Type) -and
                        ($token[$x].Start -eq $ParsedContent[$x].Start) -and
                        ($token[$x].Length -eq $ParsedContent[$x].Length) -and
                        ($token[$x].StartColumn -eq $ParsedContent[$x].StartColumn) -and
                        ($token[$x].EndLine -eq $ParsedContent[$x].EndLine) -and
                        ($token[$x].EndColumn -eq $ParsedContent[$x].EndColumn)
                    ) | Should -BeTrue

                }

            }

            It "should not find token where parameters are invalid" {

                $token = (GetToken -ParsedContent $ParsedContent -Type "Unknown" -Content "Data")

                $token | Should -BeNullOrEmpty

            }

        }

    }

}
