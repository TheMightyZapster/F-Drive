Describe "Repo sanity" {
  It "README exists" { Test-Path "README.md" | Should -BeTrue }
}
