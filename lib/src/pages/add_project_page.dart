import 'package:flutter/material.dart';

/// Add Project in Task List screen — Figma node 101:358.
///
/// Simple form: project name field + optional category color + Add button.
/// [onAdd] is called with the trimmed project name when Add is tapped.
class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key, this.onAdd});

  final void Function(String name)? onAdd;

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  bool _hasName = false;

  static const _colors = [
    Color(0xFF5F33E1),
    Color(0xFFFF7D53),
    Color(0xFF0087FF),
    Color(0xFFF0C400),
    Color(0xFFFF5252),
    Color(0xFF00C896),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => _hasName = _nameController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Add Project',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF24252C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance close button
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Project Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6E6A7C),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('project-name-field'),
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter project name',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Category Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6E6A7C),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 0; i < _colors.length; i++) ...[
                    GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = i),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _colors[i],
                          shape: BoxShape.circle,
                          border: _selectedColorIndex == i
                              ? Border.all(
                                  color: const Color(0xFF24252C), width: 2.5)
                              : null,
                        ),
                      ),
                    ),
                    if (i < _colors.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _hasName
                      ? () {
                          widget.onAdd?.call(_nameController.text.trim());
                          Navigator.maybePop(context);
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5F33E1),
                    disabledBackgroundColor: const Color(0xFFDDD6F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
