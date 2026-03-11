# CLI-Anything Native 使用示例

## 示例 1：为 GIMP 生成 CLI

### 用户输入
```
为 https://github.com/GNOME/gimp 生成一个 CLI 工具
```

### Skill 执行流程

#### Phase 0: Source Acquisition
```bash
gh repo clone https://github.com/GNOME/gimp /tmp/gimp-source
cd /tmp/gimp-source
```

#### Phase 1: Codebase Analysis
- 读取 README.md 了解项目结构
- 使用 `find` 和 `grep` 分析关键文件
- 识别后端引擎（GEGL、Pillow）
- 生成 GIMP.md 架构文档

#### Phase 2: CLI Architecture Design
- 设计命令分组：project, layer, filter, export
- 定义项目 JSON 格式
- 规划 REPL 交互

#### Phase 3: Implementation
生成以下文件：
```
gimp/agent-harness/
├── GIMP.md
├── setup.py
└── cli_anything/
    └── gimp/
        ├── __init__.py
        ├── gimp_cli.py
        ├── README.md
        ├── core/
        │   ├── __init__.py
        │   ├── project.py
        │   ├── session.py
        │   ├── layers.py
        │   ├── filters.py
        │   └── export.py
        ├── utils/
        │   ├── __init__.py
        │   ├── gimp_backend.py
        │   └── repl_skin.py
        └── tests/
            ├── __init__.py
            ├── TEST.md
            ├── test_core.py
            └── test_full_e2e.py
```

#### Phase 4-7: Test and Publish
```bash
cd gimp/agent-harness
pip install -e .
pytest tests/ -v
which cli-anything-gimp
```

## 示例 2：为本地软件生成 CLI

### 用户输入
```
为 ./my-custom-app 构建 CLI
```

### 执行
直接跳转到 Phase 1（源码已在本地）

## 示例 3：分阶段执行

### 用户输入
```
执行 CLI-Anything Phase 1-3 分析并实现 ./blender
```

### 执行
仅执行 Phase 1, 2, 3，跳过测试和发布

## 生成的 CLI 使用示例

```bash
# 安装后使用
cli-anything-gimp project new -o poster.json --width 1920 --height 1080
cli-anything-gimp --project poster.json layer add -n "Background"
cli-anything-gimp --project poster.json export render output.png

# REPL 模式
cli-anything-gimp
> project new --width 800 --height 600
> layer add-from-file photo.jpg
> filter add blur --radius 2
> export render output.jpg
> exit
```
