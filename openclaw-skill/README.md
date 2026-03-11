# CLI-Anything Native - OpenClaw Skill

纯原生 OpenClaw 实现的 CLI-Anything，无需 ACP、无需 OpenCode。

## 特点

- ✅ **零外部依赖**：不需要 acpx 插件或 OpenCode
- ✅ **原生工具**：直接使用 OpenClaw 的 read/write/exec/subagents
- ✅ **完全兼容**：生成的 CLI 与 CLI-Anything 标准一致
- ✅ **可分阶段**：支持分阶段执行，便于调试
- ✅ **并行加速**：使用 subagents 加速多阶段任务
- ✅ **Python 虚拟环境**：自动创建和管理 venv，避免污染系统环境
- ✅ **uv 支持**：如果系统安装了 uv，自动使用 uv 管理环境（更快）
- ✅ **Python 3.12**：默认使用 Python 3.12，确保最佳兼容性

## 安装

### 方式 1：使用安装脚本（推荐）

```bash
cd /path/to/CLI-Anything/openclaw-skill
./install.sh
```

这将：
1. 安装 skill 到 `~/.openclaw/workspace/skills/cli-anything-native`
2. 在 `CLI-Anything/.venv` 创建 Python 3.12 虚拟环境
3. 安装所需依赖 (click, prompt-toolkit, pytest)

**如果系统安装了 uv**，会自动使用 uv（比标准 pip 快 10-100 倍）

### 方式 2：指定自定义 venv 路径

```bash
./install.sh /path/to/your/venv
```

### 方式 3：使用 uv 安装（最快）

如果你已经安装了 [uv](https://github.com/astral-sh/uv)：

```bash
# install.sh 会自动检测并使用 uv
./install.sh

# 或者手动使用 uv
uv venv CLI-Anything/.venv --python 3.12
uv pip install --python CLI-Anything/.venv/bin/python click prompt-toolkit pytest
```

uv 的优势：
- 比 pip 快 10-100 倍
- 自动管理 Python 版本
- 并行下载和安装

### 方式 4：手动安装

```bash
# 创建目录
mkdir -p ~/.openclaw/workspace/skills

# 复制 skill
cp -r openclaw-skill ~/.openclaw/workspace/skills/cli-anything-native

# 创建虚拟环境（推荐）
cd /path/to/CLI-Anything
python3 -m venv .venv
source .venv/bin/activate
pip install click prompt-toolkit pytest pytest-cov
```

### 方式 5：软链接（开发模式）

```bash
ln -s $(pwd)/openclaw-skill ~/.openclaw/workspace/skills/cli-anything-native
```

## 虚拟环境管理

### 激活虚拟环境

```bash
# 方式 1：使用生成的激活脚本
source ~/.openclaw/workspace/skills/cli-anything-native/activate-venv

# 方式 2：直接使用 venv
source /path/to/CLI-Anything/.venv/bin/activate
```

### 虚拟环境位置

| 安装方式 | 默认 venv 位置 |
|---------|--------------|
| `./install.sh` | `CLI-Anything/.venv` |
| `./install.sh /custom/path` | `/custom/path` |
| 手动 | 用户指定 |

### 为什么要用 venv？

1. **隔离依赖**：不影响系统 Python 环境
2. **版本控制**：可以为不同项目使用不同依赖版本
3. **安全**：避免权限问题和系统包冲突
4. **Python 3.12**：使用最新的 Python 特性

### uv vs pip

| 特性 | uv | pip |
|------|-----|-----|
| 速度 | ⚡ 10-100x 更快 | 🐢 标准速度 |
| Python 管理 | ✅ 内置 | ❌ 需单独安装 |
| 兼容性 | ✅ 兼容 pip | - 标准 |
| 安装 | `cargo install uv` | 预装 |

推荐使用 uv：`curl -LsSf https://astral.sh/uv/install.sh | sh`
4. **可复现**：明确依赖版本，便于部署

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
├── install.sh                    # 安装脚本（支持 venv）
├── activate-venv                 # 生成的 venv 激活脚本
├── skill-config.json             # 技能配置（包含 venv 路径）
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
| Python 环境 | 依赖外部 | 自带 venv |

## 上游仓库

本 skill 是 [CLI-Anything](https://github.com/HKUDS/CLI-Anything) 的衍生实现，
遵循相同的 7 阶段方法论和输出规范。

## License

与上游 CLI-Anything 相同：MIT License
