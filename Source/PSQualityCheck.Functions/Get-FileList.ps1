function Get-FileList {
    <#
        .SYNOPSIS
        Return a list of files

        .DESCRIPTION
        Return a list of files from the specified path matching the passed extension

        .PARAMETER Path
        A string containing the path

        .PARAMETER Extension
        A string containing the extension

        .EXAMPLE
        $files = Get-FileList -Path 'c:\folder' -Extension ".ps1"
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$Extension
    )

    $Extension = $Extension

    $FileNameArray = @()

    if (Test-Path -Path $Path) {

        # Get the list of files
        $SelectedFilesArray = Get-ChildItem -Path $Path -Recurse -Exclude "*.Tests.*" | Where-Object { $_.Extension -eq $Extension } | Select-Object -Property FullName
        # Convert to a string array of filenames
        $SelectedFilesArray | ForEach-Object { $FileNameArray += [string]$_.FullName }

    }

    return $FileNameArray

}
