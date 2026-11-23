$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'userdata'
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
$logPath=Join-Path $taskRoot 'build/current-tests.log'
$process=Start-Process -FilePath (Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe') -ArgumentList @('--log-file',$logPath,'--path',(Join-Path $taskRoot 'game'),'--','--smoke') -PassThru -WindowStyle Hidden
if (-not $process.WaitForExit(60000)) { $process.Kill(); throw 'Runtime regression exceeded 60 seconds; inspect build/current-tests.log' }
$logText=Get-Content -LiteralPath $logPath -Raw
if ($process.ExitCode -ne 0 -or $logText -match '(SCRIPT ERROR|ERROR:|Assertion failed)' -or $logText -notmatch 'V08_TESTS_OK' -or $logText -notmatch 'AUDIO_TESTS_OK' -or $logText -notmatch 'PERCEPTION_OK' -or $logText -notmatch 'SMOKE_OK') {
 Write-Output $logText
 throw 'Game runtime regression failed'
}
Write-Output $logText
