import 'dart:convert';
import 'dart:io';

const List<String> _supportedInputExtensions = <String>[
  'wav',
  'm4a',
  'mp3',
  'aac',
];

const List<String> _preferredExtensionOrder = <String>[
  'wav',
  'm4a',
  'mp3',
  'aac',
];

Future<void> main(List<String> args) async {
  final config = _ImportConfig.fromArgs(args);

  if (config.showHelp) {
    _printUsage();
    return;
  }

  final deliveryRoot = Directory(config.deliveryRoot);
  if (!deliveryRoot.existsSync()) {
    stderr.writeln('Delivery root does not exist: ${config.deliveryRoot}');
    exitCode = 2;
    return;
  }

  final manifestFile = File(config.manifestPath);
  if (!manifestFile.existsSync()) {
    stderr.writeln('Manifest file does not exist: ${config.manifestPath}');
    exitCode = 2;
    return;
  }

  final manifest = _ManifestDocument.fromFile(manifestFile);
  final discoveredFiles = _discoverDeliveryFiles(deliveryRoot);

  if (discoveredFiles.conflicts.isNotEmpty) {
    stdout.writeln(
      'Detected multiple teacher files for the same target stem. The importer kept the preferred one.',
    );
    for (final conflict in discoveredFiles.conflicts.take(20)) {
      stdout.writeln('  $conflict');
    }
    if (discoveredFiles.conflicts.length > 20) {
      stdout.writeln('  ... ${discoveredFiles.conflicts.length - 20} more');
    }
  }

  if (discoveredFiles.files.isEmpty) {
    stderr.writeln(
      'No supported audio files were found under ${config.deliveryRoot}.',
    );
    stderr.writeln(
      'Expected files to live somewhere under a path segment like assets/audio/...',
    );
    exitCode = 4;
    return;
  }

  final report = await _ingestHumanAudio(
    config: config,
    manifest: manifest,
    discoveredFiles: discoveredFiles.files,
  );

  if (config.dryRun) {
    stdout.writeln('Dry run completed. No files were copied or transcoded.');
  } else {
    final outputManifest = File(config.outputManifestPath);
    outputManifest.parent.createSync(recursive: true);
    outputManifest.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
      encoding: utf8,
    );
    stdout.writeln('Manifest updated: ${config.outputManifestPath}');
  }

  if (config.reportPath.isNotEmpty) {
    final reportFile = File(config.reportPath);
    reportFile.parent.createSync(recursive: true);
    reportFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(report.toJson()),
      encoding: utf8,
    );
    stdout.writeln('Import report written: ${config.reportPath}');
  }

  stdout.writeln('Summary:');
  stdout.writeln('  Delivery files discovered: ${discoveredFiles.files.length}');
  stdout.writeln('  Human variants imported: ${report.imported.length}');
  stdout.writeln('  Missing manifest matches: ${report.missing.length}');
  stdout.writeln('  Manifest items skipped: ${report.skipped.length}');

  if (report.missing.isNotEmpty) {
    stdout.writeln('Missing matches (first 20):');
    for (final item in report.missing.take(20)) {
      stdout.writeln('  ${item['deliveryRelativePath']}');
    }
  }
}

void _printUsage() {
  stdout.writeln('''
Human audio importer for arabic_learning_app

Usage:
  dart run tool/import_human_audio.dart --delivery-root=<path> [options]

Examples:
  dart run tool/import_human_audio.dart \
    --delivery-root="C:/Users/yujingtao/Desktop/app音频文件管理/正式/配音录制任务_分阶段交付/阶段01_字母组1_ا_ب_ت_ث/02_老师交付音频" \
    --source-label=expert \
    --revision=20260314-stage01

  dart run tool/import_human_audio.dart \
    --delivery-root="C:/Users/yujingtao/Desktop/app音频文件管理/正式/配音录制任务_分阶段交付" \
    --revision=20260314-batch1 \
    --report=build/audio/human_import_report.json

Options:
  --delivery-root=PATH       Required. Can point to a single phase folder or the whole delivery root.
  --manifest=PATH            Input manifest path. Default: assets/data/audio_manifest.json
  --output-manifest=PATH     Output manifest path. Default: same as --manifest
  --source-label=LABEL       Human source label. Default: expert
  --revision=REV             Revision/batch tag appended to imported variants. Default: current date
  --target-bitrate=BITRATE   MP3 bitrate for transcoding. Default: 48k
  --target-sample-rate=HZ    Sample rate for transcoding. Default: 24000
  --ffmpeg=CMD               ffmpeg executable path. Default: ffmpeg
  --report=PATH              Optional JSON report path. Default: build/audio/human_import_report.json
  --force                    Rebuild imported variants for this revision.
  --dry-run                  Validate and plan import without writing files.
  --help                     Show help.

Workflow assumptions:
  1. Teachers can keep the existing Excel contract and delivery naming.
  2. Delivery files may be mp3, m4a, wav or aac.
  3. The app runtime keeps AI and human variants side by side using a generated human suffix.
  4. Matching is based on relative directory + file stem, not on the teacher file extension.
''');
}

