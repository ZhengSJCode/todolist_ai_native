# Voice Kanban Doubao ASR Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a macOS-first voice recording flow to Voice Kanban using `record` in Flutter and Doubao ASR on the Dart server, while preserving the existing text parse/save behavior.

**Architecture:** The Flutter client captures 16 kHz mono PCM audio in stream mode with `record`, posts the raw bytes to a new internal `POST /voice/transcribe` endpoint, then reuses the existing `/parse` and `/entries` text endpoints with `sourceType: "voice"`. The server keeps the client-to-server contract simple, wraps the incoming bytes in the official Doubao OpenAI-compatible transcription request, and returns only a transcript string to the client.

**Tech Stack:** Flutter, Dart, Riverpod, record, http, shelf, Doubao ASR (Volcengine), Flutter widget tests, Dart server tests

---

## Preconditions

1. Execute this plan in a fresh git worktree, not in the shared main workspace.
2. Keep the approved spec open while implementing: [2026-04-14-voice-kanban-asr-design.md](/Users/zhengshuaijie/AndroidStudioProjects/company/translator_app/modules/todolist_ai_native/docs/superpowers/specs/2026-04-14-voice-kanban-asr-design.md)
3. Keep the official references open while coding:
   - `record` package example and platform notes: [pub.dev/packages/record](https://pub.dev/packages/record/versions/6.2.0)
   - Doubao ASR HTTP interface doc: [volcengine.com/docs/6893/1446852](https://www.volcengine.com/docs/6893/1446852)
4. Follow the Doubao doc literally for provider-specific request fields.
5. Do not guess the Doubao base URL or model id. Copy those exact values from the official Volcengine console-generated sample into environment variables before runtime verification.

## File Structure

### Client

- Modify: `pubspec.yaml`
  Responsibility: remove the root `test` dependency that currently blocks `flutter pub get`, add `record`
- Create: `lib/src/audio/recorded_audio_clip.dart`
  Responsibility: immutable PCM clip payload for upload
- Create: `lib/src/audio/voice_audio_recorder.dart`
  Responsibility: abstract recording interface used by providers and tests
- Create: `lib/src/audio/record_voice_audio_recorder.dart`
  Responsibility: thin `record` wrapper using stream mode and PCM output
- Create: `lib/src/api/voice_transcription_client.dart`
  Responsibility: abstract client-to-server transcription interface
- Create: `lib/src/api/http_voice_transcription_client.dart`
  Responsibility: POST raw PCM bytes to `/voice/transcribe` and parse `{ transcript }`
- Modify: `lib/src/api/voice_kanban_api_client.dart`
  Responsibility: allow `createEntry(..., sourceType: 'voice')`
- Modify: `lib/src/provider/voice_kanban_provider.dart`
  Responsibility: allow item persistence with custom `sourceType`
- Create: `lib/src/provider/voice_kanban_voice_flow_provider.dart`
  Responsibility: coordinate record -> transcribe -> parse -> save for the minimal voice flow
- Modify: `lib/src/pages/voice_kanban_page.dart`
  Responsibility: render voice controls, read-only transcript, and wire voice save behavior

### Server

- Modify: `server/pubspec.yaml`
  Responsibility: add runtime HTTP dependencies for Doubao ASR calls
- Create: `server/lib/voice_transcriber.dart`
  Responsibility: server-side transcription interface and audio payload model
- Create: `server/lib/doubao_voice_transcriber.dart`
  Responsibility: call Doubao ASR using the official OpenAI-compatible transcription shape
- Modify: `server/lib/server.dart`
  Responsibility: add `POST /voice/transcribe`, accept `sourceType: "voice"` for `/entries`
- Modify: `server/bin/main.dart`
  Responsibility: create the real `DoubaoVoiceTranscriber` from environment config

### Tests

- Modify: `test/voice_kanban_api_client_test.dart`
  Responsibility: cover `sourceType: "voice"` persistence
- Create: `test/http_voice_transcription_client_test.dart`
  Responsibility: cover the new client-to-server `/voice/transcribe` contract
- Create: `test/voice_kanban_voice_flow_provider_test.dart`
  Responsibility: cover record -> transcribe -> parse -> save orchestration
- Modify: `test/voice_kanban_page_test.dart`
  Responsibility: cover voice buttons, transcript display, and voice save path
- Modify: `server/test/server_test.dart`
  Responsibility: cover `/voice/transcribe` and `/entries` with `sourceType: "voice"`
- Create: `server/test/doubao_voice_transcriber_test.dart`
  Responsibility: cover Doubao request shape and transcript parsing

## Task 1: Restore The Local Baseline And Add Platform Dependencies

**Files:**
- Modify: `pubspec.yaml`
- Modify: `server/pubspec.yaml`
- Modify: `macos/Runner/Info.plist`
- Modify: `macos/Runner/DebugProfile.entitlements`
- Modify: `macos/Runner/Release.entitlements`

- [ ] **Step 1: Reproduce the current root dependency failure**

Run: `flutter pub get`

Expected: FAIL with a version-solving error mentioning `flutter_test`, `test ^1.26.2`, and `freezed ^2.5.7`.

- [ ] **Step 2: Read the official demos before editing code**

Open these pages in the browser and keep them pinned while implementing:

```text
https://pub.dev/packages/record/versions/6.2.0
https://www.volcengine.com/docs/6893/1446852
```

Implementation rule for the next tasks:

```text
Use `record` stream mode with `AudioEncoder.pcm16bits`.
Use the Doubao OpenAI-compatible transcription field names from the official doc.
Do not invent a model id or base URL; copy them from the Volcengine console sample.
```

- [ ] **Step 3: Update root Flutter dependencies and macOS microphone permissions**

Update `pubspec.yaml` to remove the root `test` dev dependency and add `record`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.3.0
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  go_router: ^14.8.1
  record: ^6.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.5
  build_runner: ^2.4.15
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  riverpod_generator: ^2.6.2
  todolist_server:
    path: server/
  flutter_lints: ^6.0.0
  patrol: ^4.1.0
  patrol_finders: ^3.2.0
```

Update `macos/Runner/Info.plist` to include microphone usage text:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风录制语音待办。</string>
```

Update `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` to allow audio input:

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

- [ ] **Step 4: Add the server runtime dependencies needed for Doubao HTTP calls**

Update `server/pubspec.yaml`:

```yaml
dependencies:
  google_generative_ai: ^0.4.7
  shelf: ^1.4.0
  shelf_router: ^1.1.0
  uuid: ^4.5.0
  http: ^1.3.0
  http_parser: ^4.1.2

dev_dependencies:
  lints: ^5.0.0
  test: ^1.25.0
```

- [ ] **Step 5: Verify the dependency baseline is fixed**

Run:

```bash
flutter pub get
(cd server && dart pub get)
```

Expected:

```text
Got dependencies!
```

- [ ] **Step 6: Commit the baseline fix**

```bash
git add pubspec.yaml server/pubspec.yaml macos/Runner/Info.plist macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements pubspec.lock server/pubspec.lock
git commit -m "chore: add voice recording baseline dependencies"
```

## Task 2: Add The Server Voice Contract And Accept `sourceType: "voice"`

**Files:**
- Create: `server/lib/voice_transcriber.dart`
- Modify: `server/lib/server.dart`
- Modify: `server/test/server_test.dart`

- [ ] **Step 1: Write the failing server tests for voice transcription and voice persistence**

Add these support types near the top of `server/test/server_test.dart`:

```dart
import 'package:todolist_server/voice_transcriber.dart';

class FakeVoiceTranscriber implements VoiceTranscriber {
  FakeVoiceTranscriber({this.transcript = '买鸡蛋', this.shouldFail = false});

  final String transcript;
  final bool shouldFail;
  VoiceAudioPayload? lastPayload;

  @override
  Future<String> transcribe(VoiceAudioPayload payload) async {
    lastPayload = payload;
    if (shouldFail) {
      throw const VoiceTranscriptionException('transcriber failed');
    }
    return transcript;
  }
}
```

Update `setUp()` to inject the fake transcriber:

```dart
late FakeVoiceTranscriber fakeVoiceTranscriber;

setUp(() async {
  fakeVoiceTranscriber = FakeVoiceTranscriber();
  httpServer = await createServer(
    port: 0,
    transcriber: fakeVoiceTranscriber,
  );
  baseUrl = 'http://192.168.67.235:${httpServer.port}';
});
```

Add these tests:

```dart
group('POST /voice/transcribe', () {
  test('V1: returns transcript from the transcriber', () async {
    final response = await http.post(
      Uri.parse('$baseUrl/voice/transcribe'),
      headers: {
        'content-type': 'application/octet-stream',
        'x-audio-format': 'pcm_s16le',
        'x-sample-rate': '16000',
        'x-file-name': 'voice-input.pcm',
      },
      body: [1, 2, 3, 4],
    );

    expect(response.statusCode, 200);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    expect(body['transcript'], '买鸡蛋');
    expect(fakeVoiceTranscriber.lastPayload!.bytes, [1, 2, 3, 4]);
    expect(fakeVoiceTranscriber.lastPayload!.format, 'pcm_s16le');
    expect(fakeVoiceTranscriber.lastPayload!.sampleRateHz, 16000);
  });

  test('V2: empty audio body returns 400', () async {
    final response = await http.post(
      Uri.parse('$baseUrl/voice/transcribe'),
      headers: {
        'content-type': 'application/octet-stream',
        'x-audio-format': 'pcm_s16le',
        'x-sample-rate': '16000',
      },
      body: <int>[],
    );

    expect(response.statusCode, 400);
  });
});

test('P7: POST /entries accepts sourceType voice', () async {
  final response = await http.post(
    Uri.parse('$baseUrl/entries'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode({
      'rawText': '买鸡蛋',
      'sourceType': 'voice',
    }),
  );

  expect(response.statusCode, 201);
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  expect(body['rawEntry']['sourceType'], 'voice');
});
```

- [ ] **Step 2: Run the server tests to verify the route is missing and `voice` is rejected**

Run: `(cd server && dart test test/server_test.dart)`

Expected:

```text
FAIL: POST /voice/transcribe returns 404 or missing route
FAIL: POST /entries accepts sourceType voice returns 400
```

- [ ] **Step 3: Implement the minimal server-side contract and route wiring**

Create `server/lib/voice_transcriber.dart`:

```dart
class VoiceAudioPayload {
  const VoiceAudioPayload({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.format,
    required this.sampleRateHz,
  });

  final List<int> bytes;
  final String fileName;
  final String mimeType;
  final String format;
  final int sampleRateHz;
}

abstract interface class VoiceTranscriber {
  Future<String> transcribe(VoiceAudioPayload payload);
}

class VoiceTranscriptionException implements Exception {
  const VoiceTranscriptionException(this.message);

  final String message;

  @override
  String toString() => 'VoiceTranscriptionException($message)';
}
```

Update `server/lib/server.dart`:

```dart
import 'dart:typed_data';

import 'voice_transcriber.dart';

Future<HttpServer> createServer({
  int port = 8080,
  TodoRepository? repository,
  InternetAddress? address,
  VoiceTranscriber? transcriber,
}) async {
  final repo = repository ?? TodoRepository();
  final router = Router();

  router.post('/voice/transcribe', (Request req) async {
    final bytes = await _readBytes(req);
    final format = req.headers['x-audio-format'];
    final sampleRate = int.tryParse(req.headers['x-sample-rate'] ?? '');
    final fileName = req.headers['x-file-name'] ?? 'voice-input.pcm';

    if (bytes.isEmpty) return _error(400, 'audio body is required');
    if (format != 'pcm_s16le') return _error(400, 'x-audio-format must be pcm_s16le');
    if (sampleRate == null || sampleRate <= 0) {
      return _error(400, 'x-sample-rate must be a positive integer');
    }
    if (transcriber == null) {
      return _error(503, 'voice transcription is not configured');
    }

    try {
      final transcript = await transcriber.transcribe(
        VoiceAudioPayload(
          bytes: bytes,
          fileName: fileName,
          mimeType: req.headers['content-type'] ?? 'application/octet-stream',
          format: format,
          sampleRateHz: sampleRate,
        ),
      );
      return _json({'transcript': transcript}, statusCode: 200);
    } on VoiceTranscriptionException catch (error) {
      return _error(502, error.message);
    }
  });

  router.post('/entries', (Request req) async {
    final body = await _parseBody(req);
    final rawText = body['rawText'] as String?;
    final sourceType = body['sourceType'] as String? ?? 'text';

    if (sourceType != 'text' && sourceType != 'voice') {
      return _error(400, 'Invalid sourceType, only "text" or "voice" is supported');
    }

    if (rawText == null || rawText.trim().isEmpty) {
      return _error(400, 'rawText is required and cannot be empty');
    }

    final parser = RuleBasedEntryParser();
    final drafts = await parser.parse(rawText);

    final result = repo.createEntry(
      rawText: rawText.trim(),
      sourceType: sourceType,
      drafts: drafts,
    );

    return _json(result.toJson(), statusCode: 201);
  });
}

Future<List<int>> _readBytes(Request req) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in req.read()) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}
```

- [ ] **Step 4: Run the server tests to verify the contract now passes**

Run: `(cd server && dart test test/server_test.dart)`

Expected:

```text
All tests passed.
```

- [ ] **Step 5: Commit the server contract**

```bash
git add server/lib/voice_transcriber.dart server/lib/server.dart server/test/server_test.dart
git commit -m "feat: add voice transcription server contract"
```

## Task 3: Add The Doubao ASR Adapter Using The Official Request Shape

**Files:**
- Create: `server/lib/doubao_voice_transcriber.dart`
- Modify: `server/bin/main.dart`
- Create: `server/test/doubao_voice_transcriber_test.dart`

- [ ] **Step 1: Write the failing unit test for the Doubao request shape**

Create `server/test/doubao_voice_transcriber_test.dart`:

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:todolist_server/doubao_voice_transcriber.dart';
import 'package:todolist_server/voice_transcriber.dart';

void main() {
  test('D1: sends an OpenAI-compatible multipart request to Doubao', () async {
    final mockClient = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'https://doubao.example/v1/audio/transcriptions',
      );
      expect(request.headers['authorization'], 'Bearer test-key');

      final multipart = request as http.MultipartRequest;
      expect(multipart.fields['model'], 'doubao-asr');
      expect(multipart.fields['response_format'], 'json');
      expect(multipart.files.single.field, 'file');
      expect(multipart.files.single.filename, 'voice-input.pcm');

      return http.Response(jsonEncode({'text': '买鸡蛋'}), 200);
    });

    final transcriber = DoubaoVoiceTranscriber(
      httpClient: mockClient,
      baseUrl: 'https://doubao.example/v1',
      apiKey: 'test-key',
      model: 'doubao-asr',
    );

    final transcript = await transcriber.transcribe(
      const VoiceAudioPayload(
        bytes: [1, 2, 3],
        fileName: 'voice-input.pcm',
        mimeType: 'application/octet-stream',
        format: 'pcm_s16le',
        sampleRateHz: 16000,
      ),
    );

    expect(transcript, '买鸡蛋');
  });
}
```

- [ ] **Step 2: Run the new unit test to verify the adapter is still missing**

Run: `(cd server && dart test test/doubao_voice_transcriber_test.dart)`

Expected:

```text
FAIL with "Target of URI doesn't exist" or "Undefined class 'DoubaoVoiceTranscriber'"
```

- [ ] **Step 3: Implement the real Doubao adapter and wire it into `server/bin/main.dart`**

Create `server/lib/doubao_voice_transcriber.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'voice_transcriber.dart';

