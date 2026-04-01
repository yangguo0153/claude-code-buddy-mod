# Claude Code Buddy 传奇品质 Mod

让宠物直接成为传奇品质 + 闪光。

## 修改效果

| 项目 | 原版 | 修改后 |
|-----|------|-------|
| 品质权重 | legendary 1% | legendary 99% |
| 闪光概率 | 1% | 99% |

## 安装

```bash
git clone https://github.com/yangguo0153/claude-code-buddy-mod.git
cd claude-code-buddy-mod
chmod +x *.sh

# 安装自动更新别名
./install-alias.sh
source ~/.zshrc
```

## 使用

```bash
# 推荐：一键重新孵化（Legendary + Shiny）
./rehatch.sh

# 或手动修改
./make-legendary.sh
```

## 永久性说明

```
┌─────────────────────────────────────────────┐
│  Bones (由种子决定，永久固定)               │
│  ├─ Species, Eye, Hat                       │
│  ├─ Shiny (闪光)                            │
│  ├─ Rarity (品质)                           │
│  └─ Stats (属性)                            │
│                                             │
│  Soul (存储在 ~/.claude.json)              │
│  ├─ Name                                    │
│  └─ Personality                             │
└─────────────────────────────────────────────┘
```

**种子不变 = 宠物属性永久固定**

官方版本更新后，只需重新运行 `./rehatch.sh` 或 `./make-legendary.sh`。

## 版本更新处理

- 使用 `claude-auto` 自动检测版本变化
- 版本更新后首次运行自动修改权重+闪光
- 种子保持不变，宠物属性不变

## 注意事项

- 仅支持 Claude Code 2.1.x (arm64 macOS)
- 不修改 RARITY_FLOOR（避免 stats 溢出错误）
- 可能违反 Anthropic 使用条款

## License

MIT