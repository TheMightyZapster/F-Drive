<#
  Convert-PDFs.ps1
  PURPOSE : Batch extract .txt from all PDFs under ResearchBase (non
destructive)
  USAGE   : .\Convert-PDFs.ps1 [-Root <ResearchBase path>] [-Force]
 #>
 [CmdletBinding()]param([string]$Root,[switch]$Force)
 $ErrorActionPreference = 'Stop'
 $ProjectRoot = (Get-Location).Path
 if(-not $Root){ $Root = Join-Path $ProjectRoot 'ResearchBase' }
 $find = Join-Path $ProjectRoot 'Find-Poppler.ps1'
 $pdftotext = if(Test-Path $find){ & $find-Quiet } else { $null }
 if(-not $pdftotext){ Write-Warning "pdftotext.exe not found. Run Install
Poppler.ps1 or pass -PdfToText in Setup."; exit 1 }
 3
$files = Get-ChildItem-LiteralPath $Root-Recurse-File-Filter *.pdf
ErrorAction SilentlyContinue
 foreach($f in $files){
 $txt = [System.IO.Path]::ChangeExtension($f.FullName,'.txt')
 if((Test-Path-LiteralPath $txt)-and-not $Force){ Write-Host
 "Skip (exists): $txt"-ForegroundColor DarkGray; continue }
 & $pdftotext-layout-enc UTF-8-- "$($f.FullName)" "$txt" 2>$null
 if(Test-Path-LiteralPath $txt){ Write-Host "OK: $txt"-ForegroundColor
 Green } else { Write-Warning "Failed: $($f.FullName)" }
 }
 Write-Host "Done."-ForegroundColor Green