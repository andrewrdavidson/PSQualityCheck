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

        It "should Path type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-FileList').Parameters['Path'].ParameterType.Name | Should -Be 'String'

        }

        It "should Extension type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-FileList').Parameters['Extension'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

    }

}
