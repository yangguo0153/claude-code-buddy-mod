# Claude Code Buddy 深度优化 Mod

让宠物长期陪伴你成长。

## 核心理念

**你的宠物是长期的！**

```
┌─────────────────────────────────────────────┐
│  Bones (每次动态计算，使用官方最新配置)      │
│  ├─ species, eye, hat                       │
│  │   → 官方新增 dragon/owl/capybara         │
│  │   → 你自动获得新外观 ✓                   │
│  ├─ stats                                   │
│  │   → 官方改进计算公式                     │
│  │   → 自动重新计算 ✓                       │
│  └─ 品质/属性基础值                         │
│      → 版本更新后需重新修改                 │
│                                             │
│  Soul (存储在 ~/.claude.json，永久保留)     │
│  ├─ name: "Pickle"                          │
│  ├─ personality: "A legendary dragon..."    │
│  └─ hatchedAt: timestamp                    │
│      → 你的宠物名字不变 ✓                   │
└─────────────────────────────────────────────┘
```

## 安装

```bash
git clone https://github.com/yangguo0153/claude-code-buddy-mod.git
cd claude-code-buddy-mod
chmod +x *.sh

# 安装自动更新别名
./install-alias.sh
source ~/.zshrc  # 或重启终端
```

## 使用方式

### 推荐：使用 claude-auto

```bash
claude-auto
```

- 版本更新后自动检测并修改
- 不需要每次启动检查
- 官方新功能自动享受

### 手动修改

```bash
./make-legendary.sh
```

## 修改效果

| 项目 | 原版 | 修改后 |
|-----|------|-------|
| 品质权重 | legendary 1% | legendary 99% |
| 属性基础值 | legendary=50 | legendary=90 |
| DEBUGGING | 50-80 | 90-100 |
| PATIENCE | 50-80 | 90-100 |
| WISDOM | 50-80 | 90-100 |

## 长期陪伴原理

你的宠物会随官方更新一起成长：

| 官方更新 | 你的宠物 |
|---------|---------|
| 新增 species (dragon, owl, capybara...) | 自动获得 ✓ |
| 新增 hats (wizard, crown...) | 自动获得 ✓ |
| 改进 stats 计算公式 | 自动重新计算 ✓ |
| 新增动画/交互 | 自动享受 ✓ |
| 版本号变化 | 需运行 claude-auto |

## 命令对比

| 命令 | 说明 |
|-----|------|
| `claude` | 原版命令，不自动修改 |
| `claude-auto` | 自动检测版本变化，修改后启动 |
| `./check-status.sh` | 查看当前宠物状态 |

## 技术细节

Buddy 系统设计：
- **Bones** (species, eye, hat, stats) 每次 `userId + SALT` 动态计算
- **Soul** (name, personality) 存储在配置中

我们的修改：
- 权重：`common:60,...,legendary:1` → `common:00,...,legendary:9`
- 属性基础值：`legendary:50` → `legendary:90`

## 注意事项

- 仅支持 Claude Code 2.1.x (arm64 macOS)
- 版本更新后首次运行 `claude-auto` 会自动修改
- 可能违反 Anthropic 使用条款，自行承担风险

## License

MIT