function Export-FunctionsFromModule {
    <#
        .SYNOPSIS
        Export functions from a PowerShell module (.psm1)

        .DESCRIPTION
        Takes a PowerShell module and outputs a single file for each function containing the code for that function

        .PARAMETER Path
        A string Path containing the full file name and path to the module

        .PARAMETER FunctionExtractPath
        A string Path containing the full path to the extraction folder

        .EXAMPLE
        Export-FunctionsFromModule -Path 'c:\path.to\module.psm1' -FunctionExtractPath 'c:\extract'
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$FunctionExtractPath
    )

    # Get the file properties of our module
    $fileProperties = (Get-Item -LiteralPath $Path)
    $moduleName = $fileProperties.BaseName

    # Generate a new temporary output path for our extracted functions
    $FunctionOutputPath = Join-Path -Path $FunctionExtractPath -ChildPath $moduleName
    New-Item $FunctionOutputPath -ItemType 'Directory'

    # Get the plain content of the module file
    $ModuleFileContent = Get-Content -Path $Path -ErrorAction Stop

    # Parse the PowerShell module using PSParser
    $ParserErrors = $null
    $ParsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($ModuleFileContent, [ref]$ParserErrors)

    # Create an array of where each reference of the keyword 'function' is
    $ParsedFunctions = ($ParsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

    # Initialise the $parsedFunction tracking variable
    $parsedFunction = 0

    if ($ParsedFunctions.Count -ge 1) {

        foreach ($Function in $ParsedFunctions) {

            # Counter for the array $ParsedFunction to help find the 'next' function
            $parsedFunction++

            # Get the name of the current function
            # Cheat: Simply getting all properties with the same line number as the 'function' statement
            $FunctionProperties = $ParsedFileFunctions | Where-Object { $_.StartLine -eq $Function.StartLine }
            $FunctionName = ($FunctionProperties | Where-Object { $_.Type -eq "CommandArgument" }).Content

            # Establish the Start and End lines for the function in the main module file
            if ($parsedFunction -eq $ParsedFunctions.Count) {

                # This is the last function in the module so set the last line of this function to be the last line in the module file

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

                # EndLine needs to be where the last } is
                for ($line = $ParsedFunctions[$parsedFunction].StartLine; $line -gt $Function.StartLine; $line--) {
                    if ($ModuleFileContent[$line] -like "}") {
                        $EndLine = $line
                        break
                    }
                }

            }

            # Setup the FunctionOutputFile for the function file
            $FunctionOutputFileName = "{0}\{1}{2}" -f $FunctionOutputPath, $FunctionName, ".ps1"

            # If the file doesn't exist create an empty file so that we can Add-Content to it
            if (-not (Test-Path -Path $FunctionOutputFileName)) {
                Out-File -FilePath $FunctionOutputFileName
            }

            # Output the lines of the function to the FunctionOutputFile
            for ($line = $StartLine; $line -lt $EndLine; $line++) {
                Add-Content -Path $FunctionOutputFileName -Value $ModuleFileContent[$line]
            }

        }
    }
    else {
        Write-Warning "Module contains no functions, skipping"
    }

}
