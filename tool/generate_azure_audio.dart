import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/data/sample_lessons.dart';

const String _defaultVoice = 'ar-SA-HamedNeural';
const String _defaultOutputFormat = 'audio-24khz-48kbitrate-mono-mp3';
const String _defaultUserAgent = 'arabic-learning-app-audio-generator';
const Duration _requestSpacing = Duration(milliseconds: 150);

Future<void> main(List<String> args) async {
  final config = _GeneratorConfig.fromArgs(args);

  if (config.showHelp) {
    _printUsage();
    return;
  }

  final manifest = _buildManifest(config);
  final manifestFile = File(config.manifestPath);
  manifestFile.parent.createSync(recursive: true);
  manifestFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
  );

  stdout.writeln(
    'Manifest generated: ${manifest.items.length} items -> ${config.manifestPath}',
  );
  stdout.writeln(
    'Lessons: ${manifest.items.where((item) => item.scope == 'lesson').length}, '
    'Alphabet: ${manifest.items.where((item) => item.scope == 'alphabet').length}',
  );

  if (config.dryRun) {
    stdout
        .writeln('Dry run enabled. No audio files were requested from Azure.');
    return;
  }

  final key = Platform.environment['AZURE_SPEECH_KEY']?.trim() ?? '';
  final region = Platform.environment['AZURE_SPEECH_REGION']?.trim() ?? '';

  if (key.isEmpty || region.isEmpty) {
    stderr.writeln(
      'Missing Azure credentials. Set AZURE_SPEECH_KEY and AZURE_SPEECH_REGION first.',
    );
    exitCode = 2;
    return;
  }

  final synthesizer = _AzureSpeechSynthesizer(
    subscriptionKey: key,
    region: region,
    voice: config.voice,
    outputFormat: config.outputFormat,
    userAgent: _defaultUserAgent,
  );

  var generatedCount = 0;
  var skippedCount = 0;

  for (final item in manifest.items) {
    final outFile = File(item.assetPath);
    outFile.parent.createSync(recursive: true);

    if (config.skipExisting && outFile.existsSync()) {
      skippedCount++;
      stdout.writeln('Skip existing: ${item.assetPath}');
      continue;
    }

    stdout.writeln('Generate: ${item.id} -> ${item.assetPath}');
    await synthesizer.synthesize(item);
    generatedCount++;
    await Future<void>.delayed(_requestSpacing);
  }

  stdout.writeln(
    'Done. Generated $generatedCount files, skipped $skippedCount existing files.',
  );
}

void _printUsage() {
  stdout.writeln('''
Azure audio generator for arabic_learning_app

Usage:
  dart run tool/generate_azure_audio.dart [options]

PowerShell example:
  \$env:AZURE_SPEECH_KEY="your_key"
  \$env:AZURE_SPEECH_REGION="eastus"
  dart run tool/generate_azure_audio.dart --skip-existing

Options:
  --dry-run            Build the manifest only, do not call Azure.
  --skip-existing      Skip files that already exist. Default: true
  --force              Regenerate files even if they already exist.
  --voice=VOICE        Azure voice name. Default: $_defaultVoice
  --format=FORMAT      Azure output format. Default: $_defaultOutputFormat
  --manifest=PATH      Manifest output path. Default: assets/data/audio_manifest.json
  --only-lessons       Generate lesson word/sentence audio only.
  --only-alphabet      Generate alphabet audio only.
  --help               Show this help.

Notes:
  1. Azure Speech REST currently exposes MP3/Opus/PCM style output formats, not AAC/M4A.
  2. This script therefore defaults to MP3, which is also the fallback format allowed in your spec.
''');
}

_AudioManifest _buildManifest(_GeneratorConfig config) {
  final items = <_AudioManifestItem>[];

  if (!config.onlyAlphabet) {
    items.addAll(_buildLessonItems(config));
  }

  if (!config.onlyLessons) {
    items.addAll(_buildAlphabetItems(config));
  }

  return _AudioManifest(
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    outputFormat: config.outputFormat,
    voice: config.voice,
    items: items,
  );
}

