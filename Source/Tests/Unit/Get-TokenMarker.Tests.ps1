Describe "Get-TokenMarker.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFileContent'
            'Type'
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-TokenMarker').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-TokenMarker').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}
