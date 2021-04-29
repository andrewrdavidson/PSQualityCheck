function TestHelpTokensCountIsValid {
    <#
        .SYNOPSIS
        Check that help tokens count is valid

        .DESCRIPTION
        Check that the help tokens count is valid by making sure that they appear between Min and Max times

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER HelpRulesPath
        Path to the HelpRules file

        .EXAMPLE
        TestHelpTokensCountIsValid -HelpTokens $HelpTokens -HelpRulesPath "C:\HelpRules"

        .NOTES
        This function will only check the Min/Max counts of required help tokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens,

        [parameter(Mandatory = $true)]
        [string]$HelpRulesPath
    )

    try {

        $helpRules = Import-PowerShellDataFile -Path $HelpRulesPath

        $tokenFound = @{}
        for ($order = 1; $order -le $HelpRules.Count; $order++) {
            $helpRuleIndex = [string]$order
            $token = $HelpRules.$helpRuleIndex.Key
            $tokenFound[$token] = $false
        }

        $tokenErrors = @()

        foreach ($key in $HelpTokens.Keys) {

            for ($order = 1; $order -le $HelpRules.Count; $order++) {

                $helpRuleIndex = [string]$order
                $token = $HelpRules.$helpRuleIndex

                if ( $token.Key -eq $key ) {

                    $tokenFound[$key] = $true

                    if ($HelpTokens.$key.Count -lt $token.MinOccurrences -or
                        $HelpTokens.$key.Count -gt $token.MaxOccurrences -and
                        $token.Required -eq $true) {

                        $tokenErrors += "Found $(($HelpTokens.$key).Count) occurrences of '$key' which is not between $($token.MinOccurrences) and $($token.MaxOccurrences). "

                    }

                }

            }

        }

        if ($tokenErrors.Count -ge 1) {

            throw $tokenErrors

        }

    }
    catch {

        throw $_.Exception.Message

    }

}
