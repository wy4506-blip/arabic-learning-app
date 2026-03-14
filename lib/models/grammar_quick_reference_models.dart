import 'package:flutter/material.dart';

class GrammarQuickReferenceExample {
  final String arabic;
  final String transliteration;
  final String translationZh;
  final String translationEn;
  final String? noteZh;
  final String? noteEn;

  const GrammarQuickReferenceExample({
    required this.arabic,
    required this.transliteration,
    required this.translationZh,
    required this.translationEn,
    this.noteZh,
    this.noteEn,
  });
}

class GrammarQuickReferenceSection {
  final String id;
  final String titleZh;
  final String titleEn;
  final String arabicTerm;
  final String arabicPreview;
  final String summaryZh;
  final String summaryEn;
  final List<String> detailBulletsZh;
  final List<String> detailBulletsEn;
  final List<String> tagsZh;
  final List<String> tagsEn;
  final List<String> searchKeywords;
  final List<GrammarQuickReferenceExample> examples;
  final IconData icon;
  final Color accentColor;
  final Color accentSurfaceColor;

  const GrammarQuickReferenceSection({
    required this.id,
    required this.titleZh,
    required this.titleEn,
    required this.arabicTerm,
    required this.arabicPreview,
    required this.summaryZh,
    required this.summaryEn,
    required this.detailBulletsZh,
    required this.detailBulletsEn,
    required this.tagsZh,
    required this.tagsEn,
    required this.searchKeywords,
    required this.examples,
    required this.icon,
    required this.accentColor,
    required this.accentSurfaceColor,
  });

  bool matchesQuery(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return true;

    final buffer = StringBuffer()
      ..writeln(titleZh)
      ..writeln(titleEn)
      ..writeln(arabicTerm)
      ..writeln(arabicPreview)
      ..writeln(summaryZh)
      ..writeln(summaryEn);

    for (final keyword in searchKeywords) {
      buffer.writeln(keyword);
    }
    for (final tag in tagsZh) {
      buffer.writeln(tag);
    }
    for (final tag in tagsEn) {
      buffer.writeln(tag);
    }
    for (final bullet in detailBulletsZh) {
      buffer.writeln(bullet);
    }
    for (final bullet in detailBulletsEn) {
      buffer.writeln(bullet);
    }
    for (final example in examples) {
      buffer
        ..writeln(example.arabic)
        ..writeln(example.transliteration)
        ..writeln(example.translationZh)
        ..writeln(example.translationEn);
      if (example.noteZh != null) {
        buffer.writeln(example.noteZh);
      }
      if (example.noteEn != null) {
        buffer.writeln(example.noteEn);
      }
    }

    return _normalize(buffer.toString()).contains(normalizedQuery);
  }
}

String normalizeQuickReferenceQuery(String input) {
  return _normalize(input);
}

String _normalize(String value) {
  final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
  return value
      .replaceAll(diacritics, '')
      .toLowerCase()
      .replaceAll('，', ' ')
      .replaceAll('。', ' ')
      .replaceAll('/', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
