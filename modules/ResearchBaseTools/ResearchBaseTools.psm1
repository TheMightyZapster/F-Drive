function Get-RBConfig {
    # Return something non-empty with an IndexRootAbs property
    $repoRoot = (Get-Location).Path
    $indexDir = Join-Path $repoRoot "ResearchBase\09_datasets_indices"
    if (-not (Test-Path $indexDir)) { New-Item -ItemType Directory $indexDir -Force | Out-Null }

    # You can extend this later with real settings
    [pscustomobject]@{
        Name         = "ResearchBase"
        RepoRoot     = $repoRoot
        IndexRootAbs = (Resolve-Path $indexDir).Path
    }
}

function Get-RBRefRegex {
    # Return a *[regex]* object, not a string, so .IsMatch() works in tests.
    # Start with a simple Bible-ref-like pattern (tune to your needs later):
    # Examples matched: "John 3:16", "1 John 1:9", "Ps 23:1-3"
    return [regex]'(?ix)
        \b
        (?:[1-3]\s*)?[A-Za-z]+        # Book (optionally with leading number)
        \s+
        \d+                           # Chapter
        :
        \d+                           # Verse
        (?:-\d+)?                     # Optional range
        \b
    '
}
