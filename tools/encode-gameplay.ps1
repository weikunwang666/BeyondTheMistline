$ErrorActionPreference='Stop'
$taskRoot=Split-Path $PSScriptRoot -Parent
$encoder='C:/Program Files/EVCapture/ffmpeg.exe'
$rawPath=Join-Path $taskRoot 'videos/mainline-raw.avi'
$outputPath=Join-Path $taskRoot 'videos/BeyondTheMistline-guided-gameplay.mp4'
if (-not (Test-Path -LiteralPath $rawPath)) { throw 'Record the real game run first with test-mainline.ps1 -RecordVideo' }
& $encoder -y -i $rawPath -t 300 -vf 'scale=1280:-2:out_range=tv' -pix_fmt yuv420p -r 30 -c:v libx264 -preset fast -crf 25 -maxrate 4M -bufsize 8M -c:a aac -b:a 128k -movflags +faststart $outputPath
if ($LASTEXITCODE -ne 0) { throw 'Gameplay encode failed' }
Get-Item -LiteralPath $outputPath | Select-Object FullName,Length
