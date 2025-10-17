Param(
  [string]$Owner = "TheMightyZapster",
  [string]$Repo,
  [ValidateSet("private","public")] [string]$Visibility = "private",
  [ValidateSet("node","python")] [string]$Stack
)

function Require-Cmd($cmd) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Error "Missing required command: $cmd"
    exit 1
  }
}

Require-Cmd gh
Require-Cmd git

try { gh auth status | Out-Null } catch { Write-Error "Please run 'gh auth login' first."; exit 1 }

if (-not $Repo) { $Repo = Read-Host "Repo name (e.g., my-project)" }
if (-not $Repo) { Write-Error "Repo name is required."; exit 1 }
if (-not $Stack) {
  $choice = Read-Host "Stack to keep (node/python)"
  if ($choice -notin @("node","python")) { Write-Error "Choose node or python"; exit 1 }
  $Stack = $choice
}

# CODEOWNERS already points to @TheMightyZapster

$workflowName = ""
if ($Stack -eq "node") {
  if (Test-Path ".github/workflows/ci-python.yml") { Remove-Item ".github/workflows/ci-python.yml" -Force }
  $workflowName = "build-and-test-node"
} else {
  if (Test-Path ".github/workflows/ci-node.yml") { Remove-Item ".github/workflows/ci-node.yml" -Force }
  $workflowName = "build-and-test-python"
}

if (-not (Test-Path ".git")) {
  git init -b main | Out-Null
  git add .
  git commit -m "chore: bootstrap solo workflow" | Out-Null
}

try {
  gh repo create "$Owner/$Repo" --source=. --remote=origin --push --$Visibility
} catch {
  git remote add origin "https://github.com/$Owner/$Repo.git" 2>$null
  git push -u origin main
}

try {
  gh api -X PUT "repos/$Owner/$Repo/branches/main/protection" `
    -H "Accept: application/vnd.github+json" `
    -F required_linear_history=false `
    -F allow_force_pushes=false `
    -F allow_deletions=false `
    -F enforce_admins=true `
    -F required_pull_request_reviews= `
    -F restrictions= | Out-Null
} catch {}

try {
  gh api -X PUT "repos/$Owner/$Repo/branches/main/protection/required_status_checks" `
    -H "Accept: application/vnd.github+json" `
    -F strict=false `
    -f "checks[0][context]"="$workflowName" | Out-Null
} catch {}

Write-Host "Done! Repo: https://github.com/$Owner/$Repo"
