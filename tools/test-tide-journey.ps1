param([string]$Executable)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'tide-qa'
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
foreach ($mode in @('test','read')) {
 $logPath=Join-Path $taskRoot ('build/tide-journey-'+$mode+'.log')
 $arguments=@('--log-file',$logPath)
 if (-not $Executable) { $arguments+=@('--path',(Join-Path $taskRoot 'game')) }
 $arguments+=@('--',('--tide-journey-'+$mode))
 $binary=if ($Executable) { $Executable } else { Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe' }
 $process=Start-Process -FilePath $binary -ArgumentList $arguments -PassThru -WindowStyle Hidden
 if (-not $process.WaitForExit(240000)) { $process.Kill(); throw 'Tide route exceeded four minutes' }
 $log=Get-Content -LiteralPath $logPath -Raw
 $marker=if ($mode -eq 'test') { 'TIDE_JOURNEY_OK' } else { 'TIDE_JOURNEY_RESTART_OK' }
 if ($process.ExitCode -ne 0 -or $log -match 'ERROR|FAILED' -or $log -notmatch $marker) { throw "Tide journey failed: $log" }
 Write-Output $log
}
