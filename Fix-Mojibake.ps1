$targets = Get-ChildItem -Recurse -Include *.ps1,*.psm1 -File -ErrorAction SilentlyContinue
foreach ($t in $targets) {
  $raw = Get-Content -LiteralPath $t.FullName -Raw -ErrorAction SilentlyContinue
  if (-not $raw) { continue }
  $new = $raw -replace 'Â','' -replace 'â€“','–' -replace 'â€”','—' -replace 'â€˜', '‘' -replace 'â€™','’' -replace 'â€œ','“' -replace 'â€�','”'
  $new = $new -replace '\[[^\]]*-\]','[\u2013-]'
  if ($new != $raw) { Set-Content -LiteralPath $t.FullName -Value $new -Encoding UTF8; Write-Host "Rewrote $($t.FullName)" }
}
Write-Host "Done."