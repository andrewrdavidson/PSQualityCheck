function Get-FileContent {
    <#
        .SYNOPSIS
        Gets the content of a script file

        .DESCRIPTION
        Gets the content of the file or the content of the function inside the file

        .PARAMETER Path
        A file name to parse

        .EXAMPLE
        $fileContent = Get-FileContent -Path 'c:\file.txt'
    #>
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    try {

        $fileContent = Get-Content -Path $Path

        $parserErrors = $null

        # If the file content is null (an empty file) then generate an empty parsedFileFunctions array to allow the function to complete
        if ([string]::IsNullOrEmpty($fileContent)) {
            $parsedFileFunctions = @()
        }
        else {
            $parsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$parserErrors)
        }

        # Create an array of where each reference of the keyword 'function' is
        $parsedFunctions = ($parsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

        if ($parsedFunctions.Count -gt 1) {
            throw "Too many functions in file, file is invalid"
        }

        if ($parsedFunctions.Count -eq 1) {

            if ($fileContent.Count -gt 1) {

                foreach ($function in $parsedFunctions) {

                    $startLine = ($function.StartLine)

                    for ($line = $fileContent.Count; $line -gt $function.StartLine; $line--) {

                        if ($fileContent[$line] -like "*}*") {

                            $endLine = $line
                            break

                        }

                    }

                    # Output the lines of the function to the FunctionOutputFile
                    for ($line = $startLine; $line -lt $endLine; $line++) {

                        $parsedFileContent += $fileContent[$line]

                        if ($line -ne ($fileContent.Count - 1)) {
                            $parsedFileContent += "`r`n"
                        }

                    }

                }

            }
            else {

                # if there is only one line then the content should be on the line between { and }
                [int]$startBracket = $fileContent.IndexOf('{')
                [int]$endBracket = $fileContent.LastIndexOf('}')

                $parsedFileContent = $fileContent.substring($startBracket + 1, $endBracket - 1 - $startBracket)

            }
        }
        else {

            if ($fileContent.Count -gt 1) {

                for ($line = 0; $line -lt $fileContent.Count; $line++) {

                    $parsedFileContent += $fileContent[$line]

                    if ($line -ne ($fileContent.Count - 1)) {
                        $parsedFileContent += "`r`n"
                    }

                }

            }
            else {

                $parsedFileContent = $fileContent

            }

        }

    }
    catch {
        throw
    }

    return $parsedFileContent

}
