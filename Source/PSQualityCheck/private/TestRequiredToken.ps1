function TestRequiredToken {
    <#
        .SYNOPSIS
        Check that help tokens contain required tokens

        .DESCRIPTION
        Check that the help comments contain tokens that are specified in the external verification data file

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER HelpRulesPath
        Path to the HelpRules file

        .EXAMPLE
        TestRequiredToken -HelpTokens $HelpTokens -HelpRulesPath "C:\HelpRules"
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

        $tokenErrors = @()

        for ($order = 1; $order -le $HelpRules.Count; $order++) {

            $helpRuleIndex = [string]$order
            $token = $HelpRules.$helpRuleIndex

            if ($token.Key -notin $HelpTokens.Keys ) {

                if ($token.Required -eq $true) {

                    $tokenErrors += $token.Key

                }

            }

        }

        if ($tokenErrors.Count -ge 1) {
            throw "Missing required token(s): $tokenErrors"
        }

    }
    catch {

        throw $_.Exception.Message

    }

}