List<_AudioManifestItem> _buildLessonItems(_GeneratorConfig config) {
  final items = <_AudioManifestItem>[];

  for (final lesson in sampleLessons) {
    final lessonTag = lesson.sequence.toString().padLeft(2, '0');
    var wordIndex = 1;
    var sentenceIndex = 1;

    for (final word in lesson.vocabulary) {
      items.addAll(
        _buildDualSpeedItems(
          scope: 'lesson',
          lessonId: 'lesson_$lessonTag',
          groupId: lesson.unitId,
          type: 'word',
          sourceType: 'lesson_vocabulary',
          sourceId: word.id ?? '${lesson.id}_word_$wordIndex',
          textAr: word.arabic,
          textPlain: word.plainArabic,
          textZh: word.chinese,
          fileStem: 'l${lessonTag}_w_${wordIndex.toString().padLeft(3, '0')}',
          relativeDir: 'lesson_$lessonTag/word',
          extension: config.fileExtension,
        ),
      );
      wordIndex++;
    }

    for (final pattern in lesson.patterns) {
      items.addAll(
        _buildDualSpeedItems(
          scope: 'lesson',
          lessonId: 'lesson_$lessonTag',
          groupId: lesson.unitId,
          type: 'sentence',
          sourceType: 'lesson_pattern',
          sourceId: '${lesson.id}_pattern_$sentenceIndex',
          textAr: pattern.arabic,
          textPlain: _stripArabicDiacritics(pattern.arabic),
          textZh: pattern.chinese,
          fileStem:
              'l${lessonTag}_s_${sentenceIndex.toString().padLeft(3, '0')}',
          relativeDir: 'lesson_$lessonTag/sentence',
          extension: config.fileExtension,
        ),
      );
      sentenceIndex++;
    }

    for (var dialogueIndex = 0;
        dialogueIndex < lesson.dialogues.length;
        dialogueIndex++) {
      final line = lesson.dialogues[dialogueIndex];
      items.addAll(
        _buildDualSpeedItems(
          scope: 'lesson',
          lessonId: 'lesson_$lessonTag',
          groupId: lesson.unitId,
          type: 'sentence',
          sourceType: 'lesson_dialogue',
          sourceId: '${lesson.id}_dialogue_${dialogueIndex + 1}',
          textAr: line.arabic,
          textPlain: _stripArabicDiacritics(line.arabic),
          textZh: line.chinese,
          fileStem:
              'l${lessonTag}_s_${sentenceIndex.toString().padLeft(3, '0')}',
          relativeDir: 'lesson_$lessonTag/sentence',
          extension: config.fileExtension,
          speaker: line.speaker,
        ),
      );
      sentenceIndex++;
    }
  }

  return items;
}

List<_AudioManifestItem> _buildAlphabetItems(_GeneratorConfig config) {
  final items = <_AudioManifestItem>[];
  var letterIndex = 1;
  var pronunciationIndex = 1;
  var exampleWordIndex = 1;

  for (final group in sampleAlphabetGroups) {
    final groupTag = group.id.toString().padLeft(2, '0');
    for (final letter in group.letters) {
      items.add(
        _AudioManifestItem(
          id: 'alpha_l_${letterIndex.toString().padLeft(3, '0')}_normal',
          scope: 'alphabet',
          lessonId: 'alphabet',
          groupId: 'group_$groupTag',
          type: 'letter',
          sourceType: 'alphabet_letter',
          sourceId: 'alphabet_letter_$letterIndex',
          textAr: letter.arabic,
          textPlain: letter.arabic,
          textZh: letter.name,
          speed: 'normal',
          fileName:
              'alpha_l_${letterIndex.toString().padLeft(3, '0')}_normal.${config.fileExtension}',
          assetPath:
              'assets/audio/alphabet/letter/alpha_l_${letterIndex.toString().padLeft(3, '0')}_normal.${config.fileExtension}',
          relativeAssetPath:
              'alphabet/letter/alpha_l_${letterIndex.toString().padLeft(3, '0')}_normal.${config.fileExtension}',
        ),
      );
      letterIndex++;

      for (final pronunciation in letter.pronunciations) {
        items.add(
          _AudioManifestItem(
            id: 'alpha_p_${pronunciationIndex.toString().padLeft(3, '0')}_normal',
            scope: 'alphabet',
            lessonId: 'alphabet',
            groupId: 'group_$groupTag',
            type: 'pronunciation',
            sourceType: 'alphabet_pronunciation',
            sourceId: 'alphabet_pronunciation_$pronunciationIndex',
            textAr: pronunciation.form,
            textPlain: _stripArabicDiacritics(pronunciation.form),
            textZh: pronunciation.label,
            speed: 'normal',
            fileName:
                'alpha_p_${pronunciationIndex.toString().padLeft(3, '0')}_normal.${config.fileExtension}',
            assetPath:
                'assets/audio/alphabet/pronunciation/alpha_p_${pronunciationIndex.toString().padLeft(3, '0')}_normal.${config.fileExtension}',
            relativeAssetPath:
                'alphabet/pronunciation/alpha_p_${pronunciationIndex.toString().padLeft(3, '0')}_normal.${config.fileExtension}',
          ),
        );
        pronunciationIndex++;
      }

      items.addAll(
        _buildDualSpeedItems(
          scope: 'alphabet',
          lessonId: 'alphabet',
          groupId: 'group_$groupTag',
          type: 'word',
          sourceType: 'alphabet_example_word',
          sourceId: 'alphabet_example_word_$exampleWordIndex',
          textAr: letter.example.arabic,
          textPlain: _stripArabicDiacritics(letter.example.arabic),
          textZh: letter.example.meaning,
          fileStem: 'alpha_w_${exampleWordIndex.toString().padLeft(3, '0')}',
          relativeDir: 'alphabet/word',
          extension: config.fileExtension,
        ),
      );
      exampleWordIndex++;
    }
  }

  return items;
}