Future<_ImportReport> _ingestHumanAudio({
  required _ImportConfig config,
  required _ManifestDocument manifest,
  required Map<String, _DiscoveredDeliveryFile> discoveredFiles,
}) async {
  final aiItems = manifest.items.where((item) => item.voiceType == 'ai').toList();
  final imported = <Map<String, dynamic>>[];
  final missing = <Map<String, dynamic>>[];
  final skipped = <Map<String, dynamic>>[];
  final ffmpegRequired = discoveredFiles.values.any((file) => file.extension != 'mp3');

  if (ffmpegRequired && !config.dryRun) {
    await _ensureFfmpegAvailable(config.ffmpegCommand);
  }

  for (final aiItem in aiItems) {
    final deliveryKey = _deliveryLookupKeyForManifestItem(aiItem);
    final deliveryFile = discoveredFiles[deliveryKey];

    if (deliveryFile == null) {
      continue;
    }

    final baseLogicalId = aiItem.logicalId;
    final target = _buildHumanTarget(
      relativeAssetPath: aiItem.relativeAssetPath,
      revision: config.revision,
    );

    final variantId = '${baseLogicalId}__human__${_slugify(config.revision)}';
    final existing = manifest.items.where((item) => item.id == variantId).toList();
    if (existing.isNotEmpty && !config.force) {
      skipped.add(<String, dynamic>{
        'logicalId': baseLogicalId,
        'reason': 'already-imported',
        'targetRelativeAssetPath': target.relativeAssetPath,
      });
      continue;
    }

    final importedItem = aiItem.copyWith(
      id: variantId,
      fileName: target.fileName,
      assetPath: target.assetPath,
      relativeAssetPath: target.relativeAssetPath,
      voiceType: 'human',
      source: config.sourceLabel,
      sourceFileName: deliveryFile.fileName,
      sourceFormat: deliveryFile.extension,
      revision: config.revision,
      importedAt: DateTime.now().toUtc().toIso8601String(),
    );

    if (!config.dryRun) {
      final outFile = File(importedItem.assetPath);
      outFile.parent.createSync(recursive: true);
      await _materializeHumanVariant(
        source: deliveryFile.file,
        target: outFile,
        ffmpegCommand: config.ffmpegCommand,
        targetBitrate: config.targetBitrate,
        targetSampleRate: config.targetSampleRate,
      );
    }

    manifest.upsertItem(importedItem);
    imported.add(<String, dynamic>{
      'logicalId': baseLogicalId,
      'sourceFile': deliveryFile.file.path,
      'targetRelativeAssetPath': importedItem.relativeAssetPath,
      'sourceFormat': deliveryFile.extension,
    });
  }

  for (final deliveryFile in discoveredFiles.values) {
    final matched = aiItems.any(
      (item) => _deliveryLookupKeyForManifestItem(item) == deliveryFile.lookupKey,
    );
    if (!matched) {
      missing.add(<String, dynamic>{
        'deliveryRelativePath': deliveryFile.deliveryRelativePath,
        'filePath': deliveryFile.file.path,
      });
    }
  }

  manifest.backfillAiMetadata();

  return _ImportReport(
    imported: imported,
    missing: missing,
    skipped: skipped,
  );
}

Future<void> _ensureFfmpegAvailable(String command) async {
  final result = await Process.run(command, <String>['-version']);
  if (result.exitCode != 0) {
    throw ProcessException(
      command,
      <String>['-version'],
      'ffmpeg is required for m4a/wav/aac imports but was not found.',
      result.exitCode,
    );
  }
}

