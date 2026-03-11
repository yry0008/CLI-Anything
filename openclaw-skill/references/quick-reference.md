# CLI-Anything 快速参考

## 7 阶段速查

```
Phase 0: 源码获取 → web_fetch / git clone
Phase 1: 代码分析 → read + grep/find
Phase 2: 架构设计 → write <SOFTWARE>.md
Phase 3: 实现 → write Python 代码
Phase 4: 测试规划 → write TEST.md
Phase 5: 测试实现 → write tests/ + pytest
Phase 6: 测试文档 → 更新 TEST.md
Phase 7: 发布安装 → pip install -e .
```

## 目录结构模板

```
<software>/
└── agent-harness/
    ├── <SOFTWARE>.md          # 架构 SOP
    ├── setup.py               # find_namespace_packages
    └── cli_anything/          # 无 __init__.py
        └── <software>/        # 有 __init__.py
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

## setup.py 模板

```python
from setuptools import setup, find_namespace_packages

setup(
    name="cli-anything-<software>",
    version="1.0.0",
    packages=find_namespace_packages(include=["cli_anything.*"]),
    install_requires=["click>=8.0.0", "prompt-toolkit>=3.0.0"],
    entry_points={
        "console_scripts": [
            "cli-anything-<software>=cli_anything.<software>.<software>_cli:main",
        ],
    },
)
```

## 后端调用模板

```python
import shutil
import subprocess

def find_<software>():
    """查找软件可执行文件"""
    path = shutil.which("<software>")
    if path:
        return path
    raise RuntimeError(
        "<Software> 未安装。请安装：\n"
        "  apt install <software>  # Debian/Ubuntu\n"
        "  brew install <software>  # macOS"
    )

def render_project(project_path, output_path, **kwargs):
    """调用真实软件进行渲染"""
    software = find_<software>()
    subprocess.run([
        software, "--headless",
        "--convert-to", "pdf",
        "--outdir", output_dir,
        project_path,
    ], check=True)
    return {"output": output_path, "format": "pdf"}
```

## OpenClaw 工具映射

| 原功能 | OpenClaw 工具 |
|--------|--------------|
| 读取文件 | `read` |
| 写入文件 | `write` |
| 执行命令 | `exec` |
| 克隆仓库 | `exec: gh clone` 或 `web_fetch` |
| 分析代码 | `read` + `exec: grep/find` |
| 并行任务 | `sessions_spawn` (subagents) |

## 常见后端

| 软件 | 后端 CLI | 格式 |
|------|----------|------|
| LibreOffice | `libreoffice --headless` | ODF ZIP |
| Blender | `blender --background --python` | .blend |
| GIMP | `gimp -i -b -` | .xcf |
| Inkscape | `inkscape --actions=` | SVG |
| MLT 视频 | `melt` | MLT XML |
| Audacity | `sox` | .aup3 |

## 关键原则

1. **使用真实软件**：调用实际软件渲染，不要重新实现
2. **软件是硬依赖**：未安装时报错
3. **命名空间包**：`cli_anything/` 无 `__init__.py`
4. **JSON 输出**：所有命令支持 `--json`
5. **验证输出**：检查文件格式和内容
