function Test-HelpForUnspecifiedTokens {
    <#
        .SYNOPSIS
        Check that help tokens do not contain unspecified tokens

        .DESCRIPTION
        Check that the help comments do not contain tokens that are not specified in the external verification data file

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .EXAMPLE
        Test-HelpForUnspecifiedTokens -HelpTokens $HelpTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens
    )

    try {

        $module = Get-Module -Name PSQualityCheck

        if (Test-Path -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1")) {

            $helpElementRules = (Import-PowerShellDataFile -Path (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1"))

        }
        else {

            throw "Unable to load Checks\HelpElementRules.psd1"

        }

        $tokenErrors = @()
        $helpTokensKeys = @()

        # Create an array of the help element rules elements
        for ($order = 1; $order -le $helpElementRules.Count; $order++) {

            $token = $helpElementRules."$order"

            $helpTokensKeys += $token.key

        }

        # search through the found tokens and match them against the rules
        foreach ($key in $HelpTokens.Keys) {

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
