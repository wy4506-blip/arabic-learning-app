import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/services/audio_manifest_service.dart';
import 'package:arabic_learning_app/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AudioManifestService.debugResetTestData();
    AudioService.debugClearPlaybackOverrides();
  });

  test('plays mapped learning asset when a bundled resource exists', () async {
    final assetCalls = <String>[];
    final ttsCalls = <String>[];

    AudioManifestService.debugLoadTestData(
      manifestItems: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'alpha_letter_ai_normal',
          'scope': 'alphabet',
          'lessonId': 'alphabet',
          'type': 'letter',
          'speed': 'normal',
          'textAr': 'ا',
          'textPlain': 'ا',
          'relativeAssetPath': 'alphabet/letter/alpha_l_001_normal.mp3',
          'voiceType': 'ai',
        },
      ],
      bundledAssetPaths: <String>{
        'assets/audio/alphabet/letter/alpha_l_001_normal.mp3',
      },
    );
    AudioService.debugSetPlaybackOverrides(
      assetPlaybackHandler: (path) async => assetCalls.add(path),
      ttsPlaybackHandler: (text) async => ttsCalls.add(text),
      windowsTtsDisabled: false,
    );

    await AudioService.playLearningText(
      const LearningAudioRequest.alphabet(
        type: 'letter',
        textAr: 'ا',
      ),
    );

    expect(
        assetCalls, <String>['audio/alphabet/letter/alpha_l_001_normal.mp3']);
    expect(ttsCalls, isEmpty);
  });

  test('falls back through missing human assets until an ai asset is available',
      () async {
    final assetCalls = <String>[];
    final ttsCalls = <String>[];

    AudioManifestService.debugLoadTestData(
      manifestItems: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'alpha_letter_human_slow',
          'scope': 'alphabet',
          'lessonId': 'alphabet',
          'type': 'letter',
          'speed': 'slow',
          'textAr': 'ب',
          'textPlain': 'ب',
          'relativeAssetPath': 'alphabet/letter/alpha_l_002_slow__human__.m4a',
          'voiceType': 'human',
        },
        <String, dynamic>{
          'id': 'alpha_letter_human_normal',
          'scope': 'alphabet',
          'lessonId': 'alphabet',
          'type': 'letter',
          'speed': 'normal',
          'textAr': 'ب',
          'textPlain': 'ب',
          'relativeAssetPath':
              'alphabet/letter/alpha_l_002_normal__human__.m4a',
          'voiceType': 'human',
        },
        <String, dynamic>{
          'id': 'alpha_letter_ai_slow',
          'scope': 'alphabet',
          'lessonId': 'alphabet',
          'type': 'letter',
          'speed': 'slow',
          'textAr': 'ب',
          'textPlain': 'ب',
          'relativeAssetPath': 'alphabet/letter/alpha_l_002_slow.mp3',
          'voiceType': 'ai',
        },
      ],
      bundledAssetPaths: <String>{
        'assets/audio/alphabet/letter/alpha_l_002_slow.mp3',
      },
    );
    AudioService.debugSetPlaybackOverrides(
      assetPlaybackHandler: (path) async => assetCalls.add(path),
      ttsPlaybackHandler: (text) async => ttsCalls.add(text),
      windowsTtsDisabled: false,
    );

    await AudioService.playLearningText(
      const LearningAudioRequest.alphabet(
        type: 'letter',
        textAr: 'ب',
      ),
    );

    expect(assetCalls, <String>['audio/alphabet/letter/alpha_l_002_slow.mp3']);
    expect(ttsCalls, isEmpty);
  });

  test('uses tts only after all asset fallbacks are exhausted', () async {
    final assetCalls = <String>[];
    final ttsCalls = <String>[];

    AudioManifestService.debugLoadTestData(
      manifestItems: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'lesson_sentence_human_slow',
          'scope': 'lesson',
          'lessonId': 'lesson_01',
          'type': 'sentence',
          'speed': 'slow',
          'textAr': 'مَرْحَبًا',
          'textPlain': 'مرحبا',
          'relativeAssetPath': 'lesson_01/sentence/l01_s_001_slow__human__.mp3',
          'voiceType': 'human',
        },
      ],
      bundledAssetPaths: <String>{},
    );
    AudioService.debugSetPlaybackOverrides(
      assetPlaybackHandler: (path) async => assetCalls.add(path),
      ttsPlaybackHandler: (text) async => ttsCalls.add(text),
      windowsTtsDisabled: false,
    );

    await AudioService.playLearningText(
      const LearningAudioRequest.lesson(
        lessonSequence: 1,
        type: 'sentence',
        textAr: 'مَرْحَبًا',
        textPlain: 'مرحبا',
      ),
    );

    expect(assetCalls, isEmpty);
    expect(ttsCalls, <String>['مَرْحَبًا']);
  });
}
