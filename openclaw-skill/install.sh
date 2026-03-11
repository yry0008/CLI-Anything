#!/bin/bash
# Install CLI-Anything Native skill for OpenClaw

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.openclaw/skills/cli-anything-native"

echo "Installing CLI-Anything Native skill..."
echo "Source: $SKILL_DIR"
echo "Target: $TARGET_DIR"

# Create skills directory if not exists
mkdir -p "$(dirname "$TARGET_DIR")"

# Remove existing installation if present
if [ -e "$TARGET_DIR" ]; then
    echo "Removing existing installation..."
    rm -rf "$TARGET_DIR"
fi

# Copy skill files
cp -r "$SKILL_DIR" "$TARGET_DIR"

echo ""
echo "✅ CLI-Anything Native skill installed successfully!"
echo ""
echo "You can now use commands like:"
echo "  '为 GIMP 生成 CLI 工具'"
echo "  '使用 CLI-Anything 为 https://github.com/blender/blender 创建 CLI'"
