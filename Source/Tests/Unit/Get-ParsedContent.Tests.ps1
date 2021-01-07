Describe "Get-ParsedContent.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-ParsedContent').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-ParsedContent').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should Content type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-ParsedContent').Parameters['Content'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-ParsedContent -Content $null

            } | Should -Throw

        }

        $parsedFileContent = @(
            @{
                "Content" = "function"
                "Type" = "Keyword"
                "Start" = 0
                "Length" = 8
                "StartLine" = 1
                "StartColumn" = 1
                "EndLine" = 1
                "EndColumn" = 9
            },
            @{
                "Content" = "Get-FileContent"
                "Type" = "CommandArgument"
                "Start" = 9
                "Length" = 15
                "StartLine" = 1
                "StartColumn" = 10
                "EndLine" = 1
                "EndColumn" = 25
            },
            @{
                "Content" = "{"
                "Type" = "GroupStart"
                "Start" = 25
                "Length" = 1
                "StartLine" = 1
                "StartColumn" = 26
                "EndLine" = 1
                "EndColumn" = 27
            },
            @{
                "Content" = "}"
                "Type" = "GroupEnd"
                "Start" = 26
                "Length" = 1
                "StartLine" = 1
                "StartColumn" = 27
                "EndLine" = 1
                "EndColumn" = 28
            }
        )

        It "should return correct parse tokens for content" -TestCases @{ 'ParsedFileContent' = $parsedFileContent } {

            $fileContent = "function Get-FileContent {}"

            ($parsedModule, $parserErrorCount) = Get-ParsedContent -Content $fileContent

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

            $parserErrorCount | Should -BeExactly 0

        }


        It "should not return matching parse tokens for mismatching content" -TestCases @{ 'ParsedFileContent' = $parsedFileContent } {

            $fileContent = "function Get-Content {}"

            ($parsedModule, $parserErrorCount) = Get-ParsedContent -Content $fileContent

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

            $flag | Should -BeFalse

            $parserErrorCount | Should -BeExactly 0

        }

    }

}
