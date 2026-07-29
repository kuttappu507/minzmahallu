#!/usr/bin/env bash
# =============================================================================
# download-latest.sh — Download the latest MMS.exe build from GitHub Actions
#
# Usage:
#   ./build-scripts/download-latest.sh
#
# Requires:
#   - GH_TOKEN env var (PAT with `actions: read` scope)
#   - OR ~/.gh_token file containing the PAT
#   - OR `gh` CLI installed and authenticated
# =============================================================================
set -euo pipefail

OWNER="kuttappu507"
REPO="minzmahallu"
WORKFLOW="build-windows.yml"
ARTIFACT_NAME="MMS-portable-windows-x64"

# Resolve token
GH_TOKEN="${GH_TOKEN:-}"
if [ -z "$GH_TOKEN" ] && [ -f "$HOME/.gh_token" ]; then
    GH_TOKEN="$(cat "$HOME/.gh_token" | tr -d '[:space:]')"
fi

# Try gh CLI first (easiest)
if command -v gh >/dev/null 2>&1; then
    if [ -n "$GH_TOKEN" ]; then
        export GH_TOKEN
    fi
    echo "Using gh CLI to download latest $ARTIFACT_NAME..."
    gh run download \
        --repo "${OWNER}/${REPO}" \
        --name "$ARTIFACT_NAME" \
        --dir "./mms-download" \
        "$(gh run list --repo "${OWNER}/${REPO}" --workflow="$WORKFLOW" --status success --limit 1 --json databaseId -q '.[0].databaseId')"
    echo ""
    echo "Downloaded to: ./mms-download/"
    ls -lh ./mms-download/
    exit 0
fi

# Fall back to curl + REST API
if [ -z "$GH_TOKEN" ]; then
    echo "ERROR: Need GH_TOKEN or gh CLI to download artifacts."
    exit 1
fi

echo "Fetching latest successful run for workflow $WORKFLOW..."
RUN_ID=$(curl -sS -H "Authorization: token $GH_TOKEN" \
    "https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows/${WORKFLOW}/runs?status=success&per_page=1" \
    | python3 -c "import sys, json; print(json.load(sys.stdin)['workflow_runs'][0]['id'])")

echo "Latest run ID: $RUN_ID"
echo "Fetching artifact list for run $RUN_ID..."
ARTIFACT_URL=$(curl -sS -H "Authorization: token $GH_TOKEN" \
    "https://api.github.com/repos/${OWNER}/${REPO}/actions/runs/${RUN_ID}/artifacts" \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
for a in data['artifacts']:
    if a['name'] == '${ARTIFACT_NAME}':
        print(a['archive_download_url'])
        break
")

if [ -z "$ARTIFACT_URL" ]; then
    echo "ERROR: Artifact $ARTIFACT_NAME not found in run $RUN_ID"
    exit 1
fi

echo "Downloading $ARTIFACT_NAME.zip..."
mkdir -p ./mms-download
curl -L -H "Authorization: token $GH_TOKEN" \
    -o "./mms-download/${ARTIFACT_NAME}.zip" \
    "$ARTIFACT_URL"

echo ""
echo "Downloaded to: ./mms-download/${ARTIFACT_NAME}.zip"
ls -lh "./mms-download/${ARTIFACT_NAME}.zip"
echo ""
echo "Unzip with: unzip ./mms-download/${ARTIFACT_NAME}.zip -d ./mms-download/"
