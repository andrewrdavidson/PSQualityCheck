InModuleScope PSQualityCheck {

    Describe "ExportFunctionsFromModule.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'Path'; 'Type' = 'String' }
            @{ 'Name' = 'ExtractPath'; 'Type' = 'String' }
        ) {

            BeforeAll {
                $commandletUnderTest = "ExportFunctionsFromModule"
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

            BeforeAll {

                $sourcePath = Join-Path -Path $TestDrive -ChildPath "Source"
                New-Item -Path $sourcePath -ItemType Directory
                $extractPath = Join-Path -Path $TestDrive -ChildPath "Extract"
                New-Item -Path $extractPath -ItemType Directory

            }

            It "should throw when passing null parameters" {

                {

                    ExportFunctionsFromModule -Path $null -ExtractPath $null

                } | Should -Throw

            }

            It "should throw when passing non-module file" {

                {
                    $fileContent = ""
                    $testPath1 = Join-Path -Path $sourcePath -ChildPath 'test.ps1'
                    Set-Content -Path $testPath1 -Value $fileContent

                    ExportFunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

                } | Should -Throw

            }

            It "should throw when passing functionless module file" {

                {
                    $fileContent = ""
                    $testPath1 = Join-Path -Path $sourcePath -ChildPath 'test.psm1'
                    Set-Content -Path $testPath1 -Value $fileContent

                    ExportFunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

                } | Should -Throw

            }

            It "should not throw and create valid extracted file when passing simple, valid module file" {

                {
                    $testPath1 = Join-Path -Path $sourcePath -ChildPath 'test.psm1'
                    $fileContent = "function Test-Function {
                    Write-Host
                }"
                    Set-Content -Path $testPath1 -Value $fileContent

                    $functionPath = Join-Path $extractPath -ChildPath "test"
                    $functionFile = Join-Path $functionPath -ChildPath "Test-Function.ps1"

                    ExportFunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

                    $files = Get-ChildItem -Path $functionPath

                    (Get-ChildItem -Path $functionPath).Count | Should -BeExactly 1
                    (Get-ChildItem -Path $functionPath).FullName | Should -BeExactly $functionFile

                } | Should -Not -Throw

            }

            It "should not throw and create valid extracted files when passing simple, valid multi-function module file" {

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

                    ExportFunctionsFromModule -Path $testPath1 -ExtractPath $extractPath

                    $files = Get-ChildItem -Path $functionPath

                    (Get-ChildItem -Path $functionPath).Count | Should -BeExactly 2
                    (Get-ChildItem -Path $functionPath).FullName | Should -BeExactly @($functionFile1, $functionFile2)

                } | Should -Not -Throw

            }

        }

    }

}
