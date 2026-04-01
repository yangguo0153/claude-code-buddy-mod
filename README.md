# Claude Code Buddy 深度优化 Mod

将 Claude Code 宠物改为传奇品质，并大幅提升属性基础值。

## v3.0 新特性

- ✅ **属性深度优化**: 将 legendary 属性基础值从 50 提升到 90
- ✅ **版本更新检测**: 自动检测 Claude Code 版本更新，提示重新修改
- ✅ **一键重新孵化**: 如不满意可换种子获得新宠物
- ✅ **完整备份恢复**: 随时恢复原版

## 修改效果

| 项目 | 原版 | 修改后 |
|-----|------|-------|
| 品质权重 | legendary 1% | legendary 99% |
| 属性基础值 | legendary=50 | legendary=90 |
| DEBUGGING | 50-80 | 90-100 |
| PATIENCE | 50-80 | 90-100 |
| WISDOM | 50-80 | 90-100 |
| SNARK | 50-80 | 90-100 |
| CHAOS | 40-55 (dump) | 80-95 |

注：属性由 `userId + SALT` 哈希确定，其中有一个属性是 peak（最高），一个是 dump（最低）。floor 提升到 90 后，即使 dump 属性也会是 80-95。

## 使用方法

```bash
# 克隆
git clone https://github.com/yangguo0153/claude-code-buddy-mod.git
cd claude-code-buddy-mod
chmod +x *.sh

# 运行
./make-legendary.sh

# 重启终端
claude
```

### 重新孵化（换宠物）

如果对当前宠物不满意（species/personality/stats），再次运行脚本选择重新孵化：

```bash
./make-legendary.sh
# 选择 1) 重新孵化
# 种子会 +1，获得新宠物
```

### 查看状态

```bash
./check-status.sh
```

显示：
- 版本信息
- 修改状态
- 当前宠物配置
- 是否需要重新修改

### 恢复原版

```bash
./restore.sh
```

## 版本更新处理

Claude Code 更新时会安装新二进制，修改会失效。脚本会：

1. 检测到版本号变化
2. 提示需要重新修改
3. 运行脚本后自动修改新版本

检测逻辑：将当前版本号存储在 `~/.claude/.buddy-mod-applied`，每次运行对比。

### 自动检测 Hook

安装后每次打开终端自动检测版本变化：

```bash
./install-hook.sh
source ~/.zshrc  # 或重启终端
```

效果：
- 版本更新后打开终端会提示
- 或使用 `claude-mod-check` 别名（检测 + 启动）

### 官方功能更新

**你的宠物会自动享受官方新功能！**

Buddy 系统设计：
- **Bones (动态计算)**: species, eye, hat, stats — 使用官方最新数组
- **Soul (存储配置)**: name, personality, hatchedAt — 保留你的宠物

所以：
- ✅ 官方新增 **species/hats** → 你自动获得新外观
- ✅ 官方改进 **stats 计算逻辑** → 自动应用
- ✅ 官方新增 **动画/交互** → 自动享受
- ❌ 版本更新后 **权重/floor 修改失效** → 运行脚本重新修改

## 解决的问题

### 1. 简介不匹配

问题描述：species 变了但 personality 文本还是旧的。

解决：选择"重新孵化"，删除 `~/.claude.json` 中的 companion 配置，重新生成 personality。

### 2. 属性不满意

问题描述：想要特定属性高。

解决：
- 将 legendary floor 从 50 提升到 90，所有属性大幅提高
- 如果想要不同分布，换种子重新孵化

### 3. 版本更新重置

问题描述：更新后修改失效。

解决：
- 自动检测版本变化
- 重新运行脚本即可

## 技术细节

### 修改内容

| 文件位置 | 原值 | 新值 |
|---------|------|------|
| 权重 | `common:60,uncommon:25,rare:10,epic:4,legendary:1` | `common:00,uncommon:00,rare:00,epic:0,legendary:9` |
| 属性基础值 | `legendary:50` | `legendary:90` |
| 种子 | `friend-2026-401` | `friend-2026-XXX` |

### 属性计算公式

```javascript
floor = RARITY_FLOOR[rarity]  // legendary: 50 → 修改后 90
peak = randomStat()           // floor + 50 + random(30) → 140-170 (上限100)
dump = randomStat()           // floor - 10 + random(15) → 修改后 80-95
others = floor + random(40)   // 修改后 90-130 (上限100)
```

## 注意事项

- 仅支持 Claude Code 2.1.x (arm64 macOS)
- 修改二进制需移除签名并重新签名
- 可能违反 Anthropic 使用条款，自行承担风险
- Windows/Linux 用户需要修改对应二进制位置

## License

MIT