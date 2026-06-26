#!/usr/bin/env bash
# Push industry map PNG to picGo img/cursor/ via deploy key.
# Usage: push-to-picgo.sh <行业名称> [local-png-path]
# Example: push-to-picgo.sh PCB /opt/cursor/artifacts/assets/PCB-map-uhd.png
set -euo pipefail

INDUSTRY="${1:?行业名称 required}"
PNG="${2:-/opt/cursor/artifacts/assets/${INDUSTRY}-map-uhd.png}"
REMOTE="img/cursor/${INDUSTRY}-map-uhd.png"
REPO_DIR="${PICGO_REPO_DIR:-/tmp/picGo}"

if [[ ! -f "$PNG" ]]; then
  echo "PNG not found: $PNG" >&2
  exit 1
fi

bash /workspace/.cursor/setup-picgo-ssh.sh 2>/dev/null || true

if [[ ! -d "$REPO_DIR/.git" ]]; then
  git clone git@github-picgo:wanghaowish/picGo.git "$REPO_DIR"
else
  git -C "$REPO_DIR" pull --rebase origin main
fi

mkdir -p "$REPO_DIR/img/cursor"
cp "$PNG" "$REPO_DIR/$REMOTE"

cd "$REPO_DIR"
git config user.email "cursor-agent@users.noreply.github.com"
git config user.name "Cursor Agent"
git add "$REMOTE"
if git diff --cached --quiet; then
  echo "No changes for $REMOTE"
else
  git commit -m "feat(cursor): update ${INDUSTRY} industry chain map"
  git push origin main
fi

echo "https://raw.githubusercontent.com/wanghaowish/picGo/main/${REMOTE}"
