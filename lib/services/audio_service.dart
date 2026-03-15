import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/alphabet_group.dart';
import '../models/app_settings.dart';
import 'audio_manifest_service.dart';

enum LearningAudioTrack { human, ai }

class LearningAudioRequest {
  final String scope;
  final String type;
  final String? asset;
  final String? textAr;
  final String? textPlain;
  final int? lessonSequence;
  final bool allowTts;
  final List<LearningAudioTrack> voicePriority;
  final List<String> speedPriority;
  final String? debugLabel;

  const LearningAudioRequest({
    required this.scope,
    required this.type,
    this.asset,
    this.textAr,
    this.textPlain,
    this.lessonSequence,
    this.allowTts = true,
    this.voicePriority = const <LearningAudioTrack>[
      LearningAudioTrack.human,
      LearningAudioTrack.ai,
    ],
    this.speedPriority = const <String>['slow', 'normal'],
    this.debugLabel,
  });

  const LearningAudioRequest.alphabet({
    required String type,
    required String textAr,
    String? textPlain,
    String? asset,
    String? debugLabel,
    bool allowTts = true,
  }) : this(
          scope: 'alphabet',
          type: type,
          asset: asset,
          textAr: textAr,
          textPlain: textPlain,
          debugLabel: debugLabel,
          allowTts: allowTts,
        );

  const LearningAudioRequest.lesson({
    required int lessonSequence,
    required String type,
    String? textAr,
    String? textPlain,
    String? asset,
    String? debugLabel,
    bool allowTts = true,
  }) : this(
          scope: 'lesson',
          type: type,
          lessonSequence: lessonSequence,
          asset: asset,
          textAr: textAr,
          textPlain: textPlain,
          debugLabel: debugLabel,
          allowTts: allowTts,
        );

  const LearningAudioRequest.general({
    required String textAr,
    String? textPlain,
    String type = 'sentence',
    String scope = 'general',
    String? asset,
    String? debugLabel,
    bool allowTts = true,
  }) : this(
          scope: scope,
          type: type,
          asset: asset,
          textAr: textAr,
          textPlain: textPlain,
          debugLabel: debugLabel,
          allowTts: allowTts,
        );

