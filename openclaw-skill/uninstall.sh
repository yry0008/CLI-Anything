#!/bin/bash
# Uninstall CLI-Anything Native skill for OpenClaw

set -e

TARGET_DIR="${HOME}/.openclaw/workspace/skills/cli-anything-native"
LOCAL_BIN="${HOME}/.local/bin"

echo "══════════════════════════════════════════════════════════════════"
echo "  CLI-Anything Native Skill Uninstaller"
echo "══════════════════════════════════════════════════════════════════"
echo ""

# Check if skill is installed
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Skill not found at: $TARGET_DIR"
    echo "   Nothing to uninstall."
    exit 1
fi

# Read configuration if available
CONFIG_FILE="$TARGET_DIR/skill-config.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "📖 Reading configuration..."
    VENV_PATH=$(grep -o '"venv_path": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    echo "   Venv path: $VENV_PATH"
fi

echo ""
echo "⚠️  This will remove:"
echo "   - Skill directory: $TARGET_DIR"
echo "   - Wrapper scripts: $LOCAL_BIN/cli-anything-*"
echo ""
read -p "Are you sure you want to uninstall? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "🗑️  Uninstalling..."

# Remove wrapper scripts
echo "   Removing wrapper scripts..."
wrapper_count=0
for wrapper in "$LOCAL_BIN"/cli-anything-*; do
    if [ -f "$wrapper" ]; then
        # Check if it's our wrapper (contains "CLI-Anything Native Skill")
        if grep -q "CLI-Anything Native Skill" "$wrapper" 2>/dev/null; then
            rm "$wrapper"
            echo "     Removed: $(basename "$wrapper")"
            ((wrapper_count++))
        fi
    fi
done

if [ $wrapper_count -eq 0 ]; then
    echo "     No wrapper scripts found"
else
    echo "     Removed $wrapper_count wrapper(s)"
fi

# Remove skill directory
echo "   Removing skill directory..."
if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
    echo "     Removed: $TARGET_DIR"
fi

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  ✅ CLI-Anything Native skill uninstalled successfully!"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "Note: If you added ~/.local/bin to your PATH manually,"
echo "      you may want to remove it from your shell config."
echo ""
