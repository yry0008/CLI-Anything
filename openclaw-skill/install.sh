#!/bin/bash
# Install CLI-Anything Native skill for OpenClaw
# Usage: ./install.sh [venv_path]
#   venv_path: Optional path to Python virtual environment
#              Default: <cli-anything-repo>/.venv

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ANYTHING_REPO="$(dirname "$SKILL_DIR")"

# Target directory in OpenClaw workspace
TARGET_DIR="${HOME}/.openclaw/workspace/skills/cli-anything-native"

# Virtual environment path (default: repo/.venv)
VENV_PATH="${1:-$CLI_ANYTHING_REPO/.venv}"

# Python version
PYTHON_VERSION="3.12"

echo "══════════════════════════════════════════════════════════════════"
echo "  CLI-Anything Native Skill Installer"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "Skill source: $SKILL_DIR"
echo "Install target: $TARGET_DIR"
echo "Virtual env: $VENV_PATH"
echo "Python version: $PYTHON_VERSION"
echo ""

# Check for uv
USE_UV=false
if command -v uv &> /dev/null; then
    USE_UV=true
    echo "✅ uv detected - using uv for faster Python management"
else
    echo "ℹ️  uv not found - using standard Python venv"
    echo "   (Install uv for faster setup: https://github.com/astral-sh/uv)"
fi
echo ""

# Create skills directory if not exists
mkdir -p "$(dirname "$TARGET_DIR")"

# Remove existing installation if present
if [ -e "$TARGET_DIR" ]; then
    echo "⚠️  Removing existing skill installation..."
    rm -rf "$TARGET_DIR"
fi

# Copy skill files
echo "📁 Copying skill files..."
cp -r "$SKILL_DIR" "$TARGET_DIR"

# Make scripts executable
chmod +x "$TARGET_DIR/skill-manager.py"

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_PATH" ]; then
    echo ""
    echo "🐍 Creating Python $PYTHON_VERSION virtual environment..."
    
    if [ "$USE_UV" = true ]; then
        # Use uv for faster setup
        echo "   Using uv..."
        uv venv "$VENV_PATH" --python "$PYTHON_VERSION"
        
        echo ""
        echo "📦 Installing dependencies with uv..."
        uv pip install --python "$VENV_PATH/bin/python" click prompt-toolkit pytest pytest-cov
    else
        # Standard venv approach
        if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 12) else 1)" 2>/dev/null; then
            echo "⚠️  Python 3.12+ not found, trying to install..."
            if command -v pyenv &> /dev/null; then
                pyenv install -s 3.12
                pyenv local 3.12
            else
                echo "   Using system Python (may not be 3.12)"
            fi
        fi
        
        python3 -m venv "$VENV_PATH"
        echo "✅ Virtual environment created at: $VENV_PATH"
        
        echo ""
        echo "📦 Installing dependencies..."
        "$VENV_PATH/bin/pip" install --upgrade pip
        "$VENV_PATH/bin/pip" install click prompt-toolkit pytest pytest-cov
    fi
    
    echo "✅ Dependencies installed"
else
    echo ""
    echo "ℹ️  Virtual environment already exists at: $VENV_PATH"
    
    # Check Python version in existing venv
    VENV_PYTHON="$VENV_PATH/bin/python"
    if [ -f "$VENV_PYTHON" ]; then
        VENV_PY_VERSION=$($VENV_PYTHON --version 2>&1 | grep -oP '\d+\.\d+')
        echo "   Python version: $VENV_PY_VERSION"
        
        if [ "$VENV_PY_VERSION" != "$PYTHON_VERSION" ]; then
            echo "⚠️  Warning: Expected Python $PYTHON_VERSION, found $VENV_PY_VERSION"
        fi
    fi
fi

# Create activation helper script
cat > "$TARGET_DIR/activate-venv" << EOF
#!/bin/bash
# Activate the CLI-Anything virtual environment
source "$VENV_PATH/bin/activate"
echo "✅ Virtual environment activated: $VENV_PATH"
echo "Python: \$(which python3) (\$(python3 --version))"
echo "Pip: \$(which pip)"
EOF
chmod +x "$TARGET_DIR/activate-venv"

# Create skill configuration
cat > "$TARGET_DIR/skill-config.json" << EOF
{
  "name": "cli-anything-native",
  "version": "1.0.0",
  "venv_path": "$VENV_PATH",
  "python_version": "$PYTHON_VERSION",
  "use_uv": $USE_UV,
  "cli_anything_repo": "$CLI_ANYTHING_REPO",
  "install_date": "$(date -Iseconds)"
}
EOF

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  ✅ CLI-Anything Native skill installed successfully!"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "📍 Installation Summary:"
echo "   Skill: $TARGET_DIR"
echo "   Venv:  $VENV_PATH"
echo "   Python: $PYTHON_VERSION"
if [ "$USE_UV" = true ]; then
    echo "   Package Manager: uv"
else
    echo "   Package Manager: pip"
fi
echo ""
echo "🔧 Usage:"
echo "   1. Activate venv: source $TARGET_DIR/activate-venv"
echo "   2. Or directly: $VENV_PATH/bin/python <script>"
echo "   3. Skill manager: $TARGET_DIR/skill-manager.py status"
echo ""
echo "💡 You can now use commands like:"
echo "   '为 GIMP 生成 CLI 工具'"
echo "   '使用 CLI-Anything 为 https://github.com/blender/blender 创建 CLI'"
echo ""
echo "📖 For custom venv location, use:"
echo "   ./install.sh /path/to/venv"
echo ""
