import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_widgets.dart';

class ReviewStatusStrip extends StatelessWidget {
  final String title;
  final List<ReviewStatusMetric> metrics;

  const ReviewStatusStrip({
    super.key,
    required this.title,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        AppSurface(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: metrics
                .map(
                  (metric) => _ReviewStatusChip(metric: metric),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class ReviewStatusMetric {
  final String label;
  final String value;
  final IconData icon;

  const ReviewStatusMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _ReviewStatusChip extends StatelessWidget {
  final ReviewStatusMetric metric;

  const _ReviewStatusChip({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              metric.icon,
              size: 18,
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                metric.value,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
