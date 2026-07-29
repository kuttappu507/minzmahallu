#!/usr/bin/env bash
# =============================================================================
# github-upload.sh — One-click commit + push to GitHub
#
# Usage:
#   ./build-scripts/github-upload.sh "your commit message"
#
# Requires:
#   - A GitHub Personal Access Token (PAT) with `repo` scope
#   - Set the PAT as env var:  export GH_TOKEN=ghp_xxxxxxxxxxxxxxxx
#   - Or: write the PAT to ~/.gh_token  (chmod 600 ~/.gh_token)
#
# First run only: also sets up the git remote if missing.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="$(cd "$SCRIPT_DIR/.." && pwd)"
REMOTE_URL="https://github.com/kuttappu507/minzmahallu.git"
OWNER="kuttappu507"
REPO="minzmahallu"

cd "$PROJ"

# ---------------------------------------------------------------------------
# 1. Resolve the GitHub PAT
# ---------------------------------------------------------------------------
GH_TOKEN="${GH_TOKEN:-}"
if [ -z "$GH_TOKEN" ] && [ -f "$HOME/.gh_token" ]; then
    GH_TOKEN="$(cat "$HOME/.gh_token" | tr -d '[:space:]')"
fi

if [ -z "$GH_TOKEN" ]; then
    echo "ERROR: No GitHub PAT found."
    echo ""
    echo "Create one at: https://github.com/settings/tokens (classic, with 'repo' scope)"
    echo "Then either:"
    echo "  export GH_TOKEN=ghp_xxxxxxxxxxxx"
    echo "  # or"
    echo "  echo 'ghp_xxxxxxxxxxxx' > ~/.gh_token && chmod 600 ~/.gh_token"
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Initialize git if needed
# ---------------------------------------------------------------------------
if [ ! -d .git ]; then
    git init
    git config user.email "builder@mms.local"
    git config user.name "MMS Builder"
    git branch -M main
fi

# Inject the PAT into the remote URL (so push works non-interactively)
PAT_URL="https://x-access-token:${GH_TOKEN}@github.com/${OWNER}/${REPO}.git"
git remote remove origin 2>/dev/null || true
git remote add origin "$PAT_URL"

# ---------------------------------------------------------------------------
# 3. Stage + commit
# ---------------------------------------------------------------------------
COMMIT_MSG="${1:-Build MMS.exe with new emerald theme + CI workflow}"
git add -A
git status --short

if git diff --cached --quiet; then
    echo "Nothing to commit — working tree clean."
else
    git commit -m "$COMMIT_MSG"
fi

# ---------------------------------------------------------------------------
# 4. Push
# ---------------------------------------------------------------------------
echo ""
echo "Pushing to GitHub..."
git push -u origin main || git push -u origin main --force-with-lease

# ---------------------------------------------------------------------------
# 5. Report next steps
# ---------------------------------------------------------------------------
echo ""
echo "============================================================"
echo " Push complete!"
echo "============================================================"
echo ""
echo " Repository:  https://github.com/${OWNER}/${REPO}"
echo ""
echo " GitHub Actions build will start automatically."
echo " Watch it at: https://github.com/${OWNER}/${REPO}/actions"
echo ""
echo " When the build finishes (~10 min), download the artifact:"
echo "   https://github.com/${OWNER}/${REPO}/actions/workflows/build-windows.yml"
echo ""
echo " To create a Release with the binary attached:"
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0"
echo "   # Release appears at: https://github.com/${OWNER}/${REPO}/releases"
echo ""
