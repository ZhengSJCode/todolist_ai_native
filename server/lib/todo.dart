/// Domain model for a Todo item.
class Todo {
  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.projectId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String description;
  final bool completed;
  final String? projectId;
  final DateTime createdAt;

  Todo copyWith({
    String? title,
    String? description,
    bool? completed,
    String? projectId,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'completed': completed,
    if (projectId != null) 'projectId': projectId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'] as String,
    title: json['title'] as String,
    description: (json['description'] as String?) ?? '',
    completed: (json['completed'] as bool?) ?? false,
    projectId: json['projectId'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}
