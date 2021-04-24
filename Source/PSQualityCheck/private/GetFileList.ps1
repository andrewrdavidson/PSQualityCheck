function GetFileList {
    <#
        .SYNOPSIS
        Return a list of files

        .DESCRIPTION
        Return a list of files from the specified path matching the passed extension

        .PARAMETER Path
        A string containing the path

        .PARAMETER Extension
        A string containing the extension

        .PARAMETER Recurse
        A switch specifying whether or not to recursively search the path specified

        .EXAMPLE
        $files = GetFileList -Path 'c:\folder' -Extension ".ps1"

        .EXAMPLE
        $files = GetFileList -Path 'c:\folder' -Extension ".ps1" -Recurse
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$Extension,
        [parameter(Mandatory = $false)]
        [switch]$Recurse
    )

    $Extension = $Extension

    $FileNameArray = @()

    if (Test-Path -Path $Path) {

        $gciSplat = @{
            'Path'    = $Path
            'Exclude' = "*.Tests.*"
        }
        if ($PSBoundParameters.ContainsKey('Recurse')) {
            $gciSplat.Add('Recurse', $true)
        }

        $SelectedFilesArray = Get-ChildItem @gciSplat | Where-Object { $_.Extension -eq $Extension } | Select-Object -Property FullName
        $SelectedFilesArray | ForEach-Object { $FileNameArray += [string]$_.FullName }

    }

    return $FileNameArray

}
