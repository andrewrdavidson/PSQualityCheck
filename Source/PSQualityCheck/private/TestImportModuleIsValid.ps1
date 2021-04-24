function TestImportModuleIsValid {
    <#
        .SYNOPSIS
        Test that the Import-Module commands are valid

        .DESCRIPTION
        Test that the Import-Module commands contain a -Name parameter, and one of RequiredVersion, MinimumVersion or MaximumVersion

        .PARAMETER ParsedContent
        An object containing the source file parsed into its Tokenizer components

        .PARAMETER ImportModuleTokens
        An object containing the Import-Module tokens found

        .EXAMPLE
        TestImportModuleIsValid -ParsedContent $ParsedContent -ImportModuleTokens $importModuleTokens
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedContent,
        [parameter(Mandatory = $true)]
        [System.Object[]]$ImportModuleTokens
    )

    try {

        $errString = ""

        foreach ($token in $importModuleTokens) {

            $importModuleStatement = GetTokenComponent -ParsedContent $ParsedContent -StartLine $token.StartLine

            try {
                $name = ($importModuleStatement | Where-Object { $_.Type -eq "CommandArgument" } | Select-Object -First 1).Content
            }
            catch {
                $name = $null
            }
            if ($null -eq $name) {

                $name = ($importModuleStatement | Where-Object { $_.Type -eq "String" } | Select-Object -First 1).Content

            }

            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and $_.Content -eq "-Name" })) {

                $errString += "Import-Module for '$name' : Missing -Name parameter keyword. "

            }

            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and
                        ( $_.Content -eq "-RequiredVersion" -or $_.Content -eq "-MinimumVersion" -or $_.Content -eq "-MaximumVersion" )
                    })) {

                $errString += "Import-Module for '$name' : Missing -RequiredVersion, -MinimumVersion or -MaximumVersion parameter keyword. "

            }

        }

        if (-not ([string]::IsNullOrEmpty($errString))) {

            throw $errString

        }

    }
    catch {

        throw $_.Exception.Message

    }

}
