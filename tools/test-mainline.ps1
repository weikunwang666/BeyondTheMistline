param([switch]$RecordVideo)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$runId=[guid]::NewGuid().ToString('N').Substring(0,8)
$env:APPDATA=Join-Path $PSScriptRoot ('mainline-qa-runs/'+$runId)
New-Item -ItemType Directory -Force $env:APPDATA | Out-Null
Set-Content (Join-Path $taskRoot 'build/mainline-profile.txt') $env:APPDATA
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
$logPath=Join-Path $taskRoot $(if ($RecordVideo) { 'build/mainline-record.log' } else { 'build/mainline-release.log' })
$argsList=@('--log-file',$logPath)
if ($RecordVideo) {
 New-Item -ItemType Directory -Force (Join-Path $taskRoot 'videos') | Out-Null
 $argsList+=@('--write-movie',(Join-Path $taskRoot 'videos/mainline-raw.avi'),'--fixed-fps','30')
}
$argsList+=@('--','--mainline-test')
$process=Start-Process -FilePath (Join-Path $taskRoot 'build/BeyondTheMistline.exe') -ArgumentList $argsList -PassThru -WindowStyle Hidden
Write-Output ('MAINLINE_PROCESS '+$process.Id)
$deadline=[DateTime]::UtcNow.AddMinutes(13)
$previous=''
while (-not $process.WaitForExit(10000)) {
 if ([DateTime]::UtcNow -gt $deadline) { $process.Kill(); throw 'Mainline test exceeded thirteen minutes' }
 if (Test-Path -LiteralPath $logPath) {
  $last=Get-Content -LiteralPath $logPath -Tail 1
  if ($last -and $last -ne $previous) { Write-Output $last; $previous=$last }
 }
}
$log=Get-Content -LiteralPath $logPath -Raw
if ($process.ExitCode -ne 0 -or $log -match 'ERROR|FAILED' -or $log -notmatch 'MAINLINE_OK') { throw "Mainline journey failed: $log" }
Write-Output $log
$readLog=Join-Path $taskRoot 'build/mainline-restart.log'
$reader=Start-Process -FilePath (Join-Path $taskRoot 'build/BeyondTheMistline.exe') -ArgumentList @('--log-file',$readLog,'--','--mainline-read') -PassThru -WindowStyle Hidden
if (!$reader.WaitForExit(60000)) { $reader.Kill(); throw 'Mainline restart exceeded sixty seconds' }
$readText=Get-Content $readLog -Raw
if ($reader.ExitCode -ne 0 -or $readText -match 'ERROR|FAILED' -or $readText -notmatch 'MAINLINE_RESTART_OK') { throw $readText }
Write-Output $readText
