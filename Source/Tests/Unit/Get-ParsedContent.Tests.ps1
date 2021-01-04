Describe "Get-ParsedContent.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-ParsedContent').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-ParsedContent').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should Content type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-ParsedContent').Parameters['Content'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

    }

}
