param([string]$Executable)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'compact-qa'
$env:TEMP=Join-Path $PSScriptRoot 'temp'
$env:TMP=$env:TEMP
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
$logPath=Join-Path $taskRoot 'build/compact-test.log'
$arguments=@('--log-file',$logPath)
if (!$Executable) { $arguments+=@('--path',(Join-Path $taskRoot 'game')) }
$arguments+=@('--','--compact-test')
$binary=if ($Executable) {$Executable} else {Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe'}
$process=Start-Process $binary -ArgumentList $arguments -PassThru -WindowStyle Hidden
if (!$process.WaitForExit(60000)) { $process.Kill(); throw 'Compact test exceeded 60 seconds' }
$log=Get-Content $logPath -Raw
if ($process.ExitCode -ne 0 -or $log -match 'ERROR|FAILED' -or $log -notmatch 'COMPACT_OK') { throw $log }
Write-Output $log
