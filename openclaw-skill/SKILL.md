---
name: cli-anything-native
description: Native OpenClaw integration for CLI-Anything - automatically generate CLI harnesses for any GUI application without requiring ACP or external AI agents. Implements the complete 7-phase CLI-Anything methodology using OpenClaw's native tools (read, write, exec, subagents). Use when the user wants to (1) Build a CLI harness for a GUI software without ACP/OpenCode, (2) Generate CLI tools natively within OpenClaw, (3) Create agent-controllable interfaces for GUI applications, (4) Convert GUI software to CLI using the full 7-phase workflow.
---

# CLI-Anything Native (OpenClaw Integration)

**无需 ACP、无需 OpenCode** — 纯原生 OpenClaw 实现 CLI-Anything 方法论。

## 什么是 CLI-Anything Native？

这是 CLI-Anything 的原生 OpenClaw 实现，直接使用 OpenClaw 的工具（`read`, `write`, `exec`, `subagents`）完成 7 阶段 CLI 生成流程。

### 与 ACP/OpenCode 方案的区别

| 特性 | ACP + OpenCode | 原生 Skill |
|------|---------------|-----------|
| 外部依赖 | 需要 acpx + OpenCode | 仅 OpenClaw |
| 执行方式 | 间接（通过 ACP 会话） | 直接（原生工具）|
| 错误处理 | 较难调试 | 精确控制 |
| 可分阶段 | 困难 | 容易 |
| 并行化 | 受限 | 支持 subagents |

## 7 阶段实现方式

| 阶段 | OpenCode 方式 | **原生 Skill 方式** |
|------|--------------|---------------------|
| Phase 0 | 读取命令文件 | `web_fetch` / `exec: git clone` |
| Phase 1 | AI 分析 | `read` + `exec: find/grep` 分析 |
| Phase 2 | AI 设计 | `write` 生成架构文档 |
| Phase 3 | AI 实现 | `write` 生成 Python 代码 |
| Phase 4 | AI 规划 | `write` 生成 TEST.md |
| Phase 5 | AI 测试 | `write` + `exec: pytest` |
| Phase 6 | AI 文档 | `exec: pytest` 更新文档 |
| Phase 7 | AI 发布 | `exec: pip install -e .` |

## 安装

### 安装位置

Skill 安装在：`~/.openclaw/workspace/skills/cli-anything-native`

虚拟环境位置：`~/.openclaw/workspace/skills/cli-anything-native/.venv`

CLI 访问：`~/.local/bin/cli-anything-*`

### 安装方式

```bash
cd /path/to/CLI-Anything/openclaw-skill
./install.sh
```

安装脚本会自动：
1. 复制 skill 文件到 `~/.openclaw/workspace/skills/cli-anything-native`
2. 在 skill 目录创建 **Python 3.12** 虚拟环境 (`.venv`)
3. 安装依赖包（click, prompt-toolkit, pytest）
4. 为 `cli-anything-*` 命令创建 wrapper 脚本到 `~/.local/bin`

