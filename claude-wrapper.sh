#!/bin/bash
# Claude Code Wrapper
# 自动检测版本变化并修改后启动 claude

VERSIONS_DIR="$HOME/.local/share/claude/versions"
MOD_MARKER="$HOME/.claude/.buddy-mod-applied"
SCRIPT_DIR="$HOME/Desktop/split-repos/claude-code-buddy-mod"

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)

if [[ -z "$CURRENT_VER" ]]; then
    # 未安装，直接启动原版 claude
    exec claude "$@"
fi

# 检查是否需要修改
if [[ -f "$MOD_MARKER" ]] && [[ "$(cat "$MOD_MARKER")" == "$CURRENT_VER" ]]; then
    # 已修改，直接启动
    exec claude "$@"
fi

# 需要修改，静默执行
echo "⚡ 检测到版本更新，正在应用 Buddy 修改..."

# 执行修改脚本（静默模式）
"$SCRIPT_DIR/make-legendary.sh" --quiet 2>/dev/null

# 启动 claude
exec claude "$@"