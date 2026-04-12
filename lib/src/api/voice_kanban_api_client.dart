import 'dart:convert';
import 'package:http/http.dart' as http;
import 'todo_api_client.dart' show ApiException;
import 'voice_kanban_model.dart';

class VoiceKanbanApiClient {
  VoiceKanbanApiClient({http.Client? httpClient, String? baseUrl})
      : _client = httpClient ?? http.Client(),
        _base = baseUrl ?? 'http://192.168.67.235:9001';

  final http.Client _client;
  final String _base;

  Future<List<ParsedDraft>> parse(String rawText) async {
    final res = await _client.post(
      Uri.parse('$_base/parse'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'rawText': rawText, 'sourceType': 'text'}),
    );
    _assertOk(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((e) => ParsedDraft.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CreateEntryResponse> createEntry(String rawText) async {
    final res = await _client.post(
      Uri.parse('$_base/entries'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'rawText': rawText, 'sourceType': 'text'}),
    );
    _assertOk(res, expected: 201);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return CreateEntryResponse.fromJson(data);
  }

  Future<List<ParsedItem>> listItems({ParsedItemType? type}) async {
    var uri = Uri.parse('$_base/items');
    if (type != null) {
      uri = uri.replace(queryParameters: {'type': type.name});
    } else {
      uri = uri.replace(queryParameters: {'type': 'all'});
    }

    final res = await _client.get(uri);
    _assertOk(res);
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => ParsedItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _assertOk(http.Response res, {int expected = 200}) {
    if (res.statusCode != expected) {
      String errorMessage = res.body;
      try {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        if (decoded.containsKey('error')) {
          errorMessage = decoded['error'] as String;
        }
      } catch (_) {}
      throw ApiException(res.statusCode, errorMessage);
    }
  }
}
