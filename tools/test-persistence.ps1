param([string]$Executable)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'persistence-qa'
$engine=Join-Path $PSScriptRoot 'Godot_v4.5.2-stable_win64_console.exe'
function Run-Persistence([string]$Mode,[string]$Label,[switch]$Backup) {
 $logPath=Join-Path $taskRoot ('build/persistence-'+$Label+'.log')
 $arguments=@('--log-file',$logPath)
 if (-not $Executable) { $arguments+=@('--path',(Join-Path $taskRoot 'game')) }
 $arguments+=@('--',$Mode)
 if ($Backup) { $arguments+='--expect-backup' }
 $binary=if ($Executable) { $Executable } else { $engine }
 $process=Start-Process -FilePath $binary -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
 $log=Get-Content -LiteralPath $logPath -Raw
 if ($process.ExitCode -ne 0 -or $log -match 'ERROR|FAILED' -or $log -notmatch 'PERSIST_(WRITE|READ|UNREADABLE)_OK') { throw "Persistence test failed: $Label`n$log" }
 Write-Output $log
}
Run-Persistence '--save-write' 'write'
Run-Persistence '--save-read' 'restart'
$savePath=Join-Path $env:APPDATA 'Godot/app_userdata/雾线之外 Beyond the Mistline/mistline.json'
if (-not (Test-Path -LiteralPath ($savePath+'.bak'))) { throw 'Missing backup fixture' }
Set-Content -LiteralPath $savePath -Value '{truncated' -NoNewline
Run-Persistence '--save-read' 'recovery' -Backup
# Well-formed JSON with invalid nested state must also fall back safely.
$data=Get-Content -LiteralPath ($savePath+'.bak') -Raw | ConvertFrom-Json
$data.built=@(@{kind='门框';pos=@(0,1);angle=0})
$data | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $savePath
Run-Persistence '--save-read' 'schema-recovery' -Backup
Set-Content -LiteralPath $savePath -Value '{broken-primary' -NoNewline
Set-Content -LiteralPath ($savePath+'.bak') -Value '{broken-backup' -NoNewline
$before=Get-FileHash -LiteralPath $savePath
Run-Persistence '--save-unreadable' 'both-corrupt'
if ((Get-FileHash -LiteralPath $savePath).Hash -ne $before.Hash) { throw 'Unreadable save was overwritten' }
