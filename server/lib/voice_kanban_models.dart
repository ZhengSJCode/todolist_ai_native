class ParsedDraft {
  final String type; // 'task' | 'metric' | 'note'
  final String content;
  final String? title;
  final num? value;
  final String? unit;

  ParsedDraft({
    required this.type,
    required this.content,
    this.title,
    this.value,
    this.unit,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
        if (title != null) 'title': title,
        if (value != null) 'value': value,
        if (unit != null) 'unit': unit,
      };

  factory ParsedDraft.fromJson(Map<String, dynamic> json) {
    return ParsedDraft(
      type: json['type'] as String,
      content: json['content'] as String,
      title: json['title'] as String?,
      value: json['value'] as num?,
      unit: json['unit'] as String?,
    );
  }
}

class RawEntry {
  final String id;
  final String sourceType;
  final String rawText;
  final DateTime createdAt;

  RawEntry({
    required this.id,
    required this.sourceType,
    required this.rawText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceType': sourceType,
        'rawText': rawText,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RawEntry.fromJson(Map<String, dynamic> json) {
    return RawEntry(
      id: json['id'] as String,
      sourceType: json['sourceType'] as String,
      rawText: json['rawText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ParsedItem {
  final String id;
  final String rawEntryId;
  final String type;
  final String content;
  final String? title;
  final num? value;
  final String? unit;
  final DateTime createdAt;

  ParsedItem({
    required this.id,
    required this.rawEntryId,
    required this.type,
    required this.content,
    this.title,
    this.value,
    this.unit,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawEntryId': rawEntryId,
        'type': type,
        'content': content,
        if (title != null) 'title': title,
        if (value != null) 'value': value,
        if (unit != null) 'unit': unit,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ParsedItem.fromJson(Map<String, dynamic> json) {
    return ParsedItem(
      id: json['id'] as String,
      rawEntryId: json['rawEntryId'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      title: json['title'] as String?,
      value: json['value'] as num?,
      unit: json['unit'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CreateEntryResult {
  final RawEntry rawEntry;
  final List<ParsedItem> items;

  CreateEntryResult({required this.rawEntry, required this.items});

  Map<String, dynamic> toJson() => {
        'rawEntry': rawEntry.toJson(),
        'items': items.map((i) => i.toJson()).toList(),
      };
}
