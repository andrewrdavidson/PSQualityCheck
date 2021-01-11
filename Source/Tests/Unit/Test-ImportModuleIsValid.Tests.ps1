Describe "Test-ImportModuleIsValid.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'ParsedFile'
            'ImportModuleTokens'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Test-ImportModuleIsValid').Parameters[$parameter].Name | Should -BeExactly $parameter
                (Get-Command -Name 'Test-ImportModuleIsValid').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should ParsedFile type be Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-ImportModuleIsValid').Parameters['ParsedFile'].ParameterType.Name | Should -Be 'Object[]'

        }

        It "should ImportModuleTokens type be Object[]" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-ImportModuleIsValid').Parameters['ImportModuleTokens'].ParameterType.Name | Should -Be 'Object[]'

        }

    }

    Context "Function tests" {

        It "should throw when passing null parameter values" {

            {

                Test-ImportModuleIsValid -ParsedFile $null -ImportModuleTokens $null

            } | Should -Throw

        }

        It "should pass when passed a valid Import-Module command" {

            {

                $parsedFile = @(
                    @{
                        "Content" = "Import-Module"
                        "Type" = "Command"
                        "Start" = 0
                        "Length" = 13
                        "StartLine" = 1
                        "StartColumn" = 1
                        "EndLine" = 1
                        "EndColumn" = 14
                    },
                    @{
                        "Content" = "-Name"
                        "Type" = "CommandParameter"
                        "Start" = 14
                        "Length" = 5
                        "StartLine" = 1
                        "StartColumn" = 15
                        "EndLine" = 1
                        "EndColumn" = 20
                    },
                    @{
                        "Content" = "ModuleName"
                        "Type" = "CommandArgument"
                        "Start" = 20
                        "Length" = 10
                        "StartLine" = 1
                        "StartColumn" = 21
                        "EndLine" = 1
                        "EndColumn" = 31
                    },
                    @{
                        "Content" = "-RequiredVersion"
                        "Type" = "CommandParameter"
                        "Start" = 31
                        "Length" = 16
                        "StartLine" = 1
                        "StartColumn" = 32
                        "EndLine" = 1
                        "EndColumn" = 48
                    },
                    @{
                        "Content" = "1.0.0"
                        "Type" = "String"
                        "Start" = 48
                        "Length" = 7
                        "StartLine" = 1
                        "StartColumn" = 49
                        "EndLine" = 1
                        "EndColumn" = 56
                    }
                )

                $importModuleTokens = $parsedFile

                Test-ImportModuleIsValid -ParsedFile $parsedFile -ImportModuleTokens $importModuleTokens

            } | Should -Not -Throw

        }

        It "should throw when passed a valid Import-Module command missing all required parameters" {

            {

                $parsedFile = @(
                    @{
                        "Content" = "Import-Module"
                        "Type" = "Command"
                        "Start" = 0
                        "Length" = 13
                        "StartLine" = 1
                        "StartColumn" = 1
                        "EndLine" = 1
                        "EndColumn" = 14
                    },
                    @{
                        "Content" = "ModuleName"
                        "Type" = "CommandArgument"
                        "Start" = 14
                        "Length" = 10
                        "StartLine" = 1
                        "StartColumn" = 15
                        "EndLine" = 1
                        "EndColumn" = 25
                    }
                )

                $importModuleTokens = $parsedFile

                Test-ImportModuleIsValid -ParsedFile $parsedFile -ImportModuleTokens $importModuleTokens

            } | Should -Not -Throw

        }

        It "should throw when passed a valid Import-Module command missing -Name only" {

            {

                $parsedFile = @(
                    @{
                        "Content" = "Import-Module"
                        "Type" = "Command"
                        "Start" = 0
                        "Length" = 13
                        "StartLine" = 1
                        "StartColumn" = 1
                        "EndLine" = 1
                        "EndColumn" = 14
                    },
                    @{
                        "Content" = "ModuleName"
                        "Type" = "CommandArgument"
                        "Start" = 14
                        "Length" = 10
                        "StartLine" = 1
                        "StartColumn" = 15
                        "EndLine" = 1
                        "EndColumn" = 25
                    },
                    @{
                        "Content" = "-RequiredVersion"
                        "Type" = "CommandParameter"
                        "Start" = 25
                        "Length" = 16
                        "StartLine" = 1
                        "StartColumn" = 26
                        "EndLine" = 1
                        "EndColumn" = 42
                    },
                    @{
                        "Content" = "1.0.0"
                        "Type" = "String"
                        "Start" = 42
                        "Length" = 7
                        "StartLine" = 1
                        "StartColumn" = 43
                        "EndLine" = 1
                        "EndColumn" = 50
                    }
                )

                $importModuleTokens = $parsedFile

                Test-ImportModuleIsValid -ParsedFile $parsedFile -ImportModuleTokens $importModuleTokens

            } | Should -Not -Throw

        }

        It "should throw when passed a valid Import-Module command missing -RequiredVersion, -MinimumVersion or -MaximumVersion" {

            {

                $parsedFile = @(
                    @{
                        "Content" = "Import-Module"
                        "Type" = "Command"
                        "Start" = 0
                        "Length" = 13
                        "StartLine" = 1
                        "StartColumn" = 1
                        "EndLine" = 1
                        "EndColumn" = 14
                    },
                    @{
                        "Content" = "-Name"
                        "Type" = "CommandParameter"
                        "Start" = 14
                        "Length" = 5
                        "StartLine" = 1
                        "StartColumn" = 15
                        "EndLine" = 1
                        "EndColumn" = 20
                    },
                    @{
                        "Content" = "ModuleName"
                        "Type" = "CommandArgument"
                        "Start" = 20
                        "Length" = 10
                        "StartLine" = 1
                        "StartColumn" = 21
                        "EndLine" = 1
                        "EndColumn" = 31
                    }
                )

                $importModuleTokens = $parsedFile

                Test-ImportModuleIsValid -ParsedFile $parsedFile -ImportModuleTokens $importModuleTokens

            } | Should -Not -Throw

        }

    }

}
