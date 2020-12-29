function Test-HelpTokensCountIsValid {
    <#
        .SYNOPSIS
        Check that help tokens count is valid

        .DESCRIPTION
        Check that the help tokens count is valid by making sure that they appear between Min and Max times

        .PARAMETER HelpTokens
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpTokensCountIsValid -HelpComment $helpComment

        .NOTES
        This function will only check the Min/Max counts of required help tokens
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

        # create a HashTable for tracking whether the element has been found
        $tokenFound = @{}
        for ($order = 1; $order -le $helpElementRules.Count; $order++) {
            $token = $helpElementRules."$order".Key
            $tokenFound[$token] = $false
        }

        $tokenErrors = @()

        # loop through all the found tokens
        foreach ($key in $HelpTokens.Keys) {

            # loop through all the help element rules
            for ($order = 1; $order -le $helpElementRules.Count; $order++) {

                $token = $helpElementRules."$order"

                # if the found token matches against a rule
                if ( $token.Key -eq $key ) {

                    $tokenFound[$key] = $true

                    # if the count is not between min and max AND is required
                    # that's an error
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
