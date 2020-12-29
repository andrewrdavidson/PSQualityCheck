param(
    [parameter(Mandatory = $true)]
    [string[]]$Source,

    [parameter(Mandatory = $true)]
    [string]$FunctionExtractPath
)

Describe "Function Extraction Tests" -Tag 'Setup' {

    if ( Test-Path -Path $FunctionExtractPath ) {
        Get-ChildItem -Path $FunctionExtractPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse
        Remove-Item $FunctionExtractPath -Force -ErrorAction SilentlyContinue
    }

    New-Item -Path $FunctionExtractPath -ItemType 'Directory'

    foreach ($moduleFile in $Source) {

        Context "Module : $moduleFile" {

            It "function extraction should complete" -TestCases @{ 'moduleFile' = $moduleFile } {

                {

                    Export-FunctionsFromModule -Path $moduleFile -FunctionExtractPath $FunctionExtractPath

                } | Should -Not -Throw

            }

        }

    }
}
