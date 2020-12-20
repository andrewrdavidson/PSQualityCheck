param(
    [parameter(Mandatory = $true)]
    [string[]]$Source
)

Describe "Module Tests" {

    foreach ($moduleFile in $Source) {

        Context "Module : $moduleFile" {

            $manifestFile = [Io.Path]::ChangeExtension($moduleFile, 'psd1')

            It "Module should exist" -TestCases @{ 'moduleFile' = $moduleFile } {

                $moduleFile | Should -Exist

            }

            It "Manifest should exist" -TestCases @{ 'manifestFile' = $manifestFile } {

                $manifestFile | Should -Exist

            }

            It "Manifest should be valid" -TestCases @{ 'manifestFile' = $manifestFile } {

                $manifest = Test-ModuleManifest -Path $manifestFile -ErrorAction SilentlyContinue

                $manifest | Should -BeOfType [System.Management.Automation.PSModuleInfo]

            }

            ($ExportedCommandsCount, $CommandFoundInModuleCount, $CommandInModuleCount, $CommandFoundInManifestCount) = Get-FunctionCount -Module $moduleFile -Manifest $manifestFile

            It "Manifest should export Functions" -TestCases @{
                'ExportedCommandsCount' = $ExportedCommandsCount
            } {

                ($ExportedCommandsCount) | Should -BeGreaterOrEqual 1

            }

            It "Module should have Functions" -TestCases @{
                'CommandInModuleCount' = $CommandInModuleCount
            } {

                ($CommandInModuleCount) | Should -BeGreaterOrEqual 1

            }

            It "all exported Functions from Manifest should exist in the Module" -TestCases @{
                'ExportedCommandsCount' = $ExportedCommandsCount
                'CommandFoundInModuleCount' = $CommandFoundInModuleCount
            } {

                ($ExportedCommandsCount -eq $CommandFoundInModuleCount -and $ExportedCommandsCount -ge 1) | Should -BeTrue

            }

            It "all Functions in the Module should exist in Manifest " -TestCases @{
                'CommandInModuleCount' = $CommandInModuleCount
                'CommandFoundInManifestCount' = $CommandFoundInManifestCount
            } {

                ($CommandInModuleCount -eq $CommandFoundInManifestCount -and $CommandFoundInManifestCount -ge 1 ) | Should -BeTrue

            }

        }

    }

}
