 <#
  Export-Index.ps1
  PURPOSE : Zip the indices (and optional manifest.csv) with timestamp
  USAGE   : .\Export-Index.ps1 [-Root <ResearchBase path>] [-IncludeManifest] [
Out <zipPath>]
 #>
 [CmdletBinding()]param([string]$Root,[switch]$IncludeManifest,[string]$Out)
 $ErrorActionPreference = 'Stop'
 $ProjectRoot = (Get-Location).Path
 if(-not $Root){ $Root = Join-Path $ProjectRoot 'ResearchBase' }
 $idx = Join-Path $Root '09_datasets_indices'
 if(-not (Test-Path-LiteralPath $idx)){ throw "Indices folder not found: $idx" }
 $ts = Get-Date-Format 'yyyyMMdd_HHmmss'
 if(-not $Out){ $Out = Join-Path $ProjectRoot ("indices_"+$ts+".zip") }
 Add-Type-AssemblyName System.IO.Compression.FileSystem
 if(Test-Path-LiteralPath $Out){ Remove-Item $Out-Force }
 $zip = [System.IO.Compression.ZipFile]::Open($Out,'Create')
 try{
 [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join
Path $idx 'fulltext.ndjson'), '09_datasets_indices/fulltext.ndjson')
 [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join
Path $idx 'lines.ndjson'),
 '09_datasets_indices/lines.ndjson')
 [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join
Path $idx 'refs.ndjson'),
 '09_datasets_indices/refs.ndjson')
 if($IncludeManifest-and (Test-Path (Join-Path $Root 'manifest.csv'))){
 [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join
Path $Root 'manifest.csv'), 'manifest.csv')
 4
}
 } finally { $zip.Dispose() }
 Write-Host "Wrote: $Out"-ForegroundColor Green