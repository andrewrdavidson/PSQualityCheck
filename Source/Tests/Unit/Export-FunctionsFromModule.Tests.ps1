Describe "Export-FunctionsFromModule.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
            'ExtractPath'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Export-FunctionsFromModule').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Export-FunctionsFromModule').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}
