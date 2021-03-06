Describe "Get-FunctionCount.Tests" {

    Context "Parameter Tests" -ForEach @(
        @{ 'Name' = 'ModulePath'; 'Type' = 'String' }
        @{ 'Name' = 'ManifestPath'; 'Type' = 'String' }
    ) {

        BeforeAll {
            $commandletUnderTest = "Get-FunctionCount"
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

    # TODO Broken Test, requires Get-ParsedFile and Get-ParsedContent mocking out

    Context "Function tests" {

        BeforeAll {

            $ModulePath = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
            $ManifestPath = Join-Path -Path $TestDrive -ChildPath 'test1.psd1'

        }

        It "should throw when passing null parameters" {

            {

                Get-FunctionCount -Module $null -Manifest $null

            } | Should -Throw

        }

        It "should find one function with matching module and manifest" {

            $fileContent = "function Get-FileContent {
                Write-Host
            }"
            Set-Content -Path $ModulePath -Value $fileContent

            New-ModuleManifest -Path $ManifestPath -FunctionsToExport @('Get-FileContent')

            Get-FunctionCount -Module $ModulePath -Manifest $ManifestPath | Should -BeExactly @(1, 1, 1, 1)

            Remove-Item -Path $ModulePath -Force
            Remove-Item -Path $ManifestPath -Force

        }

        It "should find two functions in module with matching manifest and module" {

            $fileContent = "function Get-FileContent {}
            function Get-FileContent2 {}"
            Set-Content -Path $ModulePath -Value $fileContent

            New-ModuleManifest -Path $ManifestPath -FunctionsToExport @('Get-FileContent', 'Get-FileContent2')

            Get-FunctionCount -Module $ModulePath -Manifest $ManifestPath | Should -BeExactly @(2, 2, 2, 2)

            Remove-Item -Path $ModulePath -Force
            Remove-Item -Path $ManifestPath -Force

        }

        It "should not find any function in manifest or module with empty manifest" {

            $fileContent = "function Get-FileContent {}"
            Set-Content -Path $ModulePath -Value $fileContent

            New-ModuleManifest -Path $ManifestPath

            Get-FunctionCount -Module $ModulePath -Manifest $ManifestPath | Should -BeExactly @(0, 0, 0, 0)

            Remove-Item -Path $ModulePath -Force
            Remove-Item -Path $ManifestPath -Force

        }

        It "should not find function in manifest and module with mismatched functions between manifest and module" {

            $fileContent = "function Get-FileContent {}"
            Set-Content -Path $ModulePath -Value $fileContent

            New-ModuleManifest -Path $ManifestPath -FunctionsToExport @('Get-FileContent2')

            Get-FunctionCount -Module $ModulePath -Manifest $ManifestPath | Should -BeExactly @(1, 0, 1, 0)

            Remove-Item -Path $ModulePath -Force
            Remove-Item -Path $ManifestPath -Force

        }

        It "should not find function in module with function in manifest and not in module" {

            $fileContent = "function Get-FileContent {}"
            Set-Content -Path $ModulePath -Value $fileContent

            New-ModuleManifest -Path $ManifestPath -FunctionsToExport @('Get-FileContent', 'Get-FileContent2')

            Get-FunctionCount -Module $ModulePath -Manifest $ManifestPath | Should -BeExactly @(2, 1, 1, 1)

            Remove-Item -Path $ModulePath -Force
            Remove-Item -Path $ManifestPath -Force

        }

        It "should not find function in module with function in module and not in manifest" {

            $fileContent = "function Get-FileContent {}
            function Get-FileContent2 {}"
            Set-Content -Path $ModulePath -Value $fileContent

            New-ModuleManifest -Path $ManifestPath -FunctionsToExport @('Get-FileContent')

            Get-FunctionCount -Module $ModulePath -Manifest $ManifestPath | Should -BeExactly @(1, 1, 2, 1)

            Remove-Item -Path $ModulePath -Force
            Remove-Item -Path $ManifestPath -Force

        }

    }

}
