Describe "Get-Token.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFileContent'
            'Type'
            'Content'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Get-Token').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Get-Token').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ParsedFileContent type be System.Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-Token').Parameters['ParsedFileContent'].ParameterType.Name | Should -Be 'Object[]'

        }

        It "should Type type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-Token').Parameters['Type'].ParameterType.Name | Should -Be 'String'

        }

        It "should Content type be String" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Get-Token').Parameters['Content'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameters" {

            {

                Get-Token -ParsedFileContent $null -Type $null -Content $null

            } | Should -Throw

        }

    }


    BeforeAll {
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
    }

    It "should find token where parameters are valid" {

        $token = Get-Token -ParsedFileContent $parsedFileContent -Type "Keyword" -Content "Function"

        Write-Host ($token | Out-String) -ForegroundColor Cyan
        Write-Host $tokenMatch.StartLine -ForegroundColor Magenta

        for ($x = 0; $x -lt $parsedModule.Count; $x++) {

            (
                ($token[$x].StartLine -eq $parsedFileContent[$x].StartLine) -and
                ($token[$x].Content -eq $parsedFileContent[$x].Content) -and
                ($token[$x].Type -eq $parsedFileContent[$x].Type) -and
                ($token[$x].Start -eq $parsedFileContent[$x].Start) -and
                ($token[$x].Length -eq $parsedFileContent[$x].Length) -and
                ($token[$x].StartColumn -eq $parsedFileContent[$x].StartColumn) -and
                ($token[$x].EndLine -eq $parsedFileContent[$x].EndLine) -and
                ($token[$x].EndColumn -eq $parsedFileContent[$x].EndColumn)
            ) | Should -BeTrue

        }

    }

    It "should not find token where parameters are invalid" {

        $token = (Get-Token -ParsedFileContent $parsedFileContent -Type "Unknown" -Content "Data")

        $token | Should -BeNullOrEmpty

    }

}
