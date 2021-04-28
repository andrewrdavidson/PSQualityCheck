Write-Output "Checking for nuget.exe"
if (-not ($NuGetPath = (Get-Command 'nuget.exe' -ErrorAction SilentlyContinue).Path)) {

    if (-not (Test-Path -Path ".\bin" -ErrorAction SilentlyContinue)) {
        New-Item -Path "bin" -ItemType Directory
    }

    Write-Output "nuget.exe not found, downloading into project bin path"
    $NuGetPath = Resolve-Path -Path ".\bin"
    $NuGetFile = Join-Path -Path $NuGetPath -ChildPath "nuget.exe"
    Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile $NuGetFile

    $path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $environmentPaths = $path.Split(";")
    if (-not ($NuGetPath -contains $environmentPaths)) {
        Write-Output "Updating System Environment path"
        $path += ";$NuGetPath"
        $env:Path = $path
        [Environment]::SetEnvironmentVariable("Path", $path, 'Machine')
    }

}

# Bootstrap environment
Write-Output "Bootstrap NuGet PackageProvider"
Get-PackageProvider -Name 'NuGet' -ForceBootstrap | Out-Null

# Install PSDepend module if it is not already installed
if (-not (Get-Module -Name 'PSDepend' -ListAvailable)) {
    Write-Output "PSDepend is not yet installed, installing PSDepend"
    Install-Module -Name 'PSDepend' -Scope 'CurrentUser' -Force
}
else {
    Write-Output "PSDepend already installed"
}

# Install build dependencies
$psDependencyConfigPath = Join-Path -Path $PSScriptRoot -ChildPath 'install.depend.psd1'
Write-Output "Checking / resolving module dependencies from [$psDependencyConfigPath]..."
Import-Module -Name 'PSDepend'
$invokePSDependParams = @{
    Path    = $psDependencyConfigPath
    Import  = $true
    Confirm = $false
    Install = $true
    Verbose = $false
}
Invoke-PSDepend @invokePSDependParams

Write-Output "Finished installing all dependencies"
