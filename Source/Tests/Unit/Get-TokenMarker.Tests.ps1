Describe "Get-TokenMarker.Tests" {

    Context "Parameter Tests" -Foreach @(
        @{ 'Name' = 'ParsedContent'; 'Type' = 'Object[]' }
        @{ 'Name' = 'Type'; 'Type' = 'String' }
        @{ 'Name' = 'Content'; 'Type' = 'String' }
    ) {

        BeforeAll {
            $commandletUnderTest = "Get-TokenMarker"
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
                    "Content" = "function"
                    "Type" = "Keyword"
                    "Start" = 0
                    "Length" = 8
                    "StartLine" = 1
                    "StartColumn" = 1
                    "EndLine" = 1
                    "EndColumn" = 9
                },
                @{
                    "Content" = "Get-FileContent"
                    "Type" = "CommandArgument"
                    "Start" = 9
                    "Length" = 15
                    "StartLine" = 1
                    "StartColumn" = 10
                    "EndLine" = 1
                    "EndColumn" = 25
                },
                @{
                    "Content" = "{"
                    "Type" = "GroupStart"
                    "Start" = 25
                    "Length" = 1
                    "StartLine" = 1
                    "StartColumn" = 26
                    "EndLine" = 1
                    "EndColumn" = 27
                },
                @{
                    "Content" = "}"
                    "Type" = "GroupEnd"
                    "Start" = 26
                    "Length" = 1
                    "StartLine" = 1
                    "StartColumn" = 27
                    "EndLine" = 1
                    "EndColumn" = 28
                }
            )

            $tokenMatch = @{
                "Content" = "Get-FileContent"
                "Type" = "CommandArgument"
                "Start" = 9
                "Length" = 15
                "StartLine" = 1
                "StartColumn" = 10
                "EndLine" = 1
                "EndColumn" = 25
            }

        }

        It "should throw when passing null parameters" {

            {

                Get-TokenMarker -ParsedContent $null -Type $null -Content $null

            } | Should -Throw

        }

        It "should find 'CommandArgument' type with 'Get-FileContent' value" {

            $token = Get-TokenMarker -ParsedContent $ParsedContent -Type "CommandArgument" -Content "Get-FileContent"

            Compare-Object -ReferenceObject $token.Values -DifferenceObject $tokenMatch.values | Should -BeNullOrEmpty

        }

        It "should not find 'Dummy' type with 'Get-FileContent' value" {

            $token = Get-TokenMarker -ParsedContent $ParsedContent -Type "Dummy" -Content "Get-FileContent"

            $token | Should -BeNullOrEmpty

        }

        It "should not find 'CommandArgument' type with 'Dummy' value" {

            $token = Get-TokenMarker -ParsedContent $ParsedContent -Type "CommandArgument" -Content "Dummy"

            $token | Should -BeNullOrEmpty

        }

        It "should throw with 'null' type and 'null' value" {

            {

                Get-TokenMarker -ParsedContent $ParsedContent -Type $null -Content $null

            } | Should -Throw
        }

    }

}
