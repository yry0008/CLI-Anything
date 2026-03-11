# CLI-Anything Native - OpenClaw Skill

纯原生 OpenClaw 实现的 CLI-Anything，无需 ACP、无需 OpenCode。

## 特点

- ✅ **零外部依赖**：不需要 acpx 插件或 OpenCode
- ✅ **原生工具**：直接使用 OpenClaw 的 read/write/exec/subagents
- ✅ **完全兼容**：生成的 CLI 与 CLI-Anything 标准一致
- ✅ **可分阶段**：支持分阶段执行，便于调试
- ✅ **并行加速**：使用 subagents 加速多阶段任务

## 安装

将此目录复制到你的 OpenClaw skills 目录：

```bash
cp -r openclaw-skill ~/.openclaw/skills/cli-anything-native
```

或使用软链接（开发模式）：

```bash
ln -s $(pwd)/openclaw-skill ~/.openclaw/skills/cli-anything-native
```

## 使用方法

### 完整构建

```
为 GIMP 生成 CLI 工具
使用 CLI-Anything 为 https://github.com/blender/blender 创建 CLI
```

### 分阶段执行

```
执行 CLI-Anything Phase 0：获取 https://github.com/GNOME/gimp 源码
执行 CLI-Anything Phase 1 分析代码
执行 CLI-Anything Phase 3 实现 CLI
```

### 本地路径

```
为 ./myapp 构建 CLI
在 /home/user/projects/gimp 上运行 CLI-Anything
```

## 文件结构

```
openclaw-skill/
├── SKILL.md                      # 主技能文档
├── README.md                     # 本文件
├── references/
│   ├── HARNESS.md               # CLI-Anything 方法论
│   └── quick-reference.md       # 快速参考
└── examples/                     # 示例实现
```

## 工作原理

本 skill 将 CLI-Anything 的 7 阶段流程映射到 OpenClaw 的原生工具：

| 阶段 | 工具 |
|------|------|
| Phase 0 | `web_fetch` / `exec: git clone` |
| Phase 1 | `read` + `exec: find/grep` |
| Phase 2 | `write` 架构文档 |
| Phase 3 | `write` Python 代码 |
| Phase 4 | `write` 测试计划 |
| Phase 5 | `write` + `exec: pytest` |
| Phase 6 | `exec: pytest` 更新文档 |
| Phase 7 | `exec: pip install -e .` |

## 与 ACP/OpenCode 对比

| 特性 | ACP + OpenCode | 本 Skill |
|------|---------------|----------|
| 依赖 | acpx + OpenCode | 仅 OpenClaw |
| 执行 | 间接（ACP 会话） | 直接（原生） |
| 调试 | 较难 | 容易 |
| 分阶段 | 困难 | 容易 |
| 并行 | 受限 | 支持 subagents |

## 上游仓库

本 skill 是 [CLI-Anything](https://github.com/HKUDS/CLI-Anything) 的衍生实现，
遵循相同的 7 阶段方法论和输出规范。

## License

与上游 CLI-Anything 相同：MIT License