class DoubaoVoiceTranscriber implements VoiceTranscriber {
  DoubaoVoiceTranscriber({
    http.Client? httpClient,
    required String baseUrl,
    required String apiKey,
    required String model,
  })  : _client = httpClient ?? http.Client(),
        _baseUrl = baseUrl,
        _apiKey = apiKey,
        _model = model;

  factory DoubaoVoiceTranscriber.fromEnvironment({http.Client? httpClient}) {
    final baseUrl = Platform.environment['DOUBAO_ASR_BASE_URL'];
    final apiKey = Platform.environment['DOUBAO_API_KEY'];
    final model = Platform.environment['DOUBAO_ASR_MODEL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError('DOUBAO_ASR_BASE_URL is required');
    }
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('DOUBAO_API_KEY is required');
    }
    if (model == null || model.isEmpty) {
      throw StateError('DOUBAO_ASR_MODEL is required');
    }

    return DoubaoVoiceTranscriber(
      httpClient: httpClient,
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
    );
  }

  final http.Client _client;
  final String _baseUrl;
  final String _apiKey;
  final String _model;

  @override
  Future<String> transcribe(VoiceAudioPayload payload) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/audio/transcriptions'),
    )
      ..headers['authorization'] = 'Bearer $_apiKey'
      ..fields['model'] = _model
      ..fields['response_format'] = 'json'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          payload.bytes,
          filename: payload.fileName,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw VoiceTranscriptionException(
        'Doubao ASR request failed: ${response.statusCode} ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final transcript = (body['text'] as String?)?.trim() ?? '';
    if (transcript.isEmpty) {
      throw const VoiceTranscriptionException('Doubao ASR returned empty text');
    }
    return transcript;
  }
}
```

Update `server/bin/main.dart`:

```dart
import 'dart:io';

