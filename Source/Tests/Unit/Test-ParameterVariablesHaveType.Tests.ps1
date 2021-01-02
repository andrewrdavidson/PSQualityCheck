Describe "Test-ParameterVariablesHaveType.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParameterVariables'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                # Check whether the parameter exists
                (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters[$parameter].Name | Should -BeExactly $parameter

                # Check whether or not it's mandatory
                (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

            It "should $parameter not belong to a parameter set" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters[$parameter].ParameterSets.Keys | Should -Be '__AllParameterSets'

            }

        }

        It "should ParameterVariables type be HashTable" {

            (Get-Command -Name 'Test-ParameterVariablesHaveType').Parameters['ParameterVariables'].ParameterType.Name | Should -Be 'hashtable'

        }

    }

    Context "Function tests" {

        It "parameter ParameterWithType passes" {

            {
                $parameterVariable = @{
                    'ParameterWithType' = '[string]'
                }

                Test-ParameterVariablesHaveType -ParameterVariables $parameterVariable

            } | Should -Not -Throw

        }

        It "parameter ParameterWithoutType throws" {

            {
                $parameterVariable = @{
                    'ParameterWithoutType' = $null
                }

                Test-ParameterVariablesHaveType -ParameterVariables $parameterVariable

            } | Should -Throw

        }

    }

}
