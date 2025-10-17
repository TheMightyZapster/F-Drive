[CmdletBinding()] param(
  [string]$Root,
  [string]$PdfToText,
  [switch]$BypassPolicy
)
$here = (Get-Location).Path
$build = Join-Path $here 'Setup-ResearchBase.ps1'   # we leverage the integrated indexer with -NoOpen
$open  = Join-Path $here 'Open-Indices.ps1'
function Resolve-Root { param([string]$r) if ($r -and (Test-Path -LiteralPath $r)) { return (Resolve-Path -LiteralPath $r).Path }
  $cand = Join-Path (Get-Location).Path 'ResearchBase'; if (Test-Path -LiteralPath $cand) { return (Resolve-Path -LiteralPath $cand).Path }
  throw 'Could not locate ResearchBase. Run from project root or pass -Root.' }
$rootResolved = Resolve-Root -r $Root

$args = @('-File', $build, '-Root', $rootResolved, '-NoOpen')
if ($PdfToText) { $args += @('-PdfToText', $PdfToText) }

if ($BypassPolicy) {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass @args
} else {
  & powershell.exe -NoProfile @args
}

if ($LASTEXITCODE -ne  -and $LASTEXITCODE -ne 0) { Write-Warning "Setup/Index returned exit code $LASTEXITCODE" }
& $open -Root $rootResolved
