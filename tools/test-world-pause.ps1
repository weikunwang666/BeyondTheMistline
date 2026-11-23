param([string]$Executable)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'world-pause-qa'
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
$logPath=Join-Path $taskRoot 'build/world-pause.log'
$arguments=@('--log-file',$logPath)
if (-not $Executable) { $arguments+=@('--path',(Join-Path $taskRoot 'game')) }
$arguments+=@('--','--world-pause-test')
$binary=if ($Executable) { $Executable } else { Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe' }
$process=Start-Process -FilePath $binary -ArgumentList $arguments -PassThru -WindowStyle Hidden
if (-not $process.WaitForExit(60000)) { $process.Kill(); throw 'World pause test exceeded 60 seconds' }
$log=Get-Content -LiteralPath $logPath -Raw
if ($process.ExitCode -ne 0 -or $log -match 'ERROR|FAILED' -or $log -notmatch 'WORLD_PAUSE_OK') { throw "World pause failed: $log" }
Write-Output $log