Future<void> _materializeHumanVariant({
  required File source,
  required File target,
  required String ffmpegCommand,
  required String targetBitrate,
  required int targetSampleRate,
}) async {
  final sourceExt = _extensionOf(source.path);
  if (sourceExt == 'mp3') {
    source.copySync(target.path);
    return;
  }

  final result = await Process.run(
    ffmpegCommand,
    <String>[
      '-y',
      '-i',
      source.path,
      '-vn',
      '-ac',
      '1',
      '-ar',
      '$targetSampleRate',
      '-b:a',
      targetBitrate,
      target.path,
    ],
  );

  if (result.exitCode != 0) {
    throw ProcessException(
      ffmpegCommand,
      <String>[
        '-i',
        source.path,
        target.path,
      ],
      'ffmpeg failed: ${result.stderr}',
      result.exitCode,
    );
  }
}

_DiscoveredFiles _discoverDeliveryFiles(Directory root) {
  final files = <String, _DiscoveredDeliveryFile>{};
  final conflicts = <String>[];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final extension = _extensionOf(entity.path);
    if (!_supportedInputExtensions.contains(extension)) {
      continue;
    }

    final deliveryRelativePath = _deliveryRelativeAudioPath(entity.path);
    if (deliveryRelativePath == null) {
      continue;
    }

    final file = _DiscoveredDeliveryFile(
      file: entity,
      deliveryRelativePath: deliveryRelativePath,
      extension: extension,
    );

    final existing = files[file.lookupKey];
    if (existing == null) {
      files[file.lookupKey] = file;
      continue;
    }

    final winner = _preferDeliveryFile(existing, file);
    final loser = identical(winner, existing) ? file : existing;
    files[file.lookupKey] = winner;
    conflicts.add('${existing.lookupKey} => ${winner.file.path} preferred over ${loser.file.path}');
  }

  return _DiscoveredFiles(files: files, conflicts: conflicts);
}

_DiscoveredDeliveryFile _preferDeliveryFile(
  _DiscoveredDeliveryFile left,
  _DiscoveredDeliveryFile right,
) {
  final leftPriority = _preferredExtensionOrder.indexOf(left.extension);
  final rightPriority = _preferredExtensionOrder.indexOf(right.extension);
  if (leftPriority == rightPriority) {
    return left.file.lastModifiedSync().isAfter(right.file.lastModifiedSync())
        ? left
        : right;
  }
  return leftPriority < rightPriority ? left : right;
}

String? _deliveryRelativeAudioPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  const marker = '/assets/audio/';
  final markerIndex = normalized.lastIndexOf(marker);
  if (markerIndex == -1) {
    return null;
  }
  return normalized.substring(markerIndex + marker.length);
}

String _deliveryLookupKeyForManifestItem(_ManifestItem item) {
  final relative = item.relativeAssetPath;
  final separator = relative.lastIndexOf('/');
  final dir = separator == -1 ? '' : relative.substring(0, separator);
  final stem = _stemOf(separator == -1 ? relative : relative.substring(separator + 1));
  return '$dir|$stem';
}

_HumanTarget _buildHumanTarget({
  required String relativeAssetPath,
  required String revision,
}) {
  final separator = relativeAssetPath.lastIndexOf('/');
  final dir = separator == -1 ? '' : relativeAssetPath.substring(0, separator);
  final fileName = separator == -1
      ? relativeAssetPath
      : relativeAssetPath.substring(separator + 1);
  final stem = _stemOf(fileName);
  final humanFileName = '${stem}__human__${_slugify(revision)}.mp3';
  final humanRelativePath = dir.isEmpty ? humanFileName : '$dir/$humanFileName';
  return _HumanTarget(
    fileName: humanFileName,
    relativeAssetPath: humanRelativePath,
    assetPath: 'assets/audio/$humanRelativePath',
  );
}

String _slugify(String value) {
  final trimmed = value.trim().toLowerCase();
  final replaced = trimmed.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
}

String _extensionOf(String path) {
  final separator = path.replaceAll('\\', '/').split('/').last;
  final dot = separator.lastIndexOf('.');
  if (dot == -1) {
    return '';
  }
  return separator.substring(dot + 1).toLowerCase();
}

String _stemOf(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot == -1) {
    return fileName;
  }
  return fileName.substring(0, dot);
}

