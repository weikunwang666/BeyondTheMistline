param([string]$Executable)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'settings-qa'
foreach ($mode in @('write','read')) {
 $logPath=Join-Path $taskRoot ('build/settings-'+$mode+'.log')
 $argsList=@('--log-file',$logPath)
 if (-not $Executable) { $argsList+=@('--path',(Join-Path $taskRoot 'game')) }
 $argsList+=@('--',('--settings-'+$mode))
 $binary=if ($Executable) { $Executable } else { Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe' }
 $process=Start-Process -FilePath $binary -ArgumentList $argsList -PassThru -WindowStyle Hidden
 if (-not $process.WaitForExit(60000)) { $process.Kill(); throw 'Settings test exceeded 60 seconds' }
 $log=Get-Content -LiteralPath $logPath -Raw
 if ($process.ExitCode -ne 0 -or $log -match 'ERROR|FAILED' -or $log -notmatch ('SETTINGS_'+$mode.ToUpper()+'_OK')) { throw "Settings test failed: $log" }
 Write-Output $log
}
