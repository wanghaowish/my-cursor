#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${PICGO_DEPLOY_KEY:-}" ]]; then
  echo "PICGO_DEPLOY_KEY not set, skip picGo SSH setup"
  exit 0
fi
mkdir -p ~/.ssh
chmod 700 ~/.ssh
printf '%s\n' "$PICGO_DEPLOY_KEY" > ~/.ssh/picgo_deploy
chmod 600 ~/.ssh/picgo_deploy
if ! grep -q "Host github-picgo" ~/.ssh/config 2>/dev/null; then
  cat >> ~/.ssh/config <<'EOF'
Host github-picgo
  HostName github.com
  User git
  IdentityFile ~/.ssh/picgo_deploy
  IdentitiesOnly yes
EOF
  chmod 600 ~/.ssh/config
fi
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null || true
echo "picGo SSH deploy key configured"
