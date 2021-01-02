Describe "Test-HelpTokensTextIsValid.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpTokens'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                # Check whether the parameter exists
                (Get-Command -Name 'Test-HelpTokensTextIsValid').Parameters[$parameter].Name | Should -BeExactly $parameter

                # Check whether or not it's mandatory
                (Get-Command -Name 'Test-HelpTokensTextIsValid').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

        }

        It "should HelpTokens type be HashTable" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Test-HelpTokensTextIsValid').Parameters['HelpTokens'].ParameterType.Name | Should -Be 'HashTable'

        }

    }

    Context "Function tests" {

        It "should not throw when checking help element text where it exists" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                Convert the help comment into an object
                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Not -Throw

        }

        It "should throw when checking help element text where it is empty" {

            {
                $helpComment = "<#
                                .SYNOPSIS

                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking help element text where it is missing" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should not throw when checking multiple valid help element text values" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                The SYNOPSIS property
                                .DESCRIPTION
                                The DESCRIPTION property
                                .PARAMETER Path
                                The Path parameter
                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Not -Throw

        }

        It "should throw when checking multiple help element text values where one is empty" {

            {
                $helpComment = "<#
                                .SYNOPSIS

                                .DESCRIPTION
                                The DESCRIPTION property
                                .PARAMETER Path
                                The Path parameter
                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking multiple help element text values where one is missing" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                .DESCRIPTION
                                The DESCRIPTION property
                                .PARAMETER Path
                                The Path parameter
                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking multiple help element text values where all are empty" {

            {
                $helpComment = "<#
                                .SYNOPSIS

                                .DESCRIPTION

                                .PARAMETER Path

                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

        It "should throw when checking multiple help element text values where all are missing" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                .DESCRIPTION
                                .PARAMETER Path
                                #>"

                #TODO Replace this with the correct tokens for the above help
                $help = Convert-Help -HelpComment $helpComment

                Test-HelpTokensTextIsValid -HelpTokens $help

            } | Should -Throw

        }

    }

}
