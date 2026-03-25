import 'dart:convert';
import 'dart:io';

/// Executes the final human-audio import step for V2 lesson voiceover segments.
///
/// Driven by the human_import_handoff_sheet.csv produced by
/// export_human_import_handoff.dart.  All matching, path resolution, and
/// manifest registration is based on that sheet — not on audio_manifest.json.
///
/// Matching rule
/// -------------
/// For each READY_FOR_IMPORT row in the handoff sheet:
///   stem = planned_audio_filename without extension
///   The tool searches under --delivery-root for any file whose stem matches.
///   Supported extensions: wav, m4a, mp3, aac (wav > m4a > mp3 > aac by
///   preference when multiple formats exist for the same stem).
///
/// Target path convention
/// ----------------------
/// The target_asset_path column already contains the canonical relative path,
/// e.g. lesson_01/voiceover/l01_ord_001_normal.mp3
/// The tool writes to:
///   assets/audio/<target_asset_path>
/// with a human-variant suffix when --revision is supplied, i.e.:
///   assets/audio/lesson_01/voiceover/l01_ord_001_normal__human__20260321.mp3
///
/// Manifest
/// --------
/// Writes or updates assets/data/audio_manifest_v2_voiceover.json with one
/// entry per imported segment.  This file is separate from audio_manifest.json
/// (the V1 vocabulary manifest) so the two asset namespaces never collide.
///
/// Outputs
/// -------
///   build/audio/voiceover_import_summary.md
///   build/audio/voiceover_import_conflicts_report.csv
///   assets/data/audio_manifest_v2_voiceover.json   (created or updated)
///   <target asset files>                            (dry-run: skipped)

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _defaultHandoffSheetPath =
    'docs/voiceover_production_lessons_1_16/human_import_handoff_sheet.csv';
const _defaultVoiceoverManifestPath =
    'assets/data/audio_manifest_v2_voiceover.json';
const _defaultSummaryPath = 'build/audio/voiceover_import_summary.md';
const _defaultConflictsReportPath =
    'build/audio/voiceover_import_conflicts_report.csv';
const _defaultAssetRoot = 'assets/audio';

const _supportedExtensions = <String>['wav', 'm4a', 'mp3', 'aac'];
const _preferredExtensionOrder = <String>['wav', 'm4a', 'mp3', 'aac'];

const _handoffRequiredColumns = <String>[
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'approved_audio_filename',
  'planned_audio_filename',
  'batch_id',
  'qc_status',
  'import_status',
  'target_asset_path',
  'script_text_ar',
  'script_text_support',
  'target_duration_sec',
  'delivery_note',
  'final_resolution',
];

const _conflicsColumns = <String>[
  'lesson_id',
  'lesson_title',
  'segment_id',
  'planned_audio_filename',
  'target_asset_path',
  'batch_id',
  'conflict_type',
  'conflict_detail',
];

const _updatedHandoffColumns = <String>[
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'approved_audio_filename',
  'planned_audio_filename',
  'batch_id',
  'qc_status',
  'import_status',
  'target_asset_path',
  'script_text_ar',
  'script_text_support',
  'target_duration_sec',
  'delivery_note',
  'final_resolution',
  'notes',
];

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

