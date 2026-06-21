import 'package:flutter/material.dart';
import 'package:myjobs/core/widgets/empty_state_widget.dart';
import 'package:myjobs/core/widgets/global_loading_indicator.dart';
import 'package:myjobs/features/goals/data/models/goal_model.dart';
import 'package:myjobs/features/goals/data/repositories/goal_repository.dart';
import 'package:myjobs/features/goals/presentation/pages/add_goal_screen.dart';

class CareerGoalsScreen extends StatefulWidget {
  const CareerGoalsScreen({super.key});

  @override
  State<CareerGoalsScreen> createState() => _CareerGoalsScreenState();
}

class _CareerGoalsScreenState extends State<CareerGoalsScreen> {
  final GoalRepository _repository = GoalRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Career Roadmap', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<GoalModel>>(
        stream: _repository.getGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const GlobalLoadingIndicator();
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: 'Gagal memuat timeline. ${snapshot.error}',
            );
          }

          final goals = snapshot.data;

          if (goals == null || goals.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.flag_outlined,
              title: 'Belum Ada Target',
              subtitle: 'Mulai bangun roadmap karirmu. Tambahkan target pertamamu!',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final isLast = index == goals.length - 1;
              return _buildTimelineItem(context, goal, isLast);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Target'),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, GoalModel goal, bool isLast) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Node
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  _repository.toggleGoalCompletion(goal.id, goal.isCompleted);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: goal.isCompleted ? colorScheme.primary : colorScheme.surface,
                    border: Border.all(
                      color: goal.isCompleted ? colorScheme.primary : colorScheme.outlineVariant,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: goal.isCompleted
                      ? Icon(Icons.check, size: 18, color: colorScheme.onPrimary)
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Card.outlined(
                color: goal.isCompleted ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: goal.isCompleted ? Colors.transparent : colorScheme.outlineVariant,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.flag,
                        size: 100,
                        color: colorScheme.primary.withValues(alpha: 0.05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                                        color: goal.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                                color: colorScheme.error,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                onPressed: () {
                                  _repository.deleteGoal(goal.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.work_outline, size: 16, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  goal.targetJob,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (goal.targetMonth != null || goal.targetYear != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.event, size: 16, color: colorScheme.tertiary),
                                const SizedBox(width: 8),
                                Text(
                                  'Target: ${goal.targetMonth ?? ''} ${goal.targetYear ?? ''}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
