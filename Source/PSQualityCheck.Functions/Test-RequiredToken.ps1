function Test-RequiredToken {
    <#
        .SYNOPSIS
        Check that help tokens contain required tokens

        .DESCRIPTION
        Check that the help comments contain tokens that are specified in the external verification data file

        .PARAMETER HelpTokens
        A array of tokens containing the tokens of the Help Comment

        .EXAMPLE
        Test-RequiredToken -HelpTokens $HelpTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$HelpTokens
    )

    try {

        $module = Get-Module -Name PSQualityCheck

        $helpElementRulesPath = (Join-Path -Path $module.ModuleBase -ChildPath "Checks\HelpElementRules.psd1")

        if (Test-Path -Path $helpElementRulesPath) {

            $helpElementRules = Import-PowerShellDataFile -Path $helpElementRulesPath

        }
        else {

            throw "Unable to load Checks\HelpElementRules.psd1"

        }

        $tokenErrors = @()

        for ($order = 1; $order -le $helpElementRules.Count; $order++) {

            $token = $helpElementRules."$order"

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
