Describe "Get-Token.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFileContent'
            'Type'
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-Token').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-Token').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ParsedFileContent type be System.Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-Token').Parameters['ParsedFileContent'].ParameterType.Name | Should -Be 'Object[]'

        }

        It "should Type type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-Token').Parameters['Type'].ParameterType.Name | Should -Be 'String'

        }

        It "should Content type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-Token').Parameters['Content'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw passing null parameters" {

            {

                Get-Token -ParsedFileContent $null -Type $null -Content $null

            } | Should -Throw

        }

    }

}