Future<void> main(List<String> args) async {
  final config = _Config.fromArgs(args);
  if (config.showHelp) {
    _printUsage();
    return;
  }

  // 1. Load handoff sheet.
  final handoffFile = File(config.handoffSheetPath);
  if (!handoffFile.existsSync()) {
    stderr.writeln('Handoff sheet not found: ${config.handoffSheetPath}');
    exitCode = 2;
    return;
  }
  final allHandoffRows = _parseCsv(handoffFile.readAsStringSync());
  if (allHandoffRows.isEmpty) {
    stderr.writeln('Handoff sheet is empty: ${config.handoffSheetPath}');
    exitCode = 2;
    return;
  }
  _requireColumns(
      allHandoffRows, _handoffRequiredColumns, config.handoffSheetPath);

  // 2. Filter: only READY_FOR_IMPORT.
  final eligibleRows = allHandoffRows
      .where(
          (r) => (r['import_status'] ?? '').toUpperCase() == 'READY_FOR_IMPORT')
      .toList();

  final heldRows = allHandoffRows
      .where((r) =>
          (r['import_status'] ?? '').toUpperCase() != 'READY_FOR_IMPORT' &&
          (r['import_status'] ?? '').toUpperCase() != 'IMPORTED')
      .toList();

  final alreadyImportedRows = allHandoffRows
      .where((r) => (r['import_status'] ?? '').toUpperCase() == 'IMPORTED')
      .toList();

  stdout.writeln('Handoff sheet loaded: ${config.handoffSheetPath}');
  stdout.writeln(
      '  Total rows: ${allHandoffRows.length}  |  READY_FOR_IMPORT: ${eligibleRows.length}  |  HOLD/BLOCKED: ${heldRows.length}  |  Already imported: ${alreadyImportedRows.length}');

  // 3. Discover delivery files (if delivery root is given).
  final discoveredByStem = <String, _DeliveryFile>{};
  final stemConflicts = <String, List<String>>{};

  if (config.deliveryRoot.isNotEmpty) {
    final deliveryDir = Directory(config.deliveryRoot);
    if (!deliveryDir.existsSync()) {
      stderr.writeln('Delivery root not found: ${config.deliveryRoot}');
      exitCode = 2;
      return;
    }
    _discoverFiles(
      deliveryDir,
      byStem: discoveredByStem,
      conflicts: stemConflicts,
    );
    stdout.writeln(
        '  Delivery files discovered: ${discoveredByStem.length}  |  stem conflicts: ${stemConflicts.length}');
  } else {
    stdout.writeln(
        '  No --delivery-root provided. Running in source-check mode only (no file copy will occur).');
  }

  // 4. Load or create voiceover manifest.
  final voiceoverManifest = _loadOrCreateVoiceoverManifest(
    config.voiceoverManifestPath,
  );

  // 5. Process each eligible row.
  final importedRows = <Map<String, String>>[];
  final conflictRows = <Map<String, String>>[];
  final skippedRows = <Map<String, String>>[];
  final updatedHandoffRows = List<Map<String, String>>.from(allHandoffRows);

  final ffmpegNeeded = discoveredByStem.values.any(
    (f) => f.extension != 'mp3',
  );
  if (ffmpegNeeded && !config.dryRun && config.deliveryRoot.isNotEmpty) {
    final ffmpegOk = await _checkFfmpeg(config.ffmpegCommand);
    if (!ffmpegOk) {
      stderr.writeln('ffmpeg not found at `${config.ffmpegCommand}`. '
          'Required for non-mp3 delivery files. '
          'Install ffmpeg or pass --ffmpeg=<path>.');
      exitCode = 3;
      return;
    }
  }

  for (final row in eligibleRows) {
    final plannedFilename = row['planned_audio_filename'] ?? '';
    final stem = _stemOf(plannedFilename);
    final targetRelPath = (row['target_asset_path'] ?? '').trim();
    final lessonId = row['lesson_id'] ?? '';
    final segmentId = row['segment_id'] ?? '';

    if (stem.isEmpty || targetRelPath.isEmpty) {
      _addConflict(
        conflictRows,
        row: row,
        conflictType: 'BAD_ROW',
        detail: 'planned_audio_filename or target_asset_path is blank.',
      );
      continue;
    }

    // Resolve human-variant target path.
    final humanTargetRelPath = config.revision.isNotEmpty
        ? _insertHumanSuffix(targetRelPath, config.revision)
        : targetRelPath;
    final humanTargetAssetPath = '${config.assetRoot}/$humanTargetRelPath';
    final humanTargetFile = File(humanTargetAssetPath);

    // Check for duplicate (already imported this exact revision).
    final manifestKey = _manifestKey(lessonId, segmentId, humanTargetRelPath);
    final existingEntry = voiceoverManifest[manifestKey];
    if (existingEntry != null && !config.force) {
      skippedRows.add({...row, 'skip_reason': 'already-in-manifest'});
      continue;
    }

    // Resolve source delivery file.
    if (config.deliveryRoot.isEmpty) {
      // No delivery root: log as SOURCE_NOT_SET.
      _addConflict(
        conflictRows,
        row: row,
        conflictType: 'SOURCE_NOT_SET',
        detail: 'No --delivery-root provided. File cannot be resolved.',
      );
      continue;
    }

    final deliveryFile = discoveredByStem[stem];
    if (deliveryFile == null) {
      _addConflict(
        conflictRows,
        row: row,
        conflictType: 'SOURCE_NOT_FOUND',
        detail:
            'No delivery file found for stem "$stem" under ${config.deliveryRoot}.',
      );
      continue;
    }

    // Check stem conflicts.
    final conflictList = stemConflicts[stem];
    if (conflictList != null && conflictList.isNotEmpty) {
      _addConflict(
        conflictRows,
        row: row,
        conflictType: 'STEM_CONFLICT',
        detail:
            'Multiple files for stem "$stem"; kept: ${deliveryFile.file.path}. Losers: ${conflictList.join('; ')}',
      );
      // Non-fatal: proceed with the preferred file.
    }

    // Import or dry-run.
    if (!config.dryRun) {
      try {
        humanTargetFile.parent.createSync(recursive: true);
        await _materialize(
          source: deliveryFile.file,
          target: humanTargetFile,
          sourceExt: deliveryFile.extension,
          ffmpegCommand: config.ffmpegCommand,
          targetBitrate: config.targetBitrate,
          targetSampleRate: config.targetSampleRate,
        );
      } catch (e) {
        _addConflict(
          conflictRows,
          row: row,
          conflictType: 'COPY_FAILED',
          detail: e.toString(),
        );
        continue;
      }
    }

    // Register in voiceover manifest.
    final manifestEntry = _buildManifestEntry(
      row: row,
      humanRelPath: humanTargetRelPath,
      humanAssetPath: humanTargetAssetPath,
      sourceFile: deliveryFile.file.path,
      sourceExt: deliveryFile.extension,
      revision: config.revision,
      sourceLabel: config.sourceLabel,
    );
    voiceoverManifest[manifestKey] = manifestEntry;

    importedRows.add(row);

    // Update handoff row import_status.
    final handoffIdx = updatedHandoffRows.indexWhere(
        (r) => r['segment_id'] == segmentId && r['lesson_id'] == lessonId);
    if (handoffIdx != -1) {
      updatedHandoffRows[handoffIdx] = {
        ...updatedHandoffRows[handoffIdx],
        'import_status': 'IMPORTED',
        'approved_audio_filename': deliveryFile.file.path.contains('/')
            ? deliveryFile.file.path.split('/').last
            : deliveryFile.file.path.split('\\').last,
      };
    }
  }

  // 6. Write outputs.
  Directory('build/audio').createSync(recursive: true);

  // Conflicts report.
  _writeCsv(config.conflictsReportPath, _conflicsColumns, conflictRows);
  stdout.writeln(
      '  Conflicts report: ${config.conflictsReportPath} (${conflictRows.length} rows)');

  // Summary markdown.
  final summary = _buildSummary(
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    handoffSheetPath: config.handoffSheetPath,
    deliveryRoot: config.deliveryRoot,
    voiceoverManifestPath: config.voiceoverManifestPath,
    revision: config.revision,
    dryRun: config.dryRun,
    totalEligible: eligibleRows.length,
    importedCount: importedRows.length,
    skippedCount: skippedRows.length,
    conflictCount: conflictRows.length,
    heldCount: heldRows.length,
    alreadyImportedCount: alreadyImportedRows.length,
    conflictRows: conflictRows,
  );
  File(config.summaryPath)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(summary);
  stdout.writeln('  Import summary: ${config.summaryPath}');

  if (!config.dryRun) {
    // Updated voiceover manifest.
    final manifestOut = File(config.voiceoverManifestPath);
    manifestOut.parent.createSync(recursive: true);
    manifestOut.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(_serializeManifest(
        voiceoverManifest,
        revision: config.revision,
        handoffSheetPath: config.handoffSheetPath,
      )),
    );
    stdout.writeln('  Voiceover manifest: ${config.voiceoverManifestPath}');

    // Updated handoff sheet with IMPORTED rows reflected.
    if (importedRows.isNotEmpty && config.updateHandoffSheet) {
      _writeCsv(
        config.handoffSheetPath,
        _updatedHandoffColumns,
        updatedHandoffRows,
      );
      stdout.writeln('  Handoff sheet updated: ${config.handoffSheetPath}');
    }
  }

  stdout.writeln(config.dryRun
      ? '\nDry run complete. No files were written.'
      : '\nImport complete.');
  stdout.writeln('  Imported:  ${importedRows.length}');
  stdout.writeln('  Skipped:   ${skippedRows.length} (already in manifest)');
  stdout.writeln('  Conflicts: ${conflictRows.length}');
  stdout.writeln('  Held/blocked (not processed): ${heldRows.length}');

  if (conflictRows.isNotEmpty) {
    exitCode = 1;
  }
}

