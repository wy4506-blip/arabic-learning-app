import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_widgets.dart';

class ReviewQuickActions extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ReviewQuickActionItem> actions;

  const ReviewQuickActions({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        ...actions.map(
          (action) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppSurface(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              onTap: action.onTap,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: action.tintColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(action.title,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          action.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (action.badge != null) ...[
                    const SizedBox(width: 8),
                    Pill(label: action.badge!),
                  ],
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewQuickActionItem {
  final String title;
  final String subtitle;
  final String? badge;
  final IconData icon;
  final Color tintColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const ReviewQuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tintColor,
    required this.iconColor,
    this.badge,
    this.onTap,
  });
}
