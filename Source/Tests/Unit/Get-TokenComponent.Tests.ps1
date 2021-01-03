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

    }

    Context "Function tests" {

    }

}
