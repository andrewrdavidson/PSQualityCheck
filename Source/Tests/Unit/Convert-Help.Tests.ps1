Describe "Convert-Help.Tests" {

    Context "Parameter Tests" {

        $mandatoryParameters = @(
            'HelpComment'
        )

        foreach ($parameter in $mandatoryParameters) {

            It "should have $parameter as a mandatory parameter" -TestCases @{ 'parameter' = $parameter } {

                (Get-Command -Name 'Convert-Help').Parameters[$parameter].Name | Should -BeExactly $parameter
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

        It "should throw passing null parameters" {

            {

                Convert-Help -HelpComment $null

            } | Should -Throw

        }

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

        It "should find no help element text when text is empty" {

            {
                $helpComment = "<#
                                .SYNOPSIS

                                #>"

                $help = Convert-Help -HelpComment $helpComment

                ([string]::IsNullOrEmpty($help.".SYNOPSIS".Text)) | Should -BeTrue

            } | Should -Not -Throw

        }

        It "should find no help element text when text is missing" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                #>"

                $help = Convert-Help -HelpComment $helpComment

                ([string]::IsNullOrEmpty($help.".SYNOPSIS".Text)) | Should -BeTrue

            } | Should -Not -Throw

        }

        It "should find multiple help element text values" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                The SYNOPSIS property
                                .DESCRIPTION
                                The DESCRIPTION property
                                .PARAMETER Path
                                The Path parameter
                                #>"

                $help = Convert-Help -HelpComment $helpComment

                $help.".SYNOPSIS".Text | Should -BeExactly "The SYNOPSIS property"
                $help.".DESCRIPTION".Text | Should -BeExactly "The DESCRIPTION property"
                $help.".PARAMETER".Text | Should -BeExactly "The Path parameter"

            } | Should -Not -Throw

        }

        It "should find multiple help element text values where one is empty" {

            {
                $helpComment = "<#
                                .SYNOPSIS

                                .DESCRIPTION
                                The DESCRIPTION property
                                .PARAMETER Path
                                The Path parameter
                                #>"

                $help = Convert-Help -HelpComment $helpComment

                $help.".SYNOPSIS".Text | Should -BeExactly ""
                $help.".DESCRIPTION".Text | Should -BeExactly "The DESCRIPTION property"
                $help.".PARAMETER".Text | Should -BeExactly "The Path parameter"

            } | Should -Not -Throw

        }

        It "should find multiple help element text values where one is missing" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                .DESCRIPTION
                                The DESCRIPTION property
                                .PARAMETER Path
                                The Path parameter
                                #>"

                $help = Convert-Help -HelpComment $helpComment

                $help.".SYNOPSIS".Text | Should -BeExactly $null
                $help.".DESCRIPTION".Text | Should -BeExactly "The DESCRIPTION property"
                $help.".PARAMETER".Text | Should -BeExactly "The Path parameter"

            } | Should -Not -Throw

        }

        It "should find no help element text values when all text values are empty" {

            {
                $helpComment = "<#
                                .SYNOPSIS

                                .DESCRIPTION

                                .PARAMETER Path

                                #>"

                $help = Convert-Help -HelpComment $helpComment

                $help.".SYNOPSIS".Text | Should -BeExactly ""
                $help.".DESCRIPTION".Text | Should -BeExactly ""
                $help.".PARAMETER".Text | Should -BeExactly ""

            } | Should -Not -Throw

        }

        It "should find no help element text values when all text values are missing" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                .DESCRIPTION
                                .PARAMETER Path
                                #>"

                $help = Convert-Help -HelpComment $helpComment

                $help.".SYNOPSIS".Text | Should -BeExactly $null
                $help.".DESCRIPTION".Text | Should -BeExactly $null
                $help.".PARAMETER".Text | Should -BeExactly $null

            } | Should -Not -Throw

        }

        It "should find correct line numbers" {

            {
                $helpComment = "<#
                                .SYNOPSIS
                                The SYNOPSIS property
                                .DESCRIPTION
                                The DESCRIPTION property
                                .PARAMETER Path
                                The Path parameter
                                #>"

                $help = Convert-Help -HelpComment $helpComment

                $help.".SYNOPSIS".LineNumber | Should -BeExactly 1
                $help.".DESCRIPTION".LineNumber | Should -BeExactly 3
                $help.".PARAMETER".LineNumber | Should -BeExactly 5

            } | Should -Not -Throw

        }

    }

}
