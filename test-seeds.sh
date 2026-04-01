#!/bin/bash
# 批量测试种子，找到产生 cat 的种子

CLAUDE_BIN="$HOME/.local/share/claude/versions/2.1.89"
CONFIG_FILE="$HOME/.claude.json"
BACKUP="$HOME/.local/share/claude/versions/2.1.89.original"

echo "批量测试种子，找到 cat..."
echo ""

# 确保有备份
if [[ ! -f "$BACKUP" ]]; then
    cp "$CLAUDE_BIN" "$BACKUP"
fi

# 保存原配置
cp "$CONFIG_FILE" "$CONFIG_FILE.test_backup"

# 测试 1-50 号种子
for i in $(seq -w 1 50); do
    SEED="friend-2026-$i"

    # 应用种子
    codesign --remove-signature "$CLAUDE_BIN" 2>/dev/null || true

    for offset in $(grep -a -b -o "friend-2026-[0-9]*" "$CLAUDE_BIN" | cut -d: -f1); do
        printf '%s' "$SEED" | dd of="$CLAUDE_BIN" bs=1 seek=$offset conv=notrunc 2>/dev/null
    done

    xattr -c "$CLAUDE_BIN" 2>/dev/null || true
    codesign -s - "$CLAUDE_BIN" 2>/dev/null

    # 删除宠物配置
    jq 'del(.companion)' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" 2>/dev/null && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    # 运行 claude 并捕获输出
    echo "测试 $SEED..."

    # 这里需要用户手动查看结果
    echo "  运行: claude"
    echo "  查看物种后按回车继续，或输入 'found' 如果是 cat"
    read -p "  物种? " result

    if [[ "$result" == "found" ]] || [[ "$result" == "cat" ]]; then
        echo ""
        echo "✓ 找到 CAT 种子: $SEED"
        echo "  保留此种子，退出测试"
        exit 0
    fi
done

echo ""
echo "测试完成，未找到 cat"
echo "恢复原配置..."
cp "$CONFIG_FILE.test_backup" "$CONFIG_FILE"