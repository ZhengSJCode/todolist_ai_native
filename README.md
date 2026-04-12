# todolist_ai_native

A Flutter todo application under active development.

The current repository mainly contains the Flutter client scaffold plus project planning documents for a UI-first implementation. The Dart REST backend is planned, but it is not in this repository yet.

## Current Status

1. Flutter app scaffold exists in `lib/`, `test/`, and platform folders.
2. Product, architecture, and execution docs live under `docs/`.
3. The implementation workflow is test-first TDD.
4. The first implementation milestone is UI-first on Flutter Web, followed by macOS verification.
5. A future `server/` directory is planned for the Dart REST backend.

## Docs

- [Project docs index](./docs/README.md)

## Getting Started

Install Flutter dependencies:

```bash
flutter pub get
```

Run tests:

```bash
flutter test
```

Run the app on Web:

```bash
flutter run -d chrome
```

## Testing & Coverage

This project uses test-first TDD development. All tests must pass before committing (enforced by husky).

### Run all tests

```bash
flutter test
```

### Run tests with coverage

```bash
flutter test --coverage
```

This generates a coverage report in `coverage/lcov.info`.

### View coverage report (HTML)

Install lcov and generate HTML report:

```bash
# Install lcov (macOS)
brew install lcov

# Or on Ubuntu/Debian
sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
# or
xdg-open coverage/html/index.html  # Linux
```

### Coverage goals

- Target overall line coverage: >80%
- Critical business logic: >90%
- All tests must pass (100% pass rate)

## Git Hooks

This repository uses `husky` to run `flutter test` before `git commit`.

```bash
npm install
```

After dependencies are installed, commits will be blocked if tests fail.
