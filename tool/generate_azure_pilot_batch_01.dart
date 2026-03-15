import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String _defaultVoice = 'ar-SA-HamedNeural';
const String _defaultOutputFormat = 'audio-24khz-48kbitrate-mono-mp3';
const String _defaultUserAgent = 'arabic-learning-app-pilot-audio-generator';
const Duration _requestSpacing = Duration(milliseconds: 150);

Future<void> main(List<String> args) async {
  final config = _Config.fromArgs(args);

  if (config.showHelp) {
    _printUsage();
    return;
  }

  final items = _buildItems(config.voice, config.fileExtension);
  final manifest = _Manifest(
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    voice: config.voice,
    outputFormat: config.outputFormat,
    items: items,
  );

  final manifestFile = File(config.manifestPath);
  manifestFile.parent.createSync(recursive: true);
  manifestFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
  );

  stdout.writeln(
    'Pilot manifest generated: ${items.length} items -> ${config.manifestPath}',
  );

  if (config.dryRun) {
    for (final item in items) {
      stdout.writeln('Dry run: ${item.id} -> ${item.assetPath}');
    }
    stdout.writeln('Dry run enabled. No Azure requests were sent.');
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

  for (final item in items) {
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
Azure pilot audio generator for arabic_learning_app

Usage:
  dart run tool/generate_azure_pilot_batch_01.dart [options]

PowerShell example:
  \$env:AZURE_SPEECH_KEY="your_key"
  \$env:AZURE_SPEECH_REGION="eastus"
  dart run tool/generate_azure_pilot_batch_01.dart --force

Options:
  --dry-run            Build the pilot manifest only, do not call Azure.
  --skip-existing      Skip files that already exist. Default: true
  --force              Regenerate files even if they already exist.
  --voice=VOICE        Azure voice name. Default: $_defaultVoice
  --format=FORMAT      Azure output format. Default: $_defaultOutputFormat
  --manifest=PATH      Manifest output path. Default: assets/data/audio_manifest_pilot_batch_01.json
  --help               Show this help.
''');
}

List<_Item> _buildItems(String voice, String extension) {
  const unifiedRate = '-22%';
  const unifiedPitch = '+0st';

  return <_Item>[
    _Item(
      id: 'ALP-B01-001',
      category: 'letter',
      textAr: 'أَيْ',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'alphabet_soft_ay_slow.$extension',
      assetPath:
          'assets/audio/alphabet/pronunciation/alphabet_soft_ay_slow.$extension',
    ),
    _Item(
      id: 'GRM-B01-001',
      category: 'short_word',
      textAr: 'بَ',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'grammar_harakat_fatha_ba_slow.$extension',
      assetPath:
          'assets/audio/grammar/harakat_rules/grammar_harakat_fatha_ba_slow.$extension',
    ),
    _Item(
      id: 'GRM-B01-011',
      category: 'short_word',
      textAr: 'هذا',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'grammar_demonstrative_hatha_slow.$extension',
      assetPath:
          'assets/audio/grammar/demonstratives/grammar_demonstrative_hatha_slow.$extension',
    ),
    _Item(
      id: 'LES-B01-001-S',
      category: 'statement',
      textAr: 'هٰذَا كِتَابٌ جَدِيدٌ.',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'u1l3_word_book_class_example_slow.$extension',
      assetPath:
          'assets/audio/lesson_03/sentence/u1l3_word_book_class_example_slow.$extension',
    ),
    _Item(
      id: 'LES-B01-001-N',
      category: 'statement',
      textAr: 'هٰذَا كِتَابٌ جَدِيدٌ.',
      version: 'normal',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'u1l3_word_book_class_example_normal.$extension',
      assetPath:
          'assets/audio/lesson_03/sentence/u1l3_word_book_class_example_normal.$extension',
    ),
    _Item(
      id: 'LES-B01-004-S',
      category: 'statement',
      textAr: 'هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'u1l4_word_board_class_example_slow.$extension',
      assetPath:
          'assets/audio/lesson_04/sentence/u1l4_word_board_class_example_slow.$extension',
    ),
    _Item(
      id: 'LES-B01-004-N',
      category: 'statement',
      textAr: 'هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.',
      version: 'normal',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'u1l4_word_board_class_example_normal.$extension',
      assetPath:
          'assets/audio/lesson_04/sentence/u1l4_word_board_class_example_normal.$extension',
    ),
    _Item(
      id: 'GRM-B01-019-S',
      category: 'statement',
      textAr: 'أَنَا طَالِبٌ',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'grammar_nominal_i_student_slow.$extension',
      assetPath:
          'assets/audio/grammar/nominal_sentence/grammar_nominal_i_student_slow.$extension',
    ),
    _Item(
      id: 'GRM-B01-019-N',
      category: 'statement',
      textAr: 'أَنَا طَالِبٌ',
      version: 'normal',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'grammar_nominal_i_student_normal.$extension',
      assetPath:
          'assets/audio/grammar/nominal_sentence/grammar_nominal_i_student_normal.$extension',
    ),
    _Item(
      id: 'GRM-B01-020-S',
      category: 'question',
      textAr: 'هَلْ أَنْتَ طَالِبٌ؟',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'grammar_question_are_you_student_slow.$extension',
      assetPath:
          'assets/audio/grammar/question_sentence/grammar_question_are_you_student_slow.$extension',
    ),
    _Item(
      id: 'GRM-B01-020-N',
      category: 'question',
      textAr: 'هَلْ أَنْتَ طَالِبٌ؟',
      version: 'normal',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'grammar_question_are_you_student_normal.$extension',
      assetPath:
          'assets/audio/grammar/question_sentence/grammar_question_are_you_student_normal.$extension',
    ),
    _Item(
      id: 'LES-B01-009-S',
      category: 'life_sentence',
      textAr: 'أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.',
      version: 'slow',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'u4l4_word_coat_weather_example_slow.$extension',
      assetPath:
          'assets/audio/lesson_16/sentence/u4l4_word_coat_weather_example_slow.$extension',
    ),
    _Item(
      id: 'LES-B01-009-N',
      category: 'life_sentence',
      textAr: 'أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.',
      version: 'normal',
      rate: unifiedRate,
      pitch: unifiedPitch,
      fileName: 'u4l4_word_coat_weather_example_normal.$extension',
      assetPath:
          'assets/audio/lesson_16/sentence/u4l4_word_coat_weather_example_normal.$extension',
    ),
  ];
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

  Future<void> synthesize(_Item item) async {
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

  String _buildSsml(_Item item) {
    final locale = _localeFromVoice(voice);
    final useLeadingBreak = item.version == 'slow' &&
        (item.category == 'statement' ||
            item.category == 'question' ||
            item.category == 'life_sentence');
    final body = useLeadingBreak
        ? '<break time="100ms"/>${_escapeXml(item.textAr)}'
        : _escapeXml(item.textAr);
    return '''
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="$locale">
  <voice name="$voice">
    <prosody rate="${item.rate}" pitch="${item.pitch}">$body</prosody>
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

class _Config {
  final bool dryRun;
  final bool skipExisting;
  final bool showHelp;
  final String voice;
  final String outputFormat;
  final String manifestPath;

  const _Config({
    required this.dryRun,
    required this.skipExisting,
    required this.showHelp,
    required this.voice,
    required this.outputFormat,
    required this.manifestPath,
  });

  String get fileExtension => _extensionFromOutputFormat(outputFormat);

  static _Config fromArgs(List<String> args) {
    var dryRun = false;
    var skipExisting = true;
    var showHelp = false;
    var voice = _defaultVoice;
    var outputFormat = _defaultOutputFormat;
    var manifestPath = 'assets/data/audio_manifest_pilot_batch_01.json';

    for (final arg in args) {
      if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg == '--skip-existing') {
        skipExisting = true;
      } else if (arg == '--force') {
        skipExisting = false;
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

    return _Config(
      dryRun: dryRun,
      skipExisting: skipExisting,
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

class _Manifest {
  final String generatedAt;
  final String voice;
  final String outputFormat;
  final List<_Item> items;

  const _Manifest({
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
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

class _Item {
  final String id;
  final String category;
  final String textAr;
  final String version;
  final String rate;
  final String pitch;
  final String fileName;
  final String assetPath;

  const _Item({
    required this.id,
    required this.category,
    required this.textAr,
    required this.version,
    required this.rate,
    required this.pitch,
    required this.fileName,
    required this.assetPath,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'textAr': textAr,
      'version': version,
      'rate': rate,
      'pitch': pitch,
      'fileName': fileName,
      'assetPath': assetPath,
    };
  }
}
