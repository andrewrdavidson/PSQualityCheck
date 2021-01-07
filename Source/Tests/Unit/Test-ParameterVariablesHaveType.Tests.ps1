Describe "Test-ParameterVariablesHaveType.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParameterVariables'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

            It "should $parameter not belong to a parameter set" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters[$parameter].ParameterSets.Keys | Should -Be '__AllParameterSets'

            }

        }

        It "should ParameterVariables type be HashTable" {

            (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters['ParameterVariables'].ParameterType.Name | Should -Be 'HashTable'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Test-ParameterVariablesHaveType -ParameterVariables $null

            } | Should -Throw

        }

        It "should not throw with valid parameter" {

            {
                $parameterVariable = @{
                    'ParameterWithType' = '[string]'
                }

                Test-ParameterVariablesHaveType -ParameterVariables $parameterVariable

            } | Should -Not -Throw

        }

        It "should throw with null type parameter" {

            {
                $parameterVariable = @{
                    'ParameterWithoutType' = $null
                }

                Test-ParameterVariablesHaveType -ParameterVariables $parameterVariable

            } | Should -Throw

        }

        It "should throw with empty type parameter" {

            {
                $parameterVariable = @{
                    'ParameterWithEmptyType' = ''
                }

                Test-ParameterVariablesHaveType -ParameterVariables $parameterVariable

            } | Should -Throw

        }

    }

}
