param(
    [parameter(Mandatory = $true)]
    [string[]]$Source,

    [parameter(Mandatory = $true)]
    [string]$ExtractPath
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

    if ( Test-Path -Path $ExtractPath ) {
        Get-ChildItem -Path $ExtractPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse
        Remove-Item $ExtractPath -Force -ErrorAction SilentlyContinue
    }

    New-Item -Path $ExtractPath -ItemType 'Directory'

}

Describe "Function Extraction" {

    Context "Script: <_.Name> at <_.Directory>" -Foreach $moduleFiles {

        It "function extraction should complete" {

            {

                $moduleFile = $_.FullName
                ExportFunctionsFromModule -Path $moduleFile -ExtractPath $ExtractPath

            } | Should -Not -Throw

        }

    }

}
