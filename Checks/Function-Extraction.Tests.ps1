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
            'FullName' = $_
            'Name' = $fileProperties.Name
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

    Context "Script: <_.Name> at <_.Directory>" -ForEach $moduleFiles {

        BeforeEach {

            $moduleFile = $_.FullName

        }

        It "function extraction should complete" {

            {

                Export-FunctionsFromModule -Path $moduleFile -ExtractPath $ExtractPath

            } | Should -Not -Throw

        }

    }

}
