import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'audio_manifest_service.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final FlutterTts _tts = FlutterTts();

  static bool _initialized = false;
  static bool _backendAvailable = true;
  static bool _isPlaying = false;
  static bool _usingTts = false;
  static String? _currentAsset;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage('ar');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
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

      _tts.setCompletionHandler(_resetPlaybackState);
      _tts.setCancelHandler(_resetPlaybackState);
      _tts.setErrorHandler((message) {
        debugPrint('TTS error: $message');
        _resetPlaybackState();
      });
    } catch (error) {
      _backendAvailable = false;
      debugPrint('Audio backend init error: $error');
    }

    _initialized = true;
  }

  static Future<void> stop() async {
    await initialize();
    if (!_backendAvailable) {
      _resetPlaybackState();
      return;
    }
    await _player.stop();
    await _tts.stop();
    _resetPlaybackState();
  }

  static Future<bool> isPlaying() async {
    return _isPlaying;
  }

  static Future<void> playAsset(String relativePath) async {
    await initialize();
    if (!_backendAvailable) {
      throw StateError('Audio backend unavailable');
    }

    final String fullPath = _normalizeAssetPath(relativePath);
    if (_currentAsset == fullPath && _isPlaying) {
      await stop();
      return;
    }

    await stop();
    _currentAsset = fullPath;
    _usingTts = false;

    try {
      await _player.play(AssetSource(fullPath));
      _isPlaying = true;
    } catch (error) {
      _resetPlaybackState();
      debugPrint('Audio asset error: $error');
      rethrow;
    }
  }

  static Future<void> speakLetter(String text) async {
    final String normalized = text.trim();

    const Map<String, String> letterMap = <String, String>{};
    final manifestAsset = await AudioManifestService.findAlphabetAsset(
      type: 'letter',
      speed: 'normal',
      textAr: normalized,
      textPlain: normalized,
    );
    await _playAssetOrSpeak(
      asset: manifestAsset ?? letterMap[normalized],
      fallbackText: normalized,
    );
  }

  static Future<void> speakPronunciation(String form) async {
    final normalized = form.trim();
    final manifestAsset = await AudioManifestService.findAlphabetAsset(
      type: 'pronunciation',
      speed: 'normal',
      textAr: normalized,
      textPlain: normalized,
    );
    await _playAssetOrSpeak(
      asset: manifestAsset,
      fallbackText: normalized,
    );
  }

  static Future<void> speakExampleWord(String word) async {
    final String normalized = word.trim();

    const Map<String, String> wordMap = <String, String>{
      'أنا': 'words/ana.ogg.ogg',
      'نعم': 'words/naam.ogg.ogg',
      'لا': 'words/la.ogg.ogg',
      'كتاب': 'words/kitab.oga.oga',
    };
    final manifestAsset = await AudioManifestService.findAlphabetAsset(
      type: 'word',
      speed: 'normal',
      textAr: normalized,
      textPlain: normalized,
    );

    await _playAssetOrSpeak(
      asset: manifestAsset ?? wordMap[normalized],
      fallbackText: normalized,
    );
  }

  static Future<void> speakText(String text) async {
    await _speakWithTts(text.trim());
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
    String? resolvedAsset = normalizedAsset;

    if (resolvedAsset == null || resolvedAsset.isEmpty) {
      final sequence = lessonSequence;
      if (sequence != null) {
        resolvedAsset = await AudioManifestService.findLessonAsset(
          lessonSequence: sequence,
          type: type,
          speed: speed,
          textAr: normalizedTextAr,
          textPlain: normalizedTextPlain ?? normalizedText,
        );
      }
    }

    if (resolvedAsset != null && resolvedAsset.isNotEmpty) {
      try {
        await playAsset(resolvedAsset);
        return;
      } catch (_) {
        // Fall back to TTS when lesson assets are absent.
      }
    }

    await _speakWithTts(normalizedText);
  }

  static Future<void> _playAssetOrSpeak({
    required String? asset,
    required String fallbackText,
  }) async {
    if (asset == null) {
      await _speakWithTts(fallbackText);
      return;
    }

    try {
      await playAsset(asset);
    } catch (_) {
      await _speakWithTts(fallbackText);
    }
  }

  static Future<void> _speakWithTts(String text) async {
    if (text.isEmpty) return;

    await initialize();
    if (!_backendAvailable) {
      debugPrint('Audio backend unavailable. Skip speaking: $text');
      _resetPlaybackState();
      return;
    }
    await stop();

    _usingTts = true;
    _currentAsset = 'tts:$text';
    _isPlaying = true;

    try {
      await _tts.speak(text);
    } catch (error) {
      debugPrint('TTS speak error: $error');
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
