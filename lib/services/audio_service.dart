import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/app_settings.dart';
import 'audio_manifest_service.dart';

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

  static void setVoicePreference(AudioVoicePreference preference) {
    _voicePreference = preference;
  }

  static bool get _isWindowsTtsDisabled {
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

    if (!_playerAvailable) {
      throw StateError('Audio player unavailable');
    }

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
      await _player.play(AssetSource(fullPath));
      _isPlaying = true;
    } catch (error) {
      _resetPlaybackState();
      debugPrint('[Audio] Audio asset error: $error');
      rethrow;
    }
  }

  static Future<void> speakLetter(String text) async {
    final String normalized = text.trim();

    final assets = await AudioManifestService.findAlphabetAssets(
      type: 'letter',
      speed: 'normal',
      preference: _voicePreference,
      textAr: normalized,
      textPlain: normalized,
    );

    if (assets.isNotEmpty) {
      debugPrint('[Audio] manifest hit(letter): ${assets.first}');
    } else {
      debugPrint('[Audio] manifest miss(letter): $normalized');
    }

    await _playAssetsOrSpeak(
      assets: assets,
      fallbackText: normalized,
    );
  }

  static Future<void> speakPronunciation(String form) async {
    final String normalized = form.trim();

    final assets = await AudioManifestService.findAlphabetAssets(
      type: 'pronunciation',
      speed: 'normal',
      preference: _voicePreference,
      textAr: normalized,
      textPlain: normalized,
    );

    if (assets.isNotEmpty) {
      debugPrint('[Audio] manifest hit(pronunciation): ${assets.first}');
    } else {
      debugPrint('[Audio] manifest miss(pronunciation): $normalized');
    }

    await _playAssetsOrSpeak(
      assets: assets,
      fallbackText: normalized,
    );
  }

  static Future<void> speakExampleWord(String word) async {
    final String normalized = word.trim();

    final assets = await AudioManifestService.findAlphabetAssets(
      type: 'word',
      speed: 'normal',
      preference: _voicePreference,
      textAr: normalized,
      textPlain: normalized,
    );

    if (assets.isNotEmpty) {
      debugPrint('[Audio] manifest hit(word): ${assets.first}');
    } else {
      debugPrint('[Audio] manifest miss(word): $normalized');
    }

    await _playAssetsOrSpeak(
      assets: assets,
      fallbackText: normalized,
    );
  }

  static Future<void> speakText(String text) async {
    await _safeSpeakFallback(text);
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
    final normalizedAsset = asset?.trim();
    final normalizedText = fallbackText.trim();
    final normalizedTextAr = textAr?.trim();
    final normalizedTextPlain = textPlain?.trim();

    // If an explicit asset is provided, try it first.
    if (normalizedAsset != null && normalizedAsset.isNotEmpty) {
      debugPrint('[Audio] explicit asset(lesson): $normalizedAsset');
      try {
        await playAsset(normalizedAsset);
        return;
      } catch (error) {
        debugPrint('[Audio] explicit asset failed, fallback: $error');
      }
    }

    // Lookup all matching assets sorted by voice preference.
    final sequence = lessonSequence;
    if (sequence != null) {
      final assets = await AudioManifestService.findLessonAssets(
        lessonSequence: sequence,
        type: type,
        speed: speed,
        preference: _voicePreference,
        textAr: normalizedTextAr,
        textPlain: normalizedTextPlain ?? normalizedText,
      );

      for (final path in assets) {
        debugPrint('[Audio] manifest hit(lesson): $path');
        try {
          await playAsset(path);
          return;
        } catch (error) {
          debugPrint('[Audio] asset failed, try next: $error');
        }
      }

      if (assets.isEmpty) {
        debugPrint('[Audio] manifest miss(lesson): $normalizedText');
      }
    }

    await _safeSpeakFallback(normalizedText);
  }

  static Future<void> _playAssetsOrSpeak({
    required List<String> assets,
    required String fallbackText,
  }) async {
    for (final asset in assets) {
      try {
        await playAsset(asset);
        return;
      } catch (error) {
        debugPrint('[Audio] asset failed, try next: $error');
      }
    }

    if (assets.isEmpty) {
      debugPrint('[Audio] manifest miss, fallback text: $fallbackText');
    }

    await _safeSpeakFallback(fallbackText);
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
      await tts.speak(text);
    } catch (error) {
      debugPrint('[Audio] TTS failed: $error');
      _resetPlaybackState();
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
}
