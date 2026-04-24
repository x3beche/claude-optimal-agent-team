#!/bin/bash

# Claude Agent Team — Install Script
# Run this from your project root:
#   bash /path/to/claude-agent-team/install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

echo ""
echo "🤖 Claude Agent Team — Installer"
echo "================================="
echo ""
echo "Project directory: $PROJECT_DIR"
echo ""

# Check Claude Code version
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo "✅ Claude Code found: $CLAUDE_VERSION"
else
    echo "❌ Claude Code not found. Install it first:"
    echo "   https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Check tmux
if command -v tmux &> /dev/null; then
    echo "✅ tmux found"
else
    echo "❌ tmux not found. Install it:"
    echo "   macOS:  brew install tmux"
    echo "   Linux:  sudo apt install tmux"
    exit 1
fi

# Copy CLAUDE.md
if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    echo ""
    read -p "⚠️  CLAUDE.md already exists. Overwrite? (y/N): " OVERWRITE
    if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
        cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
        echo "✅ CLAUDE.md overwritten"
    else
        echo "⏭️  Skipped CLAUDE.md"
    fi
else
    cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
    echo "✅ CLAUDE.md copied to project root"
fi

# Copy settings.json
echo ""
echo "Where should settings.json go?"
echo "  1) Project-level: $PROJECT_DIR/.claude/settings.json (recommended)"
echo "  2) Global: ~/.claude/settings.json (applies to all projects)"
echo ""
read -p "Choose (1/2): " SETTINGS_CHOICE

if [ "$SETTINGS_CHOICE" = "2" ]; then
    mkdir -p "$HOME/.claude"
    if [ -f "$HOME/.claude/settings.json" ]; then
        read -p "⚠️  ~/.claude/settings.json already exists. Overwrite? (y/N): " OVERWRITE
        if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
            cp "$SCRIPT_DIR/config/settings.json" "$HOME/.claude/settings.json"
            echo "✅ settings.json copied to ~/.claude/"
        else
            echo "⏭️  Skipped settings.json"
        fi
    else
        cp "$SCRIPT_DIR/config/settings.json" "$HOME/.claude/settings.json"
        echo "✅ settings.json copied to ~/.claude/"
    fi
else
    mkdir -p "$PROJECT_DIR/.claude"
    if [ -f "$PROJECT_DIR/.claude/settings.json" ]; then
        read -p "⚠️  .claude/settings.json already exists. Overwrite? (y/N): " OVERWRITE
        if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
            cp "$SCRIPT_DIR/config/settings.json" "$PROJECT_DIR/.claude/settings.json"
            echo "✅ settings.json copied to .claude/"
        else
            echo "⏭️  Skipped settings.json"
        fi
    else
        cp "$SCRIPT_DIR/config/settings.json" "$PROJECT_DIR/.claude/settings.json"
        echo "✅ settings.json copied to .claude/"
    fi
fi

# Install Playwright browsers
echo ""
read -p "Install Playwright browsers? (~200MB download) (Y/n): " INSTALL_PW
if [ "$INSTALL_PW" != "n" ] && [ "$INSTALL_PW" != "N" ]; then
    npx playwright install
    echo "✅ Playwright browsers installed"
else
    echo "⏭️  Skipped Playwright install (run 'npx playwright install' later)"
fi

# Done
echo ""
echo "================================="
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Start your dev server in one terminal"
echo "  2. In another terminal:"
echo "     cd $PROJECT_DIR"
echo "     tmux"
echo "     claude"
echo "  3. Paste the prompt from: $SCRIPT_DIR/prompt.md"
echo ""
echo "Use Shift+Down to switch between agent panes."
echo "================================="
echo ""
