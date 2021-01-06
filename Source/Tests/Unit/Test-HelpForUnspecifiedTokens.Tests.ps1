Describe "Test-HelpForUnspecifiedTokens.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpTokens'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-HelpForUnspecifiedTokens').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-HelpForUnspecifiedTokens').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should HelpTokens type be HashTable" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpForUnspecifiedTokens').Parameters['HelpTokens'].ParameterType.Name | Should -Be 'HashTable'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Test-HelpForUnspecifiedTokens -HelpTokens $null

            } | Should -Throw

        }

    }

}
