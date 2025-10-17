 <#
  Backup-ResearchBase.ps1
  PURPOSE : Zip the entire ResearchBase (optionally excluding indices)
  USAGE   : .\Backup-ResearchBase.ps1 [-Root <ResearchBase path>] [
ExcludeIndices] [-Out <zipPath>]
 #>
 [CmdletBinding()]param([string]$Root,[switch]$ExcludeIndices,[string]$Out)
 $ErrorActionPreference = 'Stop'
 $ProjectRoot = (Get-Location).Path
 if(-not $Root){ $Root = Join-Path $ProjectRoot 'ResearchBase' }
 $ts = Get-Date-Format 'yyyyMMdd_HHmmss'
 if(-not $Out){ $Out = Join-Path $ProjectRoot ("ResearchBase_"+$ts+".zip") }
 Add-Type-AssemblyName System.IO.Compression.FileSystem
 if(Test-Path-LiteralPath $Out){ Remove-Item $Out-Force }
 $zip = [System.IO.Compression.ZipFile]::Open($Out,'Create')
 try{
 $base = Resolve-Path $Root
 $files = Get-ChildItem-LiteralPath $base-Recurse-File-ErrorAction
 SilentlyContinue
 foreach($f in $files){
 if($ExcludeIndices-and ($f.FullName-like '*\\09_datasets_indices\\*')){
 continue }
 $rel = $f.FullName.Substring($base.Path.Length).TrimStart('\\')
 [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,
 $f.FullName, $rel) | Out-Null
 }
 } finally { $zip.Dispose() }
 Write-Host "Backup: $Out"-ForegroundColor Green