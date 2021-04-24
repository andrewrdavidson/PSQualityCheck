function GetTokenMarker {
    <#
        .SYNOPSIS
        Gets token from the tokenized output

        .DESCRIPTION
        Gets single token from the tokenized output matching the passed Type and Content

        .PARAMETER ParsedContent
        A string array containing the Tokenized data

        .PARAMETER Type
        The token type to be found

        .PARAMETER Content
        The token content (or value) to be found

        .EXAMPLE
        $token = GetTokenMarker -ParsedContent $ParsedContent -Type $Type -Content $Content
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

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $Type = $Type
    $Content = $Content

    $token = @($ParsedContent | Where-Object { $_.Type -eq $Type -and $_.Content -eq $Content })

    return $token

}
