Describe "ResearchBase basics" {
  It "SelfTest script exists" {
    Test-Path "SelfTest-ResearchBase.ps1" | Should -BeTrue
  }

  It "Config loads" {
    . .\rb.ps1     # dot-source if rb.ps1 defines Get-RBConfig
    $cfg = Get-RBConfig
    $cfg | Should -Not -BeNullOrEmpty
  }
}
