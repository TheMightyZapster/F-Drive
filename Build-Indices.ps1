[CmdletBinding()] param(
  [string]$Root,                # optional: path to ResearchBase
  [string]$PdfToText            # optional: path to pdftotext.exe
)

# -------- Root resolution (no $PSScriptRoot, works from file or console) --------
if (-not $Root -or -not (Test-Path -LiteralPath $Root)) {
  $cwd = (Get-Location).Path
  $candidate = Join-Path $cwd 'ResearchBase'
  if (Test-Path -LiteralPath $candidate) { $Root = (Resolve-Path -LiteralPath $candidate).Path }
  else { throw "ResearchBase not found. Run from the folder that CONTAINS ResearchBase\ or pass -Root <path>." }
}

# -------- Output paths --------
$idxDir   = Join-Path $Root '09_datasets_indices'
$fulltext = Join-Path $idxDir 'fulltext.ndjson'
$lines    = Join-Path $idxDir 'lines.ndjson'
$refs     = Join-Path $idxDir 'refs.ndjson'
if (-not (Test-Path -LiteralPath $idxDir)) { New-Item -ItemType Directory -Force -Path $idxDir | Out-Null }
'' | Set-Content -Encoding UTF8 -Path $fulltext
'' | Set-Content -Encoding UTF8 -Path $lines
'' | Set-Content -Encoding UTF8 -Path $refs

# -------- Helpers (PS 5.1 safe) --------
function Get-Sha1Hex {
  param([Parameter(Mandatory)][string]$Path)
  $sha = New-Object System.Security.Cryptography.SHA1Managed
  $fs  = [IO.File]::OpenRead($Path)
  try { ($sha.ComputeHash($fs) | ForEach-Object ToString x2) -join '' } finally { $fs.Dispose(); $sha.Dispose() }
}
function Get-RelativePath {
  param([string]$Base, [string]$Target)
  $uBase   = New-Object System.Uri((Resolve-Path -LiteralPath $Base).Path + [IO.Path]::DirectorySeparatorChar)
  $uTarget = New-Object System.Uri((Resolve-Path -LiteralPath $Target).Path)
  ($uBase.MakeRelativeUri($uTarget).ToString()) -replace '/', '\'
}
function Write-NDJsonLine { param([string]$OutFile,[hashtable]$Obj) ($Obj | ConvertTo-Json -Depth 6 -Compress) | Add-Content -Encoding UTF8 -Path $OutFile }

function Get-TextFromFile {
  param([string]$Path,[string]$PdfToText)
  $ext = ([IO.Path]::GetExtension($Path)).ToLowerInvariant()
  try {
    switch ($ext) {
      '.txt' { return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path }
      '.md'  { return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path }
      '.csv' { return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path }
      '.json'{ return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path }
      '.xml' { return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path }
      '.html'{ return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path }
      '.docx'{
        try {
          $word = New-Object -ComObject Word.Application
          $word.Visible = $false
          $doc = $word.Documents.Open($Path, $false, $true)
          $txt = $doc.Content.Text
          $doc.Close(); $word.Quit()
          return $txt
        } catch { Write-Verbose "DOCX extract skipped: $_"; return $null }
      }
      '.pdf' {
        if ($PdfToText -and (Test-Path -LiteralPath $PdfToText)) {
          $tmp = [IO.Path]::GetTempFileName()
          $psi = New-Object System.Diagnostics.ProcessStartInfo
          $psi.FileName = $PdfToText
          $psi.Arguments = ' -q -nopgbrk -enc UTF-8 -layout ' + '"' + $Path + '" ' + '"' + $tmp + '"'
          $psi.UseShellExecute = $false
          $psi.RedirectStandardOutput = $true
          $p = [Diagnostics.Process]::Start($psi); $p.WaitForExit()
          $out = Get-Content -Raw -Encoding UTF8 -LiteralPath $tmp
          Remove-Item $tmp -Force -ErrorAction SilentlyContinue
          return $out
        } else { Write-Verbose "PDF skipped (no pdftotext): $Path"; return $null }
      }
      default { return $null }
    }
  } catch { Write-Verbose "Read failed: $Path :: $_"; return $null }
}

