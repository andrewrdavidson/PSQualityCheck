Describe "Get-FunctionCount.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ModuleFile'
            'ManifestFile'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-FunctionCount').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-FunctionCount').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}
