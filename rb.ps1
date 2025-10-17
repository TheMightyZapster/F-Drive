param([string]$ProjectRoot = (Get-Location).Path)
$modPath = Join-Path $ProjectRoot 'modules\ResearchBaseTools\ResearchBaseTools.psd1'
Import-Module -Force $modPath
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8