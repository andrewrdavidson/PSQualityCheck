function Get-ParsedFile {
    <#
        .SYNOPSIS
        Get the tokenized content of the passed file

        .DESCRIPTION
        Get and return the tokenized content of the passed PowerShell file

        .PARAMETER Path
        A string containing PowerShell filename

        .EXAMPLE
        ($ParsedModule, $ParserErrors) = Get-ParsedFile -Path $ModuleFile

    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        if (-not(Test-Path -Path $Path)) {
            throw "$Path doesn't exist"
        }
    }
    catch {
        throw $_
    }

    $fileContent = Get-Content -Path $Path -Raw

    ($ParsedModule, $ParserErrorCount) = Get-ParsedContent -Content $fileContent

    return $ParsedModule, $ParserErrorCount

}
