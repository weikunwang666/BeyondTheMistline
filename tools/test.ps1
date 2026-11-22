$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'userdata'
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
$logPath=Join-Path $taskRoot 'build/current-tests.log'
& (Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe') --path (Join-Path $taskRoot 'game') -- --smoke *> $logPath
$logText=Get-Content -LiteralPath $logPath -Raw
if ($LASTEXITCODE -ne 0 -or $logText -match '(SCRIPT ERROR|ERROR:|Assertion failed)' -or $logText -notmatch 'V08_TESTS_OK' -or $logText -notmatch 'AUDIO_TESTS_OK' -or $logText -notmatch 'PERCEPTION_OK' -or $logText -notmatch 'SMOKE_OK') {
 Write-Output $logText
 throw 'Game runtime regression failed'
}
Write-Output $logText
