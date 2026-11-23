param([string]$OutputDirectory)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
if (!$OutputDirectory) { $OutputDirectory=Join-Path $taskRoot 'build' }
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null
$OutputDirectory=(Resolve-Path -LiteralPath $OutputDirectory).Path
$env:APPDATA = Join-Path $PSScriptRoot 'userdata'
$env:LOCALAPPDATA = Join-Path $PSScriptRoot 'userdata-local'
New-Item -ItemType Directory -Force $env:LOCALAPPDATA | Out-Null
$env:TEMP = Join-Path $PSScriptRoot 'temp'
$env:TMP = $env:TEMP
New-Item -ItemType Directory -Force $env:TEMP | Out-Null
& (Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe') --headless --path (Join-Path $taskRoot 'game') --export-release 'Windows Desktop' (Join-Path $OutputDirectory 'BeyondTheMistline.exe')
if ($LASTEXITCODE -ne 0) { throw 'Godot export failed' }
Copy-Item -LiteralPath (Join-Path $taskRoot 'game/assets/fonts/OFL.txt') -Destination (Join-Path $OutputDirectory 'FONT_LICENSE.txt') -Force
