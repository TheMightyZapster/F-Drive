 <#
  Clean-Indices.ps1
  PURPOSE : Truncate fulltext/lines/refs NDJSON files safely
  USAGE   : .\Clean-Indices.ps1 [-Root <ResearchBase path>]
 #>
 [CmdletBinding()]param([string]$Root)
 $ErrorActionPreference = 'Stop'
 $ProjectRoot = (Get-Location).Path
 if(-not $Root){ $Root = Join-Path $ProjectRoot 'ResearchBase' }
 2
$idx = Join-Path $Root '09_datasets_indices'
 $targets = @('fulltext.ndjson','lines.ndjson','refs.ndjson') | ForEach-Object{
 Join-Path $idx $_ }
 foreach($t in $targets){ if(Test-Path-LiteralPath $t){ '' | Set-Content-Path
 $t-Encoding UTF8; Write-Host "Truncated: $t"-ForegroundColor Yellow } }
 Write-Host "Done."-ForegroundColor Green