import 'package:todolist_server/doubao_voice_transcriber.dart';
import 'package:todolist_server/server.dart';

void main() async {
  final server = await createServer(
    port: 9001,
    address: InternetAddress.anyIPv4,
    transcriber: DoubaoVoiceTranscriber.fromEnvironment(),
  );
  stdout.writeln('Server running on http://${server.address.host}:${server.port}');
}
```

- [ ] **Step 4: Run the adapter test and the full server suite**

Run:

```bash
(cd server && dart test test/doubao_voice_transcriber_test.dart)
(cd server && dart test)
```

Expected:

```text
All tests passed.
```

- [ ] **Step 5: Commit the Doubao adapter**

```bash
git add server/lib/doubao_voice_transcriber.dart server/bin/main.dart server/test/doubao_voice_transcriber_test.dart
git commit -m "feat: add doubao voice transcriber"
```

## Task 4: Add Client Audio Capture And The `/voice/transcribe` HTTP Client

**Files:**
- Create: `lib/src/audio/recorded_audio_clip.dart`
- Create: `lib/src/audio/voice_audio_recorder.dart`
- Create: `lib/src/audio/record_voice_audio_recorder.dart`
- Create: `lib/src/api/voice_transcription_client.dart`
- Create: `lib/src/api/http_voice_transcription_client.dart`
- Modify: `lib/src/api/voice_kanban_api_client.dart`
- Modify: `test/voice_kanban_api_client_test.dart`
- Create: `test/http_voice_transcription_client_test.dart`

- [ ] **Step 1: Write the failing client tests for `/voice/transcribe` and `sourceType: "voice"`**

Create `test/http_voice_transcription_client_test.dart`:

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/http_voice_transcription_client.dart';
import 'package:todolist_ai_native/src/audio/recorded_audio_clip.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'http_voice_transcription_client_test.mocks.dart';

void main() {
  const baseUrl = 'http://test';

  test('C1: transcribe posts raw PCM bytes to /voice/transcribe', () async {
    final mockClient = MockClient();
    final apiClient = HttpVoiceTranscriptionClient(
      httpClient: mockClient,
      baseUrl: baseUrl,
    );
    final clip = RecordedAudioClip(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'voice-input.pcm',
      format: 'pcm_s16le',
      sampleRateHz: 16000,
    );

    when(
      mockClient.post(
        Uri.parse('$baseUrl/voice/transcribe'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer(
      (_) async => http.Response(jsonEncode({'transcript': '买鸡蛋'}), 200),
    );

    final transcript = await apiClient.transcribe(clip);
    expect(transcript, '买鸡蛋');

    final captured = verify(
      mockClient.post(
        any,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      ),
    ).captured;

    final headers = captured[0] as Map<String, String>;
    final body = captured[1] as List<int>;
    expect(headers['x-audio-format'], 'pcm_s16le');
    expect(headers['x-sample-rate'], '16000');
    expect(headers['x-file-name'], 'voice-input.pcm');
    expect(body, [1, 2, 3]);
  });
}
```

