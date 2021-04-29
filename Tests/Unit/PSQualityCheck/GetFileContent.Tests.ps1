InModuleScope PSQualityCheck {

    Describe "GetFileContent.Tests" {

        Context "Parameter Tests" -Foreach @(
            @{ 'Name' = 'Path'; 'Type' = 'String' }
        ) {

            BeforeAll {
                $commandletUnderTest = "GetFileContent"
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

                    GetFileContent -Path $null

                } | Should -Throw

            }

            It "should pass when Path is valid with no function, empty content in the file" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = ""
                Set-Content -Path $testPath -Value $fileContent

                $parsedFileContent = GetFileContent -Path $testPath

                Write-Verbose "FC" -Verbose
                Write-Verbose $fileContent.GetType() -Verbose
                Write-Verbose "PC" -Verbose
                Write-Verbose $parsedFileContent.GetType() -Verbose
                Write-Verbose "FC" -Verbose
                Write-Verbose $fileContent -Verbose
                Write-Verbose "PC" -Verbose
                Write-Verbose $parsedFileContent -Verbose

                ($fileContent -eq $parsedFileContent) | Should -BeTrue

            }

            It "should pass when Path is valid with no function, single-line content in the file" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "Write-Host"
                Set-Content -Path $testPath -Value $fileContent

                $parsedFileContent = GetFileContent -Path $testPath

                Write-Verbose "FC" -Verbose
                Write-Verbose $fileContent.GetType() -Verbose
                Write-Verbose "PC" -Verbose
                Write-Verbose $parsedFileContent.GetType() -Verbose
                Write-Verbose "FC" -Verbose
                Write-Verbose $fileContent -Verbose
                Write-Verbose "PC" -Verbose
                Write-Verbose $parsedFileContent -Verbose

                ($fileContent -eq $parsedFileContent) | Should -BeTrue

            }

            It "should pass when Path is valid with no function, multi-line content in the file" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "Write-Host
            Write-Host
            "
                Set-Content -Path $testPath -Value $fileContent

                $parsedFileContent = GetFileContent -Path $testPath

                Write-Verbose "FC" -Verbose
                Write-Verbose $fileContent.GetType() -Verbose
                Write-Verbose "PC" -Verbose
                Write-Verbose $parsedFileContent.GetType() -Verbose
                Write-Verbose "FC" -Verbose
                Write-Verbose $fileContent -Verbose
                Write-Verbose "PC" -Verbose
                Write-Verbose $parsedFileContent -Verbose

                ($fileContent -eq $parsedFileContent) | Should -BeTrue

            }

            It "should pass when Path is valid with only one empty function in the file" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "function GetFileContent {}"
                $matchContent = ""
                Set-Content -Path $testPath -Value $fileContent

                $parsedFileContent = GetFileContent -Path $testPath

                ($matchContent -eq $parsedFileContent) | Should -BeTrue

            }

            It "should pass when Path is valid with only one single-line function in the file" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "function GetFileContent { Write-Host }"
                $matchContent = " Write-Host "
                Set-Content -Path $testPath -Value $fileContent

                $parsedFileContent = GetFileContent -Path $testPath

                ($matchContent -eq $parsedFileContent) | Should -BeTrue

            }

            It "should pass when Path is valid with only one single-line advanced function in the file" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "function GetFileContent { if ($true) { Write-Host } }"
                $matchContent = " if ($true) { Write-Host } "
                Set-Content -Path $testPath -Value $fileContent

                $parsedFileContent = GetFileContent -Path $testPath

                ($matchContent -eq $parsedFileContent) | Should -BeTrue

            }

            It "should pass when Path is valid with only one multi-line function in the file" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent1 = "function GetFileContent {
                                Write-Host
                            }"
                $matchContent1 = "                                Write-Host`r`n"

                Set-Content -Path $testPath -Value $fileContent1

                $parsedFileContent1 = GetFileContent -Path $testPath

                $fileContent2 = "function GetFileContent {
                                if ($true) {
                                    Write-Host
                                }
                            }"
                $matchContent2 = "                                if ($true) {
                                    Write-Host
                                }`r`n"

                Set-Content -Path $testPath -Value $fileContent2

                $parsedFileContent2 = GetFileContent -Path $testPath

                ($matchContent1 -eq $parsedFileContent1) | Should -BeTrue
                ($matchContent2 -eq $parsedFileContent2) | Should -BeTrue

            }

            It "should throw when Path is valid with two functions in the file" {

                {
                    $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                    $fileContent = "function GetFileContent {
                                    Write-Host
                                }

                                function Test-Function {
                                    Write-Host
                                }"

                    Set-Content -Path $testPath -Value $fileContent

                    $parsedFileContent = GetFileContent -Path $testPath

                } | Should -Throw

            }

        }

    }

}
