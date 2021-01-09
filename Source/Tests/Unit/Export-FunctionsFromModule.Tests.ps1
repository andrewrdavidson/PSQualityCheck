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

        $sourcePath = Join-Path -Path $TestDrive -ChildPath "Source"
        New-Item -Path $sourcePath -ItemType Directory
        $extractPath = Join-Path -Path $TestDrive -ChildPath "Extract"
        New-Item -Path $extractPath -ItemType Directory

        It "should throw when passing null parameters" {

            {

                Export-FunctionsFromModule -Path $null -ExtractPath $null

            } | Should -Throw

        }

        It "should throw when passing non-module file" -TestCases @{ 'sourcePath' = $sourcePath; 'extractPath' = $extractPath } {

            {
                $fileContent = ""
                $testPath1 = Join-Path -Path $sourcePath -ChildPath 'test.ps1'
                Set-Content -Path $testPath1 -Value $fileContent

                Export-FunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

            } | Should -Throw

        }

        It "should throw when passing functionless module file" -TestCases @{ 'sourcePath' = $sourcePath; 'extractPath' = $extractPath } {

            {
                $fileContent = ""
                $testPath1 = Join-Path -Path $sourcePath -ChildPath 'test.psm1'
                Set-Content -Path $testPath1 -Value $fileContent

                Export-FunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

            } | Should -Throw

        }

        It "should not throw and create valid extracted file when passing simple, valid module file" -TestCases @{ 'sourcePath' = $sourcePath; 'extractPath' = $extractPath } {

            {
                $testPath1 = Join-Path -Path $sourcePath -ChildPath 'test.psm1'
                $fileContent = "function Test-Function {
                    Write-Host
                }"
                Set-Content -Path $testPath1 -Value $fileContent

                $functionPath = Join-Path $extractPath -ChildPath "test"
                $functionFile = Join-Path $functionPath -ChildPath "Test-Function.ps1"

                Export-FunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

                $files = Get-ChildItem -Path $functionPath

                (Get-ChildItem -Path $functionPath).Count | Should -BeExactly 1
                (Get-ChildItem -Path $functionPath).FullName | Should -BeExactly $functionFile

            } | Should -Not -Throw

        }

        It "should not throw and create valid extracted files when passing simple, valid multi-function module file" -TestCases @{ 'sourcePath' = $sourcePath; 'extractPath' = $extractPath } {

            {
                $testPath1 = Join-Path -Path $sourcePath -ChildPath 'test.psm1'
                $fileContent = "function Test-Function {
                    Write-Host
                }
                function Test-SecondFunction {
                    Write-Host
                }"
                Set-Content -Path $testPath1 -Value $fileContent

                $functionPath = Join-Path $extractPath -ChildPath "test"
                $functionFile1 = Join-Path $functionPath -ChildPath "Test-Function.ps1"
                $functionFile2 = Join-Path $functionPath -ChildPath "Test-SecondFunction.ps1"

                Export-FunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

                $files = Get-ChildItem -Path $functionPath

                (Get-ChildItem -Path $functionPath).Count | Should -BeExactly 2
                (Get-ChildItem -Path $functionPath).FullName | Should -BeExactly @($functionFile1, $functionFile2)

            } | Should -Not -Throw

        }

    }

}
