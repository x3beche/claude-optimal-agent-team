# Claude Agent Team

Two agents for Claude Code. One writes code, the other reviews it — screenshots the browser, writes tests, runs them, and doesn't stop until everything passes.

No plugins, no global config changes, no 50-file setup. 3 files in your project, delete when you're done.

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
 │                       │◀── ❌ report ──────────│  (if issues)
 │                       │── fixes ──┐            │
 │                       │           │            │
 │                       │◀── done ──┘            │
 │                       │── "ready: fixes" ─────▶│
 │                       │                        │── re-tests
 │                       │                        │
 │                       │◀── ✅ approved ────────│  (all pass)
```

## What it does

The supervisor agent figures out your project on its own. It scans your files to detect the stack, finds the running port, discovers routes from source code, maps auth mechanisms. All of this gets saved to `.supervisor-memory.md` which updates as your project changes.

When the coder finishes something, the supervisor:
- Reviews the diff
- Opens the browser and takes a screenshot (1920×1080)
- Writes tests that match your stack (Playwright, Vitest, Jest, pytest, whatever fits)
- Runs them
- Reports failures back to the coder

This loops until everything passes. It won't approve a feature with failing tests.

## What you need

- Claude Code v2.1.32+
- tmux (`brew install tmux` or `sudo apt install tmux`)
- Node 18+ for Playwright MCP

## Setup

```bash
git clone https://github.com/x3beche/claude-agent-team.git
```

Copy the files into your project:

```bash
cd your-project
cp /path/to/claude-agent-team/CLAUDE.md .
mkdir -p .claude
cp /path/to/claude-agent-team/config/settings.json .claude/
```

Or just run the install script:

```bash
cd your-project
bash /path/to/claude-agent-team/install.sh
```

Install Playwright browsers if you haven't:

```bash
npx playwright install
```

Then start your dev server in one terminal (you manage it, agents never touch it), and in another:

```bash
cd your-project
tmux
claude
```

Paste the contents of [prompt.md](prompt.md) into Claude Code. Supervisor asks you 4 questions — project type, review priority, design reference, anything special. That's the only manual step. After that it discovers everything else by itself.

`Shift+Down` to switch between agent panes.

## File structure

```
your-project/
├── .claude/
│   └── settings.json          ← agent teams + playwright mcp
└──  CLAUDE.md                  ← roles and rules
```

If you want settings.json to apply globally instead of per-project, put it in `~/.claude/settings.json`.

## Supported stacks

It detects these automatically by scanning your project files:

Next.js, Vite, Angular, CRA, Nuxt, SvelteKit, FastAPI, Flask, Django, Rails, Express, Go, Rust

If your stack isn't listed it'll still try — it just looks at what files exist and figures it out.

## How the supervisor works

**Interview** — Asks 4 high-level questions. Doesn't ask about routes, auth, or ports.

**Discovery** — Scans the codebase. Finds routes from your route files, decorators, middleware. Finds auth from guards, middleware, seed files, env flags. Detects test tooling. Finds the running port via `ss -tlnp` or probes common ports. Saves everything to `.supervisor-memory.md`.

**Review loop** — On every coder "ready" message: reviews the diff, takes screenshots, writes tests, runs them. Fails → reports to coder → coder fixes → supervisor checks again. Passes → feature approved. This loop is rigid — it doesn't skip steps or approve half-done work.

## Notes

- First run downloads browser engines, takes a minute or two
- Visual tests are 1920×1080 desktop only
- Two agents with structured communication means less context bloat and lower token usage compared to larger multi-agent setups
- Dev server is yours — agents never start, stop, or restart it

## License

MIT
