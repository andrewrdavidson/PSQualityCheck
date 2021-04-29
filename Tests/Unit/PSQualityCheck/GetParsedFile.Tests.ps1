InModuleScope PSQualityCheck {

    Describe "GetParsedFile.Tests" {

        Context "Parameter Tests" -Foreach @(
            @{ 'Name' = 'Path'; 'Type' = 'String' }
        ) {

            BeforeAll {
                $commandletUnderTest = "GetParsedFile"
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

                $parsedFileContent = @(
                    @{
                        "Content"     = "function"
                        "Type"        = "Keyword"
                        "Start"       = 0
                        "Length"      = 8
                        "StartLine"   = 1
                        "StartColumn" = 1
                        "EndLine"     = 1
                        "EndColumn"   = 9
                    },
                    @{
                        "Content"     = "GetFileContent"
                        "Type"        = "CommandArgument"
                        "Start"       = 9
                        "Length"      = 15
                        "StartLine"   = 1
                        "StartColumn" = 10
                        "EndLine"     = 1
                        "EndColumn"   = 25
                    },
                    @{
                        "Content"     = "{"
                        "Type"        = "GroupStart"
                        "Start"       = 25
                        "Length"      = 1
                        "StartLine"   = 1
                        "StartColumn" = 26
                        "EndLine"     = 1
                        "EndColumn"   = 27
                    },
                    @{
                        "Content"     = "}"
                        "Type"        = "GroupEnd"
                        "Start"       = 26
                        "Length"      = 1
                        "StartLine"   = 1
                        "StartColumn" = 27
                        "EndLine"     = 1
                        "EndColumn"   = 28
                    }
                    @{
                        "Content"     = "`r`n"
                        "Type"        = "NewLine"
                        "Start"       = 27
                        "Length"      = 2
                        "StartLine"   = 1
                        "StartColumn" = 28
                        "EndLine"     = 2
                        "EndColumn"   = 1
                    }
                )

            }

            It "should throw when passing null parameters" {

                {

                    GetParsedFile -Path $null

                } | Should -Throw

            }

            It "should return correct parse tokens for content" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "function GetFileContent {}"

                Set-Content -Path $testPath -Value $fileContent

                ($parsedModule, $parserErrorCount) = GetParsedFile -Path $testPath

                for ($x = 0; $x -lt $parsedModule.Count; $x++) {

                    (
                        ($parsedModule[$x].StartLine -eq $parsedFileContent[$x].StartLine) -and
                        ($parsedModule[$x].Content -eq $parsedFileContent[$x].Content) -and
                        ($parsedModule[$x].Type -eq $parsedFileContent[$x].Type) -and
                        ($parsedModule[$x].Start -eq $parsedFileContent[$x].Start) -and
                        ($parsedModule[$x].Length -eq $parsedFileContent[$x].Length) -and
                        ($parsedModule[$x].StartColumn -eq $parsedFileContent[$x].StartColumn) -and
                        ($parsedModule[$x].EndLine -eq $parsedFileContent[$x].EndLine) -and
                        ($parsedModule[$x].EndColumn -eq $parsedFileContent[$x].EndColumn)
                    ) | Should -BeTrue

                }

                Remove-Item -Path $testPath -Force

                $parserErrorCount | Should -BeExactly 0

            }


            It "should not return matching parse tokens for mismatching content" {

                $testPath = Join-Path -Path $TestDrive -ChildPath 'test.ps1'
                $fileContent = "function Get-Content {}"

                Set-Content -Path $testPath -Value $fileContent

                ($parsedModule, $parserErrorCount) = GetParsedFile -Path $testPath

                $flag = $true

                for ($x = 0; $x -lt $parsedModule.Count; $x++) {

                    if (
                        ($parsedModule[$x].StartLine -ne $parsedFileContent[$x].StartLine) -or
                        ($parsedModule[$x].Content -ne $parsedFileContent[$x].Content) -or
                        ($parsedModule[$x].Type -ne $parsedFileContent[$x].Type) -or
                        ($parsedModule[$x].Start -ne $parsedFileContent[$x].Start) -or
                        ($parsedModule[$x].Length -ne $parsedFileContent[$x].Length) -or
                        ($parsedModule[$x].StartColumn -ne $parsedFileContent[$x].StartColumn) -or
                        ($parsedModule[$x].EndLine -ne $parsedFileContent[$x].EndLine) -or
                        ($parsedModule[$x].EndColumn -ne $parsedFileContent[$x].EndColumn)
                    ) {
                        $flag = $false
                    }

                }

                Remove-Item -Path $testPath -Force

                $flag | Should -BeFalse

                $parserErrorCount | Should -BeExactly 0

            }

        }

    }

}
