#!/bin/bash
# Claude Code Buddy 深度优化脚本
# 修改权重 + 属性基础值 + 随机种子

set -e

# 静默模式检测
QUIET=false
if [[ "$1" == "--quiet" ]]; then
    QUIET=true
fi

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

if ! $QUIET; then
    echo -e "${PURPLE}════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  Claude Code Buddy 深度优化 v3.1     ${NC}"
    echo -e "${PURPLE}════════════════════════════════════════${NC}"
    echo ""
fi

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
if [[ -z "$CURRENT_VER" ]]; then
    echo -e "${RED}错误: 未找到 Claude Code${NC}"
    exit 1
fi

CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"
BACKUP="$VERSIONS_DIR/${CURRENT_VER}.original"

if ! $QUIET; then
    echo -e "${CYAN}版本: $CURRENT_VER${NC}"
fi

# 检查是否已修改
if [[ -f "$MOD_MARKER" ]] && [[ "$(cat "$MOD_MARKER")" == "$CURRENT_VER" ]]; then
    if $QUIET; then
        # 静默模式：已修改，直接退出
        exit 0
    fi
    echo -e "${GREEN}✓ 已修改此版本${NC}"
    echo ""
    echo -e "${YELLOW}操作选项:${NC}"
    echo "  1) 重新孵化 (换种子获得新宠物)"
    echo "  2) 查看当前状态"
    echo "  3) 退出"
    echo ""
    read -p "选择 [1/2/3]: " action

    if [[ "$action" == "1" ]]; then
        # 检查备份是否存在
        if [[ ! -f "$BACKUP" ]]; then
            echo -e "${RED}错误: 备份文件不存在${NC}"
            exit 1
        fi

        # 从备份恢复（确保干净起点）
        echo "从备份恢复..."
        cp "$BACKUP" "$CLAUDE_BIN"

        # 生成随机种子 (1-9999, 4位数格式)
        RAND_NUM=$(jot -r 1 1 9999 2>/dev/null || shuf -i 1-9999 -n 1)
        NEW_SALT=$(printf "friend-2026-%04d" $RAND_NUM)
        echo "使用新种子: $NEW_SALT"

        codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

        # 修改权重
        WEIGHT_STR='common:00,uncommon:00,rare:00,epic:0,legendary:9'
        WEIGHT_COUNT=0
        for offset in $(grep -a -b -o "common:60,uncommon:25,rare:10,epic:4,legendary:1" "$CLAUDE_BIN" | cut -d: -f1); do
            printf '%s' "$WEIGHT_STR" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
            WEIGHT_COUNT=$((WEIGHT_COUNT + 1))
        done

        if [[ $WEIGHT_COUNT -eq 0 ]]; then
            echo -e "${RED}错误: 未找到权重定义${NC}"
            cp "$BACKUP" "$CLAUDE_BIN"
            codesign -s - "$CLAUDE_BIN" 2>/dev/null
            exit 1
        fi

        # 修改闪光概率
        SHINY_COUNT=0
        for offset in $(grep -a -b -o "shiny:H()<0.01" "$CLAUDE_BIN" | cut -d: -f1); do
            printf '%s' "shiny:H()<0.99" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
            SHINY_COUNT=$((SHINY_COUNT + 1))
        done

        # 修改种子
        SEED_COUNT=0
        for offset in $(grep -a -b -o "friend-2026-[0-9]*" "$CLAUDE_BIN" | cut -d: -f1); do
            printf '%s' "$NEW_SALT" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
            SEED_COUNT=$((SEED_COUNT + 1))
        done

        xattr -c "$CLAUDE_BIN" 2>/dev/null || true
        codesign -s - "$CLAUDE_BIN" 2>/dev/null

        # 验证二进制是否有效
        if ! "$CLAUDE_BIN" --version 2>&1 | grep -q "$CURRENT_VER"; then
            echo -e "${RED}错误: 修改后二进制无效，恢复备份...${NC}"
            cp "$BACKUP" "$CLAUDE_BIN"
            codesign -s - "$CLAUDE_BIN" 2>/dev/null
            exit 1
        fi

        # 验证修改是否成功
        if ! grep -q "legendary:9" "$CLAUDE_BIN" 2>/dev/null; then
            echo -e "${RED}错误: 权重修改失败${NC}"
            cp "$BACKUP" "$CLAUDE_BIN"
            codesign -s - "$CLAUDE_BIN" 2>/dev/null
            exit 1
        fi

        # 删除宠物配置
        if command -v jq &> /dev/null; then
            jq 'del(.companion) | del(.birthdayHatAnimationCount)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        else
            cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
            sed -i '' '/"companion":/,/}/d' "$CONFIG_FILE"
        fi
        rm -f "$MOD_MARKER" 2>/dev/null

        echo -e "${GREEN}✓ 重新孵化完成${NC}"
    elif [[ "$action" == "2" ]]; then
        ./check-status.sh
    fi
    exit 0
fi

