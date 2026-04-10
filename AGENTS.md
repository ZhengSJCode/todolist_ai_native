# AGENT.md

## Purpose

This repository hosts a todo application built with Flutter and Dart, developed with TDD.

The target project has two major parts in one repository:

1. A Flutter client module that runs independently first
2. A Dart REST backend planned for its own `server/` folder

The client is expected to follow the architectural style of `translator_lib` where practical, while remaining simple enough for a standalone MVP.

## Current Repository State

Current state, as of this document:

1. The Flutter client scaffold exists today.
2. The design and plan docs exist today.
3. The Dart REST backend does not exist yet in this repository.
4. References to `server/` in this document describe target structure, not an already-implemented component.

## Core Delivery Rules

The following rules are mandatory for work in this repository:

1. Break the business work into independent tasks.
2. Each task may require multiple commits, but every meaningful step should be captured with a real `git commit`.
3. Completely independent work should use separate git worktrees.
4. A worktree may be deleted after its tests pass and its work is integrated or no longer needed.
5. Before deep backend work, prioritize finishing the UI screens first.
6. UI implementation only needs to reach roughly 80% visual accuracy for the first pass.
7. Figma should be read through MCP when available, not treated as a vague inspiration source.

## Current Product Direction

1. Primary product: todo list / task management app
2. Visual direction: user-provided Figma reference
3. First verification target: Flutter Web
4. Second verification target: macOS
5. Android is a later rollout, not part of the first implementation milestone

## Repository Intent

This repo should stay easy to run locally on one machine.

Target single-repo, split-directory layout:

```text
/
  lib/        Flutter client entry and module-facing code
  test/       Flutter tests
  web/        Flutter Web host files
  macos/      Flutter macOS host files
  android/    Flutter Android host files
  ios/        Flutter iOS host files
  server/     Dart REST backend
  docs/       Design docs, plans, contracts
```

## Task-First Workflow

All implementation work should be split into explicit, narrowly scoped tasks.

Detailed task list:

1. See [Todo UI-First Task List](./docs/superpowers/plans/2026-04-10-todo-ui-first-task-list.md)

Good task examples:

1. Build shell layout and navigation frame
2. Implement task list screen UI
3. Implement create-task dialog UI
4. Implement task card interactions
5. Add REST list endpoint
6. Add REST create endpoint

Bad task examples:

1. Build the entire app
2. Finish frontend
3. Do backend

Task rules:

1. Each task should have one clear purpose.
2. A task may span multiple commits.
3. Commits inside a task should still be coherent and reviewable.
4. Do not batch unrelated changes into one task just because they are convenient.
5. Prefer following the repository task list unless the user intentionally changes scope or order.
6. Default execution order is:
   - repository setup
   - figma intake
   - flutter ui shell
   - core ui screens
   - web verification
   - macOS verification
   - backend skeleton
   - backend endpoints
   - client api wiring
   - end-to-end verification

## Commit Discipline

Git history is part of the project deliverable.

Rules:

1. Every meaningful step should end in a commit.
2. Do not accumulate a large pile of uncommitted changes across multiple tasks.
3. Use commit boundaries to reflect actual progress within a task.
4. If a task takes multiple iterations, keep each iteration reviewable.
5. Avoid mixing UI, backend, and unrelated refactors in one commit unless they are inseparable.
6. Before every commit, actually run the project, not just tests.
7. A commit is not ready until the current target surface can launch successfully on at least one supported runtime.

Preferred commit pattern inside a task:

1. add failing tests or scaffolding
2. implement minimal passing behavior
3. refine structure or polish while keeping tests green
4. launch the app and confirm it starts before committing

## Worktree Policy

Use git worktrees for truly independent functionality.

Use a separate worktree when:

1. Two features can proceed in parallel without shared file ownership
2. A task has high risk of destabilizing the current workspace
3. You want isolated verification before merging back

Do not create a worktree when:

1. The change is small and local
2. The work depends tightly on uncommitted changes in the current workspace
3. The task is sequential and blocks on the current task anyway

Operational rules:

1. Prefer project-local `.worktrees/` if used and properly ignored.
2. Verify worktree directories are ignored before using them.
3. Run a clean baseline in the worktree before implementation.
4. Delete the worktree after its tests pass and the work is integrated or intentionally discarded.

## Client Architecture Guidance

The Flutter client should be organized in a way that is compatible with the team's existing `translator_lib` conventions.

Prefer a structure centered on `lib/src`, for example:

```text
lib/
  main.dart
  src/
    api/
    net/
    pages/
    provider/
    ui/
    utils/
    widgets/
```

Guidelines:

1. Keep implementation under `lib/src`.
2. Treat pages as screen owners.
3. Keep state exposure in `provider/`.
4. Keep transport and API models separate enough to evolve cleanly.
5. Avoid Web-only assumptions in core UI flows so macOS can reuse the same code path.
6. Use `freezed` for Dart data classes that represent domain models, DTOs, or immutable UI state where code generation is appropriate.

## Backend Guidance

The backend should live in `server/` and be implemented in Dart.

Guidelines:

1. Keep it small and local-first.
2. Expose a REST API for todo operations.
3. Start with in-memory storage.
4. Optimize for testability and fast iteration.

Expected initial API surface:

1. `GET /todos`
2. `POST /todos`
3. `PATCH /todos/:id`
4. `DELETE /todos/:id`

## TDD Rules

Test-first TDD is the default workflow for both client and server.

Rules:

1. Do not write production code before a failing test exists.
2. Write the smallest failing test for the next behavior.
3. Verify the test fails for the expected reason.
4. Write the minimum implementation to pass.
5. Refactor only after returning to green.
6. If a task cannot be driven by an automated test yet, explicitly minimize the uncovered surface and add the closest practical test first.

Client test focus:

1. Repository tests
2. Widget tests
3. UI state tests

Server test focus:

1. Service or domain tests
2. Route or handler tests
3. Contract-oriented HTTP tests

## UI-First Execution Order

The user has explicitly requested that the UI screens be built first.

Execution rules:

1. Implement the screens before completing the backend feature set, but still drive the work with tests first.
2. It is acceptable to use temporary mock or placeholder data while building the first-pass UI.
3. The first-pass UI target is approximately 80% visual accuracy relative to the Figma design.
4. Do not spend early iterations chasing pixel-perfect fidelity.
5. After the UI skeleton is in place, connect it progressively to real REST behavior.

## Delivery Order

Always optimize for this order unless the user changes it:

1. Finalize design and implementation plan
2. Build Flutter client shell and core UI through TDD
3. Run and verify on Flutter Web
4. Run and verify on macOS
5. Build backend through TDD
6. Wire client to the backend
7. Re-run end-to-end verification
8. Consider Android later

## Pre-Commit Runtime Verification

In addition to automated tests, every commit must include a real launch check.

Rules:

1. Run the project before every commit.
2. Prefer Flutter Web first for UI work.
3. Use macOS launch verification when the current change affects desktop behavior or when Web is insufficient.
4. Do not treat passing tests as a substitute for a successful app launch.
5. If the app does not start cleanly, fix that before committing.

## Figma Reading Policy
