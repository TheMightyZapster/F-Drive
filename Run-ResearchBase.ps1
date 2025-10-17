@echo off
setlocal
REM Run me from the PROJECT ROOT (same folder as Setup-ResearchBase.ps1)


cd /d "%~dp0"


REM Prefer PowerShell 7+ if present, else Windows PowerShell
where pwsh >NUL 2>&1 && set "PS=pwsh" || set "PS=powershell"


"%PS%" -NoProfile -ExecutionPolicy Bypass -Command ^
"param([string]$root)" ^
"$ErrorActionPreference = 'Continue';" ^
"Set-Location $root;" ^
"Write-Host 'Project Root:' (Get-Location).Path -ForegroundColor Cyan;" ^
"if (-not (Test-Path -LiteralPath '.\Setup-ResearchBase.ps1')) { Write-Host 'ERROR: Setup-ResearchBase.ps1 not found in project root.' -ForegroundColor Red; exit 1 }" ^
"; try { Unblock-File .\*.ps1 -ErrorAction SilentlyContinue } catch { }" ^
"; $popplerCandidates = @(" ^
" 'C:\\Program Files\\poppler-*\\Library\\bin\\pdftotext.exe'," ^
" 'C:\\Program Files\\poppler-*\\bin\\pdftotext.exe'," ^
" $env:LOCALAPPDATA + '\\Programs\\poppler*\\Library\\bin\\pdftotext.exe'," ^
" $env:LOCALAPPDATA + '\\Programs\\poppler*\\bin\\pdftotext.exe'," ^
" (Join-Path (Join-Path $root 'tools') 'poppler\\bin\\pdftotext.exe')" ^
");" ^
"$p = $null; foreach($g in $popplerCandidates){ $hit = Get-ChildItem $g -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName; if($hit){ $p = $hit; break } }" ^
"; if ($p) {" ^
" Write-Host 'pdftotext found:' $p -ForegroundColor Green;" ^
" & .\Setup-ResearchBase.ps1 -PdfToText $p" ^
" } else {" ^
" Write-Host 'pdftotext not found. Trying winget install (oschwartz10612.Poppler)...' -ForegroundColor Yellow;" ^
" $wing = Get-Command winget -ErrorAction SilentlyContinue;" ^
" if ($wing) {" ^
" try { winget install --id=oschwartz10612.Poppler -e --accept-source-agreements --accept-package-agreements | Out-Null } catch { }" ^
" $p = Get-ChildItem 'C:\\Program Files\\poppler-*\\Library\\bin\\pdftotext.exe','C:\\Program Files\\poppler-*\\bin\\pdftotext.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName;" ^
" if ($p) { & .\Setup-ResearchBase.ps1 -PdfToText $p } else { & .\Setup-ResearchBase.ps1 -AutoPoppler }" ^
" } else {" ^
" Write-Host 'winget not available. Proceeding without PDF extraction.' -ForegroundColor Yellow;" ^
" & .\Setup-ResearchBase.ps1" ^
" }" ^
" }" ^
"; $lines = Join-Path (Join-Path $root 'ResearchBase\\09_datasets_indices') 'lines.ndjson';" ^
"if (Test-Path -LiteralPath $lines) {" ^
" Write-Host 'Quick sanity search (Greek logos forms) ...' -ForegroundColor Cyan;" ^
" if (Test-Path -LiteralPath '.\QuickSearch.ps1') { try { .\QuickSearch.ps1 '???(??|??|?|??|??|??|???|???)' -Root '.\ResearchBase' | Select-Object -First 1 | Out-Host } catch { } }" ^
" Write-Host 'Refs sanity check (Rom 8:28) ...' -ForegroundColor Cyan;" ^
" if (Test-Path -LiteralPath '.\Search-Refs.ps1') { try { .\Search-Refs.ps1 'Rom 8:28' -Root '.\ResearchBase' | Select-Object -First 1 | Out-Host } catch { } }" ^
"}" ^
"; Write-Host 'Done.' -ForegroundColor Green;", ^
"%~dp0"


endlocal