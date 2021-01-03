Describe "Get-ScriptParameters.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-ScriptParameters').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-ScriptParameters').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}
