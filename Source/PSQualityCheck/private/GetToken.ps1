function GetToken {
    <#
        .SYNOPSIS
        Get token(s) from the tokenized output

        .DESCRIPTION
        Get token(s) from the tokenized output matching the passed Type and Content

        .PARAMETER ParsedContent
        A string array containing the Tokenized data

        .PARAMETER Type
        The token type to be found

        .PARAMETER Content
        The token content (or value) to be found

        .EXAMPLE
        $outputTypeToken = (GetToken -ParsedContent $ParsedFile -Type "Attribute" -Content "OutputType")
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedContent,
        [parameter(Mandatory = $true)]
        [string]$Type,
        [parameter(Mandatory = $true)]
        [string]$Content
    )

    $token = GetTokenMarker -ParsedContent $ParsedContent -Type $Type -Content $Content

    $tokens = GetTokenComponent -ParsedContent $ParsedContent -StartLine $token.StartLine

    return $tokens

}
