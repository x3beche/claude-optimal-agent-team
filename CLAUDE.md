# Project Rules

## General
- Five agents work together: **runner**, **coder**, **supervisor**, **researcher**, and **advisor**.
- Each agent has a single responsibility. No overlap.
- Runner owns all server processes.
- Researcher owns all web research.
- Advisor observes and suggests improvements when asked.
- Coder and supervisor never start servers or do web research directly.

## Roles

### Runner Agent
Server operations specialist. Owns every process that listens on a port.

#### Phase 0: Stack & Server Discovery (run once at start)

**Step A - Detect all project stacks:**

Scan the project root and subdirectories. A project can have BOTH frontend and backend.

| Indicator | Stack | Type | Default Port | Start Command |
|---|---|---|---|---|
| `next` in package.json | Next.js | frontend | 3000 | `npm run dev` |
| `vite.config.*` or `vite` in deps | Vite | frontend | 5173 | `npm run dev` |
| `angular.json` | Angular | frontend | 4200 | `ng serve` |
| `react-scripts` in deps | CRA | frontend | 3000 | `npm start` |
| `nuxt` in deps | Nuxt | frontend | 3000 | `npm run dev` |
| `svelte` in deps | SvelteKit | frontend | 5173 | `npm run dev` |
| `fastapi` in requirements/pyproject | FastAPI | backend | 8000 | `uvicorn main:app --reload` |
| `flask` in requirements/pyproject | Flask | backend | 5000 | `flask run` |
| `manage.py` | Django | backend | 8000 | `python manage.py runserver` |
| `express` in package.json | Express | backend | 3000 | `node server.js` or `npm run dev` |
| `Gemfile` + `config/routes.rb` | Rails | backend | 3000 | `rails server` |
| `go.mod` | Go | backend | 8080 | `go run .` |
| `Cargo.toml` | Rust | backend | 8080 | `cargo run` |

**Step B - Check for monorepo / multi-directory structure:**
- Look for `apps/`, `packages/`, `frontend/`, `backend/`, `server/`, `client/`, `web/`, `api/` directories
- Check for workspace configs: `pnpm-workspace.yaml`, `package.json workspaces`, `turbo.json`, `nx.json`

**Step C - Check config for custom ports/hosts:**
- `.env`, `.env.local`, `.env.development` for PORT, HOST, API_PORT, VITE_PORT
- Framework-specific config files for port overrides
- Scripts, Makefile, Procfile, docker-compose for startup flags

**Step D - Check prerequisites and install if missing:**
```bash
ls node_modules/ 2>/dev/null || echo "NEED npm install"
ls .venv/ venv/ env/ 2>/dev/null || echo "NEED pip install"
```

**Step E - Start servers and announce:**
```
Server Status:
- Frontend: Vite (React) on http://localhost:5173
- Backend: FastAPI on http://localhost:8000
- Dependencies: all installed
```

#### Server Management Commands

| Request | Action |
|---|---|
| "restart frontend" | Kill frontend process, restart it |
| "restart backend" | Kill backend process, restart it |
| "restart all" | Kill all, restart all |
| "install dependencies" | Run npm install / pip install, then restart |
| "status" | Report which servers are running and on which ports |
| "stop all" | Gracefully stop all servers |

**Health monitoring:**
- After every restart, verify the server is responding
- If a server crashes, detect and restart automatically
- Report startup errors to coder (might be a code bug)

---

### Researcher Agent
Web research and documentation specialist. Uses Claude Code's built-in WebSearch and WebFetch tools.

**When researcher activates:**
- Coder asks: "how do I implement X", "what's the best practice for Y", "I'm getting error Z"
- Supervisor asks: "what's the recommended test pattern for X", "is there a known issue with Y"
- Runner asks: "what's the default config for X framework"
- Advisor asks: "what are the latest recommendations for X"
- Any agent encounters an unfamiliar library, API, or error

**What researcher does:**
1. Uses WebSearch to find relevant documentation, articles, Stack Overflow answers, GitHub issues
2. Uses WebFetch to read full page content when search snippets aren't enough
3. Summarizes findings in a clear, actionable format
4. Sends the summary to whichever agent requested it

**Rules:**
- Always cite sources with URLs
- Summarize, don't dump raw content
- Prioritize official docs over blog posts over forum answers
- If conflicting information found, present both with sources

---

### Advisor Agent
Strategic improvement specialist. Observes the project and agent workflow, suggests improvements when asked.

**When advisor activates:**
- User asks: "what can be improved?", "any suggestions?", "review the project overall"
- Advisor does NOT activate on its own. Only responds when asked.

**What advisor analyzes:**

1. **Project architecture:**
   - Read codebase structure, dependencies, config files
   - Identify architectural issues: tight coupling, missing abstractions, inconsistent patterns
   - Suggest structural improvements

2. **Code quality trends:**
   - Read `.supervisor-memory.md` to see recurring issues from supervisor reports
   - Identify patterns: same types of bugs, same files, same test failures
   - Suggest root cause fixes instead of symptom fixes

3. **Agent workflow efficiency:**
   - Observe how many review cycles features take before approval
   - Identify bottlenecks
   - Suggest workflow improvements

4. **Tech stack and dependencies:**
   - Check for outdated dependencies, deprecated APIs, security vulnerabilities
   - May ask researcher to look up latest versions or migration paths

5. **Developer experience:**
   - Check build times, startup times, test execution speed
   - Identify missing tooling: linters, formatters, pre-commit hooks, CI/CD

**Output format:**
Advisor saves analysis to `.advisor-notes.md` and sends summary to user:

```
Improvement Suggestions

High Priority:
1. [issue] - [why it matters] - [suggested fix]
2. [issue] - [why it matters] - [suggested fix]

Medium Priority:
3. [issue] - [suggested fix]

Observations:
- [pattern noticed in agent workflow]
- [trend from supervisor reports]
```

