#!/bin/bash
# 安装 Claude 自动修改别名
# 使用 claude-auto 命令，版本更新后自动修改并启动

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$HOME/Desktop/split-repos/claude-code-buddy-mod"
SHELL_RC=""

# 检测 shell
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "未找到 shell 配置文件"
    exit 1
fi

echo -e "${CYAN}安装 Claude Buddy 自动修改别名${NC}"
echo ""
echo "安装后可使用："
echo "  claude       - 原版命令（不自动修改）"
echo "  claude-auto  - 自动检测版本变化，修改后启动"
echo ""

# 添加别名
ALIAS_CODE="
# Claude Code Buddy 自动修改别名
alias claude-auto='$SCRIPT_DIR/claude-wrapper.sh'
"

if grep -q "alias claude-auto" "$SHELL_RC" 2>/dev/null; then
    echo -e "${GREEN}已安装别名${NC}"
else
    echo "添加别名到 $SHELL_RC ..."
    echo "$ALIAS_CODE" >> "$SHELL_RC"
    echo -e "${GREEN}✓ 安装成功${NC}"
fi

echo ""
echo -e "${YELLOW}生效方式:${NC}"
echo "  source $SHELL_RC"
echo "  或重启终端"
echo ""
echo -e "${CYAN}使用方式:${NC}"
echo "  claude-auto   # 版本更新后自动修改并启动"
echo "  claude        # 原版命令"
echo ""
echo -e "${GREEN}特点:${NC}"
echo "  • 不每次启动检查"
echo "  • 只在版本变化时自动修改"
echo "  • 官方新功能自动享受（species/hats/stats）"