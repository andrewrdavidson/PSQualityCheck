InModuleScope PSQualityCheck {

    Describe "TestParameterVariablesHaveType.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'ParameterVariables'; 'Type' = 'HashTable' }
        ) {

            BeforeAll {
                $commandletUnderTest = "TestParameterVariablesHaveType"
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

                    TestParameterVariablesHaveType -ParameterVariables $null

                } | Should -Throw

            }

            It "should not throw with valid parameter" {

                {
                    $parameterVariable = @{
                        'ParameterWithType' = '[string]'
                    }

                    TestParameterVariablesHaveType -ParameterVariables $parameterVariable

                } | Should -Not -Throw

            }

            It "should throw with null type parameter" {

                {
                    $parameterVariable = @{
                        'ParameterWithoutType' = $null
                    }

                    TestParameterVariablesHaveType -ParameterVariables $parameterVariable

                } | Should -Throw

            }

            It "should throw with empty type parameter" {

                {
                    $parameterVariable = @{
                        'ParameterWithEmptyType' = ''
                    }

                    TestParameterVariablesHaveType -ParameterVariables $parameterVariable

                } | Should -Throw

            }

        }

    }

}
