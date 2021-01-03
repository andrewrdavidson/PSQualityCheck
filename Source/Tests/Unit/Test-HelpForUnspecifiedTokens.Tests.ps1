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

    }

    Context "Function tests" {

    }

}
