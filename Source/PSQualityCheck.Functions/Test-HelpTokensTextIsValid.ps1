function Test-HelpTokensTextIsValid {
    <#
        .SYNOPSIS
        Check that Help Tokens text is valid

        .DESCRIPTION
        Check that the Help Tokens text is valid by making sure that they its not empty

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .EXAMPLE
        Test-HelpTokensTextIsValid -HelpTokens $HelpTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens
    )

    try {

        $tokenErrors = @()

        # Check that the help blocks aren't empty
        foreach ($key in $HelpTokens.Keys) {

            $tokenCount = @($HelpTokens.$key)

            for ($loop = 0; $loop -lt $tokenCount.Count; $loop++) {

                $token = $HelpTokens.$key[$loop]

                if ([string]::IsNullOrWhitespace($token.Text)) {

                    $tokenErrors += "Found '$key' does not have any text. "

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
