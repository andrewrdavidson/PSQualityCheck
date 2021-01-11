Describe "Get-TokenComponent.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedContent'
            'StartLine'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-TokenComponent').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-TokenComponent').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ParsedContent type be System.Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-TokenComponent').Parameters['ParsedContent'].ParameterType.Name | Should -Be 'Object[]'

        }

        It "should StartLine type be Int" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-TokenComponent').Parameters['StartLine'].ParameterType.Name | Should -Be 'Int32'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-TokenComponent -ParsedContent $null -StartLine $null

            } | Should -Throw

        }

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
        }

        It "should find token where 'StartLine' is valid" {

            $token = Get-TokenComponent -ParsedContent $ParsedContent -StartLine 1

            Compare-Object -ReferenceObject $token.Values -DifferenceObject $ParsedContent.values | Should -BeNullOrEmpty

        }

        It "should not find token where 'StartLine' is invalid" {

            $token = Get-TokenComponent -ParsedContent $ParsedContent -StartLine 3
            $token | Should -BeNullOrEmpty

            $token = Get-TokenComponent -ParsedContent $ParsedContent -StartLine $null
            $token | Should -BeNullOrEmpty

        }

    }

}
