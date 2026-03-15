import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../services/audio_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';

enum ArabicAudioTextVariant {
  display,
  body,
  word,
  sentence,
  grammar,
  label,
}

class LearningAudioIconButton extends StatelessWidget {
  final LearningAudioRequest request;
  final String? tooltip;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const LearningAudioIconButton({
    super.key,
    required this.request,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.size = 40,
    this.iconSize = 20,
    this.padding = EdgeInsets.zero,
  });

  Future<void> _play(BuildContext context) async {
    try {
      await AudioService.playLearningText(request);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizedText(
              context,
              zh: '当前没有可用音频，已自动尝试到最后一层。',
              en: 'No playable audio is available for this item right now.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedForeground = foregroundColor ?? AppTheme.deepAccent;
    final resolvedBackground = backgroundColor ?? const Color(0xFFEAF8F3);

    return Padding(
      padding: padding,
      child: Tooltip(
        message:
            tooltip ?? localizedText(context, zh: '播放发音', en: 'Play audio'),
        child: Material(
          color: resolvedBackground,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _play(context),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                Icons.volume_up_rounded,
                size: iconSize,
                color: resolvedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArabicTextWithAudio extends StatelessWidget {
  final String textAr;
  final LearningAudioRequest request;
  final ArabicAudioTextVariant variant;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double spacing;
  final String? tooltip;

  const ArabicTextWithAudio({
    super.key,
    required this.textAr,
    required this.request,
    this.variant = ArabicAudioTextVariant.word,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.spacing = 10,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = textAr.trim();
    final shouldShowAudio = trimmed.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildText(trimmed),
        ),
        if (shouldShowAudio) ...[
          SizedBox(width: spacing),
          LearningAudioIconButton(
            request: request,
            tooltip: tooltip,
            size: 36,
            iconSize: 18,
          ),
        ],
      ],
    );
  }

  Widget _buildText(String value) {
    switch (variant) {
      case ArabicAudioTextVariant.display:
        return ArabicText.display(
          value,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      case ArabicAudioTextVariant.body:
        return ArabicText.body(
          value,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      case ArabicAudioTextVariant.word:
        return ArabicText.word(
          value,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      case ArabicAudioTextVariant.sentence:
        return ArabicText.sentence(
          value,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      case ArabicAudioTextVariant.grammar:
        return ArabicText.grammar(
          value,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      case ArabicAudioTextVariant.label:
        return ArabicText.label(
          value,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
    }
  }
}
