#!/bin/bash
# 快速重新孵化 - Legendary + Shiny

CLAUDE_BIN="$HOME/.local/share/claude/versions/2.1.89"
CONFIG_FILE="$HOME/.claude.json"
VERSIONS_DIR="$HOME/.local/share/claude/versions"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"
BACKUP="$VERSIONS_DIR/${CURRENT_VER}.original"

echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}  Legendary + Shiny 重新孵化          ${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""

# 创建备份
if [[ ! -f "$BACKUP" ]]; then
    echo "创建备份..."
    cp "$CLAUDE_BIN" "$BACKUP"
fi

# 生成随机种子 (1-9999，更大范围避免重复)
RAND_NUM=$(jot -r 1 1 9999 2>/dev/null || shuf -i 1-9999 -n 1)
NEW_SALT=$(printf "friend-2026-%04d" $RAND_NUM)

echo "新种子: $NEW_SALT"

# 移除签名
codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

# 1. 修改权重 - legendary 99%
echo "  → 权重: legendary 99%"
WEIGHT_STR='common:00,uncommon:00,rare:00,epic:0,legendary:9'
for offset in $(grep -a -b -o "common:60,uncommon:25,rare:10,epic:4,legendary:1" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$WEIGHT_STR" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
done

# 2. 修改闪光概率 - 99%
echo "  → 闪光: 99%"
# shiny:H()<0.01 改为 shiny:H()<0.99
for offset in $(grep -a -b -o "shiny:H()<0.01" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "shiny:H()<0.99" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
done

# 3. 应用新种子
echo "  → 种子: $NEW_SALT"
for offset in $(grep -a -b -o "friend-2026-[0-9]*" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$NEW_SALT" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
done

# 清除属性并签名
xattr -c "$CLAUDE_BIN" 2>/dev/null || true
codesign -s - "$CLAUDE_BIN" 2>/dev/null

# 删除宠物配置（确保只有一条最终记录，不留孵化历史）
# 注意：配置文件不会保留孵化历史，每次只存一条当前记录
if command -v jq &> /dev/null; then
    # 删除旧宠物配置
    jq 'del(.companion)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    # 删除可能的孵化计数器
    jq 'del(.birthdayHatAnimationCount)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    # 清理修改标记文件
    rm -f ~/.claude/.buddy-mod-applied 2>/dev/null
else
    sed -i.bak '/"companion":/,/}/d' "$CONFIG_FILE"
fi

# 验证
if "$CLAUDE_BIN" --version 2>&1 | grep -q "$CURRENT_VER"; then
    echo ""
    echo -e "${GREEN}✓ 重新孵化完成${NC}"
    echo ""
    echo "品质保证:"
    echo "  • Legendary: 99%"
    echo "  • Shiny: 99%"
    echo ""
    echo -e "${YELLOW}永久性说明:${NC}"
    echo "  • Species/Eye/Hat/Shiny 由种子决定"
    echo "  • Stats 由种子 + legendary floor 决定"
    echo "  • 官方更新后只需重新运行此脚本"
    echo ""
    echo "重启终端运行 claude"
else
    echo -e "${RED}修改失败${NC}"
    exit 1
fi