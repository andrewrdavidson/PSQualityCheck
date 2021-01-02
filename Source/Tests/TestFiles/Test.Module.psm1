function One {
    <#
        .SYNOPSIS
        Test function that does nothing

        .DESCRIPTION
        Test function that does nothing but contains all the required elements to pass the checks

        .EXAMPLE
        One
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param(
    )

    # any valid function commands here, must not be empty
    Write-Output "Test Message"

}

function Two {
    <#
        .SYNOPSIS
        Test function that does nothing

        .DESCRIPTION
        Test function that does nothing but contains all the required elements to pass the checks

        .PARAMETER ThisParameter
        Test function that does nothing but contains all the required elements to pass the checks

        .EXAMPLE
        Two
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param(
        [string]$ThisParameter
    )

    # any valid function commands here, must not be empty
    Write-Output $ThisParameter

}
