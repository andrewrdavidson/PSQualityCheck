Describe "Get-FunctionCount.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ModuleFile'
            'ManifestFile'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-FunctionCount').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-FunctionCount').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ModuleFile type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-FunctionCount').Parameters['ModuleFile'].ParameterType.Name | Should -Be 'String'

        }

        It "should ManifestFile type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-FunctionCount').Parameters['ManifestFile'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw passing null parameters" {

            {

                Get-ParsedFile -FunctionCount $null -ManifestFile $null

            } | Should -Throw

        }

    }

}
