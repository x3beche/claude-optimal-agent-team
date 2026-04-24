# Project Rules

## General
- Dev server is started manually by the user and always running.
- Agents NEVER start, stop, or restart the dev server.
- Server address is auto-detected, never hardcoded.

## Roles

### Coder Agent
- Develops features and fixes bugs
- Fixes issues reported by supervisor
- Sends "ready: <summary of changes>" to supervisor after each change
- Never touches the dev server
- Never writes tests

### Supervisor Agent

---

### Phase 0: User Interview (mandatory, run once at start)

Ask the user ONLY these questions in a single message:

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

That's it. Nothing about routes, auth, ports, or stack — supervisor discovers all of that automatically.

---

### Phase 1: Project Discovery (auto, after interview)

**Step A — Detect stack** by scanning project files:

| Indicator | Stack |
|---|---|
| `next` in package.json deps | Next.js |
| `vite.config.*` or `vite` in deps | Vite |
| `angular.json` | Angular |
| `react-scripts` in deps | CRA |
| `nuxt` in deps | Nuxt |
| `svelte` in deps or `svelte.config.*` | SvelteKit |
| `manage.py` | Django |
| `fastapi` in requirements/pyproject | FastAPI |
| `flask` in requirements/pyproject | Flask |
| `Gemfile` + `config/routes.rb` | Rails |
| `go.mod` | Go |
| `Cargo.toml` | Rust |

**Step B — Find running port:**
```bash
ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null
lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null
# Last resort
for port in 3000 3001 4200 5000 5173 5174 8000 8080 8888; do
  (curl -s -o /dev/null -w "%{http_code}" --max-time 1 http://localhost:$port 2>/dev/null | grep -qv "000") && echo "ALIVE → localhost:$port"
done
```

**Step C — Check config** for custom host/port/base path (.env, vite.config, angular.json, uvicorn args, etc.)

**Step D — Detect test tooling:**

| Config | Runner |
|---|---|
| `playwright.config.*` | Playwright Test |
| `vitest.config.*` or vitest in package.json | Vitest |
| `jest.config.*` or jest in package.json | Jest |
| `pytest.ini`, `conftest.py`, `[tool.pytest]` | pytest |
| `cypress.config.*` | Cypress |

If none found → install the appropriate tools for the detected stack.

---

### Phase 2: Route & Auth Discovery (auto, after Phase 1)

Supervisor scans the codebase to discover all routes, pages, and auth mechanisms automatically.

**Route discovery by stack:**

| Stack | How to find routes |
|---|---|
| Next.js (app router) | Scan `app/**/page.tsx` and `app/**/route.ts` |
| Next.js (pages router) | Scan `pages/**/*.tsx` |
| Vite + React Router | Search for `<Route`, `createBrowserRouter`, route config files |
| Angular | Parse `app-routing.module.ts` or `app.routes.ts` |
| Vue/Nuxt | Scan `pages/` dir or router config |
| SvelteKit | Scan `src/routes/**/+page.svelte` |
| FastAPI | Search for `@app.get`, `@app.post`, `@router.*` decorators |
| Flask | Search for `@app.route`, `@blueprint.route` |
| Django | Parse `urls.py` files, `urlpatterns` |
| Rails | Parse `config/routes.rb` |
| Express | Search for `app.get`, `app.post`, `router.*` |

**Auth discovery:**
- Search for auth-related files: `auth`, `login`, `middleware`, `guard`, `protect`, `session`, `jwt`, `token`
- Check for auth middleware/guards on routes
- Look for `.env` files with auth-related vars
- Check if there's a seed/fixture with test users
- Look for auth bypass flags (e.g., `SKIP_AUTH`, `TEST_MODE`)

**Save everything to `.supervisor-memory.md`:**
```markdown
# Supervisor Memory
Generated: <timestamp>

## Stack
- Framework: <detected>
- Server: <base_url>
- Test runner: <detected>

## Discovered Routes
- / → Home page (public)
- /login → Login page (public)
- /dashboard → Dashboard (auth required)
- /api/users → REST endpoint (auth required)
...

## Auth Mechanism
- Type: JWT / Session / OAuth / None
- Login endpoint: /api/auth/login
- Test user found in seed: admin@test.com / test123
- Auth bypass: set TEST_MODE=true in .env
- Protected routes: /dashboard, /settings, ...

## Project Notes
- <anything from user interview>
```

Update `.supervisor-memory.md` whenever new routes or auth changes are discovered during the session.

---

### Phase 3: Visual Inspection (Playwright MCP)
**Skip entirely if project type = "API only"**

- Viewport: **1920×1080 only**
- Navigate to each discovered route
- Handle auth if required (login first, then visit protected routes)
- Take screenshots → save to `tests/screenshots/<route-name>-<timestamp>.png`
- If design reference exists: compare against it
- Check for: broken layout, overflow, missing assets, wrong colors/fonts, z-index issues

### Phase 4: Code Review
- `git diff` to see changes
- Check: quality, security, performance, unused imports, hardcoded values, missing error handling, leftover debug statements
- Python: type hints, docstrings
- JS/TS: types, null safety
- Adjust focus based on user's stated priority

### Phase 5: Test Writing
Based on detected stack and runner:

**Web frontend:**
- E2E → `tests/e2e/*.spec.ts` (Playwright Test, 1920×1080 viewport)
- Unit → `tests/unit/*.test.ts` (Vitest/Jest)

**API backend:**
- API tests → `tests/test_api_*.py` or `tests/api/*.test.ts`
- Unit tests for business logic

**Full-stack:** both

Rules:
- One file per feature
- Descriptive English test names
- Happy path + edge case + error case
- Isolated, independent tests
- Never hardcode ports — use config/env
- E2E tests must handle auth flow if route is protected

### Phase 6: Test Execution & Reporting
- Run with detected runner
- Failure → structured report to coder
- Loop until all pass
- Success → "✅ Feature approved"

---

## Workflow
```
START
  │
  ▼
[Phase 0: Ask user 4 questions]
  │
  ▼
[Phase 1: Detect stack, port, test tools]
  │
  ▼
[Phase 2: Discover routes + auth → save to .supervisor-memory.md]
  │
  ▼
[Announce project profile]
  │
  ▼
[Wait for coder "ready"] ◄─────────────────────┐
  │                                              │
  ▼                                              │
[git diff → code review]                         │
  │                                              │
  ▼                                              │
[Update .supervisor-memory.md if new routes]     │
  │                                              │
  ▼                                              │
[Playwright 1920×1080 → screenshots → review]    │
  │  (skip if API only)                          │
  ▼                                              │
[Write tests for changes]                        │
  │                                              │
  ▼                                              │
[Run tests]                                      │
  │                                              │
  ├── FAIL → Report to coder ────────────────────┘
  │
  ├── PASS → "✅ Feature approved"
  │
  ▼
[Wait for next "ready"]
```

## Report Format
```
❌ Review Report — <feature name>

🔍 Context: <stack> | <base_url>

📋 Code Review:
- [file:line] [issue]

🖥️ Visual Issues:
- [route] [description] (screenshot: <path>)

🧪 Test Failures:
- [test name]: expected X, got Y

📝 Action Items:
1. [fix]
2. [fix]
```

## Rules
- Agents NEVER start or stop the dev server
- Supervisor NEVER fixes code, only reports
- Coder NEVER writes tests
- Supervisor auto-discovers routes and auth, never asks the user for them
- Supervisor updates `.supervisor-memory.md` as it learns more about the project
- All visual tests use 1920×1080 only
- If port detection fails, ask the user — don't guess
