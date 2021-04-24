function GetParsedContent {
    <#
        .SYNOPSIS
        Get the tokenized content of the passed data

        .DESCRIPTION
        Get and return the tokenized content of the passed PowerShell script content

        .PARAMETER Content
        A string containing PowerShell script content

        .EXAMPLE
        ($ParsedModule, $ParserErrorCount) = GetParsedContent -Content $fileContent
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]], [System.Int32], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$Content
    )

    if (-not ([string]::IsNullOrEmpty($Content))) {

        $ParserErrors = $null
        $ParsedModule = [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$ParserErrors)

        $ParserErrorCount = $ParserErrors.Count

    }
    else {

        $ParsedModule = $null
        $ParserErrorCount = 1

    }

    return $ParsedModule, $ParserErrorCount

}
