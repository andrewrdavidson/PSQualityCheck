Describe "Get-TokenMarker.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFileContent'
            'Type'
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-TokenMarker').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-TokenMarker').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ParsedFileContent type be System.Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-TokenMarker').Parameters['ParsedFileContent'].ParameterType.Name | Should -Be 'Object[]'

        }

        It "should Type type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-TokenMarker').Parameters['Type'].ParameterType.Name | Should -Be 'String'

        }

        It "should Content type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-TokenMarker').Parameters['Content'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-TokenMarker -ParsedFileContent $null -Type $null -Content $null

            } | Should -Throw

        }

        $parsedFileContent = @(
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

        It "should find 'CommandArgument' type with 'Get-FileContent' value" -TestCases @{ 'parsedFileContent' = $parsedFileContent; 'tokenMatch' = $tokenMatch } {

            $token = Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type "CommandArgument" -Content "Get-FileContent"

            Compare-Object -ReferenceObject $token.Values -DifferenceObject $tokenMatch.values | Should -BeNullOrEmpty

        }

        It "should not find 'Dummy' type with 'Get-FileContent' value" -TestCases @{ 'parsedFileContent' = $parsedFileContent } {

            $token = Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type "Dummy" -Content "Get-FileContent"

            $token | Should -BeNullOrEmpty

        }

        It "should not find 'CommandArgument' type with 'Dummy' value" -TestCases @{ 'parsedFileContent' = $parsedFileContent } {

            $token = Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type "CommandArgument" -Content "Dummy"

            $token | Should -BeNullOrEmpty

        }

        It "should throw with 'null' type and 'null' value" -TestCases @{ 'parsedFileContent' = $parsedFileContent } {

            {

                Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type $null -Content $null

            } | Should -Throw
        }

    }

}
