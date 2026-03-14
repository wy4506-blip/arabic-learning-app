import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_widgets.dart';

class ReviewTodayCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final List<String> composition;
  final String metaText;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryTap;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryTap;

  const ReviewTodayCard({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.composition,
    required this.metaText,
    required this.primaryActionLabel,
    this.onPrimaryTap,
    this.secondaryActionLabel,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            label: badge,
            backgroundColor: AppTheme.softAccent,
            foregroundColor: AppTheme.accentMintDark,
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          if (composition.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: composition
                  .map((item) => Pill(label: item))
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            metaText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.accentMintDark,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimaryTap,
              child: Text(primaryActionLabel),
            ),
          ),
          if (secondaryActionLabel != null && onSecondaryTap != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onSecondaryTap,
                child: Text(secondaryActionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