List<_AudioManifestItem> _buildDualSpeedItems({
  required String scope,
  required String lessonId,
  required String groupId,
  required String type,
  required String sourceType,
  required String sourceId,
  required String textAr,
  required String textPlain,
  required String textZh,
  required String fileStem,
  required String relativeDir,
  required String extension,
  String? speaker,
}) {
  return <_AudioManifestItem>[
    _AudioManifestItem(
      id: '${fileStem}_normal',
      scope: scope,
      lessonId: lessonId,
      groupId: groupId,
      type: type,
      sourceType: sourceType,
      sourceId: sourceId,
      textAr: textAr,
      textPlain: textPlain,
      textZh: textZh,
      speed: 'normal',
      fileName: '${fileStem}_normal.$extension',
      assetPath: 'assets/audio/$relativeDir/${fileStem}_normal.$extension',
      relativeAssetPath: '$relativeDir/${fileStem}_normal.$extension',
      speaker: speaker,
    ),
    _AudioManifestItem(
      id: '${fileStem}_slow',
      scope: scope,
      lessonId: lessonId,
      groupId: groupId,
      type: type,
      sourceType: sourceType,
      sourceId: sourceId,
      textAr: textAr,
      textPlain: textPlain,
      textZh: textZh,
      speed: 'slow',
      fileName: '${fileStem}_slow.$extension',
      assetPath: 'assets/audio/$relativeDir/${fileStem}_slow.$extension',
      relativeAssetPath: '$relativeDir/${fileStem}_slow.$extension',
      speaker: speaker,
    ),
  ];
}

String _stripArabicDiacritics(String input) {
  return input
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll('ٰ', '')
      .trim();
}

String _escapeXml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

class _AzureSpeechSynthesizer {
  final String subscriptionKey;
  final String region;
  final String voice;
  final String outputFormat;
  final String userAgent;

  const _AzureSpeechSynthesizer({
    required this.subscriptionKey,
    required this.region,
    required this.voice,
    required this.outputFormat,
    required this.userAgent,
  });

  Future<void> synthesize(_AudioManifestItem item) async {
    final uri = Uri.parse(
      'https://$region.tts.speech.microsoft.com/cognitiveservices/v1',
    );

    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);
      request.headers.set('Ocp-Apim-Subscription-Key', subscriptionKey);
      request.headers.set('Content-Type', 'application/ssml+xml');
      request.headers.set('X-Microsoft-OutputFormat', outputFormat);
      request.headers.set('User-Agent', userAgent);

      request.add(utf8.encode(_buildSsml(item)));
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        final errorBody = await utf8.decoder.bind(response).join();
        throw HttpException(
          'Azure TTS failed (${response.statusCode}) for ${item.id}: $errorBody',
          uri: uri,
        );
      }

      final outFile = File(item.assetPath);
      final sink = outFile.openWrite();
      await response.forEach(sink.add);
      await sink.close();
    } finally {
      client.close(force: true);
    }
  }

  String _buildSsml(_AudioManifestItem item) {
    final locale = _localeFromVoice(voice);
    final rate = item.speed == 'slow' ? 'slow' : 'medium';

    return '''
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="$locale">
  <voice name="$voice">
    <prosody rate="$rate">${_escapeXml(item.textAr)}</prosody>
  </voice>
</speak>
''';
  }

  String _localeFromVoice(String voiceName) {
    final parts = voiceName.split('-');
    if (parts.length >= 2) {
      return '${parts[0]}-${parts[1]}';
    }
    return 'ar-SA';
  }
}

