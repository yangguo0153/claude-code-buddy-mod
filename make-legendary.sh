#!/bin/bash
# Claude Code Buddy 深度优化脚本
# 修改权重 + 属性基础值 + 随机种子

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

CONFIG_FILE="$HOME/.claude.json"
VERSIONS_DIR="$HOME/.local/share/claude/versions"
MOD_MARKER="$HOME/.claude/.buddy-mod-applied"

echo -e "${PURPLE}════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Claude Code Buddy 深度优化 v3.0     ${NC}"
echo -e "${PURPLE}════════════════════════════════════════${NC}"
echo ""

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
if [[ -z "$CURRENT_VER" ]]; then
    echo -e "${RED}错误: 未找到 Claude Code${NC}"
    exit 1
fi

CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"
BACKUP="$VERSIONS_DIR/${CURRENT_VER}.original"

echo -e "${CYAN}版本: $CURRENT_VER${NC}"

# 检查是否已修改
if [[ -f "$MOD_MARKER" ]] && [[ "$(cat "$MOD_MARKER")" == "$CURRENT_VER" ]]; then
    echo -e "${GREEN}✓ 已修改此版本${NC}"
    echo ""
    echo -e "${YELLOW}操作选项:${NC}"
    echo "  1) 重新孵化 (换种子获得新宠物)"
    echo "  2) 查看当前状态"
    echo "  3) 退出"
    echo ""
    read -p "选择 [1/2/3]: " action

    if [[ "$action" == "1" ]]; then
        # 获取当前种子并+1
        CURRENT_SALT=$(grep -o "friend-2026-[0-9]*" "$CLAUDE_BIN" 2>/dev/null | head -1)
        SALT_NUM=$(echo "$CURRENT_SALT" | grep -o '[0-9]*$')
        NEW_NUM=$((SALT_NUM + 1))
        NEW_SALT="friend-2026-${NEW_NUM}"
        MAX_TRY=20

        echo "尝试种子: $NEW_SALT - $NEW_NUM + $MAX_TRY"
        echo "(属性由种子决定，无法精确控制单个属性)"
        echo ""

        codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

        for offset in $(grep -a -b -o "friend-2026-[0-9]*" "$CLAUDE_BIN" | cut -d: -f1); do
            printf '%s' "$NEW_SALT" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
        done

        xattr -c "$CLAUDE_BIN" 2>/dev/null || true
        codesign -s - "$CLAUDE_BIN" 2>/dev/null

        # 删除宠物配置
        if command -v jq &> /dev/null; then
            jq 'del(.companion)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        else
            cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
            sed -i '' '/"companion":/,/}/d' "$CONFIG_FILE"
        fi

        echo -e "${GREEN}✓ 重新孵化完成${NC}"
        echo "重启 claude 查看新宠物，如不满意可再次运行换种子"
    elif [[ "$action" == "2" ]]; then
        ./check-status.sh
    fi
    exit 0
fi

# 检查版本更新
if [[ -f "$MOD_MARKER" ]]; then
    OLD_VER=$(cat "$MOD_MARKER")
    echo -e "${YELLOW}版本已更新: $OLD_VER → $CURRENT_VER${NC}"
    echo "需要重新修改"
fi

echo ""
echo -e "${CYAN}修改内容:${NC}"
echo "  1) 品质权重: legendary 99%"
echo "  2) 属性基础值: 所有属性大幅提升 (floor=90)"
echo "  3) 随机种子: 更换以获得新宠物"
echo ""
read -p "继续修改? [Y/n]: " confirm
if [[ "$confirm" == "n" ]]; then exit 0; fi

# 创建备份
if [[ ! -f "$BACKUP" ]]; then
    echo "创建备份..."
    cp "$CLAUDE_BIN" "$BACKUP"
fi

echo ""
echo "开始修改..."

# 移除签名
codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

# 1. 修改权重
echo "  → 修改品质权重..."
WEIGHT_STR='common:00,uncommon:00,rare:00,epic:0,legendary:9'
for offset in $(grep -a -b -o "common:60,uncommon:25,rare:10,epic:4,legendary:1" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$WEIGHT_STR" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
done

# 2. 修改属性基础值 (RARITY_FLOOR)
# 原值: legendary:50 → 改为 legendary:90 (相同长度)
echo "  → 提升属性基础值..."
for offset in $(grep -a -b -o "legendary:50" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "legendary:90" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
done

# 3. 修改随机种子
echo "  → 更换随机种子..."
NEW_SALT="friend-2026-001"
for offset in $(grep -a -b -o "friend-2026-401" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$NEW_SALT" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
done

# 清除属性并签名
xattr -c "$CLAUDE_BIN" 2>/dev/null || true
codesign -s - "$CLAUDE_BIN" 2>/dev/null

# 删除现有宠物配置
if grep -q '"companion"' "$CONFIG_FILE" 2>/dev/null; then
    echo "  → 删除旧宠物配置..."
    if command -v jq &> /dev/null; then
        jq 'del(.companion)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    else
        cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
        sed -i '' '/"companion":/,/}/d' "$CONFIG_FILE"
    fi
fi

# 记录版本
echo "$CURRENT_VER" > "$MOD_MARKER"

# 验证
echo ""
if "$CLAUDE_BIN" --version 2>&1 | grep -q "$CURRENT_VER"; then
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ 修改成功!                        ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}修改效果:${NC}"
    echo "  • 品质: ★★★★★ 传奇"
    echo "  • 属性基础值: 90 (原 50)"
    echo "    - DEBUGGING: 90-100"
    echo "    - PATIENCE:  90-100"
    echo "    - WISDOM:    90-100"
    echo "    - SNARK:     90-100"
    echo "    - CHAOS:     80-95 (dump 属性略低)"
    echo ""
    echo "  • 种子: $NEW_SALT"
    echo ""
    echo -e "${CYAN}重要提示:${NC}"
    echo "  - 重启终端运行 claude"
    echo "  - 版本更新后脚本自动检测并重新修改"
    echo "  - 如属性不满意，再次运行换种子"
    echo ""
    echo "查看状态: ./check-status.sh"
else
    echo -e "${RED}失败，恢复备份...${NC}"
    cp "$BACKUP" "$CLAUDE_BIN"
    codesign -s - "$CLAUDE_BIN" 2>/dev/null
    exit 1
fi