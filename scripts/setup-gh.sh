#!/usr/bin/env bash
set -euo pipefail

# Requirements: gh (GitHub CLI), git
if ! command -v gh >/dev/null 2>&1; then
  echo "Please install GitHub CLI: https://cli.github.com/" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "You must be logged in: run 'gh auth login' first." >&2
  exit 1
fi

OWNER_DEFAULT="TheMightyZapster"
read -rp "GitHub owner (username/org) [${OWNER_DEFAULT}]: " OWNER
OWNER=${OWNER:-$OWNER_DEFAULT}
if [ -z "$OWNER" ]; then echo "Owner is required."; exit 1; fi

read -rp "Repo name (e.g., my-project): " REPO
if [ -z "$REPO" ]; then echo "Repo name is required."; exit 1; fi

read -rp "Visibility (private/public) [private]: " VIS
VIS=${VIS:-private}
if [ "$VIS" != "private" ] && [ "$VIS" != "public" ]; then echo "Visibility must be private or public."; exit 1; fi

echo "Choose stack to keep:"
select STACK in "node" "python"; do
  case $STACK in
    node) KEEP="node"; break;;
    python) KEEP="python"; break;;
    *) echo "Please choose 1 or 2.";;
  esac
done

# CODEOWNERS already points to @TheMightyZapster; no replacement needed

# Keep only one CI workflow
if [ "$KEEP" = "node" ]; then
  rm -f .github/workflows/ci-python.yml
  WORKFLOW_NAME="build-and-test-node"
else
  rm -f .github/workflows/ci-node.yml
  WORKFLOW_NAME="build-and-test-python"
fi

# Initialize git if needed
if [ ! -d .git ]; then
  git init -b main
  git add .
  git commit -m "chore: bootstrap solo workflow"
fi

# Create the repo and push
gh repo create "$OWNER/$REPO" --source=. --remote=origin --push --$VIS || {
  echo "Repo may already exist. Trying to set remote and push..."
  git remote add origin "https://github.com/$OWNER/$REPO.git" || true
  git push -u origin main
}

echo "Setting basic branch protection for 'main'..."
gh api -X PUT "repos/$OWNER/$REPO/branches/main/protection"   -H "Accept: application/vnd.github+json"   -F required_linear_history=false   -F allow_force_pushes=false   -F allow_deletions=false   -F enforce_admins=true   -F required_pull_request_reviews=   -F restrictions= || true

echo "Adding required status check: $WORKFLOW_NAME"
gh api -X PUT "repos/$OWNER/$REPO/branches/main/protection/required_status_checks"   -H "Accept: application/vnd.github+json"   -F strict=false   -f checks[0][context]="$WORKFLOW_NAME" || true

echo "Done! Repo: https://github.com/$OWNER/$REPO"
