import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static bool _isPlaying = false;
  static String? _currentAsset;

  static Future<void> initialize() async {
    if (_initialized) return;

    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _currentAsset = null;
      debugPrint('Audio complete');
    });

    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      debugPrint('Audio state: $state');
      if (state != PlayerState.playing) {
        _currentAsset = null;
      }
    });

    _initialized = true;
  }

  static Future<void> stop() async {
    await initialize();
    await _player.stop();
    _isPlaying = false;
    _currentAsset = null;
    debugPrint('Audio stopped');
  }

  static Future<bool> isPlaying() async {
    return _isPlaying;
  }

  static Future<void> playAsset(String relativePath) async {
    await initialize();

    final fullPath = 'audio/$relativePath';
    debugPrint('Trying to play asset: $fullPath');

    try {
      if (_currentAsset == fullPath && _isPlaying) {
        await stop();
        return;
      }

      await stop();
      _currentAsset = fullPath;

      await _player.play(AssetSource(fullPath));
      _isPlaying = true;
      debugPrint('Play request sent: $fullPath');
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  static Future<void> speakLetter(String text) async {
    final normalized = text.trim();

    const letterMap = <String, String>{
      'ا': 'letters/alif.mp3',
      'ب': 'letters/ba.mp3',
    };

    final asset = letterMap[normalized];
    if (asset != null) {
      await playAsset(asset);
    } else {
      debugPrint('No asset mapped for letter: $normalized');
    }
  }

  static Future<void> speakPronunciation(String form) async {
    await speakLetter(form);
  }

  static Future<void> speakExampleWord(String word) async {
    final normalized = word.trim();

    const wordMap = <String, String>{
      'أنا': 'words/test.mp3',
      'نعم': 'words/test.mp3',
      'لا': 'words/test.mp3',
      'كتاب': 'words/test.mp3',
    };

    final asset = wordMap[normalized];
    if (asset != null) {
      await playAsset(asset);
    } else {
      debugPrint('No asset mapped for word: $normalized');
    }
  }

  static Future<void> speakText(String text) async {
    await speakExampleWord(text);
  }
}