# Bible ref regex (e.g., Ps 1:2–3)
$book  = '(Gen|Exod|Lev|Num|Deut|Josh|Judg|Ruth|1\s?Sam|2\s?Sam|1\s?Kgs|2\s?Kgs|1\s?Chr|2\s?Chr|Ezra|Neh|Esth|Job|Ps|Prov|Eccl|Song|Isa|Jer|Lam|Ezek|Dan|Hos|Joel|Amos|Obad|Jonah|Mic|Nah|Hab|Zeph|Hag|Zech|Mal|Matt|Mark|Luke|John|Acts|Rom|1\s?Cor|2\s?Cor|Gal|Eph|Phil|Col|1\s?Thess|2\s?Thess|1\s?Tim|2\s?Tim|Titus|Phlm|Heb|Jas|1\s?Pet|2\s?Pet|1\s?John|2\s?John|3\s?John|Jude|Rev)'
$refRe = [regex]::new("\b$book\s+\d{1,3}:\d{1,3}(?:[-–]\d{1,3})?\b", 'IgnoreCase')

# -------- Walk & index --------
$files = Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Length -lt 300MB } |
  Where-Object { $_.Extension -match '\.(txt|md|csv|json|xml|html|docx|pdf)$' }

$sw = [Diagnostics.Stopwatch]::StartNew(); $cnt = 0
foreach ($f in $files) {
  $txt = Get-TextFromFile -Path $f.FullName -PdfToText $PdfToText
  $cnt++
  if ($txt) {
    $meta = [ordered]@{
      path   = $f.FullName
      rel    = Get-RelativePath -Base $Root -Target $f.FullName
      bytes  = $f.Length
      mtime  = $f.LastWriteTimeUtc.ToString('o')
      ext    = $f.Extension.ToLowerInvariant()
      sha1   = Get-Sha1Hex $f.FullName
      sample = ($txt.Substring(0, [Math]::Min(400, $txt.Length))).Trim()
    }
    Write-NDJsonLine -OutFile $fulltext -Obj $meta

    $ln = 0
    foreach ($line in ($txt -split "`r?`n")) {
      $ln++
      Write-NDJsonLine -OutFile $lines -Obj @{ path = $f.FullName; ln = $ln; text = $line }
      foreach ($m in $refRe.Matches($line)) {
        Write-NDJsonLine -OutFile $refs -Obj @{ path = $f.FullName; ln = $ln; ref = $m.Value; text = $line }
      }
    }
  }
}
$sw.Stop()
Write-Host ("Indexed {0} files in {1} ms" -f $cnt, $sw.ElapsedMilliseconds) -ForegroundColor Green
Write-Host ("Output:`n - {0}`n - {1}`n - {2}" -f $fulltext,$lines,$refs)

# -------- QuickSearch helper in current folder (safe even in console) --------
$qs = Join-Path (Get-Location).Path 'QuickSearch.ps1'
$qsBody = @"
param([Parameter(Mandatory=`$true)][string]`$Query,[string]`$Root)
if (-not `$Root) { `$Root = '$Root' }
`$idx = Join-Path `$Root '09_datasets_indices/lines.ndjson'
if (-not (Test-Path `$idx)) { Write-Error "Index not found: `$idx. Run Build-Indices.ps1 first."; exit 1 }
Get-Content -Encoding UTF8 -LiteralPath `$idx | Where-Object { `$_ -match `$Query } | ForEach-Object {
  `$o = `$_ | ConvertFrom-Json
  "{0}:{1}: {2}" -f `$o.path,`$o.ln,`$o.text
}
"@
Set-Content -Encoding UTF8 -Path $qs -Value $qsBody
Write-Host ("QuickSearch helper created: {0}" -f $qs) -ForegroundColor Cyan
