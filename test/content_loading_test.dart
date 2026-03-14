import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/word_item.dart';
import 'package:arabic_learning_app/services/alphabet_service.dart';
import 'package:arabic_learning_app/services/audio_manifest_service.dart';
import 'package:arabic_learning_app/services/grammar_service.dart';
import 'package:arabic_learning_app/services/lesson_service.dart';
import 'package:arabic_learning_app/services/review_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const englishSettings = AppSettings(
    appLanguage: AppLanguage.en,
    meaningLanguage: ContentLanguage.en,
    showTransliteration: true,
  );
  final savedWord = WordItem(
    arabic: 'مَرْحَبًا',
    plainArabic: 'مرحبا',
    pronunciation: 'marhaban',
    meaning: '你好',
    partOfSpeech: '固定表达',
  );

  group('Content loading', () {
    test('loads the full lesson curriculum', () async {
      final lessons = await LessonService().loadLessons();

      expect(lessons, hasLength(16));
      expect(lessons.first.id, 'U1L1');
      expect(lessons.last.id, 'U4L4');
    });

    test('loads the full alphabet curriculum', () async {
      final groups = await AlphabetService.loadAlphabetGroups();
      final letterCount = groups.fold<int>(
        0,
        (sum, group) => sum + group.letters.length,
      );

      expect(groups, hasLength(7));
      expect(letterCount, 28);
    });

    test('loads grammar categories and pages', () async {
      final categories = await GrammarService.loadCategories();
      final pages = await GrammarService.loadPages();

      expect(categories, hasLength(6));
      expect(pages.length, greaterThanOrEqualTo(19));
    });

    test('resolves generated lesson audio from the manifest', () async {
      final asset = await AudioManifestService.findLessonAsset(
        lessonSequence: 1,
        type: 'word',
        speed: 'normal',
        textPlain: 'مرحبا',
      );

      expect(asset, 'lesson_01/word/l01_w_001_normal.mp3');
    });

    test('resolves generated alphabet audio from the manifest', () async {
      final asset = await AudioManifestService.findAlphabetAsset(
        type: 'letter',
        speed: 'normal',
        textPlain: 'ا',
      );

      expect(asset, isNotNull);
      expect(asset, contains('alphabet/letter'));
    });
    test('builds the review dashboard summary', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'completed_lessons': <String>['U1L1'],
        'started_lessons': <String>['U1L1'],
        'last_lesson_id': 'U1L1',
        'favorite_words': <String>[jsonEncode(savedWord.toJson())],
      });

      final dashboard = await ReviewService.buildDashboard(englishSettings);

      expect(dashboard.summary.todayPlan.totalCount, greaterThan(0));
      expect(dashboard.summary.typeCounts, isNotEmpty);
    });
  });
}
