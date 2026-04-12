import 'package:test/test.dart';
import '../lib/voice_kanban_parser.dart';

void main() {
  group('RuleBasedEntryParser', () {
    late RuleBasedEntryParser parser;

    setUp(() {
      parser = RuleBasedEntryParser();
    });

    test('X1: empty string should return empty list', () async {
      final drafts = await parser.parse('');
      expect(drafts, isEmpty);

      final drafts2 = await parser.parse('   \n\t  ');
      expect(drafts2, isEmpty);
    });

    test('X2: single note without numeric or task keyword', () async {
      final drafts = await parser.parse('今天天气真好');
      expect(drafts.length, 1);
      expect(drafts.first.type, 'note');
      expect(drafts.first.content, '今天天气真好');
    });

    test('X3: metric text with numbers', () async {
      final drafts = await parser.parse('今天体重75.5kg');
      expect(drafts.length, 1);
      expect(drafts.first.type, 'metric');
      expect(drafts.first.content, '今天体重75.5kg');
      expect(drafts.first.value, 75.5);
      expect(drafts.first.unit, 'kg');
    });

    test('X4: PRD example sentences should be separated into multiple items', () async {
      final drafts = await parser.parse('今天体重75.5kg，下班去买5斤鸡胸肉，这周感觉力量训练有进步');
      expect(drafts.length, 3);
      expect(drafts[0].type, 'metric');
      expect(drafts[0].value, 75.5);
      expect(drafts[1].type, 'task');
      expect(drafts[1].content, '买 5 斤鸡胸肉');
      expect(drafts[2].type, 'note');
      expect(drafts[2].content, '这周感觉力量训练有进步');
    });
  });
}
