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

        .PARAMETER IgnoreFile
        A path to a .psqcignore file (.gitignore file format) for ignoring files

        .EXAMPLE
        $files = GetFileList -Path 'c:\folder' -Extension ".ps1"

        .EXAMPLE
        $files = GetFileList -Path 'c:\folder' -Extension ".ps1" -Recurse

        #.EXAMPLE
        #$files = GetFileList -Path 'c:\folder' -IgnoreFile ".psqcignore"
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$Extension,
        [parameter(Mandatory = $false)]
        [switch]$Recurse,
        [parameter(Mandatory = $false)]
        [string]$IgnoreFile
    )

    $Extension = $Extension

    if (Test-Path -Path $Path) {

        $FileNameArray = @()

        if ($PSBoundParameters.ContainsKey('IgnoreFile')) {
            $SelectedFilesArray = Get-FilteredChildItem -Path $Path -IgnoreFileName $IgnoreFile
        }
        else {
            $gciSplat = @{
                'Path'    = $Path
                'Exclude' = "*.Tests.*"
            }
            if ($PSBoundParameters.ContainsKey('Recurse')) {
                $gciSplat.Add('Recurse', $true)
            }
            $SelectedFilesArray = Get-ChildItem @gciSplat
        }

        $SelectedFilesArray | Where-Object { $_.Extension -eq $Extension } | Select-Object -Property FullName | ForEach-Object { $FileNameArray += [string]$_.FullName }

    }

    return $FileNameArray

}
