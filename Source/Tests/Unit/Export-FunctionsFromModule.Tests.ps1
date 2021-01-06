Describe "Export-FunctionsFromModule.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
            'ExtractPath'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Export-FunctionsFromModule').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Export-FunctionsFromModule').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should Path type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Export-FunctionsFromModule').Parameters['Path'].ParameterType.Name | Should -Be 'String'

        }

        It "should ExtractPath type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Export-FunctionsFromModule').Parameters['ExtractPath'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Export-FunctionsFromModule -Path $null -ExtractPath $null

            } | Should -Throw

        }

    }

}
