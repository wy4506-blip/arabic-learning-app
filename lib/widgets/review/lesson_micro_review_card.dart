import 'package:flutter/material.dart';

import '../../models/review_models.dart';
import '../app_widgets.dart';

class LessonMicroReviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ReviewTask> tasks;
  final String actionLabel;
  final VoidCallback? onActionTap;

  const LessonMicroReviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          if (tasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tasks
                  .map((task) => Pill(label: task.title))
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onActionTap,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
