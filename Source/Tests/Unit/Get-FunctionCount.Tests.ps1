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

        BeforeAll {

            $moduleFile = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
            $manifestFile = Join-Path -Path $TestDrive -ChildPath 'test1.psd1'

        }

        It "should throw when passing null parameters" {

            {

                Get-ParsedFile -FunctionCount $null -ManifestFile $null

            } | Should -Throw

        }

        It "should find one function with matching module and manifest" {

            $fileContent = "function Get-FileContent {}"
            Set-Content -Path $moduleFile -Value $fileContent

            New-ModuleManifest -Path $manifestFile -FunctionsToExport @('Get-FileContent')

            Get-FunctionCount -Module $moduleFile -Manifest $manifestFile | Should -BeExactly @(1, 1, 1, 1)

            Remove-Item -Path $moduleFile -Force
            Remove-Item -Path $manifestFile -Force

        }

        It "should find two functions in module with matching manifest and module" {

            $fileContent = "function Get-FileContent {}
            function Get-FileContent2 {}"
            Set-Content -Path $moduleFile -Value $fileContent

            New-ModuleManifest -Path $manifestFile -FunctionsToExport @('Get-FileContent', 'Get-FileContent2')

            Get-FunctionCount -Module $moduleFile -Manifest $manifestFile | Should -BeExactly @(2, 2, 2, 2)

            Remove-Item -Path $moduleFile -Force
            Remove-Item -Path $manifestFile -Force

        }

        It "should not find any function in manifest or module with empty manifest" {

            $fileContent = "function Get-FileContent {}"
            Set-Content -Path $moduleFile -Value $fileContent

            New-ModuleManifest -Path $manifestFile

            Get-FunctionCount -Module $moduleFile -Manifest $manifestFile | Should -BeExactly @(0, 0, 0, 0)

            Remove-Item -Path $moduleFile -Force
            Remove-Item -Path $manifestFile -Force

        }

        It "should not find function in manifest and module with mismatched functions between manifest and module" {

            $fileContent = "function Get-FileContent {}"
            Set-Content -Path $moduleFile -Value $fileContent

            New-ModuleManifest -Path $manifestFile -FunctionsToExport @('Get-FileContent2')

            Get-FunctionCount -Module $moduleFile -Manifest $manifestFile | Should -BeExactly @(1, 0, 1, 0)

            Remove-Item -Path $moduleFile -Force
            Remove-Item -Path $manifestFile -Force

        }

        It "should not find function in module with function in manifest and not in module" {

            $fileContent = "function Get-FileContent {}"
            Set-Content -Path $moduleFile -Value $fileContent

            New-ModuleManifest -Path $manifestFile -FunctionsToExport @('Get-FileContent', 'Get-FileContent2')

            Get-FunctionCount -Module $moduleFile -Manifest $manifestFile | Should -BeExactly @(2, 1, 1, 1)

            Remove-Item -Path $moduleFile -Force
            Remove-Item -Path $manifestFile -Force

        }

        It "should not find function in module with function in module and not in manifest" {

            $fileContent = "function Get-FileContent {}
            function Get-FileContent2 {}"
            Set-Content -Path $moduleFile -Value $fileContent

            New-ModuleManifest -Path $manifestFile -FunctionsToExport @('Get-FileContent')

            Get-FunctionCount -Module $moduleFile -Manifest $manifestFile | Should -BeExactly @(1, 1, 2, 1)

            Remove-Item -Path $moduleFile -Force
            Remove-Item -Path $manifestFile -Force

        }

    }

}
