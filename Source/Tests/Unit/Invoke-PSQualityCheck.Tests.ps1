Describe "Invoke-PSQualityCheck.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
            'File'
        )

        $optionalParameters = @(
            'SonarQubeRulesPath'
            'ShowCheckResults'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Invoke-PSQualityCheck').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Invoke-PSQualityCheck').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        foreach ($parameter in $optionalParameters) {

            It "should have $parameter as a optional parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Invoke-PSQualityCheck').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Invoke-PSQualityCheck').Parameters[$parameter].Attributes.Mandatory | Should -BeFalse

            }

        }

        It "should Path parameter belong to Path parameter set" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['Path'].ParameterSets.Keys | Should -Contain 'Path'

        }

        It "should File parameter belong to File parameter set" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['File'].ParameterSets.Keys | Should -Contain 'File'

        }

        It "should SonarQubeRulesPath parameter not belong to a parameter set" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['SonarQubeRulesPath'].ParameterSets.Keys | Should -Be '__AllParameterSets'

        }

        It "should ShowCheckResults parameter not belong to a parameter set" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['ShowCheckResults'].ParameterSets.Keys | Should -Be '__AllParameterSets'

        }

        It "should Path parameter type be string[]" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['Path'].ParameterType.Name | Should -Be 'String[]'

        }

        It "should File parameter type be string[]" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['File'].ParameterType.Name | Should -Be 'String[]'

        }

        It "should SonarQubeRulesPath parameter type be string" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['SonarQubeRulesPath'].ParameterType.Name | Should -Be 'String'

        }

        It "should ShowCheckResults parameter type be switch" {

            (Get-Command -Name 'Invoke-PSQualityCheck').Parameters['ShowCheckResults'].ParameterType.Name | Should -Be 'SwitchParameter'

        }

    }

    Context "Function tests" {

    }

}
