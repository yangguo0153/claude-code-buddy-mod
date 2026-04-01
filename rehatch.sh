#!/bin/bash
# 快速重新孵化 - Legendary + Shiny
# 确保种子和配置同步

set -e

CLAUDE_BIN="$HOME/.local/share/claude/versions/2.1.89"
CONFIG_FILE="$HOME/.claude.json"
VERSIONS_DIR="$HOME/.local/share/claude/versions"

# 临时文件清理
TMP_FILE=""
trap 'rm -f "$TMP_FILE" 2>/dev/null' EXIT

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 错误处理
error_exit() {
    echo -e "${RED}错误: $1${NC}" >&2
    exit 1
}

# 检查依赖
for cmd in jq codesign; do
    if ! command -v "$cmd" &> /dev/null; then
        error_exit "需要 $cmd 命令"
    fi
done

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
if [[ -z "$CURRENT_VER" ]]; then
    error_exit "未找到 Claude Code"
fi

CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"
BACKUP="$VERSIONS_DIR/${CURRENT_VER}.original"

echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}  Legendary + Shiny 重新孵化          ${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}版本: $CURRENT_VER${NC}"

# 创建备份（如果不存在）
if [[ ! -f "$BACKUP" ]]; then
    echo "创建备份..."
    cp "$CLAUDE_BIN" "$BACKUP"
fi

# 验证备份是否有效
if ! "$BACKUP" --version 2>&1 | grep -q "$CURRENT_VER"; then
    error_exit "备份文件无效"
fi

# 从备份恢复（确保干净起点）
echo "从备份恢复..."
cp "$BACKUP" "$CLAUDE_BIN"

# 生成随机种子 (1-999, 固定15字符长度)
RAND_NUM=$(jot -r 1 1 999 2>/dev/null || shuf -i 1-999 -n 1)
NEW_SALT=$(printf "friend-2026-%03d" $RAND_NUM)

echo "新种子: $NEW_SALT"

# 移除签名
codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

# 1. 修改权重 - legendary 99%
echo "  → 权重: legendary 99%"
WEIGHT_STR='common:00,uncommon:00,rare:00,epic:0,legendary:9'
WEIGHT_COUNT=0
for offset in $(grep -a -b -o "common:60,uncommon:25,rare:10,epic:4,legendary:1" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$WEIGHT_STR" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
    WEIGHT_COUNT=$((WEIGHT_COUNT + 1))
done

if [[ $WEIGHT_COUNT -eq 0 ]]; then
    echo -e "${RED}错误: 未找到权重定义，恢复备份...${NC}" >&2
    cp "$BACKUP" "$CLAUDE_BIN" 2>/dev/null || true
    codesign -s - "$CLAUDE_BIN" 2>/dev/null || true
    error_exit "权重修改失败"
fi

# 2. 修改闪光概率 - 99%
echo "  → 闪光: 99%"
SHINY_COUNT=0
for offset in $(grep -a -b -o "shiny:H()<0.01" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "shiny:H()<0.99" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
    SHINY_COUNT=$((SHINY_COUNT + 1))
done

# 3. 修改种子
echo "  → 种子: $NEW_SALT"
SEED_COUNT=0
for offset in $(grep -a -b -o "friend-2026-401" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$NEW_SALT" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
    SEED_COUNT=$((SEED_COUNT + 1))
done

# 清除属性并签名
xattr -c "$CLAUDE_BIN" 2>/dev/null || true
codesign -s - "$CLAUDE_BIN" 2>/dev/null

# 验证二进制是否有效
if ! "$CLAUDE_BIN" --version 2>&1 | grep -q "$CURRENT_VER"; then
    echo -e "${RED}错误: 修改后二进制无效，恢复备份...${NC}" >&2
    cp "$BACKUP" "$CLAUDE_BIN" 2>/dev/null || true
    codesign -s - "$CLAUDE_BIN" 2>/dev/null || true
    error_exit "二进制修改失败"
fi

# 验证修改是否成功
if ! grep -q "legendary:9" "$CLAUDE_BIN" 2>/dev/null; then
    error_exit "权重修改验证失败"
fi

# 删除宠物配置（只保留一条最终记录）
TMP_FILE=$(mktemp)
jq 'del(.companion) | del(.birthdayHatAnimationCount)' "$CONFIG_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$CONFIG_FILE"
rm -f ~/.claude/.buddy-mod-applied 2>/dev/null

echo ""
echo -e "${GREEN}✓ 重新孵化完成${NC}"
echo ""
echo "品质保证:"
echo "  • Legendary: 99%"
echo "  • Shiny: 99%"
echo "  • 种子: $NEW_SALT"
echo ""
echo "重启终端运行 claude"