class _ImportConfig {
  final String deliveryRoot;
  final String manifestPath;
  final String outputManifestPath;
  final String sourceLabel;
  final String revision;
  final String targetBitrate;
  final int targetSampleRate;
  final String ffmpegCommand;
  final String reportPath;
  final bool dryRun;
  final bool force;
  final bool showHelp;

  const _ImportConfig({
    required this.deliveryRoot,
    required this.manifestPath,
    required this.outputManifestPath,
    required this.sourceLabel,
    required this.revision,
    required this.targetBitrate,
    required this.targetSampleRate,
    required this.ffmpegCommand,
    required this.reportPath,
    required this.dryRun,
    required this.force,
    required this.showHelp,
  });

  factory _ImportConfig.fromArgs(List<String> args) {
    var deliveryRoot = '';
    var manifestPath = 'assets/data/audio_manifest.json';
    String? outputManifestPath;
    var sourceLabel = 'expert';
    var revision = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    var targetBitrate = '48k';
    var targetSampleRate = 24000;
    var ffmpegCommand = 'ffmpeg';
    var reportPath = 'build/audio/human_import_report.json';
    var dryRun = false;
    var force = false;
    var showHelp = false;

    for (final arg in args) {
      if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg == '--force') {
        force = true;
      } else if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else if (arg.startsWith('--delivery-root=')) {
        deliveryRoot = arg.substring('--delivery-root='.length).trim();
      } else if (arg.startsWith('--manifest=')) {
        manifestPath = arg.substring('--manifest='.length).trim();
      } else if (arg.startsWith('--output-manifest=')) {
        outputManifestPath = arg.substring('--output-manifest='.length).trim();
      } else if (arg.startsWith('--source-label=')) {
        sourceLabel = arg.substring('--source-label='.length).trim();
      } else if (arg.startsWith('--revision=')) {
        revision = arg.substring('--revision='.length).trim();
      } else if (arg.startsWith('--target-bitrate=')) {
        targetBitrate = arg.substring('--target-bitrate='.length).trim();
      } else if (arg.startsWith('--target-sample-rate=')) {
        targetSampleRate = int.parse(
          arg.substring('--target-sample-rate='.length).trim(),
        );
      } else if (arg.startsWith('--ffmpeg=')) {
        ffmpegCommand = arg.substring('--ffmpeg='.length).trim();
      } else if (arg.startsWith('--report=')) {
        reportPath = arg.substring('--report='.length).trim();
      } else {
        stderr.writeln('Unknown argument: $arg');
        showHelp = true;
      }
    }

    if (deliveryRoot.isEmpty && !showHelp) {
      throw ArgumentError('--delivery-root is required.');
    }

    return _ImportConfig(
      deliveryRoot: deliveryRoot,
      manifestPath: manifestPath,
      outputManifestPath: outputManifestPath ?? manifestPath,
      sourceLabel: sourceLabel,
      revision: revision,
      targetBitrate: targetBitrate,
      targetSampleRate: targetSampleRate,
      ffmpegCommand: ffmpegCommand,
      reportPath: reportPath,
      dryRun: dryRun,
      force: force,
      showHelp: showHelp,
    );
  }
}

class _ManifestDocument {
  final Map<String, dynamic> root;
  final List<_ManifestItem> items;

  _ManifestDocument({
    required this.root,
    required this.items,
  });

  factory _ManifestDocument.fromFile(File file) {
    final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final rawItems = root['items'] as List<dynamic>? ?? const <dynamic>[];
    final items = rawItems
        .map((item) => _ManifestItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return _ManifestDocument(root: root, items: items);
  }

  void upsertItem(_ManifestItem item) {
    final index = items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      items.add(item);
      return;
    }
    items[index] = item;
  }

