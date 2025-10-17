# =========================== Bootstrap-Placeholders.ps1 ===========================
# Creates the full folder tree + placeholder files (core + nice-to-have).
# Idempotent: will not overwrite existing files. Safe to re-run anytime.
# Run from the PROJECT ROOT (the folder that CONTAINS ResearchBase\).
# PowerShell 5.1+ / 7+ compatible.

[CmdletBinding()]
param(
  [switch]$Open  # Open key files after creation
)

# --- tiny log helpers
function Say($m,[ConsoleColor]$c='Gray'){ $old=$Host.UI.RawUI.ForegroundColor; $Host.UI.RawUI.ForegroundColor=$c; Write-Host $m; $Host.UI.RawUI.ForegroundColor=$old }
function Ok ($m){ Say $m 'Green' }
function Info($m){ Say $m 'Cyan'  }
function Warn($m){ Say $m 'Yellow'}
function Err ($m){ Say $m 'Red'   }

# --- resolve root + ensure ResearchBase path
$ProjectRoot = $PSScriptRoot; if (-not $ProjectRoot) { $ProjectRoot = (Get-Location).Path }
$ResearchBase = Join-Path $ProjectRoot 'ResearchBase'
if (-not (Test-Path -LiteralPath $ResearchBase)) { New-Item -ItemType Directory -Force -Path $ResearchBase | Out-Null }

# --- helper: write a file only if missing
function New-Placeholder {
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter()][string]$Content = ''
  )
  if (Test-Path -LiteralPath $Path) { return $false }
  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $Content | Set-Content -Encoding UTF8 -LiteralPath $Path
  return $true
}

# --- directories (Core)
$dirsCore = @(
  # Core dataset areas
  'ResearchBase\00_texts',
  'ResearchBase\01_lexicons',
  'ResearchBase\02_grammars',
  'ResearchBase\03_commentaries\OT',
  'ResearchBase\03_commentaries\NT',
  'ResearchBase\04_background_dictionaries',
  'ResearchBase\05_textual_criticism',
  'ResearchBase\06_discourse_syntax',
  'ResearchBase\07_journals',
  'ResearchBase\08_notes_highlights',
  'ResearchBase\09_datasets_indices',

  # Project plumbing
  'scripts',
  'config',
  'docs',
  'tests',
  'logs',
  'tools',
  'samples',
  'modules\ResearchBaseTools',
  '.vscode'
)

# --- directories (Nice-to-have)
$dirsNice = @(
  'docs\guides',
  'tools\poppler',
  'tools\bin'
)

foreach ($d in $dirsCore + $dirsNice) {
  $path = Join-Path $ProjectRoot $d
  if (-not (Test-Path -LiteralPath $path)) { New-Item -ItemType Directory -Force -Path $path | Out-Null }
}

# --- drop .gitkeep for empty dirs
$gitkeepTargets = @(
  'ResearchBase\01_lexicons',
  'ResearchBase\02_grammars',
  'ResearchBase\03_commentaries\OT',
  'ResearchBase\03_commentaries\NT',
  'ResearchBase\04_background_dictionaries',
  'ResearchBase\05_textual_criticism',
  'ResearchBase\06_discourse_syntax',
  'ResearchBase\07_journals',
  'ResearchBase\08_notes_highlights',
  'logs','tools','docs','tests','samples'
)
foreach ($rel in $gitkeepTargets) {
  $k = Join-Path $ProjectRoot (Join-Path $rel '.gitkeep')
  if (-not (Test-Path -LiteralPath $k)) { New-Item -ItemType File -Path $k | Out-Null }
}

# --------------------------- CORE FILES (must-have) ------------------------------

# README
$readme = @"
# Original Languages ResearchBase

This repository holds your study corpus and helper scripts.

## Quick start
1. Put your source files (TXT, MD, CSV, DOCX, PDF) under **ResearchBase\\**.
2. Build indices:
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass -Force
   .\Setup-ResearchBase.ps1
