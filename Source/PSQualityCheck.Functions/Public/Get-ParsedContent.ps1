function Get-ParsedContent {
    <#
        .SYNOPSIS
        Get the tokenized content of the passed data

        .DESCRIPTION
        Get and return the tokenized content of the passed PowerShell script content

        .PARAMETER Content
        A string containing PowerShell script content

        .EXAMPLE
        ($ParsedModule, $ParserErrorCount) = Get-ParsedContent -Content $fileContent
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]], [System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    if (-not ([string]::IsNullOrEmpty($Content))) {
        $ParserErrors = $null
        $ParsedModule = [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$ParserErrors)

        return $ParsedModule, ($ParserErrors.Count)
    }

}
