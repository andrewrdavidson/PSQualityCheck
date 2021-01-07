param(
    [parameter(Mandatory = $true)]
    [string[]]$Source,

    [parameter(Mandatory = $true)]
    [string]$ExtractPath
)

Describe "Function Extraction" {

    if ( Test-Path -Path $ExtractPath ) {
        Get-ChildItem -Path $ExtractPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse
        Remove-Item $ExtractPath -Force -ErrorAction SilentlyContinue
    }

    New-Item -Path $ExtractPath -ItemType 'Directory'

    foreach ($moduleFile in $Source) {

        Context "Module : $moduleFile" {

            It "function extraction should complete" -TestCases @{ 'moduleFile' = $moduleFile } {

                {

                    Export-FunctionsFromModule -Path $moduleFile -ExtractPath $ExtractPath

                } | Should -Not -Throw

            }

        }

    }
}