  String get fallbackText {
    final ar = textAr?.trim() ?? '';
    if (ar.isNotEmpty) {
      return ar;
    }
    return textPlain?.trim() ?? '';
  }
}

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static FlutterTts? _tts;

  static bool _initialized = false;
  static bool _initializing = false;
  static bool _playerAvailable = true;
  static bool _isPlaying = false;
  static bool _usingTts = false;
  static String? _currentAsset;
  static AudioVoicePreference _voicePreference = AudioVoicePreference.ai;
  static Future<void> Function(String relativePath)? _debugAssetPlaybackHandler;
  static Future<void> Function(String text)? _debugTtsPlaybackHandler;
  static bool? _debugWindowsTtsDisabled;

  static void setVoicePreference(AudioVoicePreference preference) {
    _voicePreference = preference;
  }

  static void debugSetPlaybackOverrides({
    Future<void> Function(String relativePath)? assetPlaybackHandler,
    Future<void> Function(String text)? ttsPlaybackHandler,
    bool? windowsTtsDisabled,
  }) {
    _debugAssetPlaybackHandler = assetPlaybackHandler;
    _debugTtsPlaybackHandler = ttsPlaybackHandler;
    _debugWindowsTtsDisabled = windowsTtsDisabled;
  }

  static void debugClearPlaybackOverrides() {
    _debugAssetPlaybackHandler = null;
    _debugTtsPlaybackHandler = null;
    _debugWindowsTtsDisabled = null;
  }

  static bool get _isWindowsTtsDisabled {
    if (_debugWindowsTtsDisabled != null) {
      return _debugWindowsTtsDisabled!;
    }
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  static Future<FlutterTts?> _getTts() async {
    if (_isWindowsTtsDisabled) {
      debugPrint(
        '[Audio] Windows platform, skip flutter_tts instance creation',
      );
      return null;
    }

    if (_tts != null) return _tts;

    try {
      final tts = FlutterTts();
      await tts.awaitSpeakCompletion(true);
      await tts.setLanguage('ar');
      await tts.setSpeechRate(0.42);
      await tts.setPitch(1.0);

      tts.setCompletionHandler(_resetPlaybackState);
      tts.setCancelHandler(_resetPlaybackState);
      tts.setErrorHandler((message) {
        debugPrint('[Audio] TTS error: $message');
        _resetPlaybackState();
      });

      _tts = tts;
      return _tts;
    } catch (error) {
      debugPrint('[Audio] FlutterTts init error: $error');
      return null;
    }
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    if (_initializing) return;
    _initializing = true;

    try {
      await _player.setReleaseMode(ReleaseMode.stop);

      _player.onPlayerComplete.listen((_) {
        _resetPlaybackState();
      });

      _player.onPlayerStateChanged.listen((state) {
        if (_usingTts) return;

        _isPlaying = state == PlayerState.playing;
        if (state != PlayerState.playing) {
          _currentAsset = null;
        }
      });
    } catch (error) {
      _playerAvailable = false;
      debugPrint('[Audio] Audio player init error: $error');
    }

    _initialized = true;
    _initializing = false;
  }

  static Future<void> stop() async {
    await initialize();

    try {
      if (_playerAvailable) {
        await _player.stop();
      }
    } catch (error) {
      debugPrint('[Audio] Player stop error: $error');
    }

    if (!_isWindowsTtsDisabled) {
      try {
        final tts = await _getTts();
        if (tts != null) {
          await tts.stop();
        }
      } catch (error) {
        debugPrint('[Audio] TTS stop error: $error');
      }
    }

    _resetPlaybackState();
  }

  static Future<bool> isPlaying() async {
    return _isPlaying;
  }

  static Future<void> playAsset(String relativePath) async {
    await initialize();

    final String fullPath = _normalizeAssetPath(relativePath);

    if (_currentAsset == fullPath && _isPlaying) {
      await stop();
      return;
    }

    await stop();
    _currentAsset = fullPath;
    _usingTts = false;

    debugPrint('[Audio] play asset: $fullPath');

    try {
      if (_debugAssetPlaybackHandler != null) {
        await _debugAssetPlaybackHandler!(fullPath);
      } else {
        if (!_playerAvailable) {
          throw StateError('Audio player unavailable');
        }
        await _player.play(AssetSource(fullPath));
      }
      _isPlaying = true;
    } catch (error) {
      _resetPlaybackState();
      debugPrint('[Audio] Audio asset error: $error');
      rethrow;
    }
  }

  static Future<void> playLearningText(LearningAudioRequest request) async {
    final trail = <String>[];
    final normalizedTextAr = request.textAr?.trim() ?? '';
    final normalizedTextPlain = request.textPlain?.trim() ?? '';
    final normalizedAsset = request.asset?.trim() ?? '';

    trail.add(
      'request label=${request.debugLabel ?? '-'} scope=${request.scope} type=${request.type} '
      'textAr="$normalizedTextAr" textPlain="$normalizedTextPlain" asset="$normalizedAsset"',
    );

    final candidates = await AudioManifestService.findLearningCandidates(
      scope: request.scope,
      type: request.type,
      explicitAsset: normalizedAsset,
      lessonSequence: request.lessonSequence,
      textAr: normalizedTextAr,
      textPlain: normalizedTextPlain,
      speedPriority: request.speedPriority,
      voicePriority: _buildVoicePriority(request.voicePriority),
    );

    if (candidates.isEmpty) {
      trail.add('manifest hit resource=none');
    }

    for (final candidate in candidates) {
      final resourceType = '${candidate.voiceType}_${candidate.speed}';
      final resolvedPath = candidate.playableRelativePath;
      if (resolvedPath == null || resolvedPath.isEmpty) {
        trail.add(
          'fallback skip resource=$resourceType requested=${candidate.requestedRelativePath} reason=asset_missing',
        );
        continue;
      }

      trail.add(
        'manifest hit resource=$resourceType finalPath=$resolvedPath origin=${candidate.origin}',
      );

      try {
        await playAsset(resolvedPath);
        trail
            .add('play success resource=$resourceType finalPath=$resolvedPath');
        _printTrail(trail);
        return;
      } catch (error) {
        trail.add(
          'fallback resource=$resourceType finalPath=$resolvedPath reason=$error',
        );
      }
    }

    if (!request.allowTts) {
      trail.add(
          'final failure reason=no_playable_asset_and_tts_disabled_for_request');
      _printTrail(trail);
      throw StateError('No playable learning audio asset found.');
    }

    try {
      trail.add('fallback to tts text="${request.fallbackText}"');
      await _safeSpeakFallback(request.fallbackText);
      trail.add('tts success text="${request.fallbackText}"');
      _printTrail(trail);
    } catch (error) {
      trail.add('final failure reason=$error');
      _printTrail(trail);
      rethrow;
    }
  }

  static Future<void> speakLetter(String text) async {
    final normalized = text.trim();
    await playLearningText(
      LearningAudioRequest.alphabet(
        type: 'letter',
        textAr: normalized,
        textPlain: normalized,
        debugLabel: 'alphabet_letter',
      ),
    );
  }

  static Future<void> speakPronunciation(String form) async {
    final normalized = form.trim();
    await playLearningText(
      LearningAudioRequest.alphabet(
        type: 'pronunciation',
        textAr: normalized,
        textPlain: normalized,
        debugLabel: 'alphabet_pronunciation',
      ),
    );
  }

  static Future<void> speakPronunciationItem(
    AlphabetPronunciationItem item,
  ) async {
    await speakPronunciation(item.audioQueryText);
  }

  static Future<void> speakExampleWord(String word) async {
    final normalized = word.trim();
    await playLearningText(
      LearningAudioRequest.alphabet(
        type: 'word',
        textAr: normalized,
        textPlain: normalized,
        debugLabel: 'alphabet_word',
      ),
    );
  }

  static Future<void> speakText(String text) async {
    final normalized = text.trim();
    await playLearningText(
      LearningAudioRequest.general(
        textAr: normalized,
        textPlain: normalized,
        debugLabel: 'general_text',
      ),
    );
  }

  static Future<void> playLessonAudio({
    String? asset,
    required String fallbackText,
    int? lessonSequence,
    String type = 'sentence',
    String speed = 'normal',
    String? textAr,
    String? textPlain,
  }) async {
    final normalizedText = fallbackText.trim();
    final normalizedTextAr = textAr?.trim();
    final normalizedTextPlain = textPlain?.trim();
    await playLearningText(
      LearningAudioRequest.lesson(
        lessonSequence: lessonSequence ?? 0,
        type: type,
        asset: asset,
        textAr: normalizedTextAr ?? normalizedText,
        textPlain: normalizedTextPlain ?? normalizedText,
        debugLabel: 'lesson_$type',
      ),
    );
  }

  static Future<void> _safeSpeakFallback(String? text) async {
    final fallbackText = text?.trim() ?? '';

    if (fallbackText.isEmpty) {
      debugPrint('[Audio] fallback text empty, skip TTS');
      return;
    }

    if (_isWindowsTtsDisabled) {
      debugPrint(
        '[Audio] Windows platform: TTS unavailable for "$fallbackText"',
      );
      throw StateError(
        'No audio available: asset missing and TTS disabled on Windows',
      );
    }

    await _speakWithTts(fallbackText);
  }

  static Future<void> _speakWithTts(String text) async {
    if (text.isEmpty) return;

    if (_isWindowsTtsDisabled) {
      debugPrint('[Audio] Windows platform, skip _speakWithTts');
      return;
    }

    await initialize();

    await stop();

    if (_debugTtsPlaybackHandler != null) {
      _usingTts = true;
      _currentAsset = 'tts:$text';
      _isPlaying = true;
      try {
        await _debugTtsPlaybackHandler!(text);
      } catch (error) {
        debugPrint('[Audio] TTS failed: $error');
        _resetPlaybackState();
        rethrow;
      }
      return;
    }

    final tts = await _getTts();
    if (tts == null) {
      debugPrint('[Audio] TTS unavailable, skip speaking');
      _resetPlaybackState();
      return;
    }

    _usingTts = true;
    _currentAsset = 'tts:$text';
    _isPlaying = true;

    try {
      if (_debugTtsPlaybackHandler != null) {
        await _debugTtsPlaybackHandler!(text);
      } else {
        await tts.speak(text);
      }
    } catch (error) {
      debugPrint('[Audio] TTS failed: $error');
      _resetPlaybackState();
      rethrow;
    }
  }

  static void _resetPlaybackState() {
    _isPlaying = false;
    _usingTts = false;
    _currentAsset = null;
  }

  static String _normalizeAssetPath(String relativePath) {
    var normalized = relativePath.trim().replaceAll('\\', '/');

    if (normalized.startsWith('assets/')) {
      normalized = normalized.substring('assets/'.length);
    }

    if (!normalized.startsWith('audio/')) {
      normalized = 'audio/$normalized';
    }

    return normalized;
  }

  static List<String> _buildVoicePriority(
    List<LearningAudioTrack> overridePriority,
  ) {
    if (overridePriority.isNotEmpty) {
      return overridePriority.map((item) => item.name).toList(growable: false);
    }

    switch (_voicePreference) {
      case AudioVoicePreference.human:
      case AudioVoicePreference.ai:
        return const <String>['human', 'ai'];
    }
  }

  static void _printTrail(List<String> trail) {
    for (final line in trail) {
      debugPrint('[Audio] $line');
    }
  }
}
