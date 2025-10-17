[CmdletBinding()]param()
while($true){
  Clear-Host
  Write-Host "ResearchBase — Menu" -ForegroundColor Cyan
  "1) Index (parallel)", "2) Search", "3) Refs", "4) Export", "5) Backup", "6) SelfTest", "0) Exit" | ForEach-Object { Write-Host $_ }
  $c = Read-Host "Select"
  switch($c){
    "1" { & .\rb.ps1 index -parallel; Read-Host "(enter)"; }
    "2" { $p = Read-Host "Regex"; & .\rb.ps1 search $p | more; Read-Host "(enter)"; }
    "3" { $q = Read-Host "Query"; & .\rb.ps1 refs $q | more; Read-Host "(enter)"; }
    "4" { & .\rb.ps1 export -includemanifest; Read-Host "(enter)"; }
    "5" { & .\rb.ps1 backup -excludeindices; Read-Host "(enter)"; }
    "6" { & .\rb.ps1 selftest; Read-Host "(enter)"; }
    "0" { break }
  }
}
