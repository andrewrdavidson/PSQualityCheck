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

        It "should Content type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-ScriptParameters').Parameters['Content'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw passing null parameters" {

            {

                Get-ScriptParameters -Content $null

            } | Should -Throw

        }

    }

}
