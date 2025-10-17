[CmdletBinding()] param([string]$Root)
if (-not $Root -or -not (Test-Path -LiteralPath $Root)) {
  $cand = Join-Path (Get-Location).Path 'ResearchBase'
  if (Test-Path -LiteralPath $cand) { $Root = (Resolve-Path -LiteralPath $cand).Path }
  else { throw "ResearchBase not found. Run from the folder that contains ResearchBase\ or pass -Root <path>." }
}
$idxDir     = Join-Path $Root '09_datasets_indices'
$projRoot   = Split-Path -Parent $Root
$manifest   = Join-Path $Root 'manifest.csv'
$quick      = Join-Path $projRoot 'QuickSearch.ps1'
$refsHelper = Join-Path $projRoot 'Search-Refs.ps1'
$indexFiles = @('fulltext.ndjson','lines.ndjson','refs.ndjson') | ForEach-Object { Join-Path $idxDir $_ }

$openList = @($manifest, $quick, $refsHelper) + $indexFiles
$existing = @()
foreach ($f in $openList) { if ($f -and (Test-Path -LiteralPath $f)) { $existing += $f } }

Write-Host "Will open:" -ForegroundColor Cyan
$existing | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

function Open-With-Code {
  param([string[]]$Files)
  $cmd = Get-Command code -ErrorAction SilentlyContinue
  if ($cmd) { & $cmd.Source --reuse-window @Files; return $true }
  $cands = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "C:\Program Files\Microsoft VS Code\bin\code.cmd"
  )
  foreach ($c in $cands) { if (Test-Path -LiteralPath $c) { & $c --reuse-window @Files; return $true } }
  return $false
}

if ($existing.Count -gt 0) {
  if (-not (Open-With-Code -Files $existing)) {
    Write-Host "VS Code not found; opening in Notepad..." -ForegroundColor Yellow
    foreach ($f in $existing) { & notepad.exe "$f" }
  }
} else {
  Write-Host "Nothing to open." -ForegroundColor Yellow
}

if (Test-Path -LiteralPath $idxDir) { ii $idxDir }
if (Test-Path -LiteralPath $Root)   { ii $Root   }
