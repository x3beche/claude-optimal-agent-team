# 🤖 Claude Agent Team — Coder & Supervisor

A two-agent system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) where one agent writes code and another automatically reviews it, takes browser screenshots, discovers routes & auth, writes tests, and runs them — all without manual configuration.

```
YOU                    CODER                  SUPERVISOR
 │                       │                        │
 │── "build login page"──▶                        │
 │                       │── codes it ──┐         │
 │                       │              │         │
 │                       │◀─── done ────┘         │
 │                       │                        │
 │                       │── "ready: login" ─────▶│
 │                       │                        │── git diff → review
 │                       │                        │── browser → screenshot
 │                       │                        │── writes tests
 │                       │                        │── runs tests
 │                       │                        │
 │                       │◀── ❌ report ──────────│  (if issues found)
 │                       │── fixes ──┐            │
 │                       │           │            │
 │                       │◀── done ──┘            │
 │                       │── "ready: fixes" ─────▶│
 │                       │                        │── re-reviews
 │                       │                        │── re-tests
 │                       │                        │
 │                       │◀── ✅ approved ────────│  (all pass)
```

## ✨ Features

- **Auto-discovery** — Detects your stack (Next.js, Vite, Angular, FastAPI, Flask, Django, Rails, Go, Rust, etc.), running port, routes, auth mechanisms, and test tooling automatically
- **Browser testing** — Takes screenshots at 1920×1080 via Playwright MCP, visually inspects UI
- **Code review** — Reviews every `git diff` for quality, security, performance issues
- **Test writing** — Writes E2E and unit tests matching your stack (Playwright Test, Vitest, Jest, pytest)
- **Memory** — Stores all discoveries in `.supervisor-memory.md`, updates as your project evolves
- **Zero config** — Only asks you 4 high-level questions, figures out everything else

## 📋 Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) v2.1.32 or higher
- [tmux](https://github.com/tmux/tmux) for split-pane agent view
- [Node.js](https://nodejs.org/) 18+ (for Playwright MCP)

## 🚀 Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/claude-agent-team.git
```

### 2. Install tmux

```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt install tmux
```

### 3. Install Playwright browsers

```bash
npx playwright install
```

### 4. Copy files to your project

```bash
cd your-project

# Copy CLAUDE.md to project root
cp /path/to/claude-agent-team/CLAUDE.md .

# Copy settings.json (choose one)
# Per-project:
mkdir -p .claude
cp /path/to/claude-agent-team/config/settings.json .claude/

# Or global (applies to all projects):
cp /path/to/claude-agent-team/config/settings.json ~/.claude/
```

Or use the install script:

```bash
cd your-project
bash /path/to/claude-agent-team/install.sh
```

### 5. Start your dev server

```bash
npm run dev          # or uvicorn, flask run, ng serve, etc.
```

### 6. Start Claude Code in tmux

Open a **second terminal**:

```bash
cd your-project
tmux
claude
```

### 7. Paste the prompt

Copy the contents of [`prompt.md`](prompt.md) and paste it into Claude Code.

### 8. Answer 4 questions

Supervisor asks:

1. **Project type?** — Web app / API only / Desktop app
2. **Review priority?** — Visual / Functionality / Performance / Accessibility / All
3. **Design reference?** — Figma link or none
4. **Anything special?** — Known issues to ignore, focus areas

That's all. Everything else is auto-discovered.

### 9. Start coding

Give the coder a task. When it's done, supervisor automatically reviews, screenshots, writes tests, and runs them.

Use **Shift+Down** to switch between agent panes.

## 📁 File Structure

```
your-project/
├── .claude/
│   └── settings.json          ← enables Agent Teams + Playwright MCP
├── CLAUDE.md                  ← agent roles, discovery logic, workflow rules
└── .supervisor-memory.md      ← auto-generated at runtime (don't create manually)
```

## 🔍 Supported Stacks (auto-detected)

| Frontend | Backend | Other |
|----------|---------|-------|
| Next.js | FastAPI | Go |
| Vite (React/Vue/Svelte) | Flask | Rust |
| Angular | Django | Rails |
| CRA | Express | — |
| Nuxt | — | — |
| SvelteKit | — | — |

## 🔧 How Supervisor Works

### Phase 0 — Interview
Asks you 4 questions. No routes, no auth, no ports — just high-level context.

### Phase 1 — Project Discovery
- Scans project files to identify the tech stack
- Runs `ss -tlnp` / `lsof` / port probing to find the running server
- Checks config files for custom host/port settings
- Detects existing test tooling

### Phase 2 — Route & Auth Discovery
- Scans route files, decorators, middleware, guards
- Finds auth mechanisms, test users in seeds, bypass flags
- Saves everything to `.supervisor-memory.md`

### Phase 3 — Review Loop
On every coder "ready" message:
1. `git diff` → code review
2. Update `.supervisor-memory.md` if new routes found
3. Playwright → 1920×1080 screenshot → visual review (skip if API only)
4. Write E2E + unit tests
5. Run tests
6. Issues → structured report → coder fixes → repeat
7. All pass → ✅ Feature approved

## 📝 Notes

- First run downloads Playwright browser engines (~200MB)
- All visual tests run at **1920×1080** desktop resolution only
- `.supervisor-memory.md` is auto-generated and auto-updated — don't edit manually
- If you change your dev server port mid-session, tell supervisor to re-run discovery
- Dev server is **never** touched by agents — you manage it yourself

## 📄 License

MIT — see [LICENSE](LICENSE)
