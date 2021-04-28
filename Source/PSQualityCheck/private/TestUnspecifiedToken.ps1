function TestUnspecifiedToken {
    <#
        .SYNOPSIS
        Check that help tokens do not contain unspecified tokens

        .DESCRIPTION
        Check that the help comments do not contain tokens that are not specified in the external verification data file

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .PARAMETER HelpRulesPath
        Path to the HelpRules file

        .EXAMPLE
        TestUnspecifiedToken -HelpTokens $HelpTokens -HelpRulesPath "C:\HelpRules"
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
        $helpTokensKeys = @()

        for ($order = 1; $order -le $helpRules.Count; $order++) {

            $helpRuleIndex = [string]$order
            $token = $helpRules.$helpRuleIndex

            $helpTokensKeys += $token.key

        }

        foreach ($key in $helpTokens.Keys) {

            if ( $key -notin $helpTokensKeys ) {

                $tokenErrors += $key

            }

        }

        if ($tokenErrors.Count -ge 1) {
            throw "Found extra, non-specified, token(s): $tokenErrors"
        }

    }
    catch {

        throw $_.Exception.Message

    }

}
