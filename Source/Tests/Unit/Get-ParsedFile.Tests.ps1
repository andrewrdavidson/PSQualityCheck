Describe "Get-ParsedFile.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-ParsedFile').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-ParsedFile').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should Path type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-ParsedFile').Parameters['Path'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-ParsedFile -Path $null

            } | Should -Throw

        }

    }

}