Update `test/voice_kanban_api_client_test.dart` to verify voice persistence:

```dart
test('C6: createEntry sends sourceType voice when requested', () async {
  when(mockHttpClient.post(
    Uri.parse('$baseUrl/entries'),
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'rawEntry': {
            'id': 'entry-voice',
            'sourceType': 'voice',
            'rawText': '买鸡蛋',
            'createdAt': '2026-04-12T10:00:00.000Z'
          },
          'items': []
        }),
        201,
      ));

  await client.createEntry('买鸡蛋', sourceType: 'voice');

  final captured = verify(
    mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: captureAnyNamed('body'),
    ),
  ).captured;
  final body = jsonDecode(captured.first as String) as Map<String, dynamic>;
  expect(body['sourceType'], 'voice');
});
```

- [ ] **Step 2: Run the client tests to verify the new classes and method signature are missing**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/http_voice_transcription_client_test.dart
flutter test test/voice_kanban_api_client_test.dart
```

Expected:

```text
FAIL with missing imports for the new transcription client
FAIL with createEntry not accepting sourceType
```

- [ ] **Step 3: Implement the client audio payload, the record wrapper, the transcription client, and the voice-aware entry method**

Create `lib/src/audio/recorded_audio_clip.dart`:

```dart
import 'dart:typed_data';

class RecordedAudioClip {
  const RecordedAudioClip({
    required this.bytes,
    required this.fileName,
    required this.format,
    required this.sampleRateHz,
  });

  final Uint8List bytes;
  final String fileName;
  final String format;
  final int sampleRateHz;
}
```

Create `lib/src/audio/voice_audio_recorder.dart`:

```dart
import 'recorded_audio_clip.dart';

abstract interface class VoiceAudioRecorder {
  Future<void> start();
  Future<RecordedAudioClip?> stop();
}
```

Create `lib/src/audio/record_voice_audio_recorder.dart`:

```dart
import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'recorded_audio_clip.dart';
import 'voice_audio_recorder.dart';

