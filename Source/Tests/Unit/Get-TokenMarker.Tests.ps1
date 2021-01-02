Describe "Get-TokenMarker.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFileContent'
            'Type'
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                # Check whether the parameter exists
                (Get-Command -Name 'Get-TokenMarker').Parameters[$parameter].Name | Should -BeExactly $parameter

                # Check whether or not it's mandatory
                (Get-Command -Name 'Get-TokenMarker').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

    }

    Context "Function tests" {

    }

}