// ---------------------------------------------------------------------------
// File discovery
// ---------------------------------------------------------------------------

void _discoverFiles(
  Directory root, {
  required Map<String, _DeliveryFile> byStem,
  required Map<String, List<String>> conflicts,
}) {
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    final ext = _extOf(entity.path);
    if (!_supportedExtensions.contains(ext)) continue;
    final stem = _stemOf(entity.path.replaceAll('\\', '/').split('/').last);
    final candidate = _DeliveryFile(file: entity, extension: ext);
    final existing = byStem[stem];
    if (existing == null) {
      byStem[stem] = candidate;
    } else {
      final winner = _preferFile(existing, candidate);
      final loser = identical(winner, existing) ? candidate : existing;
      byStem[stem] = winner;
      conflicts.putIfAbsent(stem, () => []).add(loser.file.path);
    }
  }
}

_DeliveryFile _preferFile(_DeliveryFile a, _DeliveryFile b) {
  final ai = _preferredExtensionOrder.indexOf(a.extension);
  final bi = _preferredExtensionOrder.indexOf(b.extension);
  if (ai != bi) return ai < bi ? a : b;
  return a.file.lastModifiedSync().isAfter(b.file.lastModifiedSync()) ? a : b;
}

// ---------------------------------------------------------------------------
// Asset materialization
// ---------------------------------------------------------------------------

