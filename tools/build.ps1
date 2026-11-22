$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$env:APPDATA = Join-Path $PSScriptRoot 'userdata'
$env:TEMP = Join-Path $PSScriptRoot 'temp'
$env:TMP = $env:TEMP
New-Item -ItemType Directory -Force $env:TEMP | Out-Null
& (Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe') --headless --path (Join-Path $taskRoot 'game') --export-release 'Windows Desktop' (Join-Path $taskRoot 'build/BeyondTheMistline.exe')
if ($LASTEXITCODE -ne 0) { throw 'Godot export failed' }
