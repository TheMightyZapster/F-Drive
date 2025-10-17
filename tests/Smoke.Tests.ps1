Import-Module (Join-Path (Get-Location).Path "modules\ResearchBaseTools\ResearchBaseTools.psd1") -Force
Describe "ResearchBase Smoke" {
  It "Loads config" { $cfg = Get-RBConfig; $cfg.IndexRootAbs | Should -Not -BeNullOrEmpty }
  It "Builds ref regex" { $rx = Get-RBRefRegex; ($rx.IsMatch("Rom 8:28")) | Should -BeTrue }
}
