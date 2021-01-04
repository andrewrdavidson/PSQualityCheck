Describe "Test-HelpTokensParamsMatch.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpTokens'
            'ParameterVariables'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should HelpTokens type be HashTable" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters['HelpTokens'].ParameterType.Name | Should -Be 'HashTable'

        }

        It "should ParameterVariables type be PSCustomObject" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpTokensParamsMatch').Parameters['ParameterVariables'].ParameterType.Name | Should -Be 'PSObject'

        }

    }

    Context "Function tests" {

    }

}
