Describe "Get-ScriptParameters.Tests" {

    Context "Parameter Tests" -ForEach @(
        @{ 'Name' = 'Content'; 'Type' = 'String' }
    ) {

        BeforeAll {
            $commandletUnderTest = "Get-ScriptParameters"
        }

        It "should have $Name as a mandatory parameter" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].Name | Should -BeExactly $Name
            (Get-Command -Name $commandletUnderTest).Parameters[$Name].Attributes.Mandatory | Should -BeTrue

        }

        It "should $Name not belong to a parameter set" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterSets.Keys | Should -Be '__AllParameterSets'

        }

        It "should $Name type be $Type" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterType.Name | Should -Be $Type

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-ScriptParameters -Content $null

            } | Should -Throw

        }

        It "should throw when passed no parameters" {

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
            $parameterVariables.('parameterOne') | Should -BeNullOrEmpty

        }

        It "should find one parameter with type" {

            $fileContent = 'param ( [int]$parameterOne )'

            $parameterVariables = Get-ScriptParameters -Content $fileContent

            $parameterVariables.ContainsKey('parameterOne') | Should -BeTrue
            $parameterVariables.('parameterOne') | Should -BeExactly '[int]'

        }

        It "should find two parameters with type" {

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

        It "should find two parameters one with type and one without" {

            $fileContent = 'param (
                            [int]$parameterOne,
                            $parameterTwo
                            )'

            $parameterVariables = Get-ScriptParameters -Content $fileContent

            $parameterVariables.ContainsKey('parameterOne') | Should -BeTrue
            $parameterVariables.('parameterOne') | Should -BeExactly '[int]'

            $parameterVariables.ContainsKey('parameterTwo') | Should -BeTrue
            $parameterVariables.('parameterTwo') | Should -BeNullOrEmpty

        }

    }

}
