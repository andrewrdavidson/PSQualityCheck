function ExportFunctionsFromModule {
    <#
        .SYNOPSIS
        Export functions from a PowerShell module (.psm1)

        .DESCRIPTION
        Takes a PowerShell module and outputs a single file for each function containing the code for that function

        .PARAMETER Path
        A string Path containing the full file name and path to the module

        .PARAMETER ExtractPath
        A string Path containing the full path to the extraction folder

        .EXAMPLE
        ExportFunctionsFromModule -Path 'c:\path.to\module.psm1' -ExtractPath 'c:\extract'
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$ExtractPath
    )

    try {

        $fileProperties = (Get-Item -LiteralPath $Path)

        if ($fileProperties.Extension -ne ".psm1") {
            throw "Passed file does not appear to be a PowerShell module"
        }

        $moduleName = $fileProperties.BaseName

        $ModuleFileContent = Get-Content -Path $Path -ErrorAction Stop

        $ParserErrors = $null
        $ParsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($ModuleFileContent, [ref]$ParserErrors)

        $ParsedFunctions = ($ParsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

        $parsedFunction = 0

        if ($ParsedFunctions.Count -ge 1) {

            $FunctionOutputPath = Join-Path -Path $ExtractPath -ChildPath $moduleName

            if (-not (Test-Path -Path $FunctionOutputPath)) {
                New-Item $FunctionOutputPath -ItemType 'Directory'
            }

            foreach ($Function in $ParsedFunctions) {

                $parsedFunction++

                $FunctionProperties = $ParsedFileFunctions | Where-Object { $_.StartLine -eq $Function.StartLine }
                $FunctionName = ($FunctionProperties | Where-Object { $_.Type -eq "CommandArgument" }).Content

                if ($parsedFunction -eq $ParsedFunctions.Count) {

                    $StartLine = ($Function.StartLine)
                    for ($line = $ModuleFileContent.Count; $line -gt $Function.StartLine; $line--) {
                        if ($ModuleFileContent[$line] -like "}") {
                            $EndLine = $line
                            break
                        }
                    }

                }
                else {

                    $StartLine = ($Function.StartLine)

                    for ($line = $ParsedFunctions[$parsedFunction].StartLine; $line -gt $Function.StartLine; $line--) {
                        if ($ModuleFileContent[$line] -like "}") {
                            $EndLine = $line
                            break
                        }
                    }

                }

                $FunctionOutputFileName = "{0}\{1}{2}" -f $FunctionOutputPath, $FunctionName, ".ps1"

                if (-not (Test-Path -Path $FunctionOutputFileName)) {
                    Out-File -FilePath $FunctionOutputFileName
                }

                for ($line = $StartLine; $line -lt $EndLine; $line++) {
                    Add-Content -Path $FunctionOutputFileName -Value $ModuleFileContent[$line]
                }

            }
        }
        else {
            throw "File contains no functions"
        }
    }
    catch {
        throw
    }
}
