 <#
  Update-Manifest.ps1
  PURPOSE : Append/update rows in ResearchBase\manifest.csv
 7
  USAGE   : Add a single row:  .\Update-Manifest.ps1 -Category Text -Author 
'Danker' -Title 'BDAG' -Year 2000 -Language grc -Filename 'path\\file.pdf'
 #>
 [CmdletBinding()]param(
 [Parameter(Mandatory=$true)]
 [ValidateSet('Text','Lexicon','Grammar','Commentary','Journal','Notes','Dataset')]
 [string]$Category,
 [Parameter(Mandatory=$true)][string]$Author,
 [Parameter(Mandatory=$true)][string]$Title,
 [string]$Series_or_Edition,
 [int]$Year,
 [string]$Language,
 [string]$Scope_or_Notes,
 [Parameter(Mandatory=$true)][string]$Filename,
 [string]$Root
 )
 $ProjectRoot = (Get-Location).Path
 if(-not $Root){ $Root = Join-Path $ProjectRoot 'ResearchBase' }
 $manifest = Join-Path $Root 'manifest.csv'
 if(-not (Test-Path $manifest)){
 'category,author,title,series_or_edition,year,language,scope_or_notes,filename'
 | Set-Content-Path $manifest-Encoding UTF8
 }
 $line = (
 @($Category,$Author,$Title,$Series_or_Edition,$Year,$Language,$Scope_or_Notes,
 $Filename) |
 ForEach-Object { ($_-replace '"','""') } |
 ForEach-Object { '"' + $_ + '"' }
 )-join ','
 Add-Content-Path $manifest-Value $line-Encoding UTF8
 Write-Host "Added to manifest: $Title"-ForegroundColor Green