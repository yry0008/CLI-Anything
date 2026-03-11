#!/bin/bash
# Install CLI-Anything Native skill for OpenClaw
# Usage: ./install.sh [venv_path]
#   venv_path: Optional path to Python virtual environment
#              Default: <skill-dir>/.venv

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_ANYTHING_REPO="$(dirname "$SKILL_DIR")"

# Target directory in OpenClaw workspace
TARGET_DIR="${HOME}/.openclaw/workspace/skills/cli-anything-native"

# Virtual environment path (default: skill-dir/.venv)
VENV_PATH="${1:-$TARGET_DIR/.venv}"

# User local bin directory
LOCAL_BIN="${HOME}/.local/bin"

# Python version
PYTHON_VERSION="3.12"

echo "══════════════════════════════════════════════════════════════════"
echo "  CLI-Anything Native Skill Installer"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "Skill source: $SKILL_DIR"
echo "Install target: $TARGET_DIR"
echo "Virtual env: $VENV_PATH"
echo "Local bin: $LOCAL_BIN"
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

# Create directories
mkdir -p "$(dirname "$TARGET_DIR")"
mkdir -p "$LOCAL_BIN"

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

# Create wrapper scripts for cli-anything-* commands
echo ""
echo "🔗 Creating wrapper scripts in $LOCAL_BIN..."

create_wrapper() {
    local cmd_name=$1
    local wrapper_path="$LOCAL_BIN/$cmd_name"
    
    cat > "$wrapper_path" << EOF
#!/bin/bash
# Auto-generated wrapper for $cmd_name
# Source: CLI-Anything Native Skill
# Venv: $VENV_PATH

export PATH="$VENV_PATH/bin:\$PATH"
export VIRTUAL_ENV="$VENV_PATH"

if [ ! -f "$VENV_PATH/bin/$cmd_name" ]; then
    echo "Error: $cmd_name not found in virtual environment" >&2
    echo "Please reinstall the skill: ./install.sh" >&2
    exit 1
fi

exec "$VENV_PATH/bin/$cmd_name" "\$@"
EOF
    chmod +x "$wrapper_path"
    echo "  ✅ $cmd_name"
}

# Create wrappers for existing cli-anything-* commands
wrapper_count=0
if [ -d "$VENV_PATH/bin" ]; then
    for cmd in "$VENV_PATH"/bin/cli-anything-*; do
        if [ -f "$cmd" ]; then
            cmd_name=$(basename "$cmd")
            create_wrapper "$cmd_name"
            ((wrapper_count++))
        fi
    done
fi

if [ $wrapper_count -eq 0 ]; then
    echo "  ℹ️  No cli-anything-* commands found yet (will be created when you build CLIs)"
fi

# Create skill configuration
cat > "$TARGET_DIR/skill-config.json" << EOF
{
  "name": "cli-anything-native",
  "version": "1.0.0",
  "venv_path": "$VENV_PATH",
  "python_version": "$PYTHON_VERSION",
  "use_uv": $USE_UV,
  "cli_anything_repo": "$CLI_ANYTHING_REPO",
  "local_bin": "$LOCAL_BIN",
  "install_date": "$(date -Iseconds)"
}
EOF

# Create activation helper script (for direct venv access)
cat > "$TARGET_DIR/activate-venv" << EOF
#!/bin/bash
# Activate the CLI-Anything virtual environment directly
source "$VENV_PATH/bin/activate"
echo "✅ Virtual environment activated: $VENV_PATH"
echo "Python: \$(which python3) (\$(python3 --version))"
EOF
chmod +x "$TARGET_DIR/activate-venv"

# Check if ~/.local/bin is in PATH
echo ""
if [[ ":$PATH:" != *":$HOME/.local/bin:"* && ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo "⚠️  Warning: ~/.local/bin is not in your PATH"
    echo ""
    echo "To use the CLI commands, add this to your shell config:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Or run this command now:"
    echo "  export PATH=\"$LOCAL_BIN:\$PATH\""
    echo ""
fi

echo "══════════════════════════════════════════════════════════════════"
echo "  ✅ CLI-Anything Native skill installed successfully!"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "📍 Installation Summary:"
echo "   Skill: $TARGET_DIR"
echo "   Venv:  $VENV_PATH"
echo "   Wrappers: $LOCAL_BIN/cli-anything-*"
echo "   Python: $PYTHON_VERSION"
if [ "$USE_UV" = true ]; then
    echo "   Package Manager: uv"
else
    echo "   Package Manager: pip"
fi
echo ""
echo "🔧 Usage:"
echo "   CLI commands: cli-anything-<software> <args>"
echo "   Direct venv:  source $TARGET_DIR/activate-venv"
echo "   Manager:      $TARGET_DIR/skill-manager.py status"
echo ""
echo "💡 Quick start:"
echo "   '为 GIMP 生成 CLI 工具'"
echo "   '使用 CLI-Anything 为 https://github.com/blender/blender 创建 CLI'"
echo ""

# Print PATH reminder if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* && ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo "⚠️  Remember to add ~/.local/bin to your PATH!"
    echo ""
fi
