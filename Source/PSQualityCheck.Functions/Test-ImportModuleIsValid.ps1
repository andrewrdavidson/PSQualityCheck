function Test-ImportModuleIsValid {
    <#
        .SYNOPSIS
        Test that the Import-Module commands are valid

        .DESCRIPTION
        Test that the Import-Module commands contain a -Name parameter, and one of RequiredVersion, MinimumVersion or MaximumVersion

        .PARAMETER ParsedFile
        An object containing the source file parsed into its Tokenizer components

        .PARAMETER ImportModuleTokens
        An object containing the Import-Module calls found

        .EXAMPLE
        TestImportModuleIsValid -ParsedFile $parsedFile
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param(
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedFile,
        [parameter(Mandatory = $true)]
        [System.Object[]]$ImportModuleTokens
    )

    try {

        $errString = ""

        # loop through each token found looking for the -Name and one of RequiredVersion, MinimumVersion or MaximumVersion
        foreach ($token in $importModuleTokens) {

            # Get the full details of the command
            $importModuleStatement = Get-TokenComponent -ParsedFileContent $ParsedFile -StartLine $token.StartLine

            # Get the name of the module to be imported (for logging only)
            $name = ($importModuleStatement | Where-Object { $_.Type -eq "String" } | Select-Object -First 1).Content

            # if the -Name parameter is not found
            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and $_.Content -eq "-Name" })) {

                $errString += "Import-Module for '$name' : Missing -Name parameter keyword. "

            }

            # if one of RequiredVersion, MinimumVersion or MaximumVersion is not found
            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and ( $_.Content -eq "-RequiredVersion" -or $_.Content -eq "-MinimumVersion" -or $_.Content -eq "-MaximumVersion" ) })) {

                $errString += "Import-Module for '$name' : Missing -RequiredVersion, -MinimumVersion or -MaximumVersion parameter keyword. "

            }

        }

        # If there are any problems throw to fail the test
        if (-not ([string]::IsNullOrEmpty($errString))) {

            throw $errString

        }

    }
    catch {

        throw $_.Exception.Message

    }

}
