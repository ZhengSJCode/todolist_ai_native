# Voice Kanban ASR Design

## Overview

This design adds a real voice input path to the existing Voice Kanban feature.
The first pass keeps the current structured output contract centered on `ParsedDraft` and `ParsedItem`.
Voice is introduced as a new input source, not as a new output model.

The first implementation target is:

1. Record audio in the Flutter client with `record`
2. Upload the recorded audio to the server
3. Let the server perform ASR and return a transcript
4. Reuse the existing text-based `/parse` and `/entries` flow with that transcript
5. Save persisted entries with `sourceType: "voice"`

This is intentionally narrower than a general voice-serialization platform.
The goal is to ship a working macOS voice flow first while keeping clear seams for a later on-device implementation.

## Current Repository State

At the time of writing:

1. `lib/src/pages/voice_kanban_page.dart` supports text input, parse preview, save, and list filtering
2. `lib/src/api/voice_kanban_api_client.dart` only supports text-based `/parse`, `/entries`, and `/items`
3. `server/lib/server.dart` only accepts `sourceType: "text"` for `/parse` and `/entries`
4. The current Voice Kanban models already persist `sourceType` on `RawEntry`
5. Voice recording, audio upload, and ASR are not implemented yet

## Decisions

The following decisions are fixed for this design:

1. Real recording is in scope for the first implementation
2. The first implementation target is macOS, not Web
3. The client uses `record` for audio capture
4. ASR runs on the server first
5. The client uses a two-step voice flow:
   - `POST /voice/transcribe` to obtain transcript text
   - existing `/parse` and `/entries` for structured preview and persistence
6. The structured output stays compatible with the current `ParsedDraft` and `ParsedItem` model
7. The transcript is displayed read-only before save
8. Text input remains on the page as a parallel entry path
9. The first pass favors the smallest working flow over a more complete state machine
10. Web voice behavior is not part of this design

## Goals

1. Add a working voice-to-structured-entry flow to Voice Kanban on macOS
2. Preserve the existing text flow without redesigning the page around voice
3. Keep the output contract compatible with the current Voice Kanban preview and storage model
4. Introduce clear abstraction seams so server-side ASR can later be replaced or complemented by on-device ASR
5. Keep the implementation small enough to drive with TDD

## Non-Goals

1. A general voice serialization protocol beyond the current Voice Kanban output
2. Editable transcripts before parse or save
3. Full Web voice support
4. Provider-specific ASR metadata in the client UI
5. A new multi-step voice wizard or a separate dedicated voice route
6. Simultaneous text and voice preview ownership in the same page state

## Architecture

The feature should be split into small units with one clear purpose each.
The page should not directly coordinate recording, file handling, upload, transcript handling, parse, save, and error logic in one class.

### Client Units

#### 1. `AudioRecorder`

Responsibility:

1. Start recording
2. Stop recording
3. Return a local audio result that can be uploaded

First implementation:

1. `RecordAudioRecorder` backed by the `record` package

Reason:

1. This keeps device capture behind a replaceable interface
2. A later on-device ASR implementation can reuse or bypass this boundary without changing page code

#### 2. `VoiceTranscriptionApiClient`

Responsibility:

1. Upload recorded audio to `POST /voice/transcribe`
2. Return only the transcript payload needed by the client flow

This unit does not know about `ParsedDraft`, `ParsedItem`, filters, or page state.

#### 3. Existing `VoiceKanbanApiClient`

Responsibility:

1. Keep handling `/parse`
2. Keep handling `/entries`
3. Keep handling `/items`

Required change:

1. `createEntry` must support `sourceType: "voice"` when saving a transcript generated from audio

#### 4. `VoiceKanbanFlow` in provider state

Responsibility:

1. Coordinate the minimal voice path:
   - record
   - transcribe
   - parse
   - preview
   - save
   - refresh items
2. Expose a simple UI-facing state for loading, transcript, preview, and errors

This does not need a large event-driven state machine in the first pass.
It only needs enough state to keep the page deterministic and testable.

### Server Units

#### 1. `VoiceTranscriber`

Responsibility:

1. Accept audio input from the HTTP layer
2. Return transcript text

Reason:

1. The HTTP route should not contain provider-specific ASR logic
2. Tests can fake the transcriber without calling a real external ASR service

#### 2. Existing parse and entry flow

Responsibility:

1. Keep converting text into `ParsedDraft`
2. Keep persisting text-derived items through `ParsedItem`

The parser remains text-based.
Voice is just a source that becomes text before parse.

## Data Flow

### Text Path

The existing text path remains:

1. User enters text
2. Client calls `/parse`
3. Client shows preview
4. Client calls `/entries`
5. Client refreshes `/items`

### Voice Path

The new voice path is:

1. User starts recording
2. User stops recording
3. Client uploads audio to `/voice/transcribe`
4. Server returns transcript text
5. Client displays the transcript as read-only
6. Client immediately calls `/parse` with the transcript
7. Client shows the same preview UI used by the text path
8. User taps save
9. Client calls `/entries` with:

