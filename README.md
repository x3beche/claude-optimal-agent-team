# Claude Agent Team

A five-agent system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that handles the entire dev workflow: one agent manages servers, one writes code, one reviews and tests, one handles web research, and one suggests strategic improvements. Auto-discovers your stack, routes, and auth without manual configuration.

## Features

- **Server management**: Runner detects stack, installs deps, starts servers, monitors health
- **Web research**: Researcher finds docs, best practices, error solutions via WebSearch/WebFetch
- **Auto-discovery**: Detects stack, ports, routes, auth, test tooling automatically
- **Browser testing**: 1920x1080 screenshots via Playwright MCP
- **Code review**: Reviews every git diff for quality, security, performance
- **Test writing**: E2E and unit tests matching your stack
- **Strategic advice**: Advisor analyzes project and workflow, suggests improvements on demand
- **Memory**: `.supervisor-memory.md` for discoveries, `.advisor-notes.md` for improvement analysis
- **Zero config**: 4 questions, figures out everything else

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) v2.1.32+
- [tmux](https://github.com/tmux/tmux) (required by Claude Code Agent Teams for split-pane display)
- WSL or Ubuntu (for tmux support)
- [Node.js](https://nodejs.org/) 18+

## Quick Start

### 1. Clone

```bash
git clone https://github.com/x3beche/Claude-Agent-Team.git
```

### 2. Prerequisites

```bash
brew install tmux          # macOS
sudo apt install tmux      # Ubuntu/Debian
npx playwright install     # browser engines
```

### 3. Install to your project

```bash
cd your-project
bash /path/to/Claude-Agent-Team/install.sh
```

Or manually:

```bash
cp /path/to/Claude-Agent-Team/CLAUDE.md .
mkdir -p .claude
cp /path/to/Claude-Agent-Team/.claude/settings.json .claude/
```

### 4. Start

```bash
cd your-project
tmux
claude
```

No need to start your dev server. Runner handles it.

### 5. Paste the prompt

Copy contents of [prompt.md](prompt.md) into Claude Code.

### 6. Answer 4 questions, start coding

Give coder a task and the loop runs autonomously. Ask advisor for suggestions anytime.

## File Structure

This repo:
```
Claude-Agent-Team/
|-- CLAUDE.md                   <- copy to your project root
|-- .claude/
|   +-- settings.json           <- copy to your project's .claude/
|-- prompt.md                   <- paste contents into Claude Code
|-- install.sh                  <- or just run this
|-- LICENSE
+-- .gitignore
```

Your project after install:
```
your-project/
|-- CLAUDE.md                   <- agent roles, discovery logic, workflow
|-- .claude/
|   +-- settings.json           <- enables Agent Teams + Playwright MCP
|-- .supervisor-memory.md       <- auto-generated: routes, auth, discoveries
+-- .advisor-notes.md           <- auto-generated: improvement suggestions
```

## Supported Stacks (auto-detected)

| Frontend | Backend | Other |
|----------|---------|-------|
| Next.js | FastAPI | Go |
| Vite (React/Vue/Svelte) | Flask | Rust |
| Angular | Django | Rails |
| CRA | Express | |
| Nuxt | | |
| SvelteKit | | |

Works with any combination. Monorepo structures supported. Not limited to web: API, CLI, mobile, desktop, library projects all work.

## The Five Agents

### Runner (server operations)
Detects stacks, installs deps, starts/restarts servers, monitors health.

### Coder (development)
Writes code, asks runner for restarts, asks researcher when stuck. Sends "ready" to supervisor.

### Supervisor (quality assurance)
Discovers routes and auth from source. Screenshots via Playwright. Writes and runs tests. Sends structured reports. Keeps `.supervisor-memory.md` updated.

### Researcher (web research)
Searches documentation, finds error solutions, looks up best practices via WebSearch and WebFetch. Any agent can request research. Summarizes with source URLs.

### Advisor (strategic improvements)
Activates only when asked. Analyzes project architecture, reads `.supervisor-memory.md` for recurring issues, observes workflow patterns, checks dependencies, suggests improvements. Saves to `.advisor-notes.md`. Can ask researcher for external info. Never modifies anything.

## Notes

- First run downloads Playwright browser engines (~200MB)
- All visual tests run at 1920x1080 desktop resolution only
- tmux is a Claude Code Agent Teams requirement, not specific to this system
- Playwright plugin is included but handled automatically
- Advisor is passive: never interrupts, only responds when asked

## License

MIT
