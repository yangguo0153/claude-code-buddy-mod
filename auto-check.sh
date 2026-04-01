#!/bin/bash
# Claude Code Buddy 自动检测脚本
# 建议：添加到 ~/.zshrc 或 ~/.bashrc 的 PROMPT_COMMAND 或别名

VERSIONS_DIR="$HOME/.local/share/claude/versions"
MOD_MARKER="$HOME/.claude/.buddy-mod-applied"
MOD_SCRIPT="$HOME/Desktop/split-repos/claude-code-buddy-mod/make-legendary.sh"

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)

if [[ -z "$CURRENT_VER" ]]; then
    exit 0
fi

# 检查是否需要重新修改
if [[ ! -f "$MOD_MARKER" ]] || [[ "$(cat "$MOD_MARKER")" != "$CURRENT_VER" ]]; then
    echo ""
    echo "⚠️  Claude Code Buddy 需要更新修改"
    echo "    版本变化: $(cat "$MOD_MARKER" 2>/dev/null || echo '未修改') → $CURRENT_VER"
    echo "    运行: $MOD_SCRIPT"
    echo ""
fi