  void backfillAiMetadata() {
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (item.voiceType == 'human') {
        continue;
      }
      items[index] = item.copyWith(
        logicalId: item.logicalId,
        voiceType: 'ai',
        source: item.source ?? 'azure',
        sourceFormat: item.sourceFormat ?? _extensionOf(item.fileName),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...root,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class _ManifestItem {
  final String id;
  final String lessonId;
  final String groupId;
  final String scope;
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
  final String logicalId;
  final String voiceType;
  final String? source;
  final String? sourceFileName;
  final String? sourceFormat;
  final String? revision;
  final String? importedAt;

  const _ManifestItem({
    required this.id,
    required this.lessonId,
    required this.groupId,
    required this.scope,
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
    required this.logicalId,
    required this.voiceType,
    this.speaker,
    this.source,
    this.sourceFileName,
    this.sourceFormat,
    this.revision,
    this.importedAt,
  });

  factory _ManifestItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    return _ManifestItem(
      id: id,
      lessonId: json['lessonId'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      scope: json['scope'] as String? ?? '',
      type: json['type'] as String? ?? '',
      sourceType: json['sourceType'] as String? ?? '',
      sourceId: json['sourceId'] as String? ?? '',
      textAr: json['textAr'] as String? ?? '',
      textPlain: json['textPlain'] as String? ?? '',
      textZh: json['textZh'] as String? ?? '',
      speed: json['speed'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      assetPath: json['assetPath'] as String? ?? '',
      relativeAssetPath: json['relativeAssetPath'] as String? ?? '',
      speaker: json['speaker'] as String?,
      logicalId: json['logicalId'] as String? ?? id,
      voiceType: json['voiceType'] as String? ?? 'ai',
      source: json['source'] as String?,
      sourceFileName: json['sourceFileName'] as String?,
      sourceFormat: json['sourceFormat'] as String?,
      revision: json['revision'] as String?,
      importedAt: json['importedAt'] as String?,
    );
  }

  _ManifestItem copyWith({
    String? id,
    String? fileName,
    String? assetPath,
    String? relativeAssetPath,
    String? logicalId,
    String? voiceType,
    String? source,
    String? sourceFileName,
    String? sourceFormat,
    String? revision,
    String? importedAt,
  }) {
    return _ManifestItem(
      id: id ?? this.id,
      lessonId: lessonId,
      groupId: groupId,
      scope: scope,
      type: type,
      sourceType: sourceType,
      sourceId: sourceId,
      textAr: textAr,
      textPlain: textPlain,
      textZh: textZh,
      speed: speed,
      fileName: fileName ?? this.fileName,
      assetPath: assetPath ?? this.assetPath,
      relativeAssetPath: relativeAssetPath ?? this.relativeAssetPath,
      speaker: speaker,
      logicalId: logicalId ?? this.logicalId,
      voiceType: voiceType ?? this.voiceType,
      source: source ?? this.source,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      sourceFormat: sourceFormat ?? this.sourceFormat,
      revision: revision ?? this.revision,
      importedAt: importedAt ?? this.importedAt,
    );
  }

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
      'logicalId': logicalId,
      'voiceType': voiceType,
      if (source != null) 'source': source,
      if (sourceFileName != null) 'sourceFileName': sourceFileName,
      if (sourceFormat != null) 'sourceFormat': sourceFormat,
      if (revision != null) 'revision': revision,
      if (importedAt != null) 'importedAt': importedAt,
      if (speaker != null) 'speaker': speaker,
    };
  }
}

class _DiscoveredDeliveryFile {
  final File file;
  final String deliveryRelativePath;
  final String extension;

  const _DiscoveredDeliveryFile({
    required this.file,
    required this.deliveryRelativePath,
    required this.extension,
  });

  String get fileName => deliveryRelativePath.replaceAll('\\', '/').split('/').last;

  String get lookupKey {
    final normalized = deliveryRelativePath.replaceAll('\\', '/');
    final separator = normalized.lastIndexOf('/');
    final dir = separator == -1 ? '' : normalized.substring(0, separator);
    final stem = _stemOf(separator == -1 ? normalized : normalized.substring(separator + 1));
    return '$dir|$stem';
  }
}

class _DiscoveredFiles {
  final Map<String, _DiscoveredDeliveryFile> files;
  final List<String> conflicts;

  const _DiscoveredFiles({
    required this.files,
    required this.conflicts,
  });
}

class _HumanTarget {
  final String fileName;
  final String relativeAssetPath;
  final String assetPath;

  const _HumanTarget({
    required this.fileName,
    required this.relativeAssetPath,
    required this.assetPath,
  });
}

class _ImportReport {
  final List<Map<String, dynamic>> imported;
  final List<Map<String, dynamic>> missing;
  final List<Map<String, dynamic>> skipped;

  const _ImportReport({
    required this.imported,
    required this.missing,
    required this.skipped,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'imported': imported,
      'missing': missing,
      'skipped': skipped,
    };
  }
}