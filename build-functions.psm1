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
        [string]$ModuleName
    )

    Install-Module -Name $ModuleName -Repository "$ModuleName-local"

}

function Publish-BuiltModule {

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$ModuleName,
        [parameter(Mandatory = $true)]
        [string]$ArtifactsFolder,
        [parameter(Mandatory = $true)]
        [string]$SourceFolder,
        [parameter(Mandatory = $true)]
        [string]$BuildFolder,
        [switch]$Clean
    )

    $version = (Import-PowerShellDataFile -Path "$SourceFolder\$ModuleName\$ModuleName.psd1").ModuleVersion
    $repositoryName = "$moduleName-local"

    if ($null -ne (Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue)) {
        Uninstall-Module -Name $ModuleName
    }

    if ($null -ne (Get-PSRepository -Name $repositoryName -ErrorAction SilentlyContinue)) {
        Unregister-PSRepository -Name $repositoryName
    }

    $artifact = Join-Path -Path $ArtifactsFolder -ChildPath "$($ModuleName).$($version).nupkg"

    if ($PSBoundParameters.ContainsKey('Clean')) {
        if ((Test-Path -Path $artifact -ErrorAction SilentlyContinue)) {
            Remove-Item -Path $artifact -Force
        }
    }

    Register-PSRepository -Name $repositoryName -SourceLocation $ArtifactsFolder -InstallationPolicy Trusted

    Publish-Module -Path "$BuildFolder\$ModuleName\$version" -Repository $repositoryName -NuGetApiKey 'use real NuGetApiKey for real nuget server here'

}

function Uninstall-BuiltModule {

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    Uninstall-Module -Name $ModuleName

}

function Unpublish-BuiltModule {

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [parameter(Mandatory = $true)]
        [string]$ModuleName,
        [parameter(Mandatory = $true)]
        [string]$SourceFolder,
        [parameter(Mandatory = $true)]
        [string]$ArtifactsFolder
    )

    $repositoryName = "$moduleName-local"

    $version = (Import-PowerShellDataFile -Path "$SourceFolder\$ModuleName\$ModuleName.psd1").ModuleVersion

    $artifact = Join-Path -Path $ArtifactsFolder -ChildPath "$ModuleName.$version.nupkg"

    if ((Test-Path -Path $artifact -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $artifact -Force
    }

    if ($null -ne (Get-PSRepository -Name $repositoryName -ErrorAction SilentlyContinue)) {
        Unregister-PSRepository -Name $repositoryName
    }

}
