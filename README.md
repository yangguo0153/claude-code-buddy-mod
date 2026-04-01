# Claude Code Buddy 传奇品质 Mod

让宠物直接成为传奇品质。

## 修改效果

| 项目 | 原版 | 修改后 |
|-----|------|-------|
| 品质权重 | legendary 1% | legendary 99% |
| 属性基础值 | legendary=50 | legendary=50（不变） |

注：不修改 RARITY_FLOOR，避免 stats > 100 导致的渲染错误。

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
# 推荐：使用 claude-auto
claude-auto

# 或手动修改
./make-legendary.sh
```

## 长期陪伴原理

```
┌─────────────────────────────────────────────┐
│  Bones (每次动态计算，使用官方最新配置)      │
│  ├─ species, eye, hat                       │
│  │   → 官方新增 dragon/owl/capybara         │
│  │   → 你自动获得新外观 ✓                   │
│  └─ stats (floor=50)                        │
│      → DEBUGGING: 50-100                    │
│      → PATIENCE: 50-100                     │
│      → WISDOM: 50-100                       │
│                                             │
│  Soul (存储在 ~/.claude.json，永久保留)     │
│  ├─ name: "Pickle"                          │
│  └─ personality: "A legendary owl..."       │
└─────────────────────────────────────────────┘
```

## 版本更新处理

- 使用 `claude-auto` 自动检测版本变化
- 版本更新后首次运行自动修改权重
- 宠物配置（name/personality）永久保留

## 注意事项

- 仅支持 Claude Code 2.1.x (arm64 macOS)
- 不修改 RARITY_FLOOR（避免 stats 溢出错误）
- 可能违反 Anthropic 使用条款

## License

MIT