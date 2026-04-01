#!/bin/bash
# 寻找最优种子 - 让 DEBUGGING/PATIENCE/WISDOM 高，CHAOS 低

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="$HOME/.claude.json"
VERSIONS_DIR="$HOME/.local/share/claude/versions"

echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}  寻找最优 Buddy 种子                 ${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""

# 获取当前版本
CURRENT_VER=$(ls -t "$VERSIONS_DIR" 2>/dev/null | grep -E '^2\.[0-9]+\.[0-9]+$' | head -1)
CLAUDE_BIN="$VERSIONS_DIR/$CURRENT_VER"

if [[ ! -f "$CLAUDE_BIN" ]]; then
    echo "错误: Claude Code 未安装"
    exit 1
fi

# 模拟 stats 计算（需要 Python）
if ! command -v python3 &> /dev/null; then
    echo "需要 Python3"
    exit 1
fi

# 从源码中提取的 stats 计算逻辑
cat << 'PYTHON_SCRIPT' > /tmp/find_best_seed.py
import hashlib
import sys

STAT_NAMES = ['DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK']

def mulberry32(seed):
    a = seed
    def rng():
        nonlocal a
        a = (a + 0x6d2b79f5) & 0xffffffff
        t = (a ^ (a >> 15)) * (1 | a)
        t = (t + (t ^ (t >> 7)) * 61 | t) ^ t
        return ((t ^ (t >> 14)) & 0xffffffff) / 4294967296
    return rng

def hash_string(s):
    h = 2166136261
    for c in s:
        h ^= ord(c)
        h = (h * 16777619) & 0xffffffff
    return h

def pick(rng, arr):
    return arr[int(rng() * len(arr))]

def roll_stats(rng, floor=50):
    peak = pick(rng, STAT_NAMES)
    dump = pick(rng, STAT_NAMES)
    while dump == peak:
        dump = pick(rng, STAT_NAMES)

    stats = {}
    for name in STAT_NAMES:
        if name == peak:
            stats[name] = min(100, floor + 50 + int(rng() * 30))
        elif name == dump:
            stats[name] = max(1, floor - 10 + int(rng() * 15))
        else:
            stats[name] = floor + int(rng() * 40)
    return stats, peak, dump

def score_stats(stats):
    # 目标：DEBUGGING/PATIENCE/WISDOM 高，CHAOS 低
    score = 0
    score += stats['DEBUGGING']
    score += stats['PATIENCE']
    score += stats['WISDOM']
    score -= stats['CHAOS'] * 0.5  # CHAOS 越低越好
    return score

best_score = -1000
best_seed = None
best_stats = None

# 测试 1000 个种子
for i in range(1, 1001):
    seed_str = f"friend-2026-{i:03d}"
    h = hash_string(seed_str)
    rng = mulberry32(h)
    stats, peak, dump = roll_stats(rng)

    score = score_stats(stats)

    # 额外奖励：CHAOS 是 dump 属性
    if dump == 'CHAOS':
        score += 50

    # 额外奖励：DEBUGGING/PATIENCE/WISDOM 中有 peak
    if peak in ['DEBUGGING', 'PATIENCE', 'WISDOM']:
        score += 30

    if score > best_score:
        best_score = score
        best_seed = seed_str
        best_stats = stats
        best_peak = peak
        best_dump = dump

print(f"最佳种子: {best_seed}")
print(f"得分: {best_score:.1f}")
print(f"Peak: {best_peak}, Dump: {best_dump}")
print()
print("属性:")
for name in STAT_NAMES:
    bar = '█' * (best_stats[name] // 10)
    print(f"  {name:12s} {best_stats[name]:3d} {bar}")
PYTHON_SCRIPT

echo "正在分析 1000 个种子..."
python3 /tmp/find_best_seed.py

echo ""
echo -e "${YELLOW}提示:${NC}"
echo "  1. 运行 ./make-legendary.sh 选择重新孵化"
echo "  2. 输入上面显示的最佳种子"
echo "  3. 或者直接用该种子替换二进制中的 friend-2026-401"