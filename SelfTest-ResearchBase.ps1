 <#
  SelfTest-ResearchBase.ps1
  PURPOSE : Seed a tiny file, reindex, then sanity‑check QuickSearch + Search
Refs
 #>
 [CmdletBinding()]param([string]$Root)
 $ProjectRoot = (Get-Location).Path
 if(-not $Root){ $Root = Join-Path $ProjectRoot 'ResearchBase' }
 $seed = Join-Path $Root '00_texts\\SelfTest.txt'
 @"
 Paul writes of love (ἀγάπη) and hope.
 Rom 8:28 — We know that all things work together for good to those who love God.
 "@ | Set-Content-Path $seed-Encoding UTF8
 .\Reindex.ps1 | Out-Null
 Write-Host "— QuickSearch 'ἀγάπη' —"-ForegroundColor Cyan
 if(Test-Path .\QuickSearch.ps1){ .\QuickSearch.ps1 'ἀγάπη'-Root $Root | Select
Object-First 3 | Out-Host }
 Write-Host "— Search-Refs 'Rom 8:28' —"-ForegroundColor Cyan
 if(Test-Path .\Search-Refs.ps1){ .\Search-Refs.ps1 'Rom 8:28'-Root $Root |
 Select-Object-First 3 | Out-Host }
 Write-Host "Self-test complete."-ForegroundColor Green