```json
{
  "rawText": "<transcript>",
  "sourceType": "voice"
}
```

10. Client refreshes `/items`

This deliberately keeps `/parse` and `/entries` text-first.
The server-side ASR step is separate and upstream from the existing parser.

## API Design

### New Endpoint: `POST /voice/transcribe`

Purpose:

1. Receive recorded audio from the client
2. Return transcript text for downstream parse and save

Minimal successful response:

```json
{
  "transcript": "下班去买鸡胸肉"
}
```

Error response shape should stay consistent with existing server conventions:

```json
{
  "error": "transcription failed"
}
```

### Existing Endpoint: `POST /parse`

No protocol expansion is needed for the first pass.
It continues to accept text input only.

### Existing Endpoint: `POST /entries`

Required change:

1. Accept `sourceType: "voice"` in addition to `sourceType: "text"`
2. Continue persisting `rawText` as the transcript text

This keeps the persisted entry model simple and compatible with the current storage and UI.

## Page Design

The page remains a single `VoiceKanbanPage`.
No route split is needed for the first pass.

### Layout

The page keeps the existing text section and adds a new voice section nearby.

It should contain:

1. Existing text input area
2. Existing parse button
3. Existing save button
4. New voice control area:
   - start recording
   - stop recording
   - re-record or clear voice result
5. Read-only transcript block when voice transcription succeeds
6. Existing preview area reused for both input sources
7. Existing persisted item list and filters

### Simplified Interaction Rules

To keep the first pass small:

1. Text and voice both exist on the page, but only one preview result is considered current at a time
2. If the user completes a voice transcription, the page enters a simple voice-result mode
3. In voice-result mode, save uses the transcript text instead of the text field content
4. The transcript is not editable
5. Re-record clears the existing voice transcript and its preview
6. Save success clears the current working result and refreshes the list

This is intentionally less flexible than a full dual-source editor, but it is much easier to reason about and test.

## Error Handling

The first implementation only needs the minimal set of error states required to keep the flow understandable.

### Client Errors

1. Recording permission denied:
   - show a simple error message
   - do not continue
2. Recording failure or empty output:
   - show a retry-oriented error
3. Transcription failure:
   - show an error
   - do not generate preview
4. Parse failure:
   - reuse the existing parse error surface
5. Save failure:
   - reuse the existing save failure behavior

### Server Errors

1. Invalid or missing audio payload returns `400`
2. Unsupported media or malformed request returns `400`
3. Transcriber failure returns a stable error response
4. Existing text parse and entry validation rules remain in place

## Testing Strategy

This feature should still be driven by failing tests first.
The first pass needs a small but complete test set rather than broad coverage of every UI branch.

### 1. Server Tests

Add contract-oriented tests for `POST /voice/transcribe`:

1. valid audio request returns transcript
2. missing or invalid audio request returns `400`
3. transcriber failure returns stable error payload

The HTTP route should be testable with a fake `VoiceTranscriber`.
Real third-party ASR integration tests are not required for the first pass.

### 2. Client API Tests

Add tests for `VoiceTranscriptionApiClient`:

1. upload request reaches `/voice/transcribe`
2. successful response returns transcript
3. non-success response surfaces server `error`

Update `VoiceKanbanApiClient` tests to cover voice persistence:

1. `createEntry` can send `sourceType: "voice"`

### 3. Provider or Flow Tests

Add tests for the minimal happy path:

1. stop recording triggers transcription
2. successful transcription triggers parse
3. preview becomes available from the transcript
4. saving a voice preview calls `/entries` with the transcript and `sourceType: "voice"`
5. save refreshes the item list

### 4. Widget Tests

Widget tests should use fake recorder and fake API dependencies.
They do not need real microphone access.

Test the minimum UI behavior:

1. voice controls render
2. successful voice flow shows transcript
3. successful voice flow shows parsed preview
4. save from voice flow triggers the voice persistence path

## Task Breakdown

This design should be executed as separate narrow tasks:

1. Add server-side voice transcription abstraction and route tests
2. Add server implementation wiring for the first ASR provider
3. Add client-side recording and transcription abstractions
4. Integrate the minimal voice flow into `VoiceKanbanPage`
5. Verify the flow on macOS

These tasks are tightly related and should stay in the main workspace unless a later subtask becomes independently parallelizable.

## Compatibility And Future Extension

This design intentionally leaves room for a later on-device path:

1. `AudioRecorder` remains replaceable
2. `VoiceTranscriber` remains replaceable
3. The UI does not assume that all transcripts come from the server forever

If on-device ASR is added later, the page and preview model should not need a major redesign.
The replacement should happen behind the recording or transcription boundary, not inside the page widget.

## Summary

The first pass adds a real macOS voice path to the existing Voice Kanban page without changing the structured output model.
The design keeps the server responsible for ASR, keeps the parser text-based, and keeps the client responsible for recording, transcript display, preview, and save orchestration.
The result is intentionally narrow, testable, and compatible with future on-device work without prematurely generalizing the output contract.
