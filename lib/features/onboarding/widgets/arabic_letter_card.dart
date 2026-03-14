import 'package:flutter/material.dart';

import '../../../theme/app_arabic_typography.dart';
import '../../../theme/app_latin_typography.dart';
import '../../../theme/app_theme.dart';

class ArabicLetterCard extends StatelessWidget {
  final String arabic;
  final String name;
  final String transliteration;
  final String badge;
  final String description;
  final String playLabel;
  final VoidCallback onPlayAudio;

  const ArabicLetterCard({
    super.key,
    required this.arabic,
    required this.name,
    required this.transliteration,
    required this.badge,
    required this.description,
    required this.playLabel,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFF5EBDD), Color(0xFFE3F4ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: text.labelMedium?.copyWith(
                color: AppTheme.accentMintDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ArabicText.body(
            arabic,
            style: const TextStyle(
              fontSize: 92,
              height: 1,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            name,
            style: text.headlineMedium?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            transliteration,
            style: AppLatinTypography.body(
              context,
              color: AppTheme.textSecondary,
            ).copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: AppLatinTypography.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPlayAudio,
            icon: const Icon(Icons.volume_up_rounded),
            label: Text(playLabel),
          ),
        ],
      ),
    );
  }
}
