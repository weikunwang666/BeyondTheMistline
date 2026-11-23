param([switch]$Bake)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'rig-qa'
$env:TEMP=Join-Path $PSScriptRoot 'temp'
$env:TMP=$env:TEMP
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
$logPath=Join-Path $taskRoot 'build/base-rig-review.log'
$arguments=@('--path',(Join-Path $taskRoot 'game'),'--log-file',$logPath,'--','--base-rig-review')
if ($Bake) { $arguments+='--bake-rig' }
$process=Start-Process (Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe') -ArgumentList $arguments -PassThru -WindowStyle Hidden
if (!$process.WaitForExit(60000)) { $process.Kill(); throw 'Rig review exceeded 60 seconds.' }
$result=Get-Content -LiteralPath $logPath -Raw
if ($process.ExitCode -ne 0 -or $result -match '(SCRIPT ERROR|ERROR:)' -or $result -notmatch 'RIG_REVIEW_OK') { throw $result }
Write-Output 'RIG_REVIEW_OK: imported bones/actions, animated hand, body proportions and tool socket. Review build/base-rig-*.png for visual quality.'
