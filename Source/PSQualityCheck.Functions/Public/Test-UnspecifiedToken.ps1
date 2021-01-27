function Test-UnspecifiedToken {
    <#
        .SYNOPSIS
        Check that help tokens do not contain unspecified tokens

        .DESCRIPTION
        Check that the help comments do not contain tokens that are not specified in the external verification data file

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .EXAMPLE
        Test-UnspecifiedToken -HelpTokens $HelpTokens
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

        # Create an array of the help element rules elements
        for ($order = 1; $order -le $helpRules.Count; $order++) {

            $token = $helpRules."$order"

            $helpTokensKeys += $token.key

        }

        # search through the found tokens and match them against the rules
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
