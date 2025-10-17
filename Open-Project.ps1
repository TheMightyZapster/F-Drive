$ProjectRoot = (Get-Location).Path
Import-Module -Force (Join-Path $ProjectRoot "modules\ResearchBaseTools\ResearchBaseTools.psd1")
$cfg = Get-RBConfig
$idx = Join-Path $cfg.IndexRootAbs "09_datasets_indices"
foreach($p in @($ProjectRoot,$cfg.IndexRootAbs,$idx)){ if(Test-Path $p){ ii $p } }
