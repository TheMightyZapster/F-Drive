 <#
  Find-Poppler.ps1
  PURPOSE : Locate pdftotext.exe on the system (returns full path or $null)
  USAGE   : .\Find-Poppler.ps1 [-PdfToText <path>] [-Quiet]
 #>
 [CmdletBinding()]param(
 [string]$PdfToText,
 [switch]$Quiet
 )
 function Write-Info($m){ if(-not $Quiet){ Write-Host $m-ForegroundColor
 Cyan } }
 # If explicit path supplied
 if($PdfToText){ if(Test-Path-LiteralPath $PdfToText){ Write-Output (Resolve
Path $PdfToText).Path; return } }
 $probes = @(
 "C:\\Program Files\\poppler-*\\Library\\bin\\pdftotext.exe",
 "C:\\Program Files\\poppler-*\\bin\\pdftotext.exe",
 "$env:LOCALAPPDATA\\Programs\\poppler*\\Library\\bin\\pdftotext.exe",
 "$env:LOCALAPPDATA\\Programs\\poppler*\\bin\\pdftotext.exe",
 "C:\\tools\\poppler\\bin\\pdftotext.exe",
 (Join-Path (Get-Location).Path 'tools\\poppler\\bin\\pdftotext.exe')
 )
 foreach($p in $probes){ $hit = Get-ChildItem $p-ErrorAction SilentlyContinue |
 Select-Object-First 1; if($hit){ Write-Output $hit.FullName; return } }
 # Last chance: shallow recursive probe under common roots (fast bail‑out)
 $roots = @("C:\\Program Files","C:\\Program Files (x86)","$env:LOCALAPPDATA\
 \Programs")
 foreach($r in $roots){ if(Test-Path $r){ $found = Get-ChildItem-Path $r-Filter
 'pdftotext.exe'-Recurse-ErrorAction SilentlyContinue | Select-Object-First 1;
 if($found){ Write-Output $found.FullName; return } } }
 1
Write-Info "pdftotext.exe not found."; return $null