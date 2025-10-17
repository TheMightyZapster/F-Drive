function Get-RBConfig {
  # TODO: load real config; stub returns a non-empty hashtable for now
  @{ Name = "ResearchBase"; Created = (Get-Date) }
}

function Get-RBRefRegex {
  # TODO: build real regex; stub returns a simple pattern
  return '^[A-Z]+\.\d+$'
}
