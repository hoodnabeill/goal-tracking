import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../widgets/progress_bar.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({
    super.key,
    required this.goal,
    required this.onGoalUpdated,
  });

  final Goal goal;
  final ValueChanged<Goal> onGoalUpdated;

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  late Goal _goal;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal.applyDecay();
    if (_goal.progress != widget.goal.progress) {
      widget.onGoalUpdated(_goal);
    }
  }

  Future<void> _showAddTaskSheet() async {
    final titleController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B1422),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Subtask',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Each subtask carries equal weight in this MVP.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Subtask title',
                  hintText: 'What is the next visible step?',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();

                    if (title.isEmpty) {
                      return;
                    }

                    final updatedGoal = _goal.addTask(title);
                    await _applyGoalUpdate(updatedGoal);

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Subtask'),
                ),
              ),
            ],
          ),
        );
      },
    );

    titleController.dispose();
  }

  Future<void> _toggleTask(SubTask task, bool isDone) async {
    final updatedGoal = _goal.toggleTask(task.id, isDone);
    await _applyGoalUpdate(updatedGoal);
  }

  Future<void> _applyGoalUpdate(Goal updatedGoal) async {
    setState(() {
      _goal = updatedGoal;
    });
    await widget.onGoalUpdated(updatedGoal);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _goal.completedTaskCount;
    final totalCount = _goal.tasks.length;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: const Icon(Icons.add_task),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF07111F),
              Color(0xFF09192B),
              Color(0xFF05111B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1726),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0x1FFFFFFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _goal.title,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${(_goal.progress * 100).round()}%',
                          style: textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF7DFFF2),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppProgressBar(progress: _goal.progress, height: 12),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _InfoChip(
                          icon: Icons.checklist_rounded,
                          label: '$completedCount of $totalCount complete',
                        ),
                        _InfoChip(
                          icon: Icons.flash_on_rounded,
                          label: _goal.deadline == null
                              ? 'No deadline'
                              : 'Due ${_formatDate(_goal.deadline!)}',
                        ),
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          label: 'Decay every 24h inactive',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Finish any task to refresh momentum. If nothing gets completed for 24 hours, progress drops by 5%.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Subtasks',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_goal.tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1726),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'No subtasks yet. Add the next concrete step to get the bar moving.',
                    style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                )
              else
                ..._goal.tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1726),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x18FFFFFF)),
                      ),
                      child: CheckboxListTile(
                        value: task.isDone,
                        onChanged: (value) {
                          _toggleTask(task, value ?? false);
                        },
                        title: Text(
                          task.title,
                          style: textTheme.titleMedium?.copyWith(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isDone ? Colors.white60 : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          task.isDone ? 'Completed' : 'Open',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${monthLabels[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF132031),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF7ADDD3)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
