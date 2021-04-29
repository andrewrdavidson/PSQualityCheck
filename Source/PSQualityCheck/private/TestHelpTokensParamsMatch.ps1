function TestHelpTokensParamsMatch {
    <#
        .SYNOPSIS
        Checks to see whether the parameters and help PARAMETER statements match

        .DESCRIPTION
        Checks to see whether the parameters in the param block and in the help PARAMETER statements exist in both locations

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER ParameterVariables
        A object containing the parameters from the param block

        .EXAMPLE
        TestHelpTokensParamsMatch -HelpTokens $HelpTokens -ParameterVariables $ParameterVariables
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.String[]])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens,
        [parameter(Mandatory = $true)]
        [PSCustomObject]$ParameterVariables
    )

    try {

        $foundInHelpErrors = @()
        $foundInParamErrors = @()

        foreach ($key in $ParameterVariables.Keys) {

            $foundInHelp = $false

            foreach ($token in $HelpTokens.".PARAMETER") {

                if ($key -eq $token.Name) {

                    $foundInHelp = $true
                    break

                }

            }

            if ($foundInHelp -eq $false) {

                $foundInHelpErrors += "Parameter block variable '$key' was not found in help. "

            }

        }

        foreach ($token in $HelpTokens.".PARAMETER") {

            $foundInParams = $false

            foreach ($key in $ParameterVariables.Keys) {

                if ($key -eq $token.Name) {

                    $foundInParams = $true
                    break

                }

            }

            if ($foundInParams -eq $false) {

                $foundInParamErrors += "Help defined variable '$($token.Name)' was not found in parameter block definition. "

            }

        }

        if ($foundInHelpErrors.Count -ge 1 -or $foundInParamErrors.Count -ge 1) {

            $allErrors = $foundInHelpErrors + $foundInParamErrors
            throw $allErrors

        }

    }
    catch {

        throw $_.Exception.Message

    }

}
