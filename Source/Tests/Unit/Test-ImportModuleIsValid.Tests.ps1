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

    }

    Context "Function tests" {

    }

}
