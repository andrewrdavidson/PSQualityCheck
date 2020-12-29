function Get-FunctionCount {
    <#
        .SYNOPSIS
        Return the count of functions within Module and its Manifest

        .DESCRIPTION
        Return the count of functions in the Module and Manifest and whether they appear in their counterpart.
        e.g. Whether the functions in the manifest appear in the module and vice versa

        .PARAMETER ModuleFile
        A string containing the Module filename

        .PARAMETER ManifestFile
        A string containing the Manifest filename

        .EXAMPLE
        ($ExportedCommandsCount, $CommandFoundInModuleCount, $CommandInModuleCount, $CommandFoundInManifestCount) = Get-FunctionCount -Module $moduleFile -Manifest $manifestFile

    #>
    [CmdletBinding()]
    [OutputType([Int[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$ModuleFile,
        [parameter(Mandatory = $true)]
        [string]$ManifestFile
    )

    try {
        if (Test-Path -Path $ManifestFile) {
            $ExportedCommandsCount = (Test-ModuleManifest -Path $ManifestFile).ExportedCommands.Count
        }
        else {
            throw "Manifest file doesn't exist"
        }
    }
    catch {
        $ExportedCommands = @()
        $ExportedCommandsCount = 0
    }
    try {
        if (Test-Path -Path $ModuleFile) {
            ($ParsedModule, $ParserErrors) = Get-ParsedFile -Path $ModuleFile
        }
        else {
            throw "Module file doesn't exist"
        }
    }
    catch {
        $ParsedModule = @()
        $ParserErrors = 1
    }

    $CommandFoundInModuleCount = 0
    $CommandFoundInManifestCount = 0
    $CommandInModuleCount = 0

    if ( -not ([string]::IsNullOrEmpty($ParsedModule))) {

        foreach ($ExportedCommand in $ExportedCommands.Keys) {

            if ( ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.Content -eq $ExportedCommand })) {

                $CommandFoundInModuleCount++

            }

        }

        $functionNames = @()

        $functionKeywords = ($ParsedModule | Where-Object { $_.Type -eq "Keyword" -and $_.Content -eq "function" })
        $functionKeywords | ForEach-Object {

            $functionLineNo = $_.StartLine
            $functionNames += ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.StartLine -eq $functionLineNo })

        }
    }

    if ($ExportedCommandsCount -ge 1) {

        $functionNames | ForEach-Object {

            $CommandInModuleCount++
            if ($ExportedCommands.ContainsKey($_.Content)) {

                $CommandFoundInManifestCount++

            }

        }

    }

    return ($ExportedCommandsCount, $CommandFoundInModuleCount, $CommandInModuleCount, $CommandFoundInManifestCount)

}
