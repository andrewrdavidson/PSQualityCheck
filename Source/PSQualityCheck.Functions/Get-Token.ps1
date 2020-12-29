function Get-Token {
    <#
        .SYNOPSIS
        Get token(s) from the tokenized output

        .DESCRIPTION
        Get token(s) from the tokenized output matching the passed Type and Content

        .PARAMETER ParsedFileContent
        A string array containing the Tokenized data

        .PARAMETER Type
        The token type to be found

        .PARAMETER Content
        The token content (or value) to be found

        .EXAMPLE
        $outputTypeToken = (Get-Token -ParsedFileContent $ParsedFile -Type "Attribute" -Content "OutputType")
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedFileContent,
        [parameter(Mandatory = $true)]
        [string]$Type,
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    $token = Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type $Type -Content $Content

    $tokens = Get-TokenComponent -ParsedFileContent $ParsedFileContent -StartLine $token.StartLine

    return $tokens

}