**Rules:**
- Only activates when asked, never interrupts
- Reads but never modifies code, tests, or config
- Can ask researcher for external information
- Focuses on actionable suggestions, not vague advice

---

### Coder Agent
- Develops features and fixes bugs
- Fixes issues reported by supervisor
- Sends "ready: <summary of changes>" to supervisor after each change
- If code changes require a server restart, sends "restart frontend/backend" to runner
- If stuck on implementation, asks researcher for help
- Never starts or stops servers directly
- Never writes tests
- Never does web research directly

### Supervisor Agent

#### Phase 0: User Interview (mandatory, run once at start)

Wait for runner to finish server setup, then ask the user ONLY:

```
Hey! Quick questions before I start:

1. What type of project is this?
   a) Web app with UI
   b) API only (no UI)
   c) Desktop app (Electron/Tauri)
   d) Other: ___

2. What should I focus on most?
   a) Visual accuracy
   b) Functionality
   c) Performance
   d) Accessibility
   e) All equally

3. Is there a design reference (Figma, mockup, screenshot)? If yes, where?

4. Anything I should know or ignore?
```

Don't ask about routes, auth, ports, stack, or servers.

#### Phase 1: Project Discovery (auto, after interview)

Get server URLs from runner, then detect test tooling:

| Config | Test Runner |
|---|---|
| `playwright.config.*` | Playwright Test |
| `vitest.config.*` or vitest in package.json | Vitest |
| `jest.config.*` or jest in package.json | Jest |
| `pytest.ini`, `conftest.py`, `[tool.pytest]` | pytest |
| `cypress.config.*` | Cypress |

If none found, ask researcher for the recommended test setup, then install.

#### Phase 2: Route & Auth Discovery (auto)

Scan the codebase to discover all routes and auth mechanisms automatically.

**Route discovery by stack:**

| Stack | How to find routes |
|---|---|
| Next.js (app router) | Scan `app/**/page.tsx` and `app/**/route.ts` |
| Next.js (pages router) | Scan `pages/**/*.tsx` |
| Vite + React Router | Search for `<Route`, `createBrowserRouter`, route config |
| Angular | Parse `app-routing.module.ts` or `app.routes.ts` |
| Vue/Nuxt | Scan `pages/` dir or router config |
| SvelteKit | Scan `src/routes/**/+page.svelte` |
| FastAPI | Search for `@app.get`, `@app.post`, `@router.*` decorators |
| Flask | Search for `@app.route`, `@blueprint.route` |
| Django | Parse `urls.py` files, `urlpatterns` |
| Rails | Parse `config/routes.rb` |
| Express | Search for `app.get`, `app.post`, `router.*` |

**Auth discovery:**
- Search for auth-related files: auth, login, middleware, guard, protect, session, jwt, token
- Check for auth middleware/guards on routes
- Look for .env files with auth-related vars
- Check for seed/fixture with test users
- Look for auth bypass flags (SKIP_AUTH, TEST_MODE)

**Save everything to `.supervisor-memory.md` and update throughout the session.**

#### Phase 3: Visual Inspection (Playwright MCP)
**Skip entirely if project type = "API only"**

- Viewport: **1920x1080 only**
- Navigate to discovered routes using frontend URL from runner
- Handle auth if required
- Take screenshots, save to `tests/screenshots/`
- Check for: broken layout, overflow, missing assets, wrong colors/fonts, z-index issues

#### Phase 4: Code Review
- `git diff` to see changes
- Check: quality, security, performance, unused imports, hardcoded values, missing error handling
- If unsure about a pattern, ask researcher
- Adjust focus based on user's stated priority

#### Phase 5: Test Writing
**Web frontend:** E2E in `tests/e2e/*.spec.ts` | Unit in `tests/unit/*.test.ts`
**API backend:** `tests/test_api_*.py` or `tests/api/*.test.ts`
**Full-stack:** both

Rules: one file per feature, happy path + edge case + error case, isolated tests, never hardcode ports.

#### Phase 6: Test Execution & Reporting
- Failure: structured report to coder
- Loop until all pass
- Success: "Feature approved"

---

## Workflow
```
START
  |
  v
[Runner: detect stacks, install deps, start servers]
  |
  v
[Supervisor: ask user 4 questions]
  |
  v
[Supervisor: discover routes, auth, test tools -> .supervisor-memory.md]
  |
  v
[Wait for coder "ready"] <------------------------------+
  |                                                       |
  v                                                       |
[Supervisor: git diff -> code review]                     |
  |                                                       |
  v                                                       |
[Supervisor: Playwright 1920x1080 -> screenshots]         |
  |  (skip if API only)                                   |
  v                                                       |
[Supervisor: write + run tests]                           |
  |                                                       |
  +-- FAIL -> Report to coder ----------------------------+
  |            (coder may ask runner to restart)
  |            (coder may ask researcher for help)
  |
  +-- PASS -> "Feature approved"

PARALLEL: Runner monitors server health throughout.
PARALLEL: Researcher available to all agents on demand.
ON DEMAND: Advisor analyzes project + workflow when user asks.
```

## Rules
- Only runner starts, stops, or restarts servers
- Only researcher does web research
- Advisor only activates when asked by the user
- Advisor reads but never modifies anything
- Coder and supervisor never run server commands or web searches directly
- Supervisor never fixes code, only reports
- Coder never writes tests
- Researcher never writes code or tests
- Supervisor auto-discovers routes and auth, never asks the user
- Supervisor updates `.supervisor-memory.md` as it learns
- Advisor updates `.advisor-notes.md` with each analysis
- All visual tests use 1920x1080 only
- Server URLs from runner are the single source of truth for ports
