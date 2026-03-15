import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/app_settings.dart';

class AudioAssetCandidate {
  final String origin;
  final String requestedRelativePath;
  final String? playableRelativePath;
  final String voiceType;
  final String speed;
  final String? manifestId;

  const AudioAssetCandidate({
    required this.origin,
    required this.requestedRelativePath,
    required this.playableRelativePath,
    required this.voiceType,
    required this.speed,
    this.manifestId,
  });

  bool get exists => playableRelativePath != null;
}

class AudioManifestService {
  AudioManifestService._();

  static List<_AudioManifestItem>? _items;
  static bool _loaded = false;
  static Set<String>? _bundledAssetPaths;
  static bool _bundledAssetsLoaded = false;
  static List<_AudioManifestItem>? _debugItems;
  static Set<String>? _debugBundledAssetPaths;

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
    final match = _findBestItem(
      scope: 'lesson',
      lessonId: lessonId,
      type: type,
      speed: speed,
      textAr: textAr,
      textPlain: textPlain,
    );

    if (match == null) return null;
    return await resolveBundledRelativeAssetPath(match.relativeAssetPath) ??
        match.relativeAssetPath;
  }

  static Future<String?> findAlphabetAsset({
    required String type,
    required String speed,
    String? textAr,
    String? textPlain,
  }) async {
    await _ensureLoaded();
    if (_items == null) return null;

    final match = _findBestItem(
      scope: 'alphabet',
      lessonId: 'alphabet',
      type: type,
      speed: speed,
      textAr: textAr,
      textPlain: textPlain,
    );

    if (match == null) return null;
    return await resolveBundledRelativeAssetPath(match.relativeAssetPath) ??
        match.relativeAssetPath;
  }

  static Future<List<String>> findAlphabetAssets({
    required String type,
    required String speed,
    required AudioVoicePreference preference,
    String? textAr,
    String? textPlain,
  }) async {
    final orderedItems = await _findOrderedItems(
      scope: 'alphabet',
      lessonId: 'alphabet',
      type: type,
      speedPriority: <String>[speed],
      voicePriority: _voicePriorityFromPreference(preference),
      textAr: textAr,
      textPlain: textPlain,
    );

    return orderedItems
        .where((item) => item.playableRelativePath != null)
        .map((item) => item.playableRelativePath!)
        .toList(growable: false);
  }

  static Future<List<String>> findLessonAssets({
    required int lessonSequence,
    required String type,
    required String speed,
    required AudioVoicePreference preference,
    String? textAr,
    String? textPlain,
  }) async {
    final orderedItems = await _findOrderedItems(
      scope: 'lesson',
      lessonId: 'lesson_${lessonSequence.toString().padLeft(2, '0')}',
      type: type,
      speedPriority: <String>[speed],
      voicePriority: _voicePriorityFromPreference(preference),
      textAr: textAr,
      textPlain: textPlain,
    );

    return orderedItems
        .where((item) => item.playableRelativePath != null)
        .map((item) => item.playableRelativePath!)
        .toList(growable: false);
  }

  static Future<List<AudioAssetCandidate>> findLearningCandidates({
    required String scope,
    required String type,
    required List<String> speedPriority,
    required List<String> voicePriority,
    String? explicitAsset,
    int? lessonSequence,
    String? textAr,
    String? textPlain,
  }) async {
    await _ensureLoaded();
    await _ensureBundledAssetsLoaded();

    final candidates = <AudioAssetCandidate>[];
    final seenRequestedPaths = <String>{};

    Future<void> addExplicitCandidate(String value) async {
      final normalized = _normalizeRelativeAssetPath(value);
      if (normalized.isEmpty) {
        return;
      }

      if (!seenRequestedPaths.add(normalized)) {
        return;
      }

      final playable = await resolveBundledRelativeAssetPath(normalized);
      candidates.add(
        AudioAssetCandidate(
          origin: 'explicit',
          requestedRelativePath: normalized,
          playableRelativePath: playable,
          voiceType: 'explicit',
          speed: 'explicit',
        ),
      );
    }

    final normalizedExplicit = explicitAsset?.trim() ?? '';
    if (_items == null) {
      if (normalizedExplicit.isNotEmpty) {
        await addExplicitCandidate(normalizedExplicit);
      }
      return candidates;
    }

    final lessonId = scope == 'lesson'
        ? 'lesson_${(lessonSequence ?? 0).toString().padLeft(2, '0')}'
        : scope;

    final manifestCandidates = await _findOrderedItems(
      scope: scope,
      lessonId: lessonId,
      type: type,
      speedPriority: speedPriority,
      voicePriority: voicePriority,
      textAr: textAr,
      textPlain: textPlain,
    );

    for (final candidate in manifestCandidates) {
      if (seenRequestedPaths.add(candidate.requestedRelativePath)) {
        candidates.add(candidate);
      }
    }

    if (normalizedExplicit.isNotEmpty) {
      await addExplicitCandidate(normalizedExplicit);
    }

    return candidates;
  }

  static Future<String?> resolveBundledRelativeAssetPath(
    String relativePath,
  ) async {
    await _ensureBundledAssetsLoaded();

    final normalized = _normalizeRelativeAssetPath(relativePath);
    if (normalized.isEmpty) return null;

    final bundled = _bundledAssetPaths ?? const <String>{};
    final exactAssetPath = _toAssetPath(normalized);
    if (bundled.contains(exactAssetPath)) {
      return normalized;
    }

    final stem = normalized.replaceFirst(RegExp(r'\.[^.]+$'), '');
    for (final extension in _supportedExtensions) {
      final alternative = '$stem$extension';
      if (bundled.contains(_toAssetPath(alternative))) {
        return alternative;
      }
    }

    return null;
  }

  static void debugLoadTestData({
    required List<Map<String, dynamic>> manifestItems,
    required Set<String> bundledAssetPaths,
  }) {
    _debugItems = manifestItems
        .map((item) => _AudioManifestItem.fromJson(item))
        .toList(growable: false);
    _debugBundledAssetPaths = bundledAssetPaths
        .map(_normalizeDebugAssetPath)
        .where((item) => item.isNotEmpty)
        .toSet();
    _loaded = false;
    _bundledAssetsLoaded = false;
    _items = null;
    _bundledAssetPaths = null;
  }

  static void debugResetTestData() {
    _debugItems = null;
    _debugBundledAssetPaths = null;
    _loaded = false;
    _bundledAssetsLoaded = false;
    _items = null;
    _bundledAssetPaths = null;
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;

    if (_debugItems != null) {
      _items = _debugItems;
      return;
    }

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

  static Future<void> _ensureBundledAssetsLoaded() async {
    if (_bundledAssetsLoaded) return;
    _bundledAssetsLoaded = true;

    if (_debugBundledAssetPaths != null) {
      _bundledAssetPaths = _debugBundledAssetPaths;
      return;
    }

    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final decoded = jsonDecode(manifestJson) as Map<String, dynamic>;
      _bundledAssetPaths =
          decoded.keys.map((item) => item.replaceAll('\\', '/')).toSet();
    } catch (_) {
      _bundledAssetPaths = const <String>{};
    }
  }

  static Future<List<AudioAssetCandidate>> _findOrderedItems({
    required String scope,
    required String lessonId,
    required String type,
    required List<String> speedPriority,
    required List<String> voicePriority,
    String? textAr,
    String? textPlain,
  }) async {
    if (_items == null) {
      return const <AudioAssetCandidate>[];
    }

    final targetArabic = _normalizeText(textAr);
    final targetPlain = _normalizeText(textPlain);

    final matchingItems = _items!
        .where(
          (item) =>
              item.scope == scope &&
              item.lessonId == lessonId &&
              item.type == type &&
              _matchesText(
                item: item,
                targetArabic: targetArabic,
                targetPlain: targetPlain,
              ),
        )
        .toList(growable: false)
      ..sort(
        (left, right) => _comparePriority(
          left: left,
          right: right,
          speedPriority: speedPriority,
          voicePriority: voicePriority,
        ),
      );

    final candidates = <AudioAssetCandidate>[];
    final seenPaths = <String>{};
    for (final item in matchingItems) {
      final playable =
          await resolveBundledRelativeAssetPath(item.relativeAssetPath);
      final dedupeKey = playable ?? item.relativeAssetPath;
      if (!seenPaths.add(dedupeKey)) {
        continue;
      }

      candidates.add(
        AudioAssetCandidate(
          origin: 'manifest',
          requestedRelativePath: item.relativeAssetPath,
          playableRelativePath: playable,
          voiceType: item.voiceType,
          speed: item.speed,
          manifestId: item.id,
        ),
      );
    }

    return candidates;
  }

  static _AudioManifestItem? _findBestItem({
    required String scope,
    required String lessonId,
    required String type,
    required String speed,
    String? textAr,
    String? textPlain,
  }) {
    if (_items == null) return null;

    final targetArabic = _normalizeText(textAr);
    final targetPlain = _normalizeText(textPlain);

    for (final item in _items!) {
      if (item.scope != scope ||
          item.lessonId != lessonId ||
          item.type != type ||
          item.speed != speed) {
        continue;
      }

      if (_matchesText(
        item: item,
        targetArabic: targetArabic,
        targetPlain: targetPlain,
      )) {
        return item;
      }
    }

    return null;
  }

  static bool _matchesText({
    required _AudioManifestItem item,
    required String targetArabic,
    required String targetPlain,
  }) {
    final itemArabic = _normalizeText(item.textAr);
    final itemPlain = _normalizeText(item.textPlain);

    final matchesArabic = targetArabic.isNotEmpty &&
        (itemArabic == targetArabic || itemPlain == targetArabic);
    final matchesPlain = targetPlain.isNotEmpty &&
        (itemPlain == targetPlain || itemArabic == targetPlain);

    return matchesArabic || matchesPlain;
  }

  static int _comparePriority({
    required _AudioManifestItem left,
    required _AudioManifestItem right,
    required List<String> speedPriority,
    required List<String> voicePriority,
  }) {
    final leftVoice = _priorityIndex(voicePriority, left.voiceType);
    final rightVoice = _priorityIndex(voicePriority, right.voiceType);
    if (leftVoice != rightVoice) {
      return leftVoice.compareTo(rightVoice);
    }

    final leftSpeed = _priorityIndex(speedPriority, left.speed);
    final rightSpeed = _priorityIndex(speedPriority, right.speed);
    if (leftSpeed != rightSpeed) {
      return leftSpeed.compareTo(rightSpeed);
    }

    return left.relativeAssetPath.compareTo(right.relativeAssetPath);
  }

  static int _priorityIndex(List<String> values, String candidate) {
    final index = values.indexOf(candidate);
    return index == -1 ? values.length + 1 : index;
  }

  static List<String> _voicePriorityFromPreference(
    AudioVoicePreference preference,
  ) {
    if (preference == AudioVoicePreference.human) {
      return const <String>['human', 'ai'];
    }
    return const <String>['ai', 'human'];
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

  static String _normalizeRelativeAssetPath(String value) {
    var normalized = value.trim().replaceAll('\\', '/');
    if (normalized.startsWith('assets/')) {
      normalized = normalized.substring('assets/'.length);
    }
    if (normalized.startsWith('audio/')) {
      normalized = normalized.substring('audio/'.length);
    }
    return normalized;
  }

  static String _toAssetPath(String relativePath) {
    return 'assets/audio/${_normalizeRelativeAssetPath(relativePath)}';
  }

  static String _normalizeDebugAssetPath(String value) {
    var normalized = value.trim().replaceAll('\\', '/');
    if (!normalized.startsWith('assets/')) {
      if (normalized.startsWith('audio/')) {
        normalized = 'assets/$normalized';
      } else {
        normalized = 'assets/audio/$normalized';
      }
    }
    return normalized;
  }

  static const List<String> _supportedExtensions = <String>[
    '.mp3',
    '.m4a',
    '.wav',
    '.ogg',
  ];
}

class _AudioManifestItem {
  final String id;
  final String scope;
  final String lessonId;
  final String type;
  final String speed;
  final String textAr;
  final String textPlain;
  final String relativeAssetPath;
  final String voiceType;

  const _AudioManifestItem({
    required this.id,
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
      id: json['id'] as String? ?? '',
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
