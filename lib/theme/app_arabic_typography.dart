import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/app_settings.dart';

enum ArabicTextRole {
  display,
  body,
  word,
  sentence,
  grammar,
  label,
}

class AppArabicTypography {
  AppArabicTypography._();

  // Katibeh is used for decorative Arabic display content, while Noto Naskh
  // Arabic stays on learning-heavy screens for clarity and stability.
  static const String displayFontFamily = 'ArabicDisplay';
  static const String bodyFontFamily = 'ArabicBody';

  static bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(text);
  }

  static TextDirection textDirectionOf(String text) {
    return isArabic(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  static TextStyle styleFor(
    ArabicTextRole role, {
    Color? color,
  }) {
    switch (role) {
      case ArabicTextRole.display:
        return displayStyle(color: color ?? const Color(0xFF24332B));
      case ArabicTextRole.body:
        return bodyStyle(color: color ?? const Color(0xFF1F2937));
      case ArabicTextRole.word:
        return wordStyle(color: color ?? const Color(0xFF111827));
      case ArabicTextRole.sentence:
        return sentenceStyle(color: color ?? const Color(0xFF111827));
      case ArabicTextRole.grammar:
        return grammarStyle(color: color ?? const Color(0xFF1F2937));
      case ArabicTextRole.label:
        return labelStyle(color: color ?? const Color(0xFF6B7280));
    }
  }

  static TextStyle displayStyle({
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w400,
    Color color = const Color(0xFF24332B),
    double height = 1.08,
  }) {
    return TextStyle(
      fontFamily: displayFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle bodyStyle({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w400,
    Color color = const Color(0xFF1F2937),
    double height = 1.7,
  }) {
    return TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle wordStyle({
    Color color = const Color(0xFF111827),
  }) {
    return bodyStyle(
      fontSize: 30,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.75,
    );
  }

  static TextStyle sentenceStyle({
    Color color = const Color(0xFF111827),
  }) {
    return bodyStyle(
      fontSize: 26,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.85,
    );
  }

  static TextStyle grammarStyle({
    Color color = const Color(0xFF1F2937),
  }) {
    return bodyStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.8,
    );
  }

  static TextStyle labelStyle({
    Color color = const Color(0xFF6B7280),
  }) {
    return bodyStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.45,
    );
  }
}

class ArabicText extends StatelessWidget {
  final String data;
  final ArabicTextRole role;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ArabicText.display(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = ArabicTextRole.display;

  const ArabicText.body(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = ArabicTextRole.body;

  const ArabicText.word(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = ArabicTextRole.word;

  const ArabicText.sentence(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = ArabicTextRole.sentence;

  const ArabicText.grammar(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = ArabicTextRole.grammar;

  const ArabicText.label(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : role = ArabicTextRole.label;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.maybeOf(context)?.settings;
    final scale = settings?.arabicFontScale == ArabicFontScale.large ? 1.12 : 1.0;
    final TextStyle baseStyle = AppArabicTypography.styleFor(role).copyWith(
      fontSize: AppArabicTypography.styleFor(role).fontSize == null
          ? null
          : AppArabicTypography.styleFor(role).fontSize! * scale,
    );

    return Text(
      data,
      style: style == null ? baseStyle : baseStyle.merge(style),
      textDirection: AppArabicTypography.textDirectionOf(data),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