class RecordVoiceAudioRecorder implements VoiceAudioRecorder {
  RecordVoiceAudioRecorder({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<Uint8List>? _subscription;
  BytesBuilder _buffer = BytesBuilder(copy: false);

  @override
  Future<void> start() async {
    if (!await _recorder.hasPermission()) {
      throw StateError('microphone permission denied');
    }

    _buffer = BytesBuilder(copy: false);
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    _subscription = stream.listen(_buffer.add);
  }

  @override
  Future<RecordedAudioClip?> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();

    final bytes = _buffer.takeBytes();
    if (bytes.isEmpty) return null;

    return RecordedAudioClip(
      bytes: bytes,
      fileName: 'voice-input.pcm',
      format: 'pcm_s16le',
      sampleRateHz: 16000,
    );
  }
}
```

Create `lib/src/api/voice_transcription_client.dart`:

```dart
import '../audio/recorded_audio_clip.dart';

abstract interface class VoiceTranscriptionClient {
  Future<String> transcribe(RecordedAudioClip clip);
}
```

Create `lib/src/api/http_voice_transcription_client.dart`:

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../audio/recorded_audio_clip.dart';
import 'todo_api_client.dart' show ApiException;
import 'voice_transcription_client.dart';

class HttpVoiceTranscriptionClient implements VoiceTranscriptionClient {
  HttpVoiceTranscriptionClient({http.Client? httpClient, String? baseUrl})
      : _client = httpClient ?? http.Client(),
        _base = baseUrl ?? 'http://192.168.67.235:9001';

  final http.Client _client;
  final String _base;

  @override
  Future<String> transcribe(RecordedAudioClip clip) async {
    final response = await _client.post(
      Uri.parse('$_base/voice/transcribe'),
      headers: {
        'content-type': 'application/octet-stream',
        'x-audio-format': clip.format,
        'x-sample-rate': '${clip.sampleRateHz}',
        'x-file-name': clip.fileName,
      },
      body: clip.bytes,
    );

    if (response.statusCode != 200) {
      var message = response.body;
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        message = decoded['error'] as String? ?? response.body;
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final transcript = (data['transcript'] as String?)?.trim() ?? '';
    if (transcript.isEmpty) {
      throw const ApiException(500, 'Missing transcript in response');
    }
    return transcript;
  }
}
```

Update `lib/src/api/voice_kanban_api_client.dart`:

```dart
Future<CreateEntryResponse> createEntry(
  String rawText, {
  String sourceType = 'text',
}) async {
  final res = await _client.post(
    Uri.parse('$_base/entries'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode({
      'rawText': rawText,
      'sourceType': sourceType,
    }),
  );
  _assertOk(res, expected: 201);
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  return CreateEntryResponse.fromJson(data);
}
```

Do not unit-test `RecordVoiceAudioRecorder` directly.
It is plugin glue code and should be covered by the flow tests plus the final macOS runtime verification.

- [ ] **Step 4: Re-run build generation and the client tests**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/http_voice_transcription_client_test.dart
flutter test test/voice_kanban_api_client_test.dart
```

Expected:

```text
All tests passed.
```

- [ ] **Step 5: Commit the client capture and transcription code**

```bash
git add pubspec.yaml pubspec.lock lib/src/audio/recorded_audio_clip.dart lib/src/audio/voice_audio_recorder.dart lib/src/audio/record_voice_audio_recorder.dart lib/src/api/voice_transcription_client.dart lib/src/api/http_voice_transcription_client.dart lib/src/api/voice_kanban_api_client.dart test/http_voice_transcription_client_test.dart test/http_voice_transcription_client_test.mocks.dart test/voice_kanban_api_client_test.dart
git commit -m "feat: add client voice transcription support"
```

## Task 5: Add The Voice Flow Provider

**Files:**
- Create: `lib/src/provider/voice_kanban_voice_flow_provider.dart`
- Modify: `lib/src/provider/voice_kanban_provider.dart`
- Create: `test/voice_kanban_voice_flow_provider_test.dart`

- [ ] **Step 1: Write the failing provider tests for record -> transcribe -> parse -> save**

Create `test/voice_kanban_voice_flow_provider_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_api_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_model.dart';
import 'package:todolist_ai_native/src/api/voice_transcription_client.dart';
import 'package:todolist_ai_native/src/audio/recorded_audio_clip.dart';
import 'package:todolist_ai_native/src/audio/voice_audio_recorder.dart';
import 'package:todolist_ai_native/src/provider/voice_kanban_provider.dart';
import 'package:todolist_ai_native/src/provider/voice_kanban_voice_flow_provider.dart';

import 'voice_kanban_provider_test.mocks.dart';

class FakeVoiceAudioRecorder implements VoiceAudioRecorder {
  bool started = false;
  RecordedAudioClip? clip;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<RecordedAudioClip?> stop() async => clip;
}

class FakeVoiceTranscriptionClient implements VoiceTranscriptionClient {
  FakeVoiceTranscriptionClient(this.transcript);

  final String transcript;
  int callCount = 0;

