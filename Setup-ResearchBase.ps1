param([string]$ProjectRoot = (Get-Location).Path,[switch]$SkipPopplerInstall)
Import-Module -Force (Join-Path $ProjectRoot 'modules\ResearchBaseTools\ResearchBaseTools.psd1')
$PdfToText = Find-RBPoppler
if (-not $PdfToText -and -not $SkipPopplerInstall) { $PdfToText = Ensure-RBPoppler }
if (-not $PdfToText) { Write-Warning 'pdftotext not available; PDFs will be skipped.' }
Index-RB -ProjectRoot $ProjectRoot -PdfToText $PdfToText
Write-Host 'Setup & Index complete.' -ForegroundColor Green