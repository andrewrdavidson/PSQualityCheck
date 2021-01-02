Describe "Test-ImportModuleIsValid.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFile'
            'ImportModuleTokens'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                # Check whether the parameter exists
                (Get-Command -Name 'Test-ImportModuleIsValid').Parameters[$parameter].Name | Should -BeExactly $parameter

                # Check whether or not it's mandatory
                (Get-Command -Name 'Test-ImportModuleIsValid').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}
