param([Parameter(Position=0,Mandatory=$true)][string]$Pattern,[string]$Root = (Get-Location).Path)
. "$PSScriptRoot\rb.ps1" -ProjectRoot $Root
Search-RB -Pattern $Pattern