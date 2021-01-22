Describe "Test-ParameterVariablesHaveType.Tests" {

    Context "Parameter Tests" -ForEach @(
        @{ 'Name' = 'ParameterVariables'; 'Type' = 'HashTable' }
    ) {

        BeforeAll {
            $commandletUnderTest = "Test-ParameterVariablesHaveType"
        }

        It "should have $Name as a mandatory parameter" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].Name | Should -BeExactly $Name
            (Get-Command -Name $commandletUnderTest).Parameters[$Name].Attributes.Mandatory | Should -BeTrue

        }

        It "should $Name not belong to a parameter set" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterSets.Keys | Should -Be '__AllParameterSets'

        }

        It "should $Name type be $Type" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterType.Name | Should -Be $Type

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
