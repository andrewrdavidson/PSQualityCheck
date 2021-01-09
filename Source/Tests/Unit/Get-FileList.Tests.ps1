Describe "Get-FileList.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Path'
            'Extension'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-FileList').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-FileList').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should Path type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-FileList').Parameters['Path'].ParameterType.Name | Should -Be 'String'

        }

        It "should Extension type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-FileList').Parameters['Extension'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-FileList -Path $null -Extension $null

            } | Should -Throw

        }

        It "should return one file when checking folder with one matching files" {

            $fileContent = "function Get-FileContent {}"
            $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.ps1'
            Set-Content -Path $testPath1 -Value $fileContent

            $fileList = Get-FileList -Path $TestDrive -Extension ".ps1"

            Remove-Item -Path $testPath1 -Force

            $fileList.Count | Should -BeExactly 1

        }

        It "should return two files when checking folder with two matching files" {

            $fileContent = "function Get-FileContent {}"
            $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.ps1'
            Set-Content -Path $testPath1 -Value $fileContent
            $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
            Set-Content -Path $testPath2 -Value $fileContent

            $fileList = Get-FileList -Path $TestDrive -Extension ".ps1"

            Remove-Item -Path $testPath1 -Force
            Remove-Item -Path $testPath2 -Force

            $fileList.Count | Should -BeExactly 2

        }

        It "should return no files when checking folder with non-matching files" {

            $fileContent = "function Get-FileContent {}"
            $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
            Set-Content -Path $testPath1 -Value $fileContent

            $fileList = Get-FileList -Path $TestDrive -Extension ".ps1"

            Remove-Item -Path $testPath1 -Force

            $fileList.Count | Should -BeExactly 0

        }

        It "should return one file when checking folder with some matching files" {

            $fileContent = "function Get-FileContent {}"
            $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
            Set-Content -Path $testPath1 -Value $fileContent
            $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
            Set-Content -Path $testPath2 -Value $fileContent

            $fileList = Get-FileList -Path $TestDrive -Extension ".ps1"

            Remove-Item -Path $testPath1 -Force
            Remove-Item -Path $testPath2 -Force

            $fileList.Count | Should -BeExactly 1

        }

        It "should return correct file when checking folder" {

            $fileContent = "function Get-FileContent {}"
            $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
            Set-Content -Path $testPath1 -Value $fileContent
            $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
            Set-Content -Path $testPath2 -Value $fileContent

            $fileList = Get-FileList -Path $TestDrive -Extension ".ps1"

            Remove-Item -Path $testPath1 -Force
            Remove-Item -Path $testPath2 -Force

            $fileList | Should -BeExactly $testPath2

        }

        It "should return multiple correct files when checking folder" {

            $fileContent = "function Get-FileContent {}"
            $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.ps1'
            Set-Content -Path $testPath1 -Value $fileContent
            $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
            Set-Content -Path $testPath2 -Value $fileContent

            $fileList = Get-FileList -Path $TestDrive -Extension ".ps1"

            Remove-Item -Path $testPath1 -Force
            Remove-Item -Path $testPath2 -Force

            $fileList | Should -BeExactly  @($testPath1, $testPath2)

        }

        It "should not return Test files when checking folder" {

            $fileContent = "function Get-FileContent {}"
            $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test.Tests.ps1'
            Set-Content -Path $testPath1 -Value $fileContent

            $fileList = Get-FileList -Path $TestDrive -Extension ".ps1"

            Remove-Item -Path $testPath1 -Force

            $fileList.Count | Should -BeExactly 0

        }

    }

}
