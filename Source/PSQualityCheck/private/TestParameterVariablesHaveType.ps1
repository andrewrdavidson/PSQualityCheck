function TestParameterVariablesHaveType {
    <#
        .SYNOPSIS
        Check that all the passed parameters have a type variable set.

        .DESCRIPTION
        Check that all the passed parameters have a type variable set.

        .PARAMETER ParameterVariables
        A HashTable containing the parameters from the param block

        .EXAMPLE
        TestParameterVariablesHaveType -ParameterVariables $ParameterVariables
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [HashTable]$ParameterVariables
    )

    $variableErrors = @()

    try {

        foreach ($key in $ParameterVariables.Keys) {

            if ([string]::IsNullOrEmpty($ParameterVariables.$key)) {

                $variableErrors += "Parameter '$key' does not have a type defined."

            }

        }

        if ($variableErrors.Count -ge 1) {

            throw $variableErrors
        }

    }
    catch {

        throw $_.Exception.Message

    }

}
