# Todo UI-First Task List

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the todo application incrementally with a UI-first workflow, while preserving TDD, commit discipline, and future host-integration compatibility.

**Architecture:** The Flutter client runs independently first but follows a `translator_lib`-style module structure centered on `lib/src`. The repository also contains a Dart REST backend in `server/`, but backend completion follows the first-pass UI milestone. Independent work should be isolated by task and by git worktree when appropriate.

**Tech Stack:** Flutter, Dart, Web, macOS, Riverpod, GoRouter, Dart REST backend, Git worktrees, TDD

---

## Task Inventory

### Task 1: Repository Setup And Working Rules

**Purpose:** Lock in repo structure, task discipline, and execution rules before feature work expands.

**Scope:**

1. Confirm `AGENT.md` guidance is current
2. Confirm docs and plan locations
3. Define expected repository subdirectories such as `server/`
4. Ensure working rules reflect task-first, commit-first, and worktree-first behavior

**Deliverables:**

1. Updated `AGENT.md`
2. A written plan file in `docs/superpowers/plans/`
3. Any minimal repo structure docs needed for execution

**Commit guidance:**

1. `docs: add task-first execution rules`
2. `docs: add ui-first implementation plan`

### Task 2: Figma Intake And Screen Mapping

**Purpose:** Convert the design reference into an implementable screen map for the first-pass UI.

**Scope:**

1. Read Figma through MCP when available
2. Extract the 4-screen structure
3. Map design screens to concrete product screens
4. Record any gaps between design showcase content and product MVP needs

**Deliverables:**

1. Screen inventory document or doc update
2. Component list for each screen
3. MVP vs showcase-only decision notes

**Notes:**

1. If MCP access is unavailable, record the limitation explicitly
2. Do not claim exact parity without structured frame data

**Commit guidance:**

1. `docs: map figma screens to product tasks`

### Task 3: Flutter Module Skeleton In Translator-Lib Style

**Purpose:** Establish the standalone Flutter module structure using `translator_lib`-compatible organization.

**Scope:**

1. Create `lib/src` structure
2. Establish module entry strategy
3. Set up routing shape compatible with later host integration
4. Add initial provider and page placeholders

**Deliverables:**

1. `lib/src/pages/`
2. `lib/src/provider/`
3. `lib/src/ui/`
4. `lib/src/widgets/`
5. `lib/src/api/` and `lib/src/net/` placeholders if needed

**Commit guidance:**

1. `refactor: align flutter module structure with translator_lib style`

### Task 4: App Shell And Navigation Frame UI

**Purpose:** Build the non-business shell of the application first so screen work has a stable frame.

**Scope:**

1. App theme and typography baseline
2. Home shell layout
3. Top-level navigation pattern required by the chosen design
4. Placeholder routes for all first-pass UI screens

**Deliverables:**

1. Runnable Web app shell
2. Runnable macOS shell
3. Stable route entry points for screen implementation

**Commit guidance:**

1. `feat: add todo app shell and route frame`

### Task 5: Primary Todo List Screen UI

**Purpose:** Build the main list screen with static or mock data first.

**Scope:**

1. Header and page framing
2. Task list layout
3. Task item visuals
4. Empty state
5. Loading state mock
6. Error state mock

**Deliverables:**

1. First-pass list screen
2. Reusable task item widget
3. Basic responsive behavior for browser widths

**Commit guidance:**

1. `feat: add primary todo list screen ui`

### Task 6: Create And Edit Task UI

**Purpose:** Build task creation and editing interaction surfaces before wiring backend behavior.

**Scope:**

1. Create-task input or modal
2. Edit-task interaction
3. Validation messaging in the UI layer
4. Visual states for save, cancel, and invalid input

**Deliverables:**

1. Create-task UI
2. Edit-task UI
3. Reusable form elements where appropriate

**Commit guidance:**

1. `feat: add create and edit task ui`

### Task 7: Filtering And Status Interaction UI

**Purpose:** Complete the remaining core front-end interactions using local or mock state.

**Scope:**

1. Filter controls
2. Completed vs active presentation
3. Toggle completed interaction
4. Delete interaction affordance

