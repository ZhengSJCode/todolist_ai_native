import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/voice_kanban_model.dart';
import '../provider/voice_kanban_provider.dart';
import '../provider/voice_kanban_voice_flow_provider.dart';

class VoiceKanbanPage extends ConsumerStatefulWidget {
  const VoiceKanbanPage({super.key});

  @override
  ConsumerState<VoiceKanbanPage> createState() => _VoiceKanbanPageState();
}

class _VoiceKanbanPageState extends ConsumerState<VoiceKanbanPage> {
  final _textController = TextEditingController();
  ParsedItemType? _selectedType;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleParse() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref.read(voiceKanbanVoiceFlowProvider.notifier).clearVoiceResult();
    try {
      await ref.read(voiceKanbanDraftsProvider.notifier).parse(text);
    } catch (e) {
      // Catch exceptions here to prevent unhandled promise rejections in tests.
      // The state provider will still capture the error and update its state.
    }
  }

  Future<void> _handleSave() async {
    final voiceFlow = ref.read(voiceKanbanVoiceFlowProvider);
    final transcript = voiceFlow.transcript?.trim() ?? '';
    if (transcript.isNotEmpty) {
      await ref.read(voiceKanbanVoiceFlowProvider.notifier).saveVoiceDraft();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已保存')),
        );
      }
      return;
    }

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(voiceKanbanItemsProvider.notifier).createEntry(text);
    _textController.clear();
    ref.read(voiceKanbanDraftsProvider.notifier).clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(voiceKanbanItemsProvider);
    final draftsAsync = ref.watch(voiceKanbanDraftsProvider);
    final voiceFlow = ref.watch(voiceKanbanVoiceFlowProvider);
    final hasDrafts =
        draftsAsync.hasValue && !(draftsAsync.valueOrNull?.isEmpty ?? true);
    final hasTranscript = (voiceFlow.transcript?.trim().isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('语音记录看板'),
      ),
      body: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Input and Parse area
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          key: const Key('kanban_input_field'),
                          controller: _textController,
                          decoration: const InputDecoration(
                            labelText: '输入记录',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              key: const Key('btn_parse'),
                              onPressed:
                                  draftsAsync.isLoading ? null : _handleParse,
                              child: const Text('解析'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              key: const Key('btn_save'),
                              onPressed:
                                  (hasDrafts || hasTranscript)
                                      ? _handleSave
                                      : null,
                              child: const Text('保存'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '语音录音',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton(
                                      key: const Key('btn_start_recording'),
                                      onPressed:
                                          voiceFlow.isRecording ||
                                                  voiceFlow.isTranscribing
                                              ? null
                                              : () => ref
                                                  .read(
                                                    voiceKanbanVoiceFlowProvider
                                                        .notifier,
                                                  )
                                                  .startRecording(),
                                      child: const Text('开始录音'),
                                    ),
                                    ElevatedButton(
                                      key: const Key('btn_stop_recording'),
                                      onPressed:
                                          voiceFlow.isRecording
                                              ? () => ref
                                                  .read(
                                                    voiceKanbanVoiceFlowProvider
                                                        .notifier,
                                                  )
                                                  .stopRecordingAndParse()
                                              : null,
                                      child: const Text('停止录音'),
                                    ),
                                    TextButton(
                                      key: const Key('btn_clear_voice'),
                                      onPressed:
                                          hasTranscript ||
                                                  voiceFlow.errorMessage != null
                                              ? () => ref
                                                  .read(
                                                    voiceKanbanVoiceFlowProvider
                                                        .notifier,
                                                  )
                                                  .clearVoiceResult()
                                              : null,
                                      child: const Text('清除语音结果'),
                                    ),
                                  ],
                                ),
                                if (voiceFlow.isTranscribing) ...[
                                  const SizedBox(height: 12),
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('转写中...'),
                                    ],
                                  ),
                                ],
                                if (voiceFlow.errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    voiceFlow.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                                if (hasTranscript) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    '转写文本',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Text(voiceFlow.transcript!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Drafts Preview area
                  if (draftsAsync.isLoading)
                    const CircularProgressIndicator()
                  else if (draftsAsync.hasError)
                    Text(
                      '解析错误: ${draftsAsync.error}',
                      style: const TextStyle(color: Colors.red),
                    )
                  else if (draftsAsync.valueOrNull != null &&
                      draftsAsync.valueOrNull!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '预览解析结果:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...draftsAsync.valueOrNull!.map(
                            (draft) => ListTile(
                              leading: Chip(label: Text(draft.type.name)),
                              title: Text(draft.content),
                              subtitle:
                                  draft.value != null
                                      ? Text('${draft.value} ${draft.unit ?? ""}')
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Divider(),

                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('全部', null),
                        _buildFilterChip('Task', ParsedItemType.task),
                        _buildFilterChip('Metric', ParsedItemType.metric),
                        _buildFilterChip('Note', ParsedItemType.note),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items List
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('加载失败: $err')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('暂无记录'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Chip(label: Text(item.type.name)),
                      title: Text(item.content),
                      subtitle: item.value != null ? Text('${item.value} ${item.unit ?? ""}') : null,
                      trailing: Text(item.createdAt.toString().split('.')[0]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ParsedItemType? type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        key: Key('filter_${type?.name ?? "all"}'),
        label: Text(label),
        selected: _selectedType == type,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
          });
          ref.read(voiceKanbanItemsProvider.notifier).fetchItems(type: _selectedType);
        },
      ),
    );
  }
}