# 检查版本更新
if [[ -f "$MOD_MARKER" ]]; then
    OLD_VER=$(cat "$MOD_MARKER")
    if $QUIET; then
        echo "⚡ Buddy 修改更新: $OLD_VER → $CURRENT_VER"
    else
        echo -e "${YELLOW}版本已更新: $OLD_VER → $CURRENT_VER${NC}"
    fi
fi

# 静默模式：不需要确认
if ! $QUIET; then
    echo ""
    echo -e "${CYAN}修改内容:${NC}"
    echo "  • 品质权重: legendary 99%"
    echo ""
    read -p "继续修改? [Y/n]: " confirm
    if [[ "$confirm" == "n" ]]; then exit 0; fi
fi

# 创建备份
if [[ ! -f "$BACKUP" ]]; then
    if ! $QUIET; then echo "创建备份..."; fi
    cp "$CLAUDE_BIN" "$BACKUP"
fi

# 验证备份是否有效
if ! "$BACKUP" --version 2>&1 | grep -q "$CURRENT_VER"; then
    echo -e "${RED}错误: 备份文件无效${NC}"
    exit 1
fi

# 从备份恢复（确保干净起点）
if ! $QUIET; then echo "从备份恢复..."; fi
cp "$BACKUP" "$CLAUDE_BIN"

# 移除签名
codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

# 1. 修改权重 - legendary 99%
if ! $QUIET; then echo "  → 修改品质权重..."; fi
WEIGHT_STR='common:00,uncommon:00,rare:00,epic:0,legendary:9'
WEIGHT_COUNT=0
for offset in $(grep -a -b -o "common:60,uncommon:25,rare:10,epic:4,legendary:1" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$WEIGHT_STR" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
    WEIGHT_COUNT=$((WEIGHT_COUNT + 1))
done

if [[ $WEIGHT_COUNT -eq 0 ]]; then
    echo -e "${RED}错误: 未找到权重定义${NC}"
    cp "$BACKUP" "$CLAUDE_BIN"
    codesign -s - "$CLAUDE_BIN" 2>/dev/null
    exit 1
fi

# 2. 修改闪光概率 - 99%
if ! $QUIET; then echo "  → 闪光概率 99%"; fi
SHINY_COUNT=0
for offset in $(grep -a -b -o "shiny:H()<0.01" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "shiny:H()<0.99" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
    SHINY_COUNT=$((SHINY_COUNT + 1))
done

# 清除属性并签名
xattr -c "$CLAUDE_BIN" 2>/dev/null || true
codesign -s - "$CLAUDE_BIN" 2>/dev/null

# 验证二进制是否有效
if ! "$CLAUDE_BIN" --version 2>&1 | grep -q "$CURRENT_VER"; then
    echo -e "${RED}错误: 修改后二进制无效，恢复备份...${NC}"
    cp "$BACKUP" "$CLAUDE_BIN"
    codesign -s - "$CLAUDE_BIN" 2>/dev/null
    exit 1
fi

# 验证修改是否成功
if ! grep -q "legendary:9" "$CLAUDE_BIN" 2>/dev/null; then
    echo -e "${RED}错误: 权重修改失败${NC}"
    cp "$BACKUP" "$CLAUDE_BIN"
    codesign -s - "$CLAUDE_BIN" 2>/dev/null
    exit 1
fi

# 静默模式：不删除宠物配置（保留用户宠物）
if ! $QUIET; then
    if grep -q '"companion"' "$CONFIG_FILE" 2>/dev/null; then
        echo ""
        read -p "删除现有宠物配置重新孵化? [y/N]: " del_config
        if [[ "$del_config" == "y" ]]; then
            if command -v jq &> /dev/null; then
                jq 'del(.companion) | del(.birthdayHatAnimationCount)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            else
                cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
                sed -i '' '/"companion":/,/}/d' "$CONFIG_FILE"
            fi
            # 清理修改标记文件
            rm -f "$MOD_MARKER" 2>/dev/null
            echo -e "${GREEN}✓ 已删除旧配置${NC}"
        fi
    fi
fi

# 记录版本
echo "$CURRENT_VER" > "$MOD_MARKER"

# 最终验证
if "$CLAUDE_BIN" --version 2>&1 | grep -q "$CURRENT_VER"; then
    if $QUIET; then
        echo "✓ Buddy 修改完成"
    else
        echo ""
        echo -e "${GREEN}════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ✓ 修改成功!                        ${NC}"
        echo -e "${GREEN}════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}修改效果:${NC}"
        echo "  • 品质: ★★★★★ 传奇 (99%)"
        echo "  • 属性基础值: 50 (legendary 默认值)"
        echo ""
        echo "使用 claude-auto 自动享受版本更新"
    fi
else
    echo -e "${RED}失败，恢复备份...${NC}"
    cp "$BACKUP" "$CLAUDE_BIN"
    codesign -s - "$CLAUDE_BIN" 2>/dev/null
    exit 1
fi