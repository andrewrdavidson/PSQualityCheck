InModuleScope PSQualityCheck {

    Describe "ConvertHelp.Tests" {

        Context "Parameter Tests" -ForEach @(
            @{ 'Name' = 'Help'; 'Type' = 'String' }
        ) {

            BeforeAll {
                $commandletUnderTest = "ConvertHelp"
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

            It "should throw when passing null parameters" {

                {

                    ConvertHelp -Help $null

                } | Should -Throw

            }

            It "should throw on invalid help" {

                {
                    $helpComment = '##InvalidHelp##'

                    $help = ConvertHelp -Help $helpComment

                } | Should -Throw

            }

            It "should throw on empty help" {

                {
                    $helpComment = ''

                    $help = ConvertHelp -Help $helpComment

                } | Should -Throw

            }

            It "should find <token> in help" -Foreach @(
                @{ 'Token' = '.SYNOPSIS' }
                @{ 'Token' = '.DESCRIPTION' }
                @{ 'Token' = '.PARAMETER' }
                @{ 'Token' = '.EXAMPLE' }
                @{ 'Token' = '.INPUTS' }
                @{ 'Token' = '.OUTPUTS' }
                @{ 'Token' = '.NOTES' }
                @{ 'Token' = '.LINK' }
                @{ 'Token' = '.COMPONENT' }
                @{ 'Token' = '.ROLE' }
                @{ 'Token' = '.FUNCTIONALITY' }
                @{ 'Token' = '.FORWARDHELPTARGETNAME' }
                @{ 'Token' = '.FORWARDHELPCATEGORY' }
                @{ 'Token' = '.REMOTEHELPRUNSPACE' }
                @{ 'Token' = '.EXTERNALHELP' }
            ) {

                $helpComment = "<#
                            $($token)
                            #>"

                $help = ConvertHelp -Help $helpComment

                $help.ContainsKey($token) | Should -BeTrue

            }

            It "should find .PARAMETER named Path" {

                $helpComment = "<#
                            .PARAMETER Path
                            #>"

                $help = ConvertHelp -Help $helpComment

                $help.ContainsKey(".PARAMETER") | Should -BeTrue

                $help.".PARAMETER".Name | Should -Be "Path"

            }

            It "should find multiple .PARAMETERs named Path and Source" {

                $helpComment = "<#
                            .PARAMETER Path
                            .PARAMETER Source
                            #>"

                $help = ConvertHelp -Help $helpComment

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

                $help = ConvertHelp -Help $helpComment

                $help.ContainsKey(".EXAMPLE") | Should -BeTrue

                $help.".EXAMPLE".Count | Should -Be 2

            }

            It "should not find .DUMMY in help" {

                $helpComment = "<#
                            .DUMMY
                            #>"

                $help = ConvertHelp -Help $helpComment

                $help.ContainsKey(".DUMMY") | Should -BeFalse

            }

            It "should not find .DUMMY but find .NOTES in help" {

                $helpComment = "<#
                            .DUMMY
                            .NOTES
                            #>"

                $help = ConvertHelp -Help $helpComment

                $help.ContainsKey(".DUMMY") | Should -BeFalse
                $help.ContainsKey(".NOTES") | Should -BeTrue

            }

            It "should find no help element text when text is empty" {

                {
                    $helpComment = "<#
                                .SYNOPSIS

                                #>"

                    $help = ConvertHelp -Help $helpComment

                    ([string]::IsNullOrEmpty($help.".SYNOPSIS".Text)) | Should -BeTrue

                } | Should -Not -Throw

            }

            It "should find no help element text when text is missing" {

                {
                    $helpComment = "<#
                                .SYNOPSIS
                                #>"

                    $help = ConvertHelp -Help $helpComment

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

                    $help = ConvertHelp -Help $helpComment

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

                    $help = ConvertHelp -Help $helpComment

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

                    $help = ConvertHelp -Help $helpComment

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

                    $help = ConvertHelp -Help $helpComment

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

                    $help = ConvertHelp -Help $helpComment

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

                    $help = ConvertHelp -Help $helpComment

                    $help.".SYNOPSIS".LineNumber | Should -BeExactly 1
                    $help.".DESCRIPTION".LineNumber | Should -BeExactly 3
                    $help.".PARAMETER".LineNumber | Should -BeExactly 5

                } | Should -Not -Throw

            }

        }

    }

}
