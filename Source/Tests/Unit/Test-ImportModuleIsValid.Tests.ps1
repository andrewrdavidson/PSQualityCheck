Describe "Test-ImportModuleIsValid.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFile'
            'ImportModuleTokens'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-ImportModuleIsValid').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-ImportModuleIsValid').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ParsedFile type be Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-ImportModuleIsValid').Parameters['ParsedFile'].ParameterType.Name | Should -Be 'Object[]'

        }

        It "should ImportModuleTokens type be Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-ImportModuleIsValid').Parameters['ImportModuleTokens'].ParameterType.Name | Should -Be 'Object[]'

        }


    }

    Context "Function tests" {

        It "should throw passing null parameter values" {

            {

                Test-ImportModuleIsValid -ParsedFile $null -ImportModuleTokens $null

            } | Should -Throw

        }
    }

}
