param (
    [parameter(Mandatory = $false)]
    [string]$FilesPath,
    
    [parameter(Mandatory = $false)]
    [string]$logLevel = "Normal"
)

## Make sure any modules we depend on are installed
$modulesToInstall = @(
    'Pester'
    'powershell-yaml'
)

$modulesToInstall | ForEach-Object {
    if (-not (Get-Module -ListAvailable -All $_)) {
        Write-Output "Module [$_] not found, INSTALLING..."
        Install-Module $_ -Force
    }
}

$modulesToInstall | ForEach-Object {
    Write-Output "Importing Module [$_]"
    Import-Module $_ -Force
}

## Install NuGet for KQL parsing
## https://stackoverflow.com/questions/70166382/validate-kusto-query-before-submitting-it
# Write-Output "Install PackageProvider NuGet"
# Install-PackageProvider -Name NuGet -Scope CurrentUser -Force
Import-PackageProvider -Name NuGet
Write-Output "Register PackageSource nuget.org"
Register-PackageSource -Name nuget.org -ProviderName NuGet  -Location https://www.nuget.org/api/v2 -Force

# Import Mitre Att&ck mapping
Write-Output 'Loading Mitre Att&ck framework'
$global:attack = (Get-ChildItem -Path "$($PSScriptRoot)\mitre.csv" -Recurse | Get-Content | ConvertFrom-CSV)

$nuGetPath=Get-Package -Name "Microsoft.Azure.Kusto.Language" | Select-Object -ExpandProperty Source
$dllPath=(Split-Path -Path $nuGetPath) + "\lib\netstandard2.0\Kusto.Language.dll"
[System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null

if ($FilesPath -ne '.') {
    Write-Output  "Selected filespath is [$FilesPath]"
    $copiedFiles = Get-ChildItem "*.tests.ps1" | Copy-Item -Destination $FilesPath -Force -PassThru
    $global:detectionsPath = $FilesPath
}

$PesterConfig = [PesterConfiguration]@{
    Run         = @{
        Path = "$($PSScriptRoot)"
    }
    Output      = @{
        Verbosity = "$logLevel"
    }
    TestResults = @{
        OutputFormat = 'NuUnitXml'
        OutputPath   = "."
    }
    Should      = @{
        ErrorAction = 'Continue'
    }
}

Invoke-Pester -Configuration $PesterConfig

# Cleanup test file
$copiedFiles | Remove-Item -Force
