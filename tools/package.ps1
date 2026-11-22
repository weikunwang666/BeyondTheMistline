param([ValidatePattern('^\d+\.\d+$')][string]$Version='0.17')
$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path -LiteralPath (Split-Path $PSScriptRoot -Parent)).Path
$package=Join-Path $taskRoot "BeyondTheMistline-$Version-Windows"
$zipPath=$package+'.zip'
New-Item -ItemType Directory -Force -Path $package | Out-Null
foreach ($name in @('BeyondTheMistline.exe','BeyondTheMistline.pck')) {
 Copy-Item -LiteralPath (Join-Path $taskRoot ('build/'+$name)) -Destination $package -Force
}
foreach ($name in @('README.md','ASSET_CREDITS.md')) { Copy-Item -LiteralPath (Join-Path $taskRoot $name) -Destination $package -Force }
foreach ($name in @('KNOWN_ISSUES.md','TEST_REPORT.md','MAINLINE_VALIDATION.md','GAMEPLAY_VIDEO.md','PERFORMANCE.md','AI_PERCEPTION.md')) {
 Copy-Item -LiteralPath (Join-Path $taskRoot ('docs/'+$name)) -Destination $package -Force
}
Compress-Archive -LiteralPath $package -DestinationPath $zipPath -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive=[IO.Compression.ZipFile]::OpenRead($zipPath)
try {
 foreach ($name in @('BeyondTheMistline.exe','BeyondTheMistline.pck')) {
  $source=Get-Item -LiteralPath (Join-Path $package $name)
  $entry=$archive.Entries | Where-Object { $_.Name -eq $name }
  if (-not $entry -or $entry.Length -ne $source.Length) { throw "Package missing or truncated: $name" }
 }
} finally { $archive.Dispose() }
# Retain only the current distributable, as requested; source and saves are separate.
foreach ($item in Get-ChildItem -LiteralPath $taskRoot) {
 if ($item.Name -notmatch '^BeyondTheMistline-\d+\.\d+-Windows(\.zip)?$') { continue }
 if ($item.FullName -eq $package -or $item.FullName -eq $zipPath) { continue }
 $resolved=(Resolve-Path -LiteralPath $item.FullName).Path
 if (-not $resolved.StartsWith($taskRoot+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Package outside workspace' }
 if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Refuse package link' }
 Remove-Item -LiteralPath $resolved -Recurse -Force
}
Get-Item -LiteralPath $zipPath | Select-Object FullName,Length