class _GeneratorConfig {
  final bool dryRun;
  final bool skipExisting;
  final bool onlyLessons;
  final bool onlyAlphabet;
  final bool showHelp;
  final String voice;
  final String outputFormat;
  final String manifestPath;

  const _GeneratorConfig({
    required this.dryRun,
    required this.skipExisting,
    required this.onlyLessons,
    required this.onlyAlphabet,
    required this.showHelp,
    required this.voice,
    required this.outputFormat,
    required this.manifestPath,
  });

  String get fileExtension => _extensionFromOutputFormat(outputFormat);

  static _GeneratorConfig fromArgs(List<String> args) {
    var dryRun = false;
    var skipExisting = true;
    var onlyLessons = false;
    var onlyAlphabet = false;
    var showHelp = false;
    var voice = _defaultVoice;
    var outputFormat = _defaultOutputFormat;
    var manifestPath = 'assets/data/audio_manifest.json';

    for (final arg in args) {
      if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg == '--skip-existing') {
        skipExisting = true;
      } else if (arg == '--force') {
        skipExisting = false;
      } else if (arg == '--only-lessons') {
        onlyLessons = true;
      } else if (arg == '--only-alphabet') {
        onlyAlphabet = true;
      } else if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else if (arg.startsWith('--voice=')) {
        voice = arg.substring('--voice='.length).trim();
      } else if (arg.startsWith('--format=')) {
        outputFormat = arg.substring('--format='.length).trim();
      } else if (arg.startsWith('--manifest=')) {
        manifestPath = arg.substring('--manifest='.length).trim();
      } else {
        stderr.writeln('Unknown argument: $arg');
        showHelp = true;
      }
    }

    if (onlyLessons && onlyAlphabet) {
      throw ArgumentError(
          '--only-lessons and --only-alphabet cannot be used together.');
    }

    return _GeneratorConfig(
      dryRun: dryRun,
      skipExisting: skipExisting,
      onlyLessons: onlyLessons,
      onlyAlphabet: onlyAlphabet,
      showHelp: showHelp,
      voice: voice,
      outputFormat: outputFormat,
      manifestPath: manifestPath,
    );
  }
}

String _extensionFromOutputFormat(String format) {
  if (format.contains('mp3')) {
    return 'mp3';
  }
  if (format.contains('ogg') || format.contains('opus')) {
    return 'ogg';
  }
  if (format.contains('pcm') ||
      format.contains('riff') ||
      format.contains('raw')) {
    return 'wav';
  }
  return 'bin';
}

class _AudioManifest {
  final String generatedAt;
  final String voice;
  final String outputFormat;
  final List<_AudioManifestItem> items;

  const _AudioManifest({
    required this.generatedAt,
    required this.voice,
    required this.outputFormat,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'generatedAt': generatedAt,
      'voice': voice,
      'outputFormat': outputFormat,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class _AudioManifestItem {
  final String id;
  final String scope;
  final String lessonId;
  final String groupId;
  final String type;
  final String sourceType;
  final String sourceId;
  final String textAr;
  final String textPlain;
  final String textZh;
  final String speed;
  final String fileName;
  final String assetPath;
  final String relativeAssetPath;
  final String? speaker;

  const _AudioManifestItem({
    required this.id,
    required this.scope,
    required this.lessonId,
    required this.groupId,
    required this.type,
    required this.sourceType,
    required this.sourceId,
    required this.textAr,
    required this.textPlain,
    required this.textZh,
    required this.speed,
    required this.fileName,
    required this.assetPath,
    required this.relativeAssetPath,
    this.speaker,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'lessonId': lessonId,
      'groupId': groupId,
      'scope': scope,
      'type': type,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'textAr': textAr,
      'textPlain': textPlain,
      'textZh': textZh,
      'speed': speed,
      'fileName': fileName,
      'assetPath': assetPath,
      'relativeAssetPath': relativeAssetPath,
      if (speaker != null) 'speaker': speaker,
    };
  }
}
