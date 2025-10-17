param([Parameter(Position=0,Mandatory=$true)][string]$Query,[switch]$Regex,[string]$Root = (Get-Location).Path)
. "$PSScriptRoot\rb.ps1" -ProjectRoot $Root
Search-RBRefs -Query $Query -Regex:$Regex