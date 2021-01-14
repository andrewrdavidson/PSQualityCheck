Describe "Get-FileContent.Tests" {

    Context "Parameter Tests" -ForEach @(
        @{ 'Name' = 'Path'; 'Type' = 'String' }
    ) {

        BeforeAll {
            $commandletUnderTest = "Get-FileContent"
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

                Get-FileContent -Path $null

            } | Should -Throw

        }

        It "should pass when Path is valid with no function, empty content in the file" {

            $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
            $fileContent = ""
            Set-Content -Path $testPath -Value $fileContent

            $parsedFileContent = Get-FileContent -Path $testPath

            ($fileContent -eq $parsedFileContent) | Should -BeTrue

        }

        It "should pass when Path is valid with no function, single-line content in the file" {

            $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
            $fileContent = "Write-Host"
            Set-Content -Path $testPath -Value $fileContent

            $parsedFileContent = Get-FileContent -Path $testPath

            ($fileContent -eq $parsedFileContent) | Should -BeTrue

        }

        It "should pass when Path is valid with no function, multi-line content in the file" {

            $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
            $fileContent = "Write-Host
            Write-Host
            "
            Set-Content -Path $testPath -Value $fileContent

            $parsedFileContent = Get-FileContent -Path $testPath

            ($fileContent -eq $parsedFileContent) | Should -BeTrue

        }

        It "should pass when Path is valid with only one empty function in the file" {

            $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
            $fileContent = "function Get-FileContent {}"
            $matchContent = ""
            Set-Content -Path $testPath -Value $fileContent

            $parsedFileContent = Get-FileContent -Path $testPath

            ($matchContent -eq $parsedFileContent) | Should -BeTrue

        }

        It "should pass when Path is valid with only one single-line function in the file" {

            $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
            $fileContent = "function Get-FileContent { Write-Host }"
            $matchContent = " Write-Host "
            Set-Content -Path $testPath -Value $fileContent

            $parsedFileContent = Get-FileContent -Path $testPath

            ($matchContent -eq $parsedFileContent) | Should -BeTrue

        }

        It "should pass when Path is valid with only one single-line advanced function in the file" {

            $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
            $fileContent = "function Get-FileContent { if ($true) { Write-Host } }"
            $matchContent = " if ($true) { Write-Host } "
            Set-Content -Path $testPath -Value $fileContent

            $parsedFileContent = Get-FileContent -Path $testPath

            ($matchContent -eq $parsedFileContent) | Should -BeTrue

        }

        It "should pass when Path is valid with only one multi-line function in the file" {

            $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
            $fileContent1 = "function Get-FileContent {
                                Write-Host
                            }"
            $matchContent1 = "                                Write-Host`r`n"

            Set-Content -Path $testPath -Value $fileContent1

            $parsedFileContent1 = Get-FileContent -Path $testPath

            $fileContent2 = "function Get-FileContent {
                                if ($true) {
                                    Write-Host
                                }
                            }"
            $matchContent2 = "                                if ($true) {
                                    Write-Host
                                }`r`n"

            Set-Content -Path $testPath -Value $fileContent2

            $parsedFileContent2 = Get-FileContent -Path $testPath

            ($matchContent1 -eq $parsedFileContent1) | Should -BeTrue
            ($matchContent2 -eq $parsedFileContent2) | Should -BeTrue

        }

        It "should throw when Path is valid with two functions in the file" {

            {
                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "function Get-FileContent {
                                    Write-Host
                                }

                                function Test-Function {
                                    Write-Host
                                }"

                Set-Content -Path $testPath -Value $fileContent

                $parsedFileContent = Get-FileContent -Path $testPath

            } | Should -Throw

        }

    }

}
