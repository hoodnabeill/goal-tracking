class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.tasks,
    required this.createdAt,
    required this.lastCompletedAt,
    required this.lastDecayAppliedAt,
    required this.progress,
    this.deadline,
  });

  final String id;
  final String title;
  final List<SubTask> tasks;
  final DateTime createdAt;
  final DateTime lastCompletedAt;
  final DateTime lastDecayAppliedAt;
  final double progress;
  final DateTime? deadline;

  int get completedTaskCount => tasks.where((task) => task.isDone).length;

  double get completionRate => calculateProgress(tasks);

  Goal copyWith({
    String? id,
    String? title,
    List<SubTask>? tasks,
    DateTime? createdAt,
    DateTime? lastCompletedAt,
    DateTime? lastDecayAppliedAt,
    double? progress,
    DateTime? deadline,
    bool clearDeadline = false,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      lastDecayAppliedAt: lastDecayAppliedAt ?? this.lastDecayAppliedAt,
      progress: progress ?? this.progress,
      deadline: clearDeadline ? null : deadline ?? this.deadline,
    );
  }

  Goal addTask(String title) {
    final updatedTasks = [
      ...tasks,
      SubTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
      ),
    ];

    return copyWith(
      tasks: updatedTasks,
      progress: calculateProgress(updatedTasks),
    );
  }

  Goal toggleTask(String taskId, bool isDone) {
    final updatedTasks = [
      for (final task in tasks)
        if (task.id == taskId) task.copyWith(isDone: isDone) else task,
    ];

    final now = DateTime.now();

    return copyWith(
      tasks: updatedTasks,
      progress: calculateProgress(updatedTasks),
      lastCompletedAt: isDone ? now : lastCompletedAt,
      lastDecayAppliedAt: isDone ? now : lastDecayAppliedAt,
    );
  }

  Goal applyDecay({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final hoursSinceDecay = reference.difference(lastDecayAppliedAt).inHours;

    if (hoursSinceDecay < 24 || tasks.isEmpty || progress <= 0) {
      return this;
    }

    final decaySteps = hoursSinceDecay ~/ 24;
    final updatedProgress = (progress - (decaySteps * 0.05)).clamp(0.0, 1.0);

    return copyWith(
      progress: updatedProgress,
      lastDecayAppliedAt: lastDecayAppliedAt.add(
        Duration(hours: decaySteps * 24),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastCompletedAt': lastCompletedAt.toIso8601String(),
      'lastDecayAppliedAt': lastDecayAppliedAt.toIso8601String(),
      'progress': progress,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    final tasks = ((json['tasks'] as List<dynamic>?) ?? [])
        .map(
          (task) => SubTask.fromJson(task as Map<String, dynamic>),
        )
        .toList();
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();
    final lastCompletedAt =
        DateTime.tryParse(json['lastCompletedAt'] as String? ?? '') ??
            createdAt;
    final lastDecayAppliedAt =
        DateTime.tryParse(json['lastDecayAppliedAt'] as String? ?? '') ??
            lastCompletedAt;

    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      tasks: tasks,
      createdAt: createdAt,
      lastCompletedAt: lastCompletedAt,
      lastDecayAppliedAt: lastDecayAppliedAt,
      progress: (json['progress'] as num?)?.toDouble() ??
          calculateProgress(tasks),
      deadline: json['deadline'] == null
          ? null
          : DateTime.tryParse(json['deadline'] as String),
    );
  }

  static double calculateProgress(List<SubTask> tasks) {
    if (tasks.isEmpty) {
      return 0;
    }

    final completedTasks = tasks.where((task) => task.isDone).length;
    return completedTasks / tasks.length;
  }
}

class SubTask {
  const SubTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  final String id;
  final String title;
  final bool isDone;

  SubTask copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
