function Get-ScriptParameter {
    <#
        .SYNOPSIS
        Get a list of the parameters in the param block

        .DESCRIPTION
        Create a list of the parameters, and their type (if available) from the param block

        .PARAMETER Content
        A string containing the text of the script

        .EXAMPLE
        $parameterVariables = Get-ScriptParameter -Content $Content
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [HashTable])]
    param (
        [parameter(Mandatory = $true)]
        [String]$Content
    )

    try {

        $parsedScript = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref]$null, [ref]$null)

        if ([string]::IsNullOrEmpty($parsedScript.ParamBlock)) {
            throw "No parameters found"
        }

        [string]$paramBlock = $parsedScript.ParamBlock

        ($ParsedContent, $ParserErrorCount) = Get-ParsedContent -Content $paramBlock

        $paramBlockArray = ($paramBlock -split '\n').Trim()

        $parametersFound = @{}

        for ($line = 0; $line -le $paramBlockArray.Count; $line++) {

            $paramToken = @($ParsedContent | Where-Object { $_.StartLine -eq $line })

            foreach ($token in $paramToken) {

                if ($token.Type -eq 'Attribute' -and $token.Content -eq "Parameter") {

                    # break the inner loop because this token doesn't contain a variable for definite
                    break
                }

                if ($token.Type -eq 'Type') {

                    # Found a type for a parameter
                    $foundType = $token.Content

                }

                if ($token.Type -eq 'Variable') {

                    # Found a variable
                    $parametersFound[$token.Content] = $foundType
                    $foundType = $null
                    break

                }

            }


        }

        return $parametersFound

    }
    catch {

        throw $_.Exception.Message

    }

}