String _insertHumanSuffix(String relPath, String revision) {
  final slash = relPath.lastIndexOf('/');
  final dir = slash == -1 ? '' : relPath.substring(0, slash);
  final filename = slash == -1 ? relPath : relPath.substring(slash + 1);
  final stem = _stemOf(filename);
  final humanName = '${stem}__human__${_slugify(revision)}.mp3';
  return dir.isEmpty ? humanName : '$dir/$humanName';
}

Future<void> _materialize({
  required File source,
  required File target,
  required String sourceExt,
  required String ffmpegCommand,
  required String targetBitrate,
  required int targetSampleRate,
}) async {
  if (sourceExt == 'mp3') {
    source.copySync(target.path);
    return;
  }
  final result = await Process.run(ffmpegCommand, [
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
  ]);
  if (result.exitCode != 0) {
    throw ProcessException(
      ffmpegCommand,
      ['-i', source.path, target.path],
      'ffmpeg failed (exit ${result.exitCode}): ${result.stderr}',
      result.exitCode,
    );
  }
}

Future<bool> _checkFfmpeg(String command) async {
  try {
    final r = await Process.run(command, ['-version']);
    return r.exitCode == 0;
  } catch (_) {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Manifest helpers
// ---------------------------------------------------------------------------

Map<String, Map<String, dynamic>> _loadOrCreateVoiceoverManifest(String path) {
  final file = File(path);
  if (!file.existsSync()) return {};
  try {
    final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final items = (root['items'] as List<dynamic>? ?? []);
    return {
      for (final item in items.cast<Map<String, dynamic>>())
        (_manifestKeyFromEntry(item)): item,
    };
  } catch (_) {
    return {};
  }
}

String _manifestKey(String lessonId, String segmentId, String relPath) =>
    '$lessonId|$segmentId|$relPath';

String _manifestKeyFromEntry(Map<String, dynamic> entry) =>
    '${entry['lessonId'] ?? ''}|${entry['segmentId'] ?? ''}|${entry['relativeAssetPath'] ?? ''}';

Map<String, dynamic> _buildManifestEntry({
  required Map<String, String> row,
  required String humanRelPath,
  required String humanAssetPath,
  required String sourceFile,
  required String sourceExt,
  required String revision,
  required String sourceLabel,
}) {
  final stem = _stemOf(humanRelPath.split('/').last);
  return {
    'id': stem,
    'lessonId': row['lesson_id'] ?? '',
    'lessonTitle': row['lesson_title'] ?? '',
    'segmentId': row['segment_id'] ?? '',
    'segmentType': row['segment_type'] ?? '',
    'batchId': row['batch_id'] ?? '',
    'fileName': humanRelPath.split('/').last,
    'assetPath': humanAssetPath,
    'relativeAssetPath': humanRelPath,
    'scriptTextAr': row['script_text_ar'] ?? '',
    'scriptTextSupport': row['script_text_support'] ?? '',
    'targetDurationSec': _parseInt(row['target_duration_sec']),
    'voiceType': 'human',
    'source': sourceLabel,
    'sourceFileName': sourceFile.replaceAll('\\', '/').split('/').last,
    'sourceFormat': sourceExt,
    if (revision.isNotEmpty) 'revision': revision,
    'importedAt': DateTime.now().toUtc().toIso8601String(),
    'qcStatus': row['qc_status'] ?? '',
    'finalResolution': row['final_resolution'] ?? '',
  };
}

Map<String, dynamic> _serializeManifest(
  Map<String, Map<String, dynamic>> entries, {
  required String revision,
  required String handoffSheetPath,
}) {
  return {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'schema': 'v2-voiceover-manifest',
    'revision': revision,
    'handoffSheet': handoffSheetPath,
    'itemCount': entries.length,
    'items': entries.values.toList(),
  };
}

// ---------------------------------------------------------------------------
// Conflict helpers
// ---------------------------------------------------------------------------

void _addConflict(
  List<Map<String, String>> conflictRows, {
  required Map<String, String> row,
  required String conflictType,
  required String detail,
}) {
  conflictRows.add({
    'lesson_id': row['lesson_id'] ?? '',
    'lesson_title': row['lesson_title'] ?? '',
    'segment_id': row['segment_id'] ?? '',
    'planned_audio_filename': row['planned_audio_filename'] ?? '',
    'target_asset_path': row['target_asset_path'] ?? '',
    'batch_id': row['batch_id'] ?? '',
    'conflict_type': conflictType,
    'conflict_detail': detail,
  });
}

// ---------------------------------------------------------------------------
// Summary markdown
// ---------------------------------------------------------------------------

String _buildSummary({
  required String generatedAt,
  required String handoffSheetPath,
  required String deliveryRoot,
  required String voiceoverManifestPath,
  required String revision,
  required bool dryRun,
  required int totalEligible,
  required int importedCount,
  required int skippedCount,
  required int conflictCount,
  required int heldCount,
  required int alreadyImportedCount,
  required List<Map<String, String>> conflictRows,
}) {
  final b = StringBuffer();
  b
    ..writeln('# Voiceover Import Summary')
    ..writeln()
    ..writeln('- Generated at: `$generatedAt`')
    ..writeln('- Handoff sheet: `$handoffSheetPath`')
    ..writeln(
        '- Delivery root: `${deliveryRoot.isEmpty ? 'not provided' : deliveryRoot}`')
    ..writeln('- Voiceover manifest: `$voiceoverManifestPath`')
    ..writeln(
        '- Revision: `${revision.isEmpty ? 'not set (files written at planned paths)' : revision}`')
    ..writeln('- Mode: `${dryRun ? 'DRY RUN — no files written' : 'LIVE'}`')
    ..writeln()
    ..writeln('## Counts')
    ..writeln()
    ..writeln('| Metric | Count |')
    ..writeln('| --- | --- |')
    ..writeln('| READY_FOR_IMPORT rows in handoff sheet | `$totalEligible` |')
    ..writeln('| Imported this run | `$importedCount` |')
    ..writeln('| Skipped (already in manifest) | `$skippedCount` |')
    ..writeln('| Conflicts / source not found | `$conflictCount` |')
    ..writeln('| Held / blocked (not eligible) | `$heldCount` |')
    ..writeln('| Already marked IMPORTED in sheet | `$alreadyImportedCount` |');

  if (conflictCount > 0) {
    b
      ..writeln()
      ..writeln('## Conflict Breakdown')
      ..writeln()
      ..writeln('| Type | Count |')
      ..writeln('| --- | --- |');

    final typeCounts = <String, int>{};
    for (final row in conflictRows) {
      final t = row['conflict_type'] ?? 'UNKNOWN';
      typeCounts[t] = (typeCounts[t] ?? 0) + 1;
    }
    for (final entry in typeCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      b.writeln('| `${entry.key}` | `${entry.value}` |');
    }

    b
      ..writeln()
      ..writeln(
          'Full details: `build/audio/voiceover_import_conflicts_report.csv`');

    if (typeCounts.containsKey('SOURCE_NOT_FOUND') ||
        typeCounts.containsKey('SOURCE_NOT_SET')) {
      b
        ..writeln()
        ..writeln('### Next Step For Missing Sources')
        ..writeln()
        ..writeln(
            'The recorder has not yet delivered files for these segments. '
            'Once recordings are received, place them in the delivery folder and re-run:')
        ..writeln()
        ..writeln('```powershell')
        ..writeln('dart run tool/execute_human_import.dart \\')
        ..writeln('  --delivery-root=<path_to_delivered_recordings> \\')
        ..writeln(
            '  --revision=${revision.isEmpty ? '<revision-tag>' : revision}')
        ..writeln('```');
    }
  } else if (importedCount > 0) {
    b
      ..writeln()
      ..writeln('All eligible segments imported successfully. No conflicts.');
  }

  b
    ..writeln()
    ..writeln('## What Was Excluded')
    ..writeln()
    ..writeln(
        'The following categories were intentionally excluded from this import run:')
    ..writeln()
    ..writeln('| Exclusion reason | Count |')
    ..writeln('| --- | --- |')
    ..writeln('| `HOLD` / `BLOCKED` rows in handoff sheet | `$heldCount` |')
    ..writeln('| Already marked `IMPORTED` | `$alreadyImportedCount` |')
    ..writeln()
    ..writeln(
        'HOLD/BLOCKED rows include: Lesson 03 (REVISE_REQUIRED), Lessons 04/09/10/11/12 '
        '(NATIVE_REVIEW_REQUIRED), Lessons 13–16 (PLACEHOLDER_ONLY), and any segment with '
        '`export_state=HOLD` (orthographic fragments / build artifacts).')
    ..writeln()
    ..writeln('## How To Re-run')
    ..writeln()
    ..writeln('Dry run (validate only, no writes):')
    ..writeln()
    ..writeln('```powershell')
    ..writeln('dart run tool/execute_human_import.dart \\')
    ..writeln('  --delivery-root=<path> \\')
    ..writeln('  --revision=<tag> \\')
    ..writeln('  --dry-run')
    ..writeln('```')
    ..writeln()
    ..writeln('Live run:')
    ..writeln()
    ..writeln('```powershell')
    ..writeln('dart run tool/execute_human_import.dart \\')
    ..writeln('  --delivery-root=<path> \\')
    ..writeln('  --revision=<tag>')
    ..writeln('```')
    ..writeln()
    ..writeln('Force re-import of already-registered segments:')
    ..writeln()
    ..writeln('```powershell')
    ..writeln('dart run tool/execute_human_import.dart \\')
    ..writeln('  --delivery-root=<path> \\')
    ..writeln('  --revision=<tag> \\')
    ..writeln('  --force')
    ..writeln('```');

  return b.toString();
}

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

class _Config {
  const _Config({
    required this.handoffSheetPath,
    required this.deliveryRoot,
    required this.voiceoverManifestPath,
    required this.summaryPath,
    required this.conflictsReportPath,
    required this.assetRoot,
    required this.revision,
    required this.sourceLabel,
    required this.targetBitrate,
    required this.targetSampleRate,
    required this.ffmpegCommand,
    required this.dryRun,
    required this.force,
    required this.updateHandoffSheet,
    required this.showHelp,
  });

  factory _Config.fromArgs(List<String> rawArgs) {
    var handoffSheetPath = _defaultHandoffSheetPath;
    var deliveryRoot = '';
    var voiceoverManifestPath = _defaultVoiceoverManifestPath;
    var summaryPath = _defaultSummaryPath;
    var conflictsReportPath = _defaultConflictsReportPath;
    var assetRoot = _defaultAssetRoot;
    var revision = DateTime.now()
        .toUtc()
        .toIso8601String()
        .substring(0, 10)
        .replaceAll('-', '');
    var sourceLabel = 'expert';
    var targetBitrate = '48k';
    var targetSampleRate = 24000;
    var ffmpegCommand = 'ffmpeg';
    var dryRun = false;
    var force = false;
    var updateHandoffSheet = true;
    var showHelp = false;

    for (final arg in rawArgs) {
      if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg == '--force') {
        force = true;
      } else if (arg == '--no-update-handoff') {
        updateHandoffSheet = false;
      } else if (arg.startsWith('--handoff-sheet=')) {
        handoffSheetPath = arg.substring('--handoff-sheet='.length).trim();
      } else if (arg.startsWith('--delivery-root=')) {
        deliveryRoot = arg.substring('--delivery-root='.length).trim();
      } else if (arg.startsWith('--voiceover-manifest=')) {
        voiceoverManifestPath =
            arg.substring('--voiceover-manifest='.length).trim();
      } else if (arg.startsWith('--summary=')) {
        summaryPath = arg.substring('--summary='.length).trim();
      } else if (arg.startsWith('--conflicts-report=')) {
        conflictsReportPath =
            arg.substring('--conflicts-report='.length).trim();
      } else if (arg.startsWith('--asset-root=')) {
        assetRoot = arg.substring('--asset-root='.length).trim();
      } else if (arg.startsWith('--revision=')) {
        revision = arg.substring('--revision='.length).trim();
      } else if (arg.startsWith('--source-label=')) {
        sourceLabel = arg.substring('--source-label='.length).trim();
      } else if (arg.startsWith('--target-bitrate=')) {
        targetBitrate = arg.substring('--target-bitrate='.length).trim();
      } else if (arg.startsWith('--target-sample-rate=')) {
        targetSampleRate = int.parse(
          arg.substring('--target-sample-rate='.length).trim(),
        );
      } else if (arg.startsWith('--ffmpeg=')) {
        ffmpegCommand = arg.substring('--ffmpeg='.length).trim();
      } else if (arg.trim().isNotEmpty) {
        throw FormatException('Unknown argument: $arg');
      }
    }

    return _Config(
      handoffSheetPath: handoffSheetPath,
      deliveryRoot: deliveryRoot,
      voiceoverManifestPath: voiceoverManifestPath,
      summaryPath: summaryPath,
      conflictsReportPath: conflictsReportPath,
      assetRoot: assetRoot,
      revision: revision,
      sourceLabel: sourceLabel,
      targetBitrate: targetBitrate,
      targetSampleRate: targetSampleRate,
      ffmpegCommand: ffmpegCommand,
      dryRun: dryRun,
      force: force,
      updateHandoffSheet: updateHandoffSheet,
      showHelp: showHelp,
    );
  }

  final String handoffSheetPath;
  final String deliveryRoot;
  final String voiceoverManifestPath;
  final String summaryPath;
  final String conflictsReportPath;
  final String assetRoot;
  final String revision;
  final String sourceLabel;
  final String targetBitrate;
  final int targetSampleRate;
  final String ffmpegCommand;
  final bool dryRun;
  final bool force;
  final bool updateHandoffSheet;
  final bool showHelp;
}

void _printUsage() {
  stdout.writeln('''
V2 voiceover human import executor

Reads the human_import_handoff_sheet.csv, resolves delivery files, copies or
transcodes them to the asset tree, and updates the voiceover manifest.

Usage:
  dart run tool/execute_human_import.dart [options]

Minimal invocations:
  # Validate only (no delivery root needed)
  dart run tool/execute_human_import.dart --dry-run

  # Full live import
  dart run tool/execute_human_import.dart \\
    --delivery-root=<path/to/delivered_recordings> \\
    --revision=20260321-batch-a

Default inputs:
  --handoff-sheet=$_defaultHandoffSheetPath
  --voiceover-manifest=$_defaultVoiceoverManifestPath
  --asset-root=$_defaultAssetRoot
  --summary=$_defaultSummaryPath
  --conflicts-report=$_defaultConflictsReportPath

Options:
  --handoff-sheet=PATH        Handoff sheet CSV. Default: human_import_handoff_sheet.csv
  --delivery-root=PATH        Folder containing delivered audio files. May be nested.
                              If omitted, all eligible rows report as SOURCE_NOT_SET.
  --voiceover-manifest=PATH   Voiceover manifest JSON to create or update.
  --asset-root=PATH           Root folder for app audio assets. Default: assets/audio
  --revision=TAG              Revision/batch tag for the human-variant suffix.
                              e.g. 20260321-batch-a → stem__human__20260321-batch-a.mp3
                              If blank, files are written at the planned target path (no suffix).
  --source-label=LABEL        Source label written to manifest. Default: expert
  --target-bitrate=K          FFmpeg bitrate for non-mp3 transcoding. Default: 48k
  --target-sample-rate=HZ     FFmpeg sample rate. Default: 24000
  --ffmpeg=CMD                FFmpeg executable. Default: ffmpeg (must be on PATH)
  --summary=PATH              Import summary markdown path.
  --conflicts-report=PATH     Conflict/missing CSV path.
  --dry-run                   Plan only; write summary and conflicts but no audio or manifest.
  --force                     Re-import segments already registered in the manifest.
  --no-update-handoff         Do not update import_status in the handoff sheet after import.
  --help                      Show this message.

Conflict types in the conflicts report:
  SOURCE_NOT_SET      No --delivery-root provided.
  SOURCE_NOT_FOUND    Delivery root given but no matching file found for the stem.
  STEM_CONFLICT       Multiple delivery files resolve to the same stem; preferred one used.
  BAD_ROW             Row has blank planned_audio_filename or target_asset_path.
  COPY_FAILED         File copy or ffmpeg transcode failed.

Exit codes:
  0   Success (no conflicts, or only STEM_CONFLICT non-fatals).
  1   One or more fatal conflicts (SOURCE_NOT_FOUND, COPY_FAILED, BAD_ROW).
  2   Configuration or input file error.
  3   ffmpeg not found but required.
''');
}

// ---------------------------------------------------------------------------
// CSV helpers (consistent with rest of pipeline)
// ---------------------------------------------------------------------------

void _requireColumns(
  List<Map<String, String>> rows,
  List<String> required,
  String path,
) {
  if (rows.isEmpty) return;
  final missing = required.where((c) => !rows.first.containsKey(c)).toList();
  if (missing.isNotEmpty) {
    throw FormatException('Missing columns in $path: ${missing.join(', ')}');
  }
}

void _writeCsv(
  String path,
  List<String> columns,
  List<Map<String, String>> rows,
) {
  final buf = StringBuffer();
  buf.writeln(columns.map(_csvCell).join(','));
  for (final row in rows) {
    buf.writeln(columns.map((c) => _csvCell(row[c] ?? '')).join(','));
  }
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(buf.toString());
}

String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

List<Map<String, String>> _parseCsv(String text) {
  final records = _parseCsvRecords(text);
  if (records.isEmpty) return [];
  final headers =
      records.first.map((c) => c.replaceFirst('\uFEFF', '').trim()).toList();
  return records.skip(1).where((r) => r.any((c) => c.trim().isNotEmpty)).map(
    (r) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        map[headers[i]] = i < r.length ? r[i] : '';
      }
      return map;
    },
  ).toList();
}

