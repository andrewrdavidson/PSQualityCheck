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

    }

    Context "Function tests" {

    }

}
