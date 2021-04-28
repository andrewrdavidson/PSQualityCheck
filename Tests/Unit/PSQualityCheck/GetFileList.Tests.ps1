InModuleScope PSQualityCheck {

    Describe "GetFileList.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'Path'; 'Type' = 'String'; 'MandatoryFlag' = $true }
            @{ 'Name' = 'Extension'; 'Type' = 'String'; 'MandatoryFlag' = $true }
            @{ 'Name' = 'Recurse'; 'Type' = 'SwitchParameter'; 'MandatoryFlag' = $false }
        ) {

            BeforeAll {
                $commandletUnderTest = "GetFileList"
            }

            It "should have $Name as a mandatory parameter" {

                (Get-Command -Name $commandletUnderTest).Parameters[$Name].Name | Should -BeExactly $Name
                (Get-Command -Name $commandletUnderTest).Parameters[$Name].Attributes.Mandatory | Should -BeExactly $MandatoryFlag

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

                    GetFileList -Path $null -Extension $null

                } | Should -Throw

            }

            It "should return one file when checking folder with one matching files" {

                $fileContent = "function GetFileContent {}"
                $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.ps1'
                Set-Content -Path $testPath1 -Value $fileContent

                $fileList = GetFileList -Path $TestDrive -Extension ".ps1"

                Remove-Item -Path $testPath1 -Force

                $fileList.Count | Should -BeExactly 1

            }

            It "should return two files when checking folder with two matching files" {

                $fileContent = "function GetFileContent {}"
                $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.ps1'
                Set-Content -Path $testPath1 -Value $fileContent
                $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
                Set-Content -Path $testPath2 -Value $fileContent

                $fileList = GetFileList -Path $TestDrive -Extension ".ps1"

                Remove-Item -Path $testPath1 -Force
                Remove-Item -Path $testPath2 -Force

                $fileList.Count | Should -BeExactly 2

            }

            It "should return no files when checking folder with non-matching files" {

                $fileContent = "function GetFileContent {}"
                $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
                Set-Content -Path $testPath1 -Value $fileContent

                $fileList = GetFileList -Path $TestDrive -Extension ".ps1"

                Remove-Item -Path $testPath1 -Force

                $fileList.Count | Should -BeExactly 0

            }

            It "should return one file when checking folder with some matching files" {

                $fileContent = "function GetFileContent {}"
                $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
                Set-Content -Path $testPath1 -Value $fileContent
                $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
                Set-Content -Path $testPath2 -Value $fileContent

                $fileList = GetFileList -Path $TestDrive -Extension ".ps1"

                Remove-Item -Path $testPath1 -Force
                Remove-Item -Path $testPath2 -Force

                $fileList.Count | Should -BeExactly 1

            }

            It "should return correct file when checking folder" {

                $fileContent = "function GetFileContent {}"
                $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.psm1'
                Set-Content -Path $testPath1 -Value $fileContent
                $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
                Set-Content -Path $testPath2 -Value $fileContent

                $fileList = GetFileList -Path $TestDrive -Extension ".ps1"

                Remove-Item -Path $testPath1 -Force
                Remove-Item -Path $testPath2 -Force

                $fileList | Should -BeExactly $testPath2

            }

            It "should return multiple correct files when checking folder" {

                $fileContent = "function GetFileContent {}"
                $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test1.ps1'
                Set-Content -Path $testPath1 -Value $fileContent
                $testPath2 = Join-Path -Path $TestDrive -ChildPath 'test2.ps1'
                Set-Content -Path $testPath2 -Value $fileContent

                $fileList = GetFileList -Path $TestDrive -Extension ".ps1"

                Remove-Item -Path $testPath1 -Force
                Remove-Item -Path $testPath2 -Force

                $fileList | Should -BeExactly  @($testPath1, $testPath2)

            }

            It "should not return Test files when checking folder" {

                $fileContent = "function GetFileContent {}"
                $testPath1 = Join-Path -Path $TestDrive -ChildPath 'test.Tests.ps1'
                Set-Content -Path $testPath1 -Value $fileContent

                $fileList = GetFileList -Path $TestDrive -Extension ".ps1"

                Remove-Item -Path $testPath1 -Force

                $fileList.Count | Should -BeExactly 0

            }

        }

    }

}