List<List<String>> _parseCsvRecords(String text) {
  final norm = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final records = <List<String>>[];
  var current = <String>[];
  final cell = StringBuffer();
  var inQuote = false;
  for (var i = 0; i < norm.length; i++) {
    final ch = norm[i];
    if (inQuote) {
      if (ch == '"') {
        if (i + 1 < norm.length && norm[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuote = false;
        }
      } else {
        cell.write(ch);
      }
    } else {
      if (ch == '"') {
        inQuote = true;
      } else if (ch == ',') {
        current.add(cell.toString());
        cell.clear();
      } else if (ch == '\n') {
        current.add(cell.toString());
        cell.clear();
        if (current.any((c) => c.isNotEmpty)) records.add(current);
        current = [];
      } else {
        cell.write(ch);
      }
    }
  }
  if (cell.isNotEmpty || current.isNotEmpty) {
    current.add(cell.toString());
    if (current.any((c) => c.isNotEmpty)) records.add(current);
  }
  return records;
}

// ---------------------------------------------------------------------------
// String helpers
// ---------------------------------------------------------------------------

String _stemOf(String fileName) {
  final dot = fileName.lastIndexOf('.');
  return dot == -1 ? fileName : fileName.substring(0, dot);
}

String _extOf(String path) {
  final name = path.replaceAll('\\', '/').split('/').last;
  final dot = name.lastIndexOf('.');
  if (dot == -1) return '';
  return name.substring(dot + 1).toLowerCase();
}

String _slugify(String value) {
  final t = value.trim().toLowerCase();
  return t
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

int _parseInt(String? s) {
  if (s == null || s.trim().isEmpty) return 0;
  return int.tryParse(s.trim()) ?? 0;
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _DeliveryFile {
  const _DeliveryFile({required this.file, required this.extension});
  final File file;
  final String extension;
}
