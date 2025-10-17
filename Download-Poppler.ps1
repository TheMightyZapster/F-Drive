[CmdletBinding()] param([string]$Dest = "tools\poppler")
$root = (Get-Location).Path
$dest = Join-Path $root $Dest
$zip  = Join-Path $root "tools\poppler.zip"
if (-not (Test-Path -LiteralPath $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }
$api = "https://api.github.com/repos/oschwartz10612/Poppler-windows/releases/latest"
$zipUrl = $null
try {
  $rel = Invoke-RestMethod -Uri $api -UseBasicParsing
  $asset = $rel.assets | Where-Object { $_.name -match 'poppler-.*-x86_64.*.zip' } | Select-Object -First 1
  if ($asset) { $zipUrl = $asset.browser_download_url }
} catch { }
if (-not $zipUrl) { $zipUrl = "https://github.com/oschwartz10612/Poppler-windows/releases/latest/download/poppler-23.05.0-x86_64.zip" }
Write-Host "Downloading: $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $dest)
Remove-Item $zip -Force -ErrorAction SilentlyContinue
$pdftotext = (Get-ChildItem (Join-Path $dest '*\Library\bin\pdftotext.exe') -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if ($pdftotext) {
  Write-Host "pdftot
Set-Content -LiteralPath .\Open-Indices.ps1 -Encoding UTF8 -Value @'
[CmdletBinding()] param(
  [string]$Root  # optional; defaults to .\ResearchBase
)

# Resolve ResearchBase root
if (-not $Root -or -not (Test-Path -LiteralPath $Root)) {
  $cand = Join-Path (Get-Location).Path 'ResearchBase'
  if (Test-Path -LiteralPath $cand) { $Root = (Resolve-Path -LiteralPath $cand).Path }
  else { throw "ResearchBase not found. Run from the folder that contains ResearchBase\ or pass -Root <path>." }
}

$idxDir   = Join-Path $Root '09_datasets_indices'
$projRoot = Split-Path -Parent $Root

$manifest = Join-Path $Root 'manifest.csv'
$quick    = Join-Path $projRoot 'QuickSearch.ps1'
$indexFiles = @('fulltext.ndjson','lines.ndjson','refs.ndjson') | ForEach-Object { Join-Path $idxDir $_ }

# Build the final open list (no pipes inside the here-string → avoids parse issues)
$openList = @()
$openList += $manifest
$openList += $quick
$openList += $indexFiles

# Keep only existing; warn for missing
$existing = @()
foreach ($f in $openList) {
  if (Test-Path -LiteralPath $f) { $existing += $f } else { Write-Warning "Missing: $f" }
}

function Open-With-Code {
  param([string[]]$Files)
  $cmd = Get-Command code -ErrorAction SilentlyContinue
  if ($cmd) { & $cmd.Source @Files; return $true }
  $cands = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "C:\Program Files\Microsoft VS Code\bin\code.cmd"
  )
  foreach ($c in $cands) {
    if (Test-Path -LiteralPath $c) { & $c @Files; return $true }
  }
  return $false
}

if ($existing.Count -gt 0) {
  if (-not (Open-With-Code -Files $existing)) {
    Write-Host "VS Code not found; opening in Notepad..." -ForegroundColor Yellow
    foreach ($f in $existing) { Start-Process notepad.exe -ArgumentList "`"$f`"" }
  }
}

if (Test-Path -LiteralPath $idxDir) { ii $idxDir }
if (Test-Path -LiteralPath $Root)   { ii $Root   }
