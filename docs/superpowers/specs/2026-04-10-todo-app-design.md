# Todo App Design Outline

## Overview

This project is a Flutter todo application intended to be developed with TDD.
The first delivery target is Flutter Web for rapid iteration on UI and behavior.
The second delivery target is macOS for desktop verification after the Web milestone.
The codebase should remain compatible with a later Android rollout without reshaping the core architecture.

The system includes:

- A Flutter client with UI, state management, and REST API integration
- A planned minimal REST backend that will serve todo data
- Shared API behavior expressed through contracts and mirrored in tests on both sides
- A visual direction based on the Figma design reference provided by the user

## Current Implementation State

Current repository state at the time of writing:

1. The Flutter project scaffold exists.
2. The UI described in this document is not implemented yet.
3. The REST backend described in this document is planned but not implemented yet.
4. This document mixes current constraints with target behavior for the first milestone and should be read as a design target, not a status report.

## Design Reference

The visual reference for this project is the Figma community design provided by the user:

- [Design overview canvas](https://www.figma.com/design/ZvqYjPldHK0At7LAuwmiXO/Task-management---to-do-list-app--Community---Copy-?node-id=1-87&p=f&t=tLzmviVh4noAtR8t-0)
- [Asset reference node](https://www.figma.com/design/ZvqYjPldHK0At7LAuwmiXO/Task-management---to-do-list-app--Community---Copy-?node-id=101-539&p=f&t=tLzmviVh4noAtR8t-0)

Current constraint:

1. The design link is recorded as the visual source of truth.
2. The design is a mobile task-management UI kit with multiple frames on a shared presentation canvas.
3. The design is positioned as customizable, layered, and intended for Android and iOS layouts.
4. The `1:87` link should be treated as the main design overview and screen index.
5. The `101:539` link should be treated as an asset or reference node, not the primary screen inventory source.
6. The Figma file is now accessible from Codex and can be used as a screen-level source of truth.

Known accessible frame inventory from the overview canvas:

1. `101:100` `let's start`
2. `101:125` `home`
3. `101:265` `today's tasks`
4. `101:358` `add project in task list`
5. `101:539` task details screen reference supplied by the user
6. `1:178` `cover`
7. `1:687` `about us`

Known visual characteristics confirmed from accessible nodes:

1. Primary accent color is purple around `#5F33E1`
2. Main text color uses a dark neutral around `#24252C`
3. Secondary text uses a muted neutral around `#6E6A7C`
4. Typography uses `Lexend Deca`
5. Layout is mobile-first with 375px-wide frames
6. The design includes decorative gradients, soft shapes, and illustration-heavy onboarding

## Goals

1. Build a small but complete todo product instead of a demo-only screen.
2. Use test-first TDD across client and server:
   - define expected behavior first
   - write failing tests
   - implement the minimum code to pass
3. Start with Flutter Web for faster feedback, then reuse the same client architecture for macOS.
4. Keep the first version easy to run locally on one machine.
5. Preserve room for a later Android rollout without reshaping core layers.

## Product Scope

### In Scope

1. View todo list
2. Create todo
3. Toggle completed state
4. Edit todo title
5. Delete todo
6. Filter by all, active, completed
7. Show loading, empty, and error states
8. Integrate with a real REST API
9. Keep the UI structure and styling compatible with the provided Figma direction
10. Favor a mobile-first UI structure that can still run cleanly on Web and macOS

### Out of Scope For MVP

1. Login and user accounts
2. Multi-device sync
3. Database persistence
4. Push notifications
5. Offline-first support
6. File attachments
7. Rich descriptions and subtasks
8. Pixel-perfect parity with the Figma reference before core behavior is complete
9. Reproducing all showcase-only screens if they do not serve the MVP todo workflow

## Users And Usage

The initial user model is a single local user.
The app is used to manage simple task items from a browser first, with macOS as the first desktop verification target.

Typical flow:

1. User opens the app
2. App loads todo items from the backend
3. User creates, updates, completes, filters, and deletes items
4. UI reflects backend state and handles failures clearly

## Functional Requirements

### Client

1. The home screen is the todo list screen.
2. The screen shows:
   - a title area
   - an input for new todo creation
   - an add action
   - filter controls
   - the todo list
   - empty and error states where relevant
3. Each todo item shows:
   - title
   - completion state
   - edit action
   - delete action
4. Creating a todo updates the list after a successful API response.
5. Updating completion state updates the list after a successful API response.
6. Editing title updates the list after a successful API response.
7. Deleting an item removes it from the list after a successful API response.
8. API failures must surface readable feedback and allow retry.
9. The Web layout must be usable on desktop browser widths first.
10. The same presentation layer should run on macOS without a separate code path for core todo flows.

### Screen Inventory

The accessible Figma nodes now confirm the following screen set for the mobile flow:

1. `let's start` onboarding or entry screen
2. `home` dashboard screen
3. `today's tasks` filtered task list screen
4. `add project in task list` create-project form screen
5. `101:539` task details screen shared by the user for downstream implementation reference

This means the product should no longer be treated as a vague 4-screen assumption. The file contains a concrete mobile flow and implementation can map UI work to these named frames directly.

### Server

1. Expose REST endpoints for todo operations.
2. Validate request payloads and return stable error responses.
3. Keep state in memory for the first version.
4. Return JSON only.

## Data Model

Todo:

- `id`: unique identifier
- `title`: non-empty string after trim
- `completed`: boolean
- `createdAt`: ISO 8601 timestamp
- `updatedAt`: ISO 8601 timestamp

## Business Rules

1. Title is required.
2. Title is trimmed before validation and storage.
3. Empty title is rejected.
4. Title length must be between 1 and 100 characters after trim.
5. New todos are created as incomplete.
6. List ordering is active todos first, completed todos after.
7. Within the same completion bucket, preserve creation order unless a later design changes this.
8. Error payloads must use a predictable structure for client handling.

## REST API Outline

### `GET /todos`

- Returns the todo list
- Supports optional filter query for status

### `POST /todos`

- Creates a todo
- Accepts title

### `PATCH /todos/:id`

- Updates one or more mutable fields
- Initial mutable fields:
  - `title`
  - `completed`

### `DELETE /todos/:id`

- Deletes a todo by id

## API Response Principles

1. Success responses return JSON resources.
2. Validation failures return `400`.
3. Missing resources return `404`.
4. Unexpected failures return `500`.
5. Error response shape should be stable, for example:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Title must not be empty"
  }
}
```

## Testing Strategy

### Shared Behavior

The client and server should follow the same API contract, but not rely on a single shared test file.
Instead:

1. Define the API behavior clearly
2. Verify server behavior with backend tests
3. Verify client behavior against the same contract using repository and UI tests

### Client Tests

1. Write the smallest failing automated test before each new client behavior change.
2. Unit tests for presentation-independent logic where useful
3. Repository tests for request/response mapping and error handling
4. Widget tests for:
   - initial loading
   - list rendering
   - empty state
   - error state
   - create flow
   - toggle flow
   - edit flow
   - delete flow
   - filter flow
5. Web manual verification for layout, responsiveness, and API interaction
6. macOS manual verification after Web behavior is stable

### Server Tests

1. Write the failing domain or HTTP test before each new backend behavior.
2. Domain/service tests for todo rules
3. Handler or route tests for HTTP behavior
4. Contract-oriented tests for status codes and response payloads

## Architecture Direction

### Client

The client architecture should follow `translator_lib` as the primary reference instead of a generic feature-folder app layout.
This means the todo module should be treated as an embeddable Flutter module with most implementation under `lib/src`, and with routing and host-specific concerns integrated in a way that matches the existing company codebase.

Target structure direction:

- `lib/`
- `lib/src/`
- `lib/src/api/`
- `lib/src/net/`
- `lib/src/provider/`
- `lib/src/pages/`
- `lib/src/ui/`
- `lib/src/widgets/`
- `lib/src/utils/`

For this todo module, the above can remain much smaller than `translator_lib`, but the organizational style should stay compatible.

Recommended client stack:

- Flutter
- `flutter_riverpod`
- `go_router`
- `freezed`
- `json_serializable`

These libraries are target choices for implementation. They are not fully wired into the current scaffold yet.

Module integration guidance derived from `translator_lib`:

1. Avoid building the todo feature as a one-off standalone app architecture if it will later be embedded into the host project.
2. Keep route registration modular and compatible with host-managed `GoRouter`.
3. Keep host-provided dependencies and configuration injectable during module initialization.
4. Prefer `lib/src/pages` for screen ownership and `lib/src/provider` for state exposure, matching the established module style.
5. Keep REST models, repository code, and transport code grouped in a way that matches the `api` and `net` split already used by `translator_lib`.
6. Use `freezed`-generated immutable data classes for domain models and DTOs, with generated JSON support where transport mapping is needed.

Presentation guidance:

1. Use the provided Figma link as the visual direction.
2. Prioritize screen structure, hierarchy, and interaction states before visual polish details.
3. Implement Web first, but avoid Web-only widgets or assumptions that complicate macOS.
4. Treat the reference as a mobile-first design system and adapt it carefully for larger Web and macOS widths.
5. Preserve component customization and clear layer boundaries so the implementation remains easy to evolve.

### Server

The backend should be a small REST service designed for local development and testability.
The exact framework is still open, but the contract remains REST-first.

## Non-Functional Requirements

1. Local setup must be simple enough to run on one development machine.
2. The first milestone must run in a browser.
3. The second milestone must run on macOS.
4. The client code should avoid web-only assumptions so macOS can follow cleanly.
5. The backend must be small enough to support fast test cycles.
6. The project should prefer clarity and testability over premature abstraction.
7. The module structure should align with `translator_lib` closely enough that future integration patterns remain familiar to the team.

## Milestones

1. Create project skeleton and write design outline
2. Refine the design outline with Figma-driven UI notes
3. Finalize stack and API contract details
4. Write implementation plan
5. Build backend through TDD
6. Build Flutter client through TDD
7. Verify on Flutter Web
8. Verify on macOS
9. Consider Android as a later rollout

## Open Decisions

1. Backend framework choice
2. Exact filter query format
3. Whether to share DTO definitions or only share contract documentation
4. Whether to add `description` in a later milestone
5. Which Figma frames or components should be treated as required for MVP parity
6. Whether all 4 reference screens are product-essential or whether some are showcase-only
7. How closely the todo module should mirror `translator_lib` initialization, route registration, and dependency wiring
