Describe "Get-FileList.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
            'Extension'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-FileList').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-FileList').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}
