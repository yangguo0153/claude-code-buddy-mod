# Claude Code Buddy 传奇品质 Mod

让宠物直接成为 **Legendary + Shiny** 品质。

## 功能

- ✅ Legendary 品质：99%
- ✅ Shiny 闪光：99%
- ✅ 一键重新孵化
- ✅ 版本更新后可恢复

## 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/yangguo0153/claude-code-buddy-mod.git
cd claude-code-buddy-mod

# 2. 安装自动更新别名（可选）
./install-alias.sh
source ~/.zshrc

# 3. 孵化新宠物
./rehatch.sh

# 4. 重启终端，运行 claude
```

## 使用说明

### 一键重新孵化

```bash
./rehatch.sh
```

每次运行会：
1. 随机生成新种子
2. 应用 Legendary + Shiny 修改
3. 删除旧宠物配置
4. 重启终端后运行 `claude` 获得新宠物

### 查看当前状态

```bash
./check-status.sh
```

显示：
- 版本信息
- 修改状态
- 当前宠物配置

### 自动更新别名

```bash
./install-alias.sh
source ~/.zshrc
```

安装后可使用：
- `claude-auto` - 版本更新后自动修改并启动
- `claude` - 原版命令

### 手动修改

```bash
./make-legendary.sh
```

只修改权重和闪光概率，不删除宠物配置。

### 恢复原版

```bash
./restore.sh
```

## 修改效果

| 项目 | 原版 | 修改后 |
|-----|------|-------|
| Legendary 品质 | 1% | 99% |
| Shiny 闪光 | 1% | 99% |

## 永久性说明

```
┌─────────────────────────────────────────────┐
│  Bones (由种子决定，永久固定)               │
│  ├─ Species (物种)                          │
│  ├─ Eye (眼睛)                              │
│  ├─ Hat (帽子)                              │
│  ├─ Shiny (闪光)                            │
│  ├─ Rarity (品质)                           │
│  └─ Stats (属性)                            │
│                                             │
│  Soul (存储在 ~/.claude.json)              │
│  ├─ Name (名字)                             │
│  └─ Personality (性格描述)                  │
└─────────────────────────────────────────────┘
```

**种子不变 = 宠物属性永久固定**

### 版本更新后怎么办？

官方更新 Claude Code 后：
1. 运行 `./rehatch.sh` 或 `./make-legendary.sh`
2. 或使用 `claude-auto` 自动处理

宠物配置（name/personality）存储在 `~/.claude.json`，不会丢失。

## 常见问题

### Q: 孵化卡住超过 30 秒？

网络问题导致 AI 生成 personality 超时。按 Ctrl+C 取消，然后：
1. 检查网络连接
2. 重新运行 `./rehatch.sh`

### Q: 不满意当前宠物？

运行 `./rehatch.sh` 重新孵化，每次随机生成新宠物。

### Q: 属性值不满意？

属性由种子随机决定，多运行几次 `./rehatch.sh` 直到满意。

### Q: 物种不喜欢？

物种由种子决定，多运行几次 `./rehatch.sh` 直到遇到喜欢的物种。

## 文件说明

```
claude-code-buddy-mod/
├── rehatch.sh          # 一键重新孵化（推荐）
├── make-legendary.sh   # 手动修改权重+闪光
├── check-status.sh     # 查看当前状态
├── install-alias.sh    # 安装 claude-auto 别名
├── restore.sh          # 恢复原版
├── claude-wrapper.sh   # claude-auto 包装脚本
└── README.md           # 使用说明
```

## 注意事项

- 仅支持 Claude Code 2.1.x (arm64 macOS)
- 修改二进制文件需移除签名并重新签名
- 可能违反 Anthropic 使用条款，自行承担风险

## License

MIT