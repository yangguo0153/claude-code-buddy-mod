#!/bin/bash
# 查看宠物状态 + 版本检测

CLAUDE_BIN="$HOME/.local/share/claude/versions/2.1.89"
CONFIG_FILE="$HOME/.claude.json"
MOD_MARKER="$HOME/.claude/.buddy-mod-applied"
VERSIONS_DIR="$HOME/.local/share/claude/versions"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}══════════════════════════════════════${NC}"
echo -e "${CYAN}  Claude Code Buddy 状态检查        ${NC}"
echo -e "${CYAN}══════════════════════════════════════${NC}"
echo ""

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"

echo -e "${YELLOW}版本信息:${NC}"
echo "  当前版本: $CURRENT_VER"

# 检查修改状态
if [[ -f "$MOD_MARKER" ]]; then
    MOD_VER=$(cat "$MOD_MARKER")
    if [[ "$MOD_VER" == "$CURRENT_VER" ]]; then
        echo -e "  修改状态: ${GREEN}已修改 ✓${NC}"
    else
        echo -e "  修改状态: ${RED}版本已更新，需重新修改!${NC}"
        echo -e "  ${YELLOW}运行 ./make-legendary.sh 重新修改${NC}"
    fi
else
    echo -e "  修改状态: ${YELLOW}未修改${NC}"
fi

# 检查二进制配置
if [[ -f "$CLAUDE_BIN" ]]; then
    echo ""
    echo -e "${YELLOW}二进制配置:${NC}"

    # 权重
    if grep -q "legendary:9" "$CLAUDE_BIN" 2>/dev/null; then
        echo -e "  权重: ${GREEN}legendary 99% ✓${NC}"
    else
        echo -e "  权重: ${YELLOW}原版权重${NC}"
    fi

    # 属性基础值
    if grep -q "legendary:90" "$CLAUDE_BIN" 2>/dev/null; then
        echo -e "  属性基础值: ${GREEN}legendary:90 ✓${NC}"
    else
        echo -e "  属性基础值: ${YELLOW}legendary:50 (原版)${NC}"
    fi

    # 种子
    SALT=$(grep -o "friend-2026-[0-9]*" "$CLAUDE_BIN" 2>/dev/null | head -1)
    echo "  随机种子: $SALT"
fi

# 检查宠物配置
echo ""
echo -e "${YELLOW}宠物配置:${NC}"
if [[ -f "$CONFIG_FILE" ]] && grep -q '"companion"' "$CONFIG_FILE"; then
    NAME=$(grep -o '"name":"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    PERSONALITY=$(grep -o '"personality":"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    HATCHED=$(grep -o '"hatchedAt":[0-9]*' "$CONFIG_FILE" | cut -d':' -f2)
    QUALITY=$(echo "$PERSONALITY" | grep -oE 'common|uncommon|rare|epic|legendary' || echo "未知")

    echo "  名字: $NAME"
    echo "  品质: $QUALITY"
    echo "  性格: $PERSONALITY"

    # 星级
    case "$QUALITY" in
        common)     STARS="★"; COLOR="$NC" ;;
        uncommon)   STARS="★★"; COLOR="$NC" ;;
        rare)       STARS="★★★"; COLOR="$NC" ;;
        epic)       STARS="★★★★"; COLOR="$NC" ;;
        legendary)  STARS="★★★★★"; COLOR="$YELLOW" ;;
        *)          STARS="?"; COLOR="$NC" ;;
    esac
    echo -e "  星级: ${COLOR}$STARS${NC}"

    # 检查是否匹配
    if grep -q "legendary:9" "$CLAUDE_BIN" 2>/dev/null && [[ "$QUALITY" != "legendary" ]]; then
        echo ""
        echo -e "${YELLOW}注意: 二进制已修改但 personality 未更新${NC}"
        echo "  species/stats 已变为传奇，但 personality 是旧文本"
        echo "  运行 ./make-legendary.sh 选择重新孵化"
    fi
else
    echo -e "  ${YELLOW}未开启宠物${NC}"
    echo "  运行 claude 输入 /buddy 开启"
fi

echo ""
echo -e "${CYAN}─────────────────────────────────────${NC}"

# 提示
if grep -q "legendary:9" "$CLAUDE_BIN" 2>/dev/null && grep -q "legendary:90" "$CLAUDE_BIN" 2>/dev/null; then
    if [[ -f "$MOD_MARKER" ]] && [[ "$(cat "$MOD_MARKER")" == "$CURRENT_VER" ]]; then
        echo -e "${GREEN}状态正常，修改生效${NC}"
    else
        echo -e "${RED}版本更新，需重新运行脚本${NC}"
    fi
else
    echo -e "${CYAN}运行 ./make-legendary.sh 开始修改${NC}"
fi