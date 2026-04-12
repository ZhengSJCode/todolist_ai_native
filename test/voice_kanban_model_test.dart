import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_model.dart';

void main() {
  group('Voice Kanban Models JSON serialization', () {
    test('M1: ParsedDraft.fromJson with/without optional fields', () {
      final jsonMinimal = {
        'type': 'task',
        'content': 'Buy milk'
      };
      final draftMinimal = ParsedDraft.fromJson(jsonMinimal);
      expect(draftMinimal.type, ParsedItemType.task);
      expect(draftMinimal.content, 'Buy milk');
      expect(draftMinimal.value, isNull);

      final jsonFull = {
        'type': 'metric',
        'content': 'Weight 70kg',
        'title': 'Morning weight',
        'value': 70.0,
        'unit': 'kg'
      };
      final draftFull = ParsedDraft.fromJson(jsonFull);
      expect(draftFull.type, ParsedItemType.metric);
      expect(draftFull.value, 70.0);
      expect(draftFull.unit, 'kg');
    });

    test('M2: ParsedItem.fromJson includes id, rawEntryId, createdAt', () {
      final json = {
        'id': 'item-1',
        'rawEntryId': 'entry-1',
        'type': 'note',
        'content': 'Just a thought',
        'createdAt': '2026-04-12T10:00:00.000Z'
      };
      final item = ParsedItem.fromJson(json);
      expect(item.id, 'item-1');
      expect(item.rawEntryId, 'entry-1');
      expect(item.type, ParsedItemType.note);
      expect(item.createdAt.year, 2026);
    });

    test('M3: CreateEntryResponse.fromJson nested parsing', () {
      final json = {
        'rawEntry': {
          'id': 'entry-1',
          'sourceType': 'text',
          'rawText': 'Buy milk',
          'createdAt': '2026-04-12T10:00:00.000Z'
        },
        'items': [
          {
            'id': 'item-1',
            'rawEntryId': 'entry-1',
            'type': 'task',
            'content': 'Buy milk',
            'createdAt': '2026-04-12T10:00:00.000Z'
          }
        ]
      };
      final res = CreateEntryResponse.fromJson(json);
      expect(res.rawEntry.id, 'entry-1');
      expect(res.rawEntry.rawText, 'Buy milk');
      expect(res.items.length, 1);
      expect(res.items.first.id, 'item-1');
    });
  });
}
