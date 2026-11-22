param([string]$Executable)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'ai-qa'
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
foreach ($mode in @('ai','perception')) {
 $logPath=Join-Path $taskRoot ('build/'+$mode+'-release.log')
 $arguments=@('--log-file',$logPath)
 if (-not $Executable) { $arguments+=@('--path',(Join-Path $taskRoot 'game')) }
 $arguments+=@('--',('--'+$mode+'-test'))
 $binary=if ($Executable) { $Executable } else { Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe' }
 $process=Start-Process -FilePath $binary -ArgumentList $arguments -PassThru -WindowStyle Hidden
 if (-not $process.WaitForExit(60000)) { $process.Kill(); throw "$mode exceeded 60 seconds" }
 $log=Get-Content -LiteralPath $logPath -Raw
 $marker=if ($mode -eq 'ai') { 'AI_OK' } else { 'PERCEPTION_LIVE_OK' }
 if ($process.ExitCode -ne 0 -or $log -match 'ERROR|FAILED' -or $log -notmatch $marker) { throw "$mode failed: $log" }
 Write-Output $log
}
