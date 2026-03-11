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

echo "══════════════════════════════════════════════════════════════════"
echo "  CLI-Anything Native Skill Installer"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "Skill source: $SKILL_DIR"
echo "Install target: $TARGET_DIR"
echo "Virtual env: $VENV_PATH"
echo ""

# Create skills directory if not exists
mkdir -p "$(dirname "$TARGET_DIR")"

# Remove existing installation if present
if [ -e "$TARGET_DIR" ]; then
    echo "⚠️  Removing existing installation..."
    rm -rf "$TARGET_DIR"
fi

# Copy skill files
echo "📁 Copying skill files..."
cp -r "$SKILL_DIR" "$TARGET_DIR"

# Make skill-manager.py executable
chmod +x "$TARGET_DIR/skill-manager.py"

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_PATH" ]; then
    echo ""
    echo "🐍 Creating Python virtual environment..."
    python3 -m venv "$VENV_PATH"
    echo "✅ Virtual environment created at: $VENV_PATH"
    
    # Install dependencies in venv
    echo ""
    echo "📦 Installing dependencies in virtual environment..."
    "$VENV_PATH/bin/pip" install --upgrade pip
    "$VENV_PATH/bin/pip" install click prompt-toolkit pytest pytest-cov
    echo "✅ Dependencies installed"
else
    echo ""
    echo "ℹ️  Virtual environment already exists at: $VENV_PATH"
fi

# Create activation helper script
cat > "$TARGET_DIR/activate-venv" << EOF
#!/bin/bash
# Activate the CLI-Anything virtual environment
source "$VENV_PATH/bin/activate"
echo "✅ Virtual environment activated: $VENV_PATH"
echo "Python: \$(which python3)"
echo "Pip: \$(which pip)"
EOF
chmod +x "$TARGET_DIR/activate-venv"

# Create skill configuration
cat > "$TARGET_DIR/skill-config.json" << EOF
{
  "name": "cli-anything-native",
  "version": "1.0.0",
  "venv_path": "$VENV_PATH",
  "cli_anything_repo": "$CLI_ANYTHING_REPO",
  "install_date": "$(date -Iseconds)"
}
EOF

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  ✅ CLI-Anything Native skill installed successfully!"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "📍 Installation location:"
echo "   Skill: $TARGET_DIR"
echo "   Venv:  $VENV_PATH"
echo ""
echo "🔧 Usage:"
echo "   1. Activate venv: source $TARGET_DIR/activate-venv"
echo "   2. Or directly: $VENV_PATH/bin/python <script>"
echo ""
echo "💡 You can now use commands like:"
echo "   '为 GIMP 生成 CLI 工具'"
echo "   '使用 CLI-Anything 为 https://github.com/blender/blender 创建 CLI'"
echo ""
echo "📖 For custom venv location, use:"
echo "   ./install.sh /path/to/your/venv"
echo ""