**Deliverables:**

1. Fully navigable first-pass UI for all core todo actions
2. Interaction states backed by local or temporary state

**Commit guidance:**

1. `feat: add task filter and status interaction ui`

### Task 8: UI Verification On Web

**Purpose:** Stabilize the UI-first milestone in the browser before backend integration.

**Scope:**

1. Run widget tests for current UI behavior
2. Run Web locally
3. Check rough visual parity against the design reference
4. Fix obvious layout regressions

**Deliverables:**

1. Web-verifiable UI milestone
2. Test evidence for current UI behaviors

**Commit guidance:**

1. `test: verify ui-first web milestone`
2. `fix: polish web ui regressions`

### Task 9: UI Verification On macOS

**Purpose:** Confirm the same UI path works on macOS after Web is stable.

**Scope:**

1. Launch macOS build
2. Verify layout and navigation
3. Fix platform-specific issues that block desktop use

**Deliverables:**

1. macOS-verifiable UI milestone
2. Notes on platform differences to preserve

**Commit guidance:**

1. `fix: adapt todo ui for macos verification`

### Task 10: Backend Skeleton In `server/`

**Purpose:** Establish a runnable Dart REST backend after the UI milestone is stable.

**Scope:**

1. Create `server/`
2. Add package structure
3. Add test framework setup
4. Add app entry and placeholder routes

**Deliverables:**

1. Runnable backend skeleton
2. Failing contract-oriented test placeholders

**Commit guidance:**

1. `feat: add dart backend skeleton`

### Task 11: Todo REST Endpoints Through TDD

**Purpose:** Implement backend todo behavior incrementally with tests.

**Scope:**

1. `GET /todos`
2. `POST /todos`
3. `PATCH /todos/:id`
4. `DELETE /todos/:id`
5. Validation and error payloads

**Deliverables:**

1. Passing endpoint tests
2. In-memory todo storage
3. Stable JSON response shapes

**Commit guidance:**

1. `feat: add todo list endpoint`
2. `feat: add todo create endpoint`
3. `feat: add todo update endpoint`
4. `feat: add todo delete endpoint`

### Task 12: Client API Layer And Repository Wiring

**Purpose:** Replace mock or local UI state with real REST-backed behavior.

**Scope:**

1. API client setup
2. DTO mapping
3. Repository implementation
4. Provider wiring
5. Error handling path from backend to UI

**Deliverables:**

1. Client REST integration
2. Repository tests
3. UI paths backed by real API behavior

**Commit guidance:**

1. `feat: wire todo client to rest api`

### Task 13: End-To-End Flow Verification

**Purpose:** Validate that the first complete version works from UI to backend.

**Scope:**

1. Run backend locally
2. Run Flutter Web locally
3. Verify create, list, edit, complete, delete, and filter flows
4. Re-run macOS verification if client behavior changed

**Deliverables:**

1. Working local full stack setup
2. Verification notes
3. Final cleanup tasks for the first milestone

**Commit guidance:**

1. `test: verify end-to-end todo flows`

## Worktree Guidance By Task

Use separate worktrees for tasks that are clearly independent. Recommended candidates:

1. Task 5: Primary Todo List Screen UI
2. Task 6: Create And Edit Task UI
3. Task 7: Filtering And Status Interaction UI
4. Task 10-11: Backend skeleton and REST endpoints

Keep tasks local in the main workspace when they are tightly coupled or sequencing-sensitive, such as:

1. Task 1: Repository setup
2. Task 3: Flutter skeleton
3. Task 4: App shell
4. Task 12: Client API wiring

## Commit Expectations

Every task should produce one or more reviewable commits.

Minimum standard:

1. One commit for structure or tests
2. One commit for the minimal working behavior
3. Optional follow-up commit for cleanup or polish

Do not batch multiple unrelated tasks into one commit.

## UI-First Milestone Definition

The first implementation milestone is complete when:

1. The core UI screens are built
2. The app runs on Web
3. The same UI path runs on macOS
4. Visual accuracy is roughly 80% relative to the design
5. Mock or local state is acceptable at this stage

The backend is not required to be complete for the UI-first milestone.
