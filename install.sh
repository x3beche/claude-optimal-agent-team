#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

echo ""
echo "Claude Agent Team - Installer"
echo "================================="
echo "Project: $PROJECT_DIR"
echo ""

command -v claude &>/dev/null && echo "Claude Code found" || { echo "Claude Code not found"; exit 1; }
command -v tmux &>/dev/null && echo "tmux found" || { echo "tmux not found (brew install tmux / sudo apt install tmux)"; exit 1; }

if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    read -p "CLAUDE.md exists. Overwrite? (y/N): " OW
    [ "$OW" = "y" ] || [ "$OW" = "Y" ] && cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md" && echo "CLAUDE.md overwritten" || echo "Skipped"
else
    cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
    echo "CLAUDE.md copied"
fi

echo ""
echo "Settings location:"
echo "  1) Project: .claude/settings.json (recommended)"
echo "  2) Global: ~/.claude/settings.json"
read -p "Choose (1/2): " SC
if [ "$SC" = "2" ]; then
    mkdir -p "$HOME/.claude" && cp "$SCRIPT_DIR/.claude/settings.json" "$HOME/.claude/" && echo "settings.json -> ~/.claude/"
else
    mkdir -p "$PROJECT_DIR/.claude" && cp "$SCRIPT_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/" && echo "settings.json -> .claude/"
fi

echo ""
read -p "Install Playwright browsers? (~200MB) (Y/n): " PW
[ "$PW" != "n" ] && [ "$PW" != "N" ] && npx playwright install && echo "Playwright installed" || echo "Run 'npx playwright install' later"

echo ""
echo "Done! Next: cd $PROJECT_DIR && tmux && claude"
echo "Paste prompt from: $SCRIPT_DIR/prompt.md"
