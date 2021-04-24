function GetTokenComponent {
    <#
        .SYNOPSIS
        Get all the tokens components from a single line

        .DESCRIPTION
        Get all the tokens components from a single line in the tokenized content

        .PARAMETER ParsedContent
        A string array containing the tokenized content

        .PARAMETER StartLine
        A integer of the starting line to parse

        .EXAMPLE
        $tokens = GetTokenComponent -ParsedContent $ParsedContent -StartLine 10
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [System.Object[]]$ParsedContent,
        [parameter(Mandatory = $true)]
        [int]$StartLine
    )

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $StartLine = $StartLine

    $tokenComponents = @($ParsedContent | Where-Object { $_.StartLine -eq $StartLine })

    return $tokenComponents

}
