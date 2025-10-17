#!/usr/bin/env bash
set -euo pipefail
if [ $# -ne 1 ]; then echo "Usage: $0 vX.Y.Z" >&2; exit 1; fi
TAG="$1"
git fetch origin || true
git switch main || git checkout -B main
git pull --ff-only || true
git tag -s "$TAG" -m "Release $TAG" || git tag "$TAG" -m "Release $TAG"
git push --follow-tags origin main
echo "Pushed tag $TAG"
