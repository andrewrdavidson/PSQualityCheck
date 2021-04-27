function Get-FunctionFileContent {

    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $fileContent = Get-Content -Path $Path
        $parserErrors = $null
        if ([string]::IsNullOrEmpty($fileContent)) {
            $parsedFileFunctions = @()
        }
        else {
            $parsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$parserErrors)
        }
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
                    for ($line = $startLine; $line -lt $endLine; $line++) {
                        $parsedFileContent += $fileContent[$line]
                        if ($line -ne ($fileContent.Count - 1)) {
                            $parsedFileContent += "`r`n"
                        }
                    }
                }
            }
            else {
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

function Install-BuiltModule {

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Module
    )

    # $Module = "PSTemplate"

    Install-Module -Name $Module -Repository "$Module-local"

}

function Publish-BuiltModule {

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Module,
        [parameter(Mandatory = $true)]
        [string]$ArtifactsFolder,
        [string]$BuildFolder,
        [switch]$Clean
    )

    # $Module = "PSTemplate"
    $Version = (Import-PowerShellDataFile -Path ".\source\$Module\$Module.psd1").ModuleVersion

    # QUERY: Need this?
    # New-Item -ItemType Directory -Path  ./artifacts -Force
    # $ArtifactsFolder = Resolve-Path -Path "./artifacts"
    if ($PSBoundParameters.ContainsKey('Clean')) {
        Remove-Item -Path $ArtifactsFolder -Recurse -Force
        New-Item -Path $ArtifactsFolder -ItemType Directory
    }

    Register-PSRepository -Name "$Module-local" -SourceLocation $ArtifactsFolder -InstallationPolicy Trusted

    Publish-Module -Path "$BuildFolder\$Module\$Version" -Repository "$Module-local" -NuGetApiKey 'use real NuGetApiKey for real nuget server here'

    # Install-Module -Name "$($Module)" -Repository "$($Module)-local"

    # Get-PSRepository

}

function Uninstall-BuiltModule {

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Module
    )

    # $Module = "PSTemplate"

    Uninstall-Module -Name $Module


}

function Unpublish-BuiltModule {

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$Module
    )

    # $Module = 'PSTemplate'

    Unregister-PSRepository -Name "$Module-local"

    # Remove-Item -Path "./artifacts" -Recurse -Force

    # Get-PSRepository

}
