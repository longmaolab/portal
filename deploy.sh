#!/usr/bin/env bash
# 一键部署 portal:commit + push + 服务器 git pull
# 用法:./deploy.sh "commit message"

set -e

cd "$(dirname "$0")"

SERVER_HOST="${PORTAL_SERVER_HOST:-root@207.148.98.206}"
SERVER_PATH="${PORTAL_SERVER_PATH:-/opt/games/portal}"
PUBLIC_URL="https://game.boobank.com/"

MSG="${1:-Update portal}"

# ---- 1. 提交本地改动 ----
git add -A
if git diff --cached --quiet; then
  echo "(没有新改动,跳过 commit)"
else
  git commit -m "$MSG"
fi

# ---- 2. 推到 GitHub ----
echo ""
echo "→ 推送到 GitHub..."
git push

# ---- 3. 服务器拉取 ----
echo ""
echo "→ 通知服务器拉取 ..."
ssh "$SERVER_HOST" "cd '$SERVER_PATH' && git pull --rebase"

# ---- 4. done ----
echo ""
echo "✅ 部署完成,立即生效:"
echo "   $PUBLIC_URL"
