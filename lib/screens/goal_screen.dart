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
  final Future<void> Function(Goal) onGoalUpdated;

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

                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text('Add Subtask'),
                ),
              ),
