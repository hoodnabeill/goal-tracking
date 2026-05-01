import 'package:flutter/material.dart';

import '../models/goal.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  final Goal goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${(goal.progress * 100).round()}%',
                    style: textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF83FFF0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppProgressBar(progress: goal.progress),
              const SizedBox(height: 14),
              Row(
                children: [
                  _MetaPill(
                    icon: Icons.check_circle_outline,
                    label:
                        '${goal.completedTaskCount}/${goal.tasks.length} tasks',
                  ),
                  const SizedBox(width: 10),
                  _MetaPill(
                    icon: Icons.timelapse_rounded,
                    label: _deadlineLabel(goal.deadline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _deadlineLabel(DateTime? deadline) {
    if (deadline == null) {
      return 'No deadline';
    }

    return '${_monthLabel(deadline.month)} ${deadline.day}';
  }

  String _monthLabel(int month) {
    const labels = [
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

    return labels[month - 1];
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111D2C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF7ADAD2)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
