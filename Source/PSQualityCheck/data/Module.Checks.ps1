param(
    [parameter(Mandatory = $true)]
    [string[]]$Source
)

BeforeDiscovery {

    $moduleFiles = @()

    $Source | ForEach-Object {

        $fileProperties = (Get-Item -Path $_)

        $moduleFiles += @{
            'FullName'  = $_
            'Name'      = $fileProperties.Name
            'Directory' = $fileProperties.Directory

        }

    }

}

Describe "Module Tests" -Tag "Module" {

    Context "Script: <_.Name> at <_.Directory>" -ForEach $moduleFiles {

        BeforeEach {

            $moduleFile = $_.FullName
            $manifestFile = [Io.Path]::ChangeExtension($_.FullName, 'psd1')

            ($ExportedCommandsCount, $CommandFoundInModuleCount, $CommandInModuleCount, $CommandFoundInManifestCount) = GetFunctionCount -Module $moduleFile -Manifest $manifestFile

        }

        It "Module should exist" -Tag "ModuleShouldExist" {

            $moduleFile | Should -Exist

        }

        It "Manifest should exist" -Tag "ManifestShouldExist" {

            $manifestFile | Should -Exist

        }

        It "Manifest should be valid" -Tag "ValidManifest" {

            $manifest = Test-ModuleManifest -Path $manifestFile -ErrorAction SilentlyContinue

            $manifest | Should -BeOfType [System.Management.Automation.PSModuleInfo]

        }

        It "Manifest should export Functions" -Tag "ModuleShouldExportFunctions" {

            ($ExportedCommandsCount) | Should -BeGreaterOrEqual 1

        }

        It "Module should have Functions" -Tag "ModuleShouldHaveFunctions" {

            ($CommandInModuleCount) | Should -BeGreaterOrEqual 1

        }

        It "all exported Functions from Manifest should exist in the Module" -Tag "FunctionsFromManifestExistInModule" {

            ($ExportedCommandsCount -eq $CommandFoundInModuleCount -and $ExportedCommandsCount -ge 1) | Should -BeTrue

        }

        It "all Functions in the Module should exist in Manifest " -Tag "FunctionsFromModuleExistInManifest" {

            ($CommandInModuleCount -eq $CommandFoundInManifestCount -and $CommandFoundInManifestCount -ge 1 ) | Should -BeTrue

        }

    }

}
