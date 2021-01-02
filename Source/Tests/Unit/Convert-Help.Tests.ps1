Describe "Convert-Help.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpComment'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                # Check whether the parameter exists
                (Get-Command -Name 'Convert-Help').Parameters[$parameter].Name | Should -BeExactly $parameter

                # Check whether or not it's mandatory
                (Get-Command -Name 'Convert-Help').Parameters[$parameter].Attributes.Mandatory | Should -BeTrue

            }

            It "should $parameter not belong to a parameter set" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Convert-Help').Parameters[$parameter].ParameterSets.Keys | Should -Be '__AllParameterSets'

            }

        }

        It "should HelpComment type be string" -TestCases @{ 'parameter' = $parameter } {

            (Get-Command -Name 'Convert-Help').Parameters['HelpComment'].ParameterType.Name | Should -Be 'String'

        }

    }

    Context "Function tests" {

        It "should throw on invalid help" {

            {
                $helpComment = '##InvalidHelp##'

                $help = Convert-Help -HelpComment $helpComment

            } | Should -Throw

        }

        It "should throw on empty help" {

            {
                $helpComment = ''

                $help = Convert-Help -HelpComment $helpComment

            } | Should -Throw

        }

        It "should throw on null help" {

            {
                $helpComment = $null

                $help = Convert-Help -HelpComment $helpComment

            } | Should -Throw

        }

        $helpTokens = @(
            '.SYNOPSIS'
            '.DESCRIPTION'
            '.PARAMETER'
            '.EXAMPLE'
            '.INPUTS'
            '.OUTPUTS'
            '.NOTES'
            '.LINK'
            '.COMPONENT'
            '.ROLE'
            '.FUNCTIONALITY'
            '.FORWARDHELPTARGETNAME'
            '.FORWARDHELPCATEGORY'
            '.REMOTEHELPRUNSPACE'
            '.EXTERNALHELP'
        )

        foreach ($token in $helpTokens) {

            It "should find $token in help" -TestCases @{ 'token' = $token } {

                $helpComment = "<#
                                $($token)
                                #>"

                $help = Convert-Help -HelpComment $helpComment

                $help.ContainsKey($token) | Should -BeTrue
            }

        }

        It "should find .PARAMETER named Path" {

            $helpComment = "<#
                            .PARAMETER Path
                            #>"

            $help = Convert-Help -HelpComment $helpComment

            $help.ContainsKey(".PARAMETER") | Should -BeTrue

            $help.".PARAMETER".Name | Should -Be "Path"

        }

        It "should find multiple .PARAMETERs named Path and Source" {

            $helpComment = "<#
                            .PARAMETER Path
                            .PARAMETER Source
                            #>"

            $help = Convert-Help -HelpComment $helpComment

            $help.ContainsKey(".PARAMETER") | Should -BeTrue

            $help.".PARAMETER".Name | Should -Be @('Path', 'Source')

        }

        It "should find multiple .EXAMPLEs" {

            $helpComment = "<#
                            .EXAMPLE
                            Function -Path
                            .EXAMPLE
                            Function -Source
                            #>"

            $help = Convert-Help -HelpComment $helpComment

            $help.ContainsKey(".EXAMPLE") | Should -BeTrue

            $help.".EXAMPLE".Count | Should -Be 2

        }

        It "should not find .DUMMY in help" {

            $helpComment = "<#
                            .DUMMY
                            #>"

            $help = Convert-Help -HelpComment $helpComment

            $help.ContainsKey(".DUMMY") | Should -BeFalse

        }

        It "should not find .DUMMY but find .NOTES in help" {

            $helpComment = "<#
                            .DUMMY
                            .NOTES
                            #>"

            $help = Convert-Help -HelpComment $helpComment

            $help.ContainsKey(".DUMMY") | Should -BeFalse
            $help.ContainsKey(".NOTES") | Should -BeTrue

        }

    }

}
