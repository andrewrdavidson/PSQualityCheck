Describe "Get-TokenComponent.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFileContent'
            'StartLine'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-TokenComponent').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-TokenComponent').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ParsedFileContent type be System.Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-TokenComponent').Parameters['ParsedFileContent'].ParameterType.Name | Should -Be 'Object[]'

        }

        It "should StartLine type be Int" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-TokenComponent').Parameters['StartLine'].ParameterType.Name | Should -Be 'Int32'

        }

    }

    Context "Function tests" {

    }

}
