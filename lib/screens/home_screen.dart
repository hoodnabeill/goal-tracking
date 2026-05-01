import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../services/storage_service.dart';
import '../widgets/goal_card.dart';
import 'goal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();

  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final storedGoals = await _storageService.loadGoals();
    final decayedGoals = storedGoals.map((goal) => goal.applyDecay()).toList();
    final hasDecayChanges = !_listEquals(storedGoals, decayedGoals);

    if (hasDecayChanges) {
      await _storageService.saveGoals(decayedGoals);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _goals = _sortedGoals(decayedGoals);
      _isLoading = false;
    });
  }

  Future<void> _persistGoals(List<Goal> goals) async {
    setState(() {
      _goals = _sortedGoals(goals);
    });
    await _storageService.saveGoals(_goals);
  }

  Future<void> _showAddGoalSheet() async {
    final titleController = TextEditingController();
    DateTime? deadline;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B1422),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    'Create Goal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Title it, optionally set a deadline, then start stacking wins.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Goal title',
                      hintText: 'Build a portfolio, get in shape...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                        initialDate: deadline ?? DateTime.now(),
                      );

                      if (pickedDate != null) {
                        setModalState(() {
                          deadline = pickedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      deadline == null
                          ? 'Add deadline'
                          : 'Deadline: ${_formatDate(deadline!)}',
                    ),
                  ),
                  if (deadline != null)
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          deadline = null;
                        });
                      },
                      child: const Text('Remove deadline'),
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

                        final now = DateTime.now();
                        final newGoal = Goal(
                          id: now.microsecondsSinceEpoch.toString(),
                          title: title,
                          tasks: const [],
                          createdAt: now,
                          lastCompletedAt: now,
                          lastDecayAppliedAt: now,
                          progress: 0,
                          deadline: deadline,
                        );

                        final updatedGoals = [..._goals, newGoal];
                        await _persistGoals(updatedGoals);

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.of(context).pop();
                      },
                      child: const Text('Create Goal'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
  }

  Future<void> _openGoal(Goal goal) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GoalScreen(
          goal: goal,
          onGoalUpdated: _handleGoalUpdated,
        ),
      ),
    );
  }

  Future<void> _handleGoalUpdated(Goal updatedGoal) async {
    final updatedGoals = [
      for (final goal in _goals)
        if (goal.id == updatedGoal.id) updatedGoal else goal,
    ];

    await _persistGoals(updatedGoals);
  }

  @override
  Widget build(BuildContext context) {
    final totalProgress = _goals.isEmpty
        ? 0.0
        : _goals
                .map((goal) => goal.progress)
                .reduce((value, element) => value + element) /
            _goals.length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalSheet,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress Engine',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Build momentum daily. Miss 24 hours and each goal loses 5%.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            _SummaryCard(
                              goalCount: _goals.length,
                              averageProgress: totalProgress,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text(
                                  'Your Goals',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    if (_goals.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList.builder(
                          itemCount: _goals.length,
                          itemBuilder: (context, index) {
                            final goal = _goals[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: GoalCard(
                                goal: goal,
                                onTap: () => _openGoal(goal),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Goal> _sortedGoals(List<Goal> goals) {
    final copy = [...goals];
    copy.sort(
      (first, second) => second.createdAt.compareTo(first.createdAt),
    );
    return copy;
  }

  bool _listEquals(List<Goal> first, List<Goal> second) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index++) {
      if (first[index].toJson().toString() != second[index].toJson().toString()) {
        return false;
      }
    }

    return true;
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.goalCount,
    required this.averageProgress,
  });

  final int goalCount;
  final double averageProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF12304A),
            Color(0xFF0D5C56),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Momentum',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            goalCount == 0
                ? 'Start with one goal and build from there.'
                : '$goalCount active goals in motion.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBlock(
                  label: 'Average progress',
                  value: '${(averageProgress * 100).round()}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBlock(
                  label: 'Decay rule',
                  value: '-5% / 24h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1726),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.track_changes_rounded,
                size: 52,
                color: Color(0xFF7AE3D7),
              ),
              const SizedBox(height: 16),
              Text(
                'No goals yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your first goal, break it into steps, and watch the bar move.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
