import 'dart:convert';
import 'dart:io';

import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/models/dialogue_line.dart';
import 'package:arabic_learning_app/models/lesson.dart';

Future<void> main(List<String> args) async {
  final root = Directory.current;
  final manifestFile =
      File(_join(root.path, 'assets/data/audio_manifest.json'));
  final grammarPagesFile = File(_join(root.path, 'assets/grammar/pages.json'));

  if (!manifestFile.existsSync()) {
    stderr.writeln('audio_manifest.json not found.');
    exitCode = 1;
    return;
  }

  if (!grammarPagesFile.existsSync()) {
    stderr.writeln('assets/grammar/pages.json not found.');
    exitCode = 1;
    return;
  }

  final manifestJson =
      jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final manifestItems =
      (manifestJson['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_ManifestEntry.fromJson)
          .toList(growable: false);
  final grammarPages =
      (jsonDecode(await grammarPagesFile.readAsString()) as List<dynamic>? ??
              const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

  final registeredAssetPaths = manifestItems
      .map((item) => item.assetPath)
      .where((item) => item.isNotEmpty)
      .toSet();
  final actualAssetPaths = Directory(_join(root.path, 'assets/audio'))
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => _toProjectPath(root, file.path))
      .map((path) => path.replaceAll('\\', '/'))
      .toSet();

  final expectedOwners = <_ExpectedAudioOwner>[
    ..._collectAlphabetOwners(),
    ..._collectLessonOwners(),
    ..._collectGrammarPageOwners(grammarPages),
  ];

  final missingMappings = expectedOwners
      .where((owner) => !_hasManifestMatch(owner, manifestItems))
      .toList(growable: false);
  final missingFiles = manifestItems
      .where((item) =>
          item.assetPath.isNotEmpty &&
          !actualAssetPaths.contains(item.assetPath))
      .toList(growable: false);
  final orphanAssets = actualAssetPaths
      .where((path) => !registeredAssetPaths.contains(path))
      .toList(growable: false)
    ..sort();

  stdout.writeln('=== Audio Coverage Check ===');
  stdout.writeln('Expected learning items: ${expectedOwners.length}');
  stdout.writeln('Manifest items: ${manifestItems.length}');
  stdout.writeln('Actual asset files: ${actualAssetPaths.length}');
  stdout.writeln('');

  _printSection(
    title: 'Has textAr but no audio mapping',
    lines: missingMappings
        .map((owner) => owner.describe())
        .toList(growable: false),
  );
  _printSection(
    title: 'Manifest has record but asset file missing',
    lines: missingFiles.map((item) => item.describe()).toList(growable: false),
  );
  _printSection(
    title: 'Asset file exists but manifest is missing',
    lines: orphanAssets,
  );

  if (missingMappings.isNotEmpty ||
      missingFiles.isNotEmpty ||
      orphanAssets.isNotEmpty) {
    exitCode = 2;
  }
}

List<_ExpectedAudioOwner> _collectAlphabetOwners() {
  final owners = <_ExpectedAudioOwner>[];
  for (final group in sampleAlphabetGroups) {
    for (final letter in group.letters) {
      owners.add(
        _ExpectedAudioOwner(
          scope: 'alphabet',
          type: 'letter',
          textAr: letter.arabic,
          textPlain: letter.arabic,
          location: 'alphabet/${group.id}/letter/${letter.arabic}',
        ),
      );
      owners.add(
        _ExpectedAudioOwner(
          scope: 'alphabet',
          type: 'word',
          textAr: letter.example.arabic,
          textPlain: letter.example.arabic,
          location: 'alphabet/${group.id}/example/${letter.example.arabic}',
        ),
      );
      for (final pronunciation in letter.pronunciations) {
        owners.add(
          _ExpectedAudioOwner(
            scope: 'alphabet',
            type: 'pronunciation',
            textAr: pronunciation.audioQueryText,
            textPlain: pronunciation.form,
            location: 'alphabet/${group.id}/pronunciation/${pronunciation.key}',
          ),
        );
      }
    }
  }
  return owners;
}

List<_ExpectedAudioOwner> _collectLessonOwners() {
  final owners = <_ExpectedAudioOwner>[];
  for (final lesson in sampleLessons) {
    for (final word in lesson.vocabulary) {
      owners.add(
        _ExpectedAudioOwner(
          scope: 'lesson',
          type: 'word',
          textAr: word.arabic,
          textPlain: word.plainArabic,
          lessonId: 'lesson_${lesson.sequence.toString().padLeft(2, '0')}',
          location: '${lesson.id}/word/${word.id ?? word.arabic}',
        ),
      );
      final example = word.example;
      if (example != null && example.text.hasValue) {
        owners.add(
          _ExpectedAudioOwner(
            scope: 'lesson',
            type: 'sentence',
            textAr: example.text.vocalized,
            textPlain: example.text.plain,
            lessonId: 'lesson_${lesson.sequence.toString().padLeft(2, '0')}',
            location: '${lesson.id}/word-example/${word.id ?? word.arabic}',
          ),
        );
      }
    }
    for (final pattern in lesson.patterns) {
      owners.add(
        _ExpectedAudioOwner(
          scope: 'lesson',
          type: 'sentence',
          textAr: pattern.arabic,
          textPlain: pattern.text.plain,
          lessonId: 'lesson_${lesson.sequence.toString().padLeft(2, '0')}',
          location: '${lesson.id}/pattern/${pattern.arabic}',
        ),
      );
    }
    for (final line in lesson.dialogues) {
      owners.add(_dialogueOwner(lesson, line));
    }
  }
  return owners;
}

_ExpectedAudioOwner _dialogueOwner(Lesson lesson, DialogueLine line) {
  return _ExpectedAudioOwner(
    scope: 'lesson',
    type: 'sentence',
    textAr: line.arabic,
    textPlain: line.text.plain,
    lessonId: 'lesson_${lesson.sequence.toString().padLeft(2, '0')}',
    location: '${lesson.id}/dialogue/${line.speaker}/${line.arabic}',
  );
}

List<_ExpectedAudioOwner> _collectGrammarPageOwners(
  List<Map<String, dynamic>> pages,
) {
  final owners = <_ExpectedAudioOwner>[];

  for (final page in pages) {
    final pageId = (page['id'] ?? '').toString();
    final sections = (page['sections'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>();
    for (final section in sections) {
      final sectionId = (section['id'] ?? '').toString();
      final sectionType = (section['type'] ?? '').toString();

      if (sectionType == 'rule_group') {
        final rules = (section['rules'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>();
        for (final rule in rules) {
          final example = rule['example'];
          if (example is Map<String, dynamic>) {
            final textAr = (example['arabicWithDiacritics'] ?? '').toString();
            final textPlain = (example['arabicPlain'] ?? '').toString();
            owners.add(
              _ExpectedAudioOwner(
                scope: 'grammar',
                type: 'sentence',
                textAr: textAr,
                textPlain: textPlain,
                location: 'grammar-page/$pageId/$sectionId/${rule['id']}',
              ),
            );
          }
        }
      }

      if (sectionType == 'example_group') {
        final examples =
            (section['examples'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map<String, dynamic>>();
        for (final example in examples) {
          owners.add(
            _ExpectedAudioOwner(
              scope: 'grammar',
              type: 'sentence',
              textAr: (example['arabicWithDiacritics'] ?? '').toString(),
              textPlain: (example['arabicPlain'] ?? '').toString(),
              location: 'grammar-page/$pageId/$sectionId/${example['id']}',
            ),
          );
        }
      }

      if (sectionType == 'compare_group') {
        final compares =
            (section['compares'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map<String, dynamic>>();
        for (final compare in compares) {
          final left = (compare['left'] as Map<String, dynamic>? ?? const {});
          final right = (compare['right'] as Map<String, dynamic>? ?? const {});
          for (final value in <String>[
            (left['value'] ?? '').toString(),
            (right['value'] ?? '').toString(),
          ]) {
            if (_containsArabic(value)) {
              owners.add(
                _ExpectedAudioOwner(
                  scope: 'grammar',
                  type: 'phrase',
                  textAr: value,
                  textPlain: value,
                  location:
                      'grammar-page/$pageId/$sectionId/${compare['id']}:$value',
                ),
              );
            }
          }
        }
      }

      if (sectionType == 'table_card') {
        final table = section['table'] as Map<String, dynamic>?;
        final rows = (table?['rows'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<List<dynamic>>();
        for (final row in rows) {
          for (final cell in row.map((item) => item.toString())) {
            if (_containsArabic(cell)) {
              owners.add(
                _ExpectedAudioOwner(
                  scope: 'grammar',
                  type: 'phrase',
                  textAr: cell,
                  textPlain: cell,
                  location: 'grammar-page/$pageId/$sectionId/table:$cell',
                ),
              );
            }
          }
        }
      }
    }
  }

  return owners;
}

bool _hasManifestMatch(
  _ExpectedAudioOwner owner,
  List<_ManifestEntry> manifestItems,
) {
  final targetAr = _normalizeArabic(owner.textAr);
  final targetPlain = _normalizeArabic(owner.textPlain);

  return manifestItems.any((item) {
    if (owner.scope == 'alphabet' && item.scope != 'alphabet') {
      return false;
    }
    if (owner.scope == 'lesson' && item.lessonId != owner.lessonId) {
      return false;
    }
    if (owner.scope == 'lesson' && item.scope != 'lesson') {
      return false;
    }
    if (owner.scope == 'grammar' && item.scope == 'lesson') {
      return false;
    }

    final itemAr = _normalizeArabic(item.textAr);
    final itemPlain = _normalizeArabic(item.textPlain);
    final textMatches = (targetAr.isNotEmpty &&
            (itemAr == targetAr || itemPlain == targetAr)) ||
        (targetPlain.isNotEmpty &&
            (itemPlain == targetPlain || itemAr == targetPlain));

    if (!textMatches) {
      return false;
    }

    if (owner.type == 'phrase') {
      return item.type == 'phrase' ||
          item.type == 'sentence' ||
          item.type == 'pronunciation';
    }

    return item.type == owner.type;
  });
}

bool _containsArabic(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}

String _normalizeArabic(String value) {
  return value
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll('ٰ', '')
      .replaceAll(RegExp(r'[\s\.,!\?،؛؟]+'), '')
      .trim();
}

String _join(String left, String right) {
  return '$left${Platform.pathSeparator}${right.replaceAll('/', Platform.pathSeparator)}';
}

String _toProjectPath(Directory root, String absolutePath) {
  final normalizedRoot = root.path.replaceAll('\\', '/');
  final normalizedPath = absolutePath.replaceAll('\\', '/');
  if (normalizedPath.startsWith(normalizedRoot)) {
    return normalizedPath.substring(normalizedRoot.length + 1);
  }
  return normalizedPath;
}

void _printSection({
  required String title,
  required List<String> lines,
}) {
  stdout.writeln('--- $title (${lines.length}) ---');
  if (lines.isEmpty) {
    stdout.writeln('none');
    stdout.writeln('');
    return;
  }
  for (final line in lines) {
    stdout.writeln(line);
  }
  stdout.writeln('');
}

class _ExpectedAudioOwner {
  final String scope;
  final String type;
  final String textAr;
  final String textPlain;
  final String location;
  final String? lessonId;

  const _ExpectedAudioOwner({
    required this.scope,
    required this.type,
    required this.textAr,
    required this.textPlain,
    required this.location,
    this.lessonId,
  });

  String describe() {
    return '$location | scope=$scope type=$type textAr=$textAr textPlain=$textPlain';
  }
}

class _ManifestEntry {
  final String lessonId;
  final String scope;
  final String type;
  final String textAr;
  final String textPlain;
  final String assetPath;
  final String id;

  const _ManifestEntry({
    required this.lessonId,
    required this.scope,
    required this.type,
    required this.textAr,
    required this.textPlain,
    required this.assetPath,
    required this.id,
  });

  factory _ManifestEntry.fromJson(Map<String, dynamic> json) {
    return _ManifestEntry(
      lessonId: (json['lessonId'] ?? '').toString(),
      scope: (json['scope'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      textAr: (json['textAr'] ?? '').toString(),
      textPlain: (json['textPlain'] ?? '').toString(),
      assetPath: (json['assetPath'] ?? '').toString(),
      id: (json['id'] ?? '').toString(),
    );
  }

  String describe() {
    return '$id | scope=$scope type=$type lessonId=$lessonId assetPath=$assetPath textAr=$textAr';
  }
}