  @override
  Future<String> transcribe(RecordedAudioClip clip) async {
    callCount += 1;
    return transcript;
  }
}

void main() {
  test('VF1: stopRecordingAndParse stores transcript and parsed drafts', () async {
    final fakeRecorder = FakeVoiceAudioRecorder()
      ..clip = RecordedAudioClip(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'voice-input.pcm',
        format: 'pcm_s16le',
        sampleRateHz: 16000,
      );
    final fakeTranscription = FakeVoiceTranscriptionClient('买鸡蛋');
    final mockApiClient = MockVoiceKanbanApiClient();

    when(mockApiClient.parse('买鸡蛋')).thenAnswer(
      (_) async => [const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')],
    );
    when(mockApiClient.listItems()).thenAnswer((_) async => []);

    final container = ProviderContainer(
      overrides: [
        voiceAudioRecorderProvider.overrideWithValue(fakeRecorder),
        voiceTranscriptionClientProvider.overrideWithValue(fakeTranscription),
        voiceKanbanApiClientProvider.overrideWithValue(mockApiClient),
      ],
    );
    addTearDown(container.dispose);

    await container.read(voiceKanbanVoiceFlowProvider.notifier).startRecording();
    await container.read(voiceKanbanVoiceFlowProvider.notifier).stopRecordingAndParse();

    final state = container.read(voiceKanbanVoiceFlowProvider);
    expect(state.transcript, '买鸡蛋');
    expect(state.isRecording, isFalse);
    expect(state.isTranscribing, isFalse);
    expect(container.read(voiceKanbanDraftsProvider).value!.length, 1);
  });

  test('VF2: saveVoiceDraft persists transcript as sourceType voice', () async {
    final fakeRecorder = FakeVoiceAudioRecorder()
      ..clip = RecordedAudioClip(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'voice-input.pcm',
        format: 'pcm_s16le',
        sampleRateHz: 16000,
      );
    final fakeTranscription = FakeVoiceTranscriptionClient('买鸡蛋');
    final mockApiClient = MockVoiceKanbanApiClient();

    when(mockApiClient.parse('买鸡蛋')).thenAnswer(
      (_) async => [const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')],
    );
    when(mockApiClient.createEntry('买鸡蛋', sourceType: 'voice')).thenAnswer(
      (_) async => CreateEntryResponse(
        rawEntry: RawEntry(
          id: 'entry-voice',
          sourceType: 'voice',
          rawText: '买鸡蛋',
          createdAt: DateTime.parse('2026-04-12T10:00:00.000Z'),
        ),
        items: [
          ParsedItem(
            id: 'item-voice',
            rawEntryId: 'entry-voice',
            type: ParsedItemType.task,
            content: '买鸡蛋',
            createdAt: DateTime.parse('2026-04-12T10:00:00.000Z'),
          ),
        ],
      ),
    );
    when(mockApiClient.listItems()).thenAnswer((_) async => []);

    final container = ProviderContainer(
      overrides: [
        voiceAudioRecorderProvider.overrideWithValue(fakeRecorder),
        voiceTranscriptionClientProvider.overrideWithValue(fakeTranscription),
        voiceKanbanApiClientProvider.overrideWithValue(mockApiClient),
      ],
    );
    addTearDown(container.dispose);

    await container.read(voiceKanbanVoiceFlowProvider.notifier).startRecording();
    await container.read(voiceKanbanVoiceFlowProvider.notifier).stopRecordingAndParse();

    await container.read(voiceKanbanVoiceFlowProvider.notifier).saveVoiceDraft();

    verify(mockApiClient.createEntry('买鸡蛋', sourceType: 'voice')).called(1);
    expect(container.read(voiceKanbanVoiceFlowProvider).transcript, isNull);
  });
}
```

- [ ] **Step 2: Run the provider tests to verify the flow provider is missing**

Run: `flutter test test/voice_kanban_voice_flow_provider_test.dart`

Expected:

```text
FAIL with missing `voiceAudioRecorderProvider`, `voiceTranscriptionClientProvider`, or `voiceKanbanVoiceFlowProvider`
```

- [ ] **Step 3: Implement the voice flow provider and make the item provider voice-aware**

Create `lib/src/provider/voice_kanban_voice_flow_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/http_voice_transcription_client.dart';
import '../api/voice_transcription_client.dart';
import '../audio/record_voice_audio_recorder.dart';
import '../audio/voice_audio_recorder.dart';
import 'voice_kanban_provider.dart';

part 'voice_kanban_voice_flow_provider.g.dart';

class VoiceCaptureState {
  const VoiceCaptureState({
    this.isRecording = false,
    this.isTranscribing = false,
    this.transcript,
    this.errorMessage,
  });

  final bool isRecording;
  final bool isTranscribing;
  final String? transcript;
  final String? errorMessage;

  VoiceCaptureState copyWith({
    bool? isRecording,
    bool? isTranscribing,
    String? transcript,
    String? errorMessage,
    bool clearTranscript = false,
    bool clearError = false,
  }) {
    return VoiceCaptureState(
      isRecording: isRecording ?? this.isRecording,
      isTranscribing: isTranscribing ?? this.isTranscribing,
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
VoiceAudioRecorder voiceAudioRecorder(VoiceAudioRecorderRef ref) {
  return RecordVoiceAudioRecorder();
}

@riverpod
VoiceTranscriptionClient voiceTranscriptionClient(
  VoiceTranscriptionClientRef ref,
) {
  return HttpVoiceTranscriptionClient();
}

@riverpod
class VoiceKanbanVoiceFlow extends _$VoiceKanbanVoiceFlow {
  @override
  VoiceCaptureState build() => const VoiceCaptureState();

  Future<void> startRecording() async {
    state = state.copyWith(clearError: true);
    try {
      await ref.read(voiceAudioRecorderProvider).start();
      state = state.copyWith(isRecording: true);
    } catch (_) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: '录音失败，请检查麦克风权限',
        clearTranscript: true,
      );
    }
  }

  Future<void> stopRecordingAndParse() async {
    state = state.copyWith(
      isRecording: false,
      isTranscribing: true,
      clearError: true,
    );

    try {
      final clip = await ref.read(voiceAudioRecorderProvider).stop();
      if (clip == null || clip.bytes.isEmpty) {
        throw StateError('empty recording');
      }

      final transcript = await ref.read(voiceTranscriptionClientProvider).transcribe(clip);
      await ref.read(voiceKanbanDraftsProvider.notifier).parse(transcript);

      state = state.copyWith(
        isTranscribing: false,
        transcript: transcript,
      );
    } catch (_) {
      ref.read(voiceKanbanDraftsProvider.notifier).clear();
      state = state.copyWith(
        isTranscribing: false,
        errorMessage: '语音转写失败，请重试',
        clearTranscript: true,
      );
    }
  }

  void clearVoiceResult() {
    ref.read(voiceKanbanDraftsProvider.notifier).clear();
    state = const VoiceCaptureState();
  }

  Future<void> saveVoiceDraft() async {
    final transcript = state.transcript?.trim();
    if (transcript == null || transcript.isEmpty) return;

    await ref.read(voiceKanbanItemsProvider.notifier).createEntry(
      transcript,
      sourceType: 'voice',
    );
    clearVoiceResult();
  }
}
```

Update `lib/src/provider/voice_kanban_provider.dart`:

```dart
Future<void> createEntry(String rawText, {String sourceType = 'text'}) async {
  await ref.read(voiceKanbanApiClientProvider).createEntry(
    rawText,
    sourceType: sourceType,
  );
  await fetchItems();
}
```

Run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Run the provider tests again**

Run: `flutter test test/voice_kanban_voice_flow_provider_test.dart`

Expected:

```text
All tests passed.
```

- [ ] **Step 5: Commit the voice flow provider**

```bash
git add lib/src/provider/voice_kanban_provider.dart lib/src/provider/voice_kanban_provider.g.dart lib/src/provider/voice_kanban_voice_flow_provider.dart lib/src/provider/voice_kanban_voice_flow_provider.g.dart test/voice_kanban_voice_flow_provider_test.dart
git commit -m "feat: add voice kanban flow provider"
```

## Task 6: Integrate Voice Controls Into `VoiceKanbanPage`

**Files:**
- Modify: `lib/src/pages/voice_kanban_page.dart`
- Modify: `test/voice_kanban_page_test.dart`

- [ ] **Step 1: Write the failing widget tests for voice controls, transcript display, and voice save**

Update `test/voice_kanban_page_test.dart` with a fake recorder and fake transcription client:

```dart
import 'dart:typed_data';

import 'package:todolist_ai_native/src/api/voice_transcription_client.dart';
import 'package:todolist_ai_native/src/audio/recorded_audio_clip.dart';
import 'package:todolist_ai_native/src/audio/voice_audio_recorder.dart';
import 'package:todolist_ai_native/src/provider/voice_kanban_voice_flow_provider.dart';

class FakeVoiceAudioRecorder implements VoiceAudioRecorder {
  bool started = false;
  RecordedAudioClip? clip;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<RecordedAudioClip?> stop() async => clip;
}

class FakeVoiceTranscriptionClient implements VoiceTranscriptionClient {
  FakeVoiceTranscriptionClient(this.transcript);

  final String transcript;

  @override
  Future<String> transcribe(RecordedAudioClip clip) async => transcript;
}
```

Add a helper that overrides the voice dependencies:

```dart
Widget createWidget({
  required MockVoiceKanbanApiClient mockApiClient,
  required VoiceAudioRecorder recorder,
  required VoiceTranscriptionClient transcriptionClient,
}) {
  return ProviderScope(
    overrides: [
      voiceKanbanApiClientProvider.overrideWithValue(mockApiClient),
      voiceAudioRecorderProvider.overrideWithValue(recorder),
      voiceTranscriptionClientProvider.overrideWithValue(transcriptionClient),
    ],
    child: const MaterialApp(home: VoiceKanbanPage()),
  );
}
```

Add these tests:

```dart
testWidgets('W4: voice buttons render and show transcript after stop', (tester) async {
  final fakeRecorder = FakeVoiceAudioRecorder()
    ..clip = RecordedAudioClip(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'voice-input.pcm',
      format: 'pcm_s16le',
      sampleRateHz: 16000,
    );
  final fakeTranscription = FakeVoiceTranscriptionClient('买鸡蛋');

  when(mockApiClient.listItems()).thenAnswer((_) async => []);
  when(mockApiClient.parse('买鸡蛋')).thenAnswer(
    (_) async => [const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')],
  );

  await tester.pumpWidget(
    createWidget(
      mockApiClient: mockApiClient,
      recorder: fakeRecorder,
      transcriptionClient: fakeTranscription,
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('btn_start_recording')), findsOneWidget);

  await tester.tap(find.byKey(const Key('btn_start_recording')));
  await tester.pump();
  await tester.tap(find.byKey(const Key('btn_stop_recording')));
  await tester.pump();
  await tester.pumpAndSettle();

  expect(find.text('转写文本'), findsOneWidget);
  expect(find.textContaining('买鸡蛋'), findsWidgets);
});

testWidgets('W5: save uses sourceType voice when transcript is active', (tester) async {
  final fakeRecorder = FakeVoiceAudioRecorder()
    ..clip = RecordedAudioClip(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'voice-input.pcm',
      format: 'pcm_s16le',
      sampleRateHz: 16000,
    );
  final fakeTranscription = FakeVoiceTranscriptionClient('买鸡蛋');

  when(mockApiClient.listItems()).thenAnswer((_) async => []);
  when(mockApiClient.parse('买鸡蛋')).thenAnswer(
    (_) async => [const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')],
  );
  when(mockApiClient.createEntry('买鸡蛋', sourceType: 'voice')).thenAnswer(
    (_) async => CreateEntryResponse(
      rawEntry: RawEntry(
        id: 'entry-voice',
        sourceType: 'voice',
        rawText: '买鸡蛋',
        createdAt: DateTime.parse('2026-04-12T10:00:00.000Z'),
      ),
      items: [],
    ),
  );

  await tester.pumpWidget(
    createWidget(
      mockApiClient: mockApiClient,
      recorder: fakeRecorder,
      transcriptionClient: fakeTranscription,
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('btn_start_recording')));
  await tester.pump();
  await tester.tap(find.byKey(const Key('btn_stop_recording')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('btn_save')));
  await tester.pumpAndSettle();

  verify(mockApiClient.createEntry('买鸡蛋', sourceType: 'voice')).called(1);
});
```

- [ ] **Step 2: Run the widget test file to verify the page has no voice UI yet**

Run: `flutter test test/voice_kanban_page_test.dart`

Expected:

```text
FAIL because `btn_start_recording` and transcript UI do not exist yet
```

- [ ] **Step 3: Implement the minimal page integration**

Update the imports and state usage in `lib/src/pages/voice_kanban_page.dart`:

```dart
import '../provider/voice_kanban_voice_flow_provider.dart';
```

Update `_handleSave()`:

```dart
Future<void> _handleSave() async {
  final voiceState = ref.read(voiceKanbanVoiceFlowProvider);
  final voiceTranscript = voiceState.transcript?.trim();

  if (voiceTranscript != null && voiceTranscript.isNotEmpty) {
    await ref.read(voiceKanbanVoiceFlowProvider.notifier).saveVoiceDraft();
  } else {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(voiceKanbanItemsProvider.notifier).createEntry(text);
    _textController.clear();
    ref.read(voiceKanbanDraftsProvider.notifier).clear();
  }

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }
}
```

Inside `build()`, watch the voice state:

```dart
final voiceState = ref.watch(voiceKanbanVoiceFlowProvider);
```

Insert the voice controls below the text input block:

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Card(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '语音录音',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                key: const Key('btn_start_recording'),
                onPressed: voiceState.isRecording
                    ? null
                    : () => ref.read(voiceKanbanVoiceFlowProvider.notifier).startRecording(),
                child: const Text('开始录音'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: const Key('btn_stop_recording'),
                onPressed: voiceState.isRecording
                    ? () => ref.read(voiceKanbanVoiceFlowProvider.notifier).stopRecordingAndParse()
                    : null,
                child: const Text('停止录音'),
              ),
              const SizedBox(width: 8),
              TextButton(
                key: const Key('btn_clear_voice'),
                onPressed: () => ref.read(voiceKanbanVoiceFlowProvider.notifier).clearVoiceResult(),
                child: const Text('清除语音结果'),
              ),
            ],
          ),
          if (voiceState.isTranscribing) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          if (voiceState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              voiceState.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          if ((voiceState.transcript ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              '转写文本',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(voiceState.transcript!),
          ],
        ],
      ),
    ),
  ),
),
```

Keep the text input and parse button unchanged.
Do not make the transcript editable.
Do not add a separate voice route.

- [ ] **Step 4: Re-run the widget tests and the existing provider tests**

Run:

```bash
flutter test test/voice_kanban_page_test.dart
flutter test test/voice_kanban_provider_test.dart
flutter test test/voice_kanban_voice_flow_provider_test.dart
```

Expected:

```text
All tests passed.
```

- [ ] **Step 5: Commit the page integration**

```bash
git add lib/src/pages/voice_kanban_page.dart test/voice_kanban_page_test.dart
git commit -m "feat: add voice controls to voice kanban page"
```

## Task 7: Verify The Full Flow On macOS With Real Doubao ASR

**Files:**
- Modify only if runtime verification finds a real bug

- [ ] **Step 1: Export the real Doubao environment variables from the official console sample**

Run in the terminal where the server will start:

```bash
read -rsp "Doubao API key: " DOUBAO_API_KEY && export DOUBAO_API_KEY && printf '\n'
read -rp "Doubao ASR base URL: " DOUBAO_ASR_BASE_URL && export DOUBAO_ASR_BASE_URL
read -rp "Doubao ASR model ID: " DOUBAO_ASR_MODEL && export DOUBAO_ASR_MODEL
```

Verification rule:

```text
Do not invent these values. Copy them from the Volcengine official console-generated demo for your account.
```

- [ ] **Step 2: Run the automated tests before launching**

Run:

```bash
(cd server && dart test)
flutter test test/http_voice_transcription_client_test.dart
flutter test test/voice_kanban_api_client_test.dart
flutter test test/voice_kanban_voice_flow_provider_test.dart
flutter test test/voice_kanban_page_test.dart
```

Expected:

```text
All tests passed.
```

- [ ] **Step 3: Start the real server and the macOS app**

Run in terminal A:

```bash
(cd server && dart run bin/main.dart)
```

Expected:

```text
Server running on http://0.0.0.0:9001
```

Run in terminal B:

```bash
flutter run -d macos
```

Expected:

```text
A macOS window opens successfully.
```

- [ ] **Step 4: Exercise the real voice flow manually**

Manual checklist:

```text
1. Open the Voice Kanban page.
2. Click "开始录音".
3. Speak one short todo sentence such as "下班买鸡蛋".
4. Click "停止录音".
5. Wait for the transcript to appear in the read-only transcript block.
6. Verify the parsed preview appears automatically.
7. Click "保存".
8. Verify the saved item appears in the list and that the raw entry stored by the server uses sourceType "voice".
```

- [ ] **Step 5: If runtime verification finds a bug, fix it, rerun the affected tests, and commit**

If code changed during runtime verification:

```bash
(cd server && dart test)
flutter test test/http_voice_transcription_client_test.dart
flutter test test/voice_kanban_api_client_test.dart
flutter test test/voice_kanban_voice_flow_provider_test.dart
flutter test test/voice_kanban_page_test.dart
git add .
git commit -m "fix: polish macos voice kanban flow"
```

If no files changed during runtime verification:

```text
Do not create an empty commit.
```
