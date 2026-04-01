#!/bin/bash
# 快速重新孵化 - 换随机种子

CLAUDE_BIN="$HOME/.local/share/claude/versions/2.1.89"
CONFIG_FILE="$HOME/.claude.json"

# 生成随机种子号 (1-999)
RAND_NUM=$(jot -r 1 1 999 2>/dev/null || shuf -i 1-999 -n 1)
NEW_SALT=$(printf "friend-2026-%03d" $RAND_NUM)

echo "新种子: $NEW_SALT"

# 应用种子
codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

for offset in $(grep -a -b -o "friend-2026-[0-9]*" "$CLAUDE_BIN" | cut -d: -f1); do
    printf '%s' "$NEW_SALT" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
done

xattr -c "$CLAUDE_BIN" 2>/dev/null || true
codesign -s - "$CLAUDE_BIN" 2>/dev/null

# 删除宠物配置
if command -v jq &> /dev/null; then
    jq 'del(.companion)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
fi

echo "✓ 已重新孵化"
echo "重启终端运行 claude"