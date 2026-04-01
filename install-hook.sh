#!/bin/bash
# 安装自动检测 hook
# 在每次打开终端时自动检测版本变化

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

MOD_DIR="$HOME/Desktop/split-repos/claude-code-buddy-mod"
SHELL_RC=""

# 检测当前 shell
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "未找到 .zshrc 或 .bashrc"
    exit 1
fi

echo -e "${CYAN}安装自动检测 Hook${NC}"
echo ""

# 添加检测函数到 shell rc
HOOK_CODE='
# Claude Code Buddy 自动检测
claude_buddy_check() {
    local VERSIONS_DIR="$HOME/.local/share/claude/versions"
    local MOD_MARKER="$HOME/.claude/.buddy-mod-applied"
    local CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E "^2\.[0-9]+\.[0-9]+$" | head -1)

    if [[ -n "$CURRENT_VER" ]] && [[ ! -f "$MOD_MARKER" ]] || [[ "$(cat "$MOD_MARKER" 2>/dev/null)" != "$CURRENT_VER" ]]; then
        echo ""
        echo "⚠️  Claude Code Buddy 需要更新修改"
        echo "    版本: $(cat "$MOD_MARKER" 2>/dev/null || echo "未修改") → $CURRENT_VER"
        echo "    运行: ~/Desktop/split-repos/claude-code-buddy-mod/make-legendary.sh"
        echo ""
    fi
}

# 每次打开终端时检测（可选，去掉注释启用）
# claude_buddy_check

# 或者创建 claude 别名，运行前检测
alias claude-mod-check="claude_buddy_check && claude"
'

# 检查是否已安装
if grep -q "claude_buddy_check" "$SHELL_RC" 2>/dev/null; then
    echo -e "${GREEN}已安装，跳过${NC}"
else
    echo "添加到 $SHELL_RC ..."
    echo "$HOOK_CODE" >> "$SHELL_RC"
    echo -e "${GREEN}✓ 已安装${NC}"
fi

echo ""
echo -e "${CYAN}使用方式:${NC}"
echo ""
echo "方式 1: 手动检测"
echo "  运行: claude_buddy_check"
echo ""
echo "方式 2: 启动时自动检测"
echo "  编辑 $SHELL_RC"
echo "  取消注释: # claude_buddy_check"
echo ""
echo "方式 3: 使用别名"
echo "  运行: claude-mod-check  (检测 + 启动 claude)"
echo ""
echo -e "${YELLOW}生效: source $SHELL_RC 或重启终端${NC}"