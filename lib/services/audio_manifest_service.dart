import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/app_settings.dart';

class AudioManifestService {
  AudioManifestService._();

  static List<_AudioManifestItem>? _items;
  static bool _loaded = false;

  static Future<String?> findLessonAsset({
    required int lessonSequence,
    required String type,
    required String speed,
    String? textAr,
    String? textPlain,
  }) async {
    await _ensureLoaded();
    if (_items == null) return null;

    final lessonId = 'lesson_${lessonSequence.toString().padLeft(2, '0')}';
    return _findRelativeAssetPath(
      scope: 'lesson',
      lessonId: lessonId,
      type: type,
      speed: speed,
      textAr: textAr,
      textPlain: textPlain,
    );
  }

  static Future<String?> findAlphabetAsset({
    required String type,
    required String speed,
    String? textAr,
    String? textPlain,
  }) async {
    await _ensureLoaded();
    if (_items == null) return null;

    return _findRelativeAssetPath(
      scope: 'alphabet',
      lessonId: 'alphabet',
      type: type,
      speed: speed,
      textAr: textAr,
      textPlain: textPlain,
    );
  }

  /// Returns all matching alphabet assets sorted by [preference].
  /// The preferred voice type comes first.
  static Future<List<String>> findAlphabetAssets({
    required String type,
    required String speed,
    required AudioVoicePreference preference,
    String? textAr,
    String? textPlain,
  }) async {
    await _ensureLoaded();
    if (_items == null) return const <String>[];

    return _findAllRelativeAssetPaths(
      scope: 'alphabet',
      lessonId: 'alphabet',
      type: type,
      speed: speed,
      textAr: textAr,
      textPlain: textPlain,
      preference: preference,
    );
  }

  /// Returns all matching lesson assets sorted by [preference].
  static Future<List<String>> findLessonAssets({
    required int lessonSequence,
    required String type,
    required String speed,
    required AudioVoicePreference preference,
    String? textAr,
    String? textPlain,
  }) async {
    await _ensureLoaded();
    if (_items == null) return const <String>[];

    final lessonId = 'lesson_${lessonSequence.toString().padLeft(2, '0')}';
    return _findAllRelativeAssetPaths(
      scope: 'lesson',
      lessonId: lessonId,
      type: type,
      speed: speed,
      textAr: textAr,
      textPlain: textPlain,
      preference: preference,
    );
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/audio_manifest.json',
      );
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final rawItems = jsonData['items'] as List<dynamic>? ?? const <dynamic>[];
      _items = rawItems
          .map(
            (item) => _AudioManifestItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    } catch (_) {
      _items = null;
    }
  }

  static String? _findRelativeAssetPath({
    required String scope,
    required String lessonId,
    required String type,
    required String speed,
    String? textAr,
    String? textPlain,
  }) {
    final targetArabic = _normalizeText(textAr);
    final targetPlain = _normalizeText(textPlain);

    for (final item in _items!) {
      if (item.scope != scope ||
          item.lessonId != lessonId ||
          item.type != type ||
          item.speed != speed) {
        continue;
      }

      final itemArabic = _normalizeText(item.textAr);
      final itemPlain = _normalizeText(item.textPlain);

      final matchesArabic = targetArabic.isNotEmpty &&
          (itemArabic == targetArabic || itemPlain == targetArabic);
      final matchesPlain = targetPlain.isNotEmpty &&
          (itemPlain == targetPlain || itemArabic == targetPlain);

      if (matchesArabic || matchesPlain) {
        return item.relativeAssetPath;
      }
    }

    return null;
  }

  static List<String> _findAllRelativeAssetPaths({
    required String scope,
    required String lessonId,
    required String type,
    required String speed,
    required AudioVoicePreference preference,
    String? textAr,
    String? textPlain,
  }) {
    final targetArabic = _normalizeText(textAr);
    final targetPlain = _normalizeText(textPlain);
    final preferred = <String>[];
    final fallback = <String>[];
    final preferredType =
        preference == AudioVoicePreference.human ? 'human' : 'ai';

    for (final item in _items!) {
      if (item.scope != scope ||
          item.lessonId != lessonId ||
          item.type != type ||
          item.speed != speed) {
        continue;
      }

      final itemArabic = _normalizeText(item.textAr);
      final itemPlain = _normalizeText(item.textPlain);

      final matchesArabic = targetArabic.isNotEmpty &&
          (itemArabic == targetArabic || itemPlain == targetArabic);
      final matchesPlain = targetPlain.isNotEmpty &&
          (itemPlain == targetPlain || itemArabic == targetPlain);

      if (matchesArabic || matchesPlain) {
        if (item.voiceType == preferredType) {
          preferred.add(item.relativeAssetPath);
        } else {
          fallback.add(item.relativeAssetPath);
        }
      }
    }

    return <String>[...preferred, ...fallback];
  }

  static String _normalizeText(String? value) {
    if (value == null) return '';

    return value
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ٰ', '')
        .replaceAll(
          RegExp(r'[\s\.\,\!\?\u061F\u060C\u061B\u06D4]+'),
          '',
        )
        .trim();
  }
}

class _AudioManifestItem {
  final String scope;
  final String lessonId;
  final String type;
  final String speed;
  final String textAr;
  final String textPlain;
  final String relativeAssetPath;
  final String voiceType;

  const _AudioManifestItem({
    required this.scope,
    required this.lessonId,
    required this.type,
    required this.speed,
    required this.textAr,
    required this.textPlain,
    required this.relativeAssetPath,
    required this.voiceType,
  });

  factory _AudioManifestItem.fromJson(Map<String, dynamic> json) {
    return _AudioManifestItem(
      scope: json['scope'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      speed: json['speed'] as String? ?? '',
      textAr: json['textAr'] as String? ?? '',
      textPlain: json['textPlain'] as String? ?? '',
      relativeAssetPath: json['relativeAssetPath'] as String? ?? '',
      voiceType: json['voiceType'] as String? ?? 'ai',
    );
  }
}
