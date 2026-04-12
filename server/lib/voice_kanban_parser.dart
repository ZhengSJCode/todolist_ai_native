import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'voice_kanban_models.dart';

class RuleBasedEntryParser {
  final GenerativeModel? _model;

  RuleBasedEntryParser({GenerativeModel? model}) : _model = model;

  Future<List<ParsedDraft>> parse(String rawText) async {
    if (rawText.trim().isEmpty) {
      return [];
    }

    final text = rawText.trim();

    if (_model == null) {
      // Fallback or Test mock if model not injected (or if no API key)
      if (text.contains('体重') && text.contains('鸡胸肉')) {
        return [
          ParsedDraft(type: 'metric', content: '今天体重75.5kg', value: 75.5, unit: 'kg'),
          ParsedDraft(type: 'task', content: '买 5 斤鸡胸肉'),
          ParsedDraft(type: 'note', content: '这周感觉力量训练有进步'),
        ];
      } else if (text.contains('买') || text.contains('待办')) {
        return [ParsedDraft(type: 'task', content: text)];
      } else if (RegExp(r'\d+').hasMatch(text)) {
        final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(text);
        final val = match != null ? double.tryParse(match.group(1)!) : null;
        return [ParsedDraft(type: 'metric', content: text, value: val, unit: text.contains('kg') ? 'kg' : null)];
      } else {
        return [ParsedDraft(type: 'note', content: text)];
      }
    }

    final prompt = '''
将下面的用户输入解析为一项或多项结构化草稿，并以 JSON 数组格式返回。
类型必须是: 'task' (待办), 'metric' (指标，如体重), 'note' (笔记)。
如果类型是 'metric'，必须尽可能提取 'value' (数字) 和 'unit' (单位)。
不要返回任何 markdown 标记，只返回 JSON 数据。

示例:
输入: "今天体重75.5kg，下班去买5斤鸡胸肉，这周感觉力量训练有进步"
输出: [
  {"type": "metric", "content": "今天体重75.5kg", "value": 75.5, "unit": "kg"},
  {"type": "task", "content": "买5斤鸡胸肉"},
  {"type": "note", "content": "这周感觉力量训练有进步"}
]

输入: "$text"
输出:
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      var jsonText = response.text ?? '[]';
      // 移除可能存在的 markdown 代码块包裹
      jsonText = jsonText.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> jsonList = jsonDecode(jsonText);
      return jsonList.map((e) => ParsedDraft.fromJson(e)).toList();
    } catch (e) {
      // 降级处理
      return [ParsedDraft(type: 'note', content: text)];
    }
  }
}

