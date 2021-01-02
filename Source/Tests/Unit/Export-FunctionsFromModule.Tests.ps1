Describe "Export-FunctionsFromModule.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
            'FunctionExtractPath'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                # Check whether the parameter exists
                (Get-Command -Name 'Export-FunctionsFromModule').Parameters[$parameter].Name | Should -BeExactly $parameter

                # Check whether or not it's mandatory
                (Get-Command -Name 'Export-FunctionsFromModule').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}