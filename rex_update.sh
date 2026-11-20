#!/bin/bash
# Rex 的 Agent Reach 安全版更新流程（rex-secure 分支），说明见 REX_SECURITY.md
#   ./rex_update.sh            拉上游 → 同步 fork 的 main → 把安全补丁接到新版上，然后停下等复查
#   ./rex_update.sh --install  复查通过后：安装到 ~/.agent-reach-venv 并推送 rex-secure
set -euo pipefail
cd "$(dirname "$0")"
PY=~/.agent-reach-venv/bin/python

if [[ "${1:-}" == "--install" ]]; then
  "$PY" -m pip install -q --disable-pip-version-check --force-reinstall --no-deps .
  "$PY" -m pip install -q --disable-pip-version-check .
  git push origin rex-secure --force-with-lease
  agent-reach doctor >/dev/null && echo "已安装，并推送 rex-secure"
  exit 0
fi

git fetch upstream --tags
OLD=$(git merge-base rex-secure upstream/main)
git checkout -q main && git merge -q --ff-only upstream/main && git push -q origin main
git checkout -q rex-secure && git rebase upstream/main
echo "上游新增改动（让 Claude 做安全复查）：$OLD..upstream/main"
git diff --stat "$OLD" upstream/main | tail -5
grep -rn "REX-SECURE" agent_reach | cut -c1-100
echo "复查通过后运行：./rex_update.sh --install"
