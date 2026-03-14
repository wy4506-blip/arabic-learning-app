import 'package:flutter/material.dart';

import '../../../theme/app_arabic_typography.dart';
import '../../../theme/app_latin_typography.dart';
import '../../../theme/app_theme.dart';

class ExampleSoundCard extends StatelessWidget {
  final String arabic;
  final String arabicWithDiacritics;
  final String transliteration;
  final String note;
  final VoidCallback onPlayAudio;

  const ExampleSoundCard({
    super.key,
    required this.arabic,
    required this.arabicWithDiacritics,
    required this.transliteration,
    required this.note,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.strokeLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note,
                  style: text.labelMedium,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onPlayAudio,
                icon: const Icon(Icons.volume_up_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ArabicText.body(
            arabicWithDiacritics,
            style: const TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ArabicText.body(
            arabic,
            style: const TextStyle(
              fontSize: 32,
              height: 1.1,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            transliteration,
            style: AppLatinTypography.body(context).copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
