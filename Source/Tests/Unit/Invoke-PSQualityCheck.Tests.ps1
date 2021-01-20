Describe "Invoke-PSQualityCheck.Tests" {

    Context "Parameter Tests" -ForEach @(
        @{ 'Name' = 'Path'; 'Type' = 'String[]'; 'MandatoryFlag' = $true; 'ParameterSet' = 'Path' }
        @{ 'Name' = 'File'; 'Type' = 'String[]'; 'MandatoryFlag' = $true; 'ParameterSet' = 'File' }
        @{ 'Name' = 'SonarQubeRulesPath'; 'Type' = 'String'; 'MandatoryFlag' = $false; 'ParameterSet' = '__AllParameterSets' }
        @{ 'Name' = 'ShowCheckResults'; 'Type' = 'SwitchParameter'; 'MandatoryFlag' = $false; 'ParameterSet' = '__AllParameterSets' }
        @{ 'Name' = 'ExportCheckResults'; 'Type' = 'SwitchParameter'; 'MandatoryFlag' = $false; 'ParameterSet' = '__AllParameterSets' }
        @{ 'Name' = 'Passthru'; 'Type' = 'SwitchParameter'; 'MandatoryFlag' = $false; 'ParameterSet' = '__AllParameterSets' }
        @{ 'Name' = 'Recurse'; 'Type' = 'SwitchParameter'; 'MandatoryFlag' = $false; 'ParameterSet' = 'Path' }
    ) {

        BeforeAll {
            $commandletUnderTest = "Invoke-PSQualityCheck"
        }

        It "should have $Name as a mandatory parameter property set to $MandatoryFlag" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].Name | Should -BeExactly $Name
            (Get-Command -Name $commandletUnderTest).Parameters[$Name].Attributes.Mandatory | Should -BeExactly $MandatoryFlag

        }

        It "should $Name belong to a $ParameterSet parameter set" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterSets.Keys | Should -Be $ParameterSet

        }

        It "should $Name type be $Type" {

            (Get-Command -Name $commandletUnderTest).Parameters[$Name].ParameterType.Name | Should -Be $Type

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Invoke-PSQualityCheck -Path $null

            } | Should -Throw

            {

                Invoke-PSQualityCheck -File $null

            } | Should -Throw

        }
    }

}