**uv 支持**：如果系统安装了 [uv](https://github.com/astral-sh/uv)，会自动使用 uv 管理环境（比 pip 快 10-100 倍）

### CLI 命令访问

安装后，所有 `cli-anything-*` 命令都可以通过 `~/.local/bin` 访问：

```bash
# 如果 ~/.local/bin 在 PATH 中
cli-anything-gimp project new -o test.json

# 或通过完整路径
~/.local/bin/cli-anything-gimp --help
```

**注意**：如果 `~/.local/bin` 不在 PATH 中，请添加：
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### 虚拟环境

**venv 位置**：`~/.openclaw/workspace/skills/cli-anything-native/.venv`

**Python 版本**：默认 3.12，确保最佳兼容性

**为什么使用 venv？**
- 隔离依赖，不影响系统 Python
- Python 3.12 特性支持
- uv 支持（如果使用）
- 明确的依赖版本控制
- 避免权限冲突

**激活 venv**（开发用）：
```bash
source ~/.openclaw/workspace/skills/cli-anything-native/activate-venv
```

## 使用方法

### 方式 1：完整 7 阶段（推荐）

```
为我为 GIMP 生成一个 CLI 工具
使用 CLI-Anything 为 https://github.com/blender/blender 创建 CLI
```

### 方式 2：分阶段执行

```
执行 CLI-Anything Phase 0：下载源码
执行 CLI-Anything Phase 1：分析代码
执行 CLI-Anything Phase 3：实现 CLI
```

### 方式 3：指定路径

```
在 /path/to/software 上运行 CLI-Anything
为 ./myapp 构建 CLI
```

## 工作流程

### Phase 0: Source Acquisition（源码获取）

**触发条件**：用户提供的是 GitHub URL 而非本地路径

**执行步骤**：
1. `web_fetch` 或 `gh repo clone` 获取源码
2. `exec: ls -la` 验证目录结构
3. 确定软件名称（从目录名或 URL 提取）

**输出**：本地源码路径

### Phase 1: Codebase Analysis（代码分析）

**目标**：理解软件架构、识别后端引擎、数据模型

**执行步骤**：
1. `read` 关键源码文件（README, main entry points）
2. `exec: find . -name "*.py" -o -name "*.js" | head -20` 了解代码结构
3. `exec: grep -r "render\|export\|save" --include="*.py" | head -10` 找关键功能
4. `write` 生成 `<SOFTWARE>.md` 架构文档

**输出**：
- `<SOFTWARE>.md`：软件特定的架构 SOP
- 后端引擎识别（如：Pillow, MLT, bpy, LibreOffice）
- 数据模型定义（项目文件格式、状态结构）

### Phase 2: CLI Architecture Design（架构设计）

**目标**：设计命令分组、状态模型、输出格式

**执行步骤**：
1. 分析 Phase 1 结果
2. 设计命令树（按功能领域分组）
3. 定义项目 JSON 格式
4. `write` 更新 `<SOFTWARE>.md` 设计部分

**输出**：
- 命令分组设计（如：project, layer, filter, export）
- 状态模型定义
- JSON 输出格式规范

### Phase 3: Implementation（实现）

**目标**：生成完整的 Python CLI 包

**执行步骤**：
1. `exec: mkdir -p agent-harness/cli_anything/<software>/{core,utils,tests}`
2. `write` 生成核心模块：
   - `core/project.py` - 项目管理
   - `core/session.py` - 会话/撤销
   - `core/export.py` - 渲染导出
   - `utils/<software>_backend.py` - 后端调用
   - `utils/repl_skin.py` - REPL 界面
3. `write` 生成 `<software>_cli.py` - Click CLI 入口
4. `write` 生成 `setup.py`
5. `write` 生成 `README.md`

**输出结构**：
```
<software>/
└── agent-harness/
    ├── <SOFTWARE>.md
    ├── setup.py
    └── cli_anything/
        └── <software>/
            ├── __init__.py
            ├── <software>_cli.py
            ├── README.md
            ├── core/
            │   ├── __init__.py
            │   ├── project.py
            │   ├── session.py
            │   └── export.py
            ├── utils/
            │   ├── __init__.py
            │   ├── <software>_backend.py
            │   └── repl_skin.py
            └── tests/
                ├── __init__.py
                ├── TEST.md
                ├── test_core.py
                └── test_full_e2e.py
```

### Phase 4: Test Planning（测试规划）

**目标**：创建全面的测试计划

**执行步骤**：
1. 分析已实现的功能
2. 设计单元测试场景（合成数据）
3. 设计 E2E 测试场景（真实文件）
4. `write` 生成 `TEST.md`

**输出**：
- `TEST.md`：测试计划和预期结果

### Phase 5: Test Implementation（测试实现）

**目标**：编写并运行测试

**执行步骤**：
1. `write` 生成 `tests/test_core.py` - 单元测试
2. `write` 生成 `tests/test_full_e2e.py` - E2E 测试
3. `exec: pip install pytest pytest-cov` - 安装测试依赖
4. `exec: pytest tests/ -v --tb=short` - 运行测试

**输出**：
- 测试文件
- 测试结果

### Phase 6: Test Documentation（测试文档）

**目标**：记录测试结果

**执行步骤**：
1. 收集 pytest 输出
2. `write` 更新 `TEST.md` 添加测试结果

**输出**：
- 完整的 TEST.md（包含计划和结果）

### Phase 7: PyPI Publishing（发布安装）

**目标**：本地安装并验证

**执行步骤**：
1. 激活虚拟环境（如果配置了）
2. `exec: pip install -e .` - 可编辑模式安装
3. `exec: which cli-anything-<software>` - 验证 PATH
4. `exec: cli-anything-<software> --help` - 验证 CLI 可用

**注意**：使用虚拟环境时，确保在执行 pip 安装前已激活 venv：
```bash
source /path/to/venv/bin/activate
pip install -e .
```

**输出**：
- 可用的 CLI 命令（安装在 venv 的 bin 目录中）

## 核心原则（来自 HARNESS.md）

### #1 规则：使用真实软件

CLI 必须调用实际软件进行渲染，不要重新实现渲染引擎。

```python
# ✅ 正确：调用真实软件
subprocess.run([
    "libreoffice", "--headless",
    "--convert-to", "pdf",
    project_path
])

# ❌ 错误：用 Pillow 重新实现
# image.save(output_path)  # 这样会丢失 LibreOffice 特有的格式支持
```

### 关键设计原则

1. **命名空间包**：`cli_anything/` 无 `__init__.py`（PEP 420）
2. **真实软件调用**：使用 `shutil.which()` 查找后端
3. **状态化 REPL**：支持会话和撤销/重做
4. **JSON 输出**：所有命令支持 `--json`
5. **验证输出**：检查文件魔数和格式

## 支持的软件类别

| 类别 | 示例 | 后端 |
|------|------|------|
| 图像编辑 | GIMP, Krita | Pillow/GEGL |
| 3D 建模 | Blender | bpy |
| 视频剪辑 | Kdenlive, Shotcut | MLT/melt |
| 办公套件 | LibreOffice | ODF + headless |
| 矢量图形 | Inkscape | SVG |
| 音频制作 | Audacity | wave/sox |

## 故障排除

| 问题 | 解决方案 |
|------|---------|
| 源码分析不完整 | 增加 `read` 的关键文件数量 |
| 后端找不到 | `exec: which <software>` 检查安装 |
| 测试失败 | 检查软件是否正确安装 |
| 安装后不在 PATH | 确保 `pip install -e .` 成功 |

## 参考文档

- `references/HARNESS.md` - CLI-Anything 完整方法论
- `references/quick-reference.md` - 快速参考
- `examples/` - 示例实现

## 与 CLI-Anything 上游的关系

本 skill 是 CLI-Anything 的**原生实现**，不修改上游代码：
- 遵循相同的 7 阶段方法论
- 生成相同的目录结构
- 输出与 CLI-Anything 生成的 CLI 完全兼容
- 可以导入和使用 CLI-Anything 仓库中的示例

---

**CLI-Anything Native** — 一行命令，任何软件成为 Agent 的原生工具。
