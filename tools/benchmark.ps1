param([string]$Label='baseline')
$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$env:APPDATA=Join-Path $PSScriptRoot 'benchmark-qa'
$env:MISTLINE_QA_DIR=Join-Path $taskRoot 'build'
$logPath=Join-Path $taskRoot ('build/benchmark-'+$Label+'.log')
$process=Start-Process -FilePath (Join-Path $taskRoot 'build/BeyondTheMistline.exe') -ArgumentList @('--log-file',$logPath,'--','--benchmark') -PassThru -WindowStyle Hidden
if (-not $process.WaitForExit(120000)) { $process.Kill(); throw 'Benchmark exceeded two minutes' }
$log=Get-Content -LiteralPath $logPath -Raw
if ($process.ExitCode -ne 0 -or $log -match 'ERROR' -or $log -notmatch 'BENCHMARK_OK') { throw "Benchmark failed: $log" }
$reportPath=Join-Path $taskRoot 'build/benchmark.json'
$report=Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
if ($report.render_texture[0] -ne 1920 -or $report.render_texture[1] -ne 1080) { throw 'Actual render texture was not 1080p' }
Copy-Item -LiteralPath $reportPath -Destination (Join-Path $taskRoot ('build/benchmark-'+$Label+'.json'))
$report.scenes | Select-Object scene,mean_fps,p95_ms,max_ms,draw_calls | Format-Table -AutoSize
