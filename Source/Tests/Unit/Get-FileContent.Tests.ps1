Describe "Get-FileContent.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-FileContent').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-FileContent').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should Path type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-FileContent').Parameters['Path'].ParameterType.Name | Should -Be 'String'

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
