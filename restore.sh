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

# 临时文件清理
TMP_FILE=""
trap 'rm -f "$TMP_FILE" 2>/dev/null' EXIT

# 错误处理函数
error_exit() {
    echo -e "${RED}错误: $1${NC}" >&2
    exit 1
}

# 检查依赖
for cmd in codesign; do
    if ! command -v "$cmd" &> /dev/null; then
        error_exit "需要 $cmd 命令"
    fi
done

echo -e "${YELLOW}恢复 Claude Code 原版${NC}"
echo ""

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
if [[ -z "$CURRENT_VER" ]]; then
    error_exit "无法检测当前版本"
fi

CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"
BACKUP="$VERSIONS_DIR/${CURRENT_VER}.original"
CONFIG_BACKUP="$CONFIG_FILE.bak"

# 验证备份文件存在
if [[ ! -f "$BACKUP" ]]; then
    error_exit "未找到备份文件: $BACKUP"
fi

# 验证备份文件有效性
echo "验证备份文件有效性..."
BACKUP_VERSION=$("$BACKUP" --version 2>&1 | grep -oE '2\.[0-9]+\.[0-9]+' | head -1)
if [[ -z "$BACKUP_VERSION" ]]; then
    error_exit "备份文件损坏或无效，无法获取版本信息"
fi
if [[ "$BACKUP_VERSION" != "$CURRENT_VER" ]]; then
    error_exit "备份版本 ($BACKUP_VERSION) 与当前版本 ($CURRENT_VER) 不匹配"
fi
echo -e "${GREEN}✓ 备份文件有效 (版本: $BACKUP_VERSION)${NC}"
echo ""

echo "恢复原版二进制..."
cp "$BACKUP" "$CLAUDE_BIN" || error_exit "复制文件失败"

echo "清除扩展属性..."
xattr -c "$CLAUDE_BIN" 2>/dev/null || true

echo "应用签名..."
codesign -s - "$CLAUDE_BIN" 2>/dev/null

# 删除修改标记
rm -f "$MOD_MARKER"

# 清除多次孵化痕迹
if [[ -f "$CONFIG_FILE" ]]; then
    echo "清除孵化痕迹..."
    TMP_FILE=$(mktemp)
    if grep -q "birthdayHatAnimationCount" "$CONFIG_FILE" 2>/dev/null; then
        # 移除 birthdayHatAnimationCount 字段
        sed 's/,"birthdayHatAnimationCount":[0-9]*//g' "$CONFIG_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$CONFIG_FILE"
        echo -e "${GREEN}✓ 已清除 birthdayHatAnimationCount${NC}"
    fi
fi

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
    error_exit "恢复验证失败"
fi