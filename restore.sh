#!/bin/bash
# 恢复原版

set -e

VERSIONS_DIR="$HOME/.local/share/claude/versions"
CONFIG_FILE="$HOME/.claude.json"
MOD_MARKER="$HOME/.claude/.buddy-mod-applied"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}恢复 Claude Code 原版${NC}"
echo ""

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"
BACKUP="$VERSIONS_DIR/${CURRENT_VER}.original"
CONFIG_BACKUP="$CONFIG_FILE.bak"

if [[ ! -f "$BACKUP" ]]; then
    echo -e "${RED}错误: 未找到备份文件${NC}"
    exit 1
fi

echo "恢复原版二进制..."
cp "$BACKUP" "$CLAUDE_BIN"

echo "清除扩展属性..."
xattr -c "$CLAUDE_BIN" 2>/dev/null || true

echo "应用签名..."
codesign -s - "$CLAUDE_BIN" 2>/dev/null

# 删除修改标记
rm -f "$MOD_MARKER"

# 询问恢复宠物配置
if [[ -f "$CONFIG_BACKUP" ]]; then
    echo ""
    read -p "恢复原宠物配置? [y/N]: " restore
    if [[ "$restore" == "y" || "$restore" == "Y" ]]; then
        cp "$CONFIG_BACKUP" "$CONFIG_FILE"
        echo -e "${GREEN}✓ 已恢复宠物配置${NC}"
    fi
fi

echo ""
if "$CLAUDE_BIN" --version 2>&1 | grep -q "$CURRENT_VER"; then
    echo -e "${GREEN}✓ 恢复成功${NC}"
else
    echo -e "${RED}恢复失败${NC}"
    exit 1
fi