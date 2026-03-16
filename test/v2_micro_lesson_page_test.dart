import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/app_scope.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/services/audio_service.dart';
import 'package:arabic_learning_app/widgets/arabic_text_with_audio.dart';

const _testSettings = AppSettings(
  appLanguage: AppLanguage.en,
  meaningLanguage: ContentLanguage.en,
  showTransliteration: true,
);

Future<void> _pumpTestLessonPage(
  WidgetTester tester, {
  required String lessonId,
}) async {
  await tester.pumpWidget(
    AppSettingsScope(
      settings: _testSettings,
      onSettingsChanged: (_) {},
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(),
        ),
      ),
    ),
  );

  await tester.pumpWidget(
    AppSettingsScope(
      settings: _testSettings,
      onSettingsChanged: (_) {},
      child: MaterialApp(
        home: Scaffold(
          body: V2MicroLessonPage(
            lessonId: lessonId,
            settings: _testSettings,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(() {
    AudioService.debugClearPlaybackOverrides();
  });

  testWidgets('runtime shows structured lesson sections',
      (tester) async {
    await _pumpTestLessonPage(
      tester,
      lessonId: 'V2-U1-03',
    );

    expect(find.text('Lesson Goal'), findsOneWidget);
    expect(find.text('Listen First'), findsOneWidget);
    expect(find.text('Use This Pattern'), findsOneWidget);
  });

  testWidgets('runtime shows expected audio affordance count',
      (tester) async {
    await _pumpTestLessonPage(
      tester,
      lessonId: 'V2-U1-03',
    );

    expect(find.byType(LearningAudioIconButton), findsNWidgets(3));
  });

  testWidgets('minimal page shell shows static choice shells for auto-graded practice',
      (tester) async {
    await _pumpTestLessonPage(
      tester,
      lessonId: 'V2-U1-01',
    );

    expect(find.byType(OutlinedButton), findsWidgets);
    expect(find.widgetWithText(OutlinedButton, 'مَرْحَبًا'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'صَبَاحُ الْخَيْرِ'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'مَعَ السَّلَامَةِ'), findsOneWidget);
  });

  testWidgets(
    'runtime audio request extraction remains isolated from the regression subset',
    (tester) async {
      await _pumpTestLessonPage(
        tester,
        lessonId: 'V2-U1-03',
      );

      final audioButtons = find.byType(LearningAudioIconButton);
      expect(audioButtons, findsNWidgets(3));

      final firstAudioButton = tester.widget<LearningAudioIconButton>(
        audioButtons.first,
      );
      expect(firstAudioButton.request.textAr?.trim(), isNotEmpty);
      expect(firstAudioButton.request.debugLabel?.trim(), isNotEmpty);
    },
    skip: true,
  );

  testWidgets(
    'runtime audio playback path remains isolated from the regression subset',
    (tester) async {
      final assetCalls = <String>[];
      final ttsCalls = <String>[];
      AudioService.debugSetPlaybackOverrides(
        assetPlaybackHandler: (relativePath) async => assetCalls.add(relativePath),
        ttsPlaybackHandler: (text) async => ttsCalls.add(text),
        windowsTtsDisabled: false,
      );

      await _pumpTestLessonPage(
        tester,
        lessonId: 'V2-U1-03',
      );

      final audioButtons = find.byType(LearningAudioIconButton);
      expect(audioButtons, findsNWidgets(3));

      final firstAudioButton = tester.widget<LearningAudioIconButton>(
        audioButtons.first,
      );
      await AudioService.playLearningText(firstAudioButton.request);

      expect(assetCalls.isNotEmpty || ttsCalls.isNotEmpty, isTrue);
    },
    skip: true,
  );
}