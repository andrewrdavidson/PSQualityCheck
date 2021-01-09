Describe "Get-ScriptParameters.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-ScriptParameters').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-ScriptParameters').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should Content type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-ScriptParameters').Parameters['Content'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-ScriptParameters -Content $null

            } | Should -Throw

        }

        It "should throw when passed find no parameters" {

            {
                $fileContent = "function Get-FileContent { }"

                $parameterVariables = Get-ScriptParameters -Content $fileContent

                $parameterVariables | Should -BeNullOrEmpty

            } | Should -Throw

        }

        It "should find one parameter without type" {

            $fileContent = 'param ( $parameterOne )'

            $parameterVariables = Get-ScriptParameters -Content $fileContent

            $parameterVariables.ContainsKey('parameterOne') | Should -BeTrue

        }

        It "should find one parameter with type" {

            $fileContent = 'param ( [int]$parameterOne )'

            $parameterVariables = Get-ScriptParameters -Content $fileContent

            $parameterVariables.ContainsKey('parameterOne') | Should -BeTrue
            $parameterVariables.('parameterOne') | Should -BeExactly '[int]'

        }

        It "should find one parameter with type" {

            $fileContent = 'param (
                            [int]$parameterOne,
                            [string]$parameterTwo
                            )'

            $parameterVariables = Get-ScriptParameters -Content $fileContent

            $parameterVariables.ContainsKey('parameterOne') | Should -BeTrue
            $parameterVariables.('parameterOne') | Should -BeExactly '[int]'

            $parameterVariables.ContainsKey('parameterTwo') | Should -BeTrue
            $parameterVariables.('parameterTwo') | Should -BeExactly '[string]'

        }

    }

}
