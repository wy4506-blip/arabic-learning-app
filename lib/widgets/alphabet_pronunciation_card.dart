import 'package:flutter/material.dart';

import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';

class AlphabetPronunciationCard extends StatelessWidget {
  final String arabic;
  final String title;
  final String value;
  final String subtitle;
  final bool isPlaying;
  final VoidCallback onTap;

  const AlphabetPronunciationCard({
    super.key,
    required this.arabic,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isPlaying ? AppTheme.deepAccent : const Color(0xFFE7EAEE),
              width: isPlaying ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isPlaying
                    ? const Color(0x182F7D6A)
                    : const Color(0x10000000),
                blurRadius: isPlaying ? 18 : 12,
                offset: Offset(0, isPlaying ? 8 : 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ArabicText.word(
                arabic,
                style: text.headlineSmall?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: isPlaying ? AppTheme.deepAccent : AppTheme.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: text.bodyLarge?.copyWith(
                  color: AppTheme.deepAccent,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: text.bodySmall?.copyWith(color: const Color(0xFF667085)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
