import 'dart:convert';
import 'dart:io';

/// Exports a human-import handoff sheet for all QC-approved voiceover segments.
///
/// Primary source: recording_task_sheet_lessons_01_12.csv
/// Optional overlay: completed_segments_report.csv (from update_recording_status_from_intake.dart)
///
/// Filtering rules
/// ---------------
/// When no intake manifest is provided (task-sheet mode):
///   - Includes rows where production_status = RECORDING_READY
///   - Excludes REVISE_REQUIRED, NATIVE_REVIEW_REQUIRED, PLACEHOLDER_ONLY
///   - Excludes export_state = HOLD (held orthographic fragments / build artifacts)
///   - Sets qc_status = QC_PASS and import_status = READY_FOR_IMPORT
///
/// When an intake manifest is provided (intake mode):
///   - Joins on (lesson_id, segment_id, planned_audio_filename)
///   - Includes only rows where intake.qc_status = QC_PASS
///   - Sets approved_audio_filename from intake.received_filename

const _voiceoverRoot = 'docs/voiceover_production_lessons_1_16';
const _defaultTaskSheetPath =
    '$_voiceoverRoot/recording_task_sheet_lessons_01_12.csv';
const _defaultOutputDir = _voiceoverRoot;
const _defaultHandoffSheetFilename = 'human_import_handoff_sheet.csv';
const _defaultSummaryFilename = 'human_import_handoff_summary.md';

const _eligibleProductionStatuses = <String>{'RECORDING_READY'};
const _importReadyExportStates = <String>{'READY'};
const _excludedProductionStatuses = <String>{
  'REVISE_REQUIRED',
  'NATIVE_REVIEW_REQUIRED',
  'PLACEHOLDER_ONLY',
};

const _taskSheetColumns = <String>[
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'script_text_ar',
  'script_text_support',
  'delivery_note',
  'target_duration_sec',
  'repeatability',
  'native_review_flag',
  'export_state',
  'planned_audio_filename',
  'batch_id',
  'production_status',
  'row_kind',
  'asset_stem',
  'source_ref',
  'planned_audio_asset_path',
];

const _intakeRequiredColumns = <String>[
  'lesson_id',
  'segment_id',
  'planned_audio_filename',
  'received_filename',
  'qc_status',
  'final_resolution',
];

const _handoffColumns = <String>[
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

void main(List<String> args) {
  final config = _Config.fromArgs(args);
  if (config.showHelp) {
    _printUsage();
    return;
  }

  final taskSheetFile = File(config.taskSheetPath);
  if (!taskSheetFile.existsSync()) {
    stderr.writeln('Task sheet not found: ${config.taskSheetPath}');
    exitCode = 2;
    return;
  }

  final taskRows = _parseCsv(taskSheetFile.readAsStringSync());
  if (taskRows.isEmpty) {
    stderr.writeln('Task sheet contains no rows: ${config.taskSheetPath}');
    exitCode = 2;
    return;
  }
  _requireColumns(taskRows, _taskSheetColumns, config.taskSheetPath);

  // Load optional intake manifest (completed_segments_report.csv or similar).
  final intakeMap = <String, Map<String, String>>{};
  if (config.intakeManifestPath.isNotEmpty) {
    final intakeFile = File(config.intakeManifestPath);
    if (!intakeFile.existsSync()) {
      stderr.writeln('Intake manifest not found: ${config.intakeManifestPath}');
      exitCode = 2;
      return;
    }
    final intakeRows = _parseCsv(intakeFile.readAsStringSync());
    if (intakeRows.isNotEmpty) {
      _requireColumns(
          intakeRows, _intakeRequiredColumns, config.intakeManifestPath);
      for (final row in intakeRows) {
        final key = _rowKey(row);
        if (intakeMap.containsKey(key)) {
          stderr.writeln('Duplicate intake row: $key. Aborting.');
          exitCode = 2;
          return;
        }
        intakeMap[key] = row;
      }
    }
  }

  final useIntakeFilter = intakeMap.isNotEmpty;
  final handoffRows = <Map<String, String>>[];

  for (final row in taskRows) {
    final productionStatus = (row['production_status'] ?? '').trim();
    final exportState = (row['export_state'] ?? '').trim();

    if (useIntakeFilter) {
      // Intake-driven mode: include only rows present in intake with QC_PASS.
      final intakeRow = intakeMap[_rowKey(row)];
      if (intakeRow == null) continue;
      if ((intakeRow['qc_status'] ?? '').toUpperCase() != 'QC_PASS') continue;
      handoffRows.add(_buildHandoffRow(
        taskRow: row,
        approvedFilename: intakeRow['received_filename'] ?? '',
        qcStatus: 'QC_PASS',
        importStatus: 'READY_FOR_IMPORT',
        finalResolution: (intakeRow['final_resolution'] ?? '').isNotEmpty
            ? intakeRow['final_resolution']!
            : 'READY_FOR_IMPORT',
        notes: intakeRow['qc_notes'] ?? '',
      ));
    } else {
      // Task-sheet mode: derive eligibility from lesson-level review decisions.

      // Exclude lessons that failed review or are pending native check or are placeholder.
      if (_excludedProductionStatuses.contains(productionStatus)) continue;

      // Exclude lessons not in the approved set (unexpected production_status).
      if (!_eligibleProductionStatuses.contains(productionStatus)) continue;

      // Exclude held segments: orthographic fragments and build artifacts.
      if (exportState == 'HOLD') continue;

      final importStatus = _importReadyExportStates.contains(exportState)
          ? 'READY_FOR_IMPORT'
          : 'HOLD';

      handoffRows.add(_buildHandoffRow(
        taskRow: row,
        approvedFilename: '',
        qcStatus: 'QC_PASS',
        importStatus: importStatus,
        finalResolution: 'READY_FOR_IMPORT',
        notes: exportState == 'REVIEW'
            ? 'Segment flagged for review before export; hand off once cleared.'
            : '',
      ));
    }
  }

  final outputDir = Directory(config.outputDir)..createSync(recursive: true);
  final handoffSheetPath = '${outputDir.path}/${config.handoffSheetFilename}';
  final summaryPath = '${outputDir.path}/${config.summaryFilename}';

  if (!config.dryRun) {
    _writeCsv(handoffSheetPath, _handoffColumns, handoffRows);
  }

  // Compute summary counts.
  final batchCounts = <String, int>{};
  final lessonCounts = <String, int>{};
  final importStatusCounts = <String, int>{};
  int narrationCount = 0;
  int arabicCount = 0;

  for (final row in handoffRows) {
    final batch = row['batch_id'] ?? 'UNKNOWN';
    final lesson = row['lesson_id'] ?? 'UNKNOWN';
    final ist = row['import_status'] ?? 'UNKNOWN';
    final rowKind = (row['segment_id'] ?? '').contains('_AR_')
        ? 'ARABIC_ASSET'
        : 'NARRATION_SEGMENT';
    batchCounts[batch] = (batchCounts[batch] ?? 0) + 1;
    lessonCounts[lesson] = (lessonCounts[lesson] ?? 0) + 1;
    importStatusCounts[ist] = (importStatusCounts[ist] ?? 0) + 1;
    if (rowKind == 'ARABIC_ASSET') {
      arabicCount++;
    } else {
      narrationCount++;
    }
  }

  final summary = _buildSummaryMarkdown(
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    taskSheetPath: config.taskSheetPath,
    intakeManifestPath: config.intakeManifestPath,
    handoffSheetPath: handoffSheetPath,
    useIntakeFilter: useIntakeFilter,
    totalRows: handoffRows.length,
    narrationCount: narrationCount,
    arabicCount: arabicCount,
    batchCounts: batchCounts,
    lessonCounts: lessonCounts,
    importStatusCounts: importStatusCounts,
  );

  if (!config.dryRun) {
    File(summaryPath).writeAsStringSync(summary);
    stdout.writeln('Human import handoff written to ${outputDir.path}.');
    stdout.writeln('  Handoff sheet: $handoffSheetPath');
    stdout.writeln('  Summary:       $summaryPath');
  }

  stdout.writeln('  Handoff rows:  ${handoffRows.length} '
      '(narration=$narrationCount, arabic=$arabicCount)');
  stdout.writeln(
      '  Source mode:   ${useIntakeFilter ? 'intake manifest (QC_PASS filter)' : 'task sheet (lesson-level review filter)'}');

  if (config.dryRun) {
    stdout.writeln('\n--- DRY RUN: summary preview ---');
    stdout.writeln(summary);
  }
}

// ---------------------------------------------------------------------------
// Row builders
// ---------------------------------------------------------------------------

Map<String, String> _buildHandoffRow({
  required Map<String, String> taskRow,
  required String approvedFilename,
  required String qcStatus,
  required String importStatus,
  required String finalResolution,
  required String notes,
}) {
  return <String, String>{
    'lesson_id': taskRow['lesson_id'] ?? '',
    'lesson_title': taskRow['lesson_title'] ?? '',
    'segment_id': taskRow['segment_id'] ?? '',
    'segment_type': taskRow['segment_type'] ?? '',
    'approved_audio_filename': approvedFilename,
    'planned_audio_filename': taskRow['planned_audio_filename'] ?? '',
    'batch_id': taskRow['batch_id'] ?? '',
    'qc_status': qcStatus,
    'import_status': importStatus,
    'target_asset_path': taskRow['planned_audio_asset_path'] ?? '',
    'script_text_ar': taskRow['script_text_ar'] ?? '',
    'script_text_support': taskRow['script_text_support'] ?? '',
    'target_duration_sec': taskRow['target_duration_sec'] ?? '',
    'delivery_note': taskRow['delivery_note'] ?? '',
    'final_resolution': finalResolution,
    'notes': notes,
  };
}

// ---------------------------------------------------------------------------
// Summary markdown
// ---------------------------------------------------------------------------

String _buildSummaryMarkdown({
  required String generatedAt,
  required String taskSheetPath,
  required String intakeManifestPath,
  required String handoffSheetPath,
  required bool useIntakeFilter,
  required int totalRows,
  required int narrationCount,
  required int arabicCount,
  required Map<String, int> batchCounts,
  required Map<String, int> lessonCounts,
  required Map<String, int> importStatusCounts,
}) {
  final b = StringBuffer();
  b
    ..writeln('# Human Import Handoff Summary')
    ..writeln()
    ..writeln('- Generated at: `$generatedAt`')
    ..writeln('- Task sheet: `$taskSheetPath`')
    ..writeln(
        '- Intake manifest: `${intakeManifestPath.isEmpty ? 'not provided (task-sheet mode)' : intakeManifestPath}`')
    ..writeln(
        '- Filter mode: `${useIntakeFilter ? 'intake QC_PASS' : 'lesson-level review (RECORDING_READY + READY)'}`')
    ..writeln('- Output: `$handoffSheetPath`')
    ..writeln()
    ..writeln('## Totals')
    ..writeln()
    ..writeln('| Metric | Count |')
    ..writeln('| --- | --- |')
    ..writeln('| Total handoff rows | `$totalRows` |')
    ..writeln('| Narration segments | `$narrationCount` |')
    ..writeln('| Arabic audio assets | `$arabicCount` |')
    ..writeln()
    ..writeln('## Import Status Breakdown')
    ..writeln()
    ..writeln('| Import status | Count |')
    ..writeln('| --- | --- |');

  for (final status in <String>[
    'READY_FOR_IMPORT',
    'HOLD',
    'BLOCKED',
    'IMPORTED'
  ]) {
    b.writeln('| `$status` | `${importStatusCounts[status] ?? 0}` |');
  }

  b
    ..writeln()
    ..writeln('## Rows By Batch')
    ..writeln()
    ..writeln('| Batch | Count |')
    ..writeln('| --- | --- |');

  for (final entry in batchCounts.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key))) {
    b.writeln('| `${entry.key}` | `${entry.value}` |');
  }

  b
    ..writeln()
    ..writeln('## Rows By Lesson')
    ..writeln()
    ..writeln('| Lesson ID | Count |')
    ..writeln('| --- | --- |');

  for (final entry in lessonCounts.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key))) {
    b.writeln('| `${entry.key}` | `${entry.value}` |');
  }

  b
    ..writeln()
    ..writeln('## Exclusion Rules Applied')
    ..writeln()
    ..writeln('The following rows were excluded from this handoff:')
    ..writeln()
    ..writeln(
        '- Lessons with `production_status=REVISE_REQUIRED` (Lesson 03: the connected-shape lesson returns for revision first).')
    ..writeln(
        '- Lessons with `production_status=NATIVE_REVIEW_REQUIRED` (Lessons 04, 09, 10, 11, 12: native speaker review gating).')
    ..writeln(
        '- Lessons 13-16: placeholder only, not yet scripted or approved.')
    ..writeln(
        '- Segments with `export_state=HOLD`: held orthographic fragments and build artifacts not suitable for recording or TTS export.')
    ..writeln()
    ..writeln('## How To Update This Handoff')
    ..writeln()
    ..writeln(
        'Re-run the export tool to regenerate this file from the latest data:')
    ..writeln()
    ..writeln('```powershell')
    ..writeln('dart run tool/export_human_import_handoff.dart')
    ..writeln('```')
    ..writeln()
    ..writeln(
        'To apply actual QC results after recordings are returned and checked:')
    ..writeln()
    ..writeln('```powershell')
    ..writeln('dart run tool/export_human_import_handoff.dart \\')
    ..writeln(
        '  --intake-manifest=docs/voiceover_production_lessons_1_16/recording_intake_qc_outputs/completed_segments_report.csv')
    ..writeln('```');

  return b.toString();
}

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

class _Config {
  _Config({
    required this.taskSheetPath,
    required this.intakeManifestPath,
    required this.outputDir,
    required this.handoffSheetFilename,
    required this.summaryFilename,
    required this.dryRun,
    required this.showHelp,
  });

  factory _Config.fromArgs(List<String> rawArgs) {
    var taskSheetPath = _defaultTaskSheetPath;
    var intakeManifestPath = '';
    var outputDir = _defaultOutputDir;
    var handoffSheetFilename = _defaultHandoffSheetFilename;
    var summaryFilename = _defaultSummaryFilename;
    var dryRun = false;
    var showHelp = false;

    for (final arg in rawArgs) {
      if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else if (arg == '--dry-run') {
        dryRun = true;
      } else if (arg.startsWith('--task-sheet=')) {
        taskSheetPath = arg.substring('--task-sheet='.length).trim();
      } else if (arg.startsWith('--intake-manifest=')) {
        intakeManifestPath = arg.substring('--intake-manifest='.length).trim();
      } else if (arg.startsWith('--output-dir=')) {
        outputDir = arg.substring('--output-dir='.length).trim();
      } else if (arg.startsWith('--handoff-sheet=')) {
        handoffSheetFilename = arg.substring('--handoff-sheet='.length).trim();
      } else if (arg.startsWith('--summary=')) {
        summaryFilename = arg.substring('--summary='.length).trim();
      } else if (arg.trim().isNotEmpty) {
        throw FormatException('Unknown argument: $arg');
      }
    }

    return _Config(
      taskSheetPath: taskSheetPath,
      intakeManifestPath: intakeManifestPath,
      outputDir: outputDir,
      handoffSheetFilename: handoffSheetFilename,
      summaryFilename: summaryFilename,
      dryRun: dryRun,
      showHelp: showHelp,
    );
  }

  final String taskSheetPath;
  final String intakeManifestPath;
  final String outputDir;
  final String handoffSheetFilename;
  final String summaryFilename;
  final bool dryRun;
  final bool showHelp;
}

void _printUsage() {
  stdout.writeln('''
Human import handoff exporter for the lesson voiceover pipeline

Usage:
  dart run tool/export_human_import_handoff.dart [options]

Default inputs:
  --task-sheet=$_defaultTaskSheetPath
  --output-dir=$_defaultOutputDir

Options:
  --task-sheet=PATH          Recording task sheet CSV. Default: recording_task_sheet_lessons_01_12.csv
  --intake-manifest=PATH     Optional completed_segments_report.csv from update_recording_status_from_intake.dart.
                             When provided, switches to intake mode: only rows with qc_status=QC_PASS are included
                             and approved_audio_filename is set from received_filename.
                             When omitted, uses task-sheet mode: filters by production_status=RECORDING_READY
                             and export_state=READY, treating lesson-level review pass as approval.
  --output-dir=PATH          Output directory. Default: $_defaultOutputDir
  --handoff-sheet=FILENAME   Output handoff CSV filename. Default: $_defaultHandoffSheetFilename
  --summary=FILENAME         Output summary markdown filename. Default: $_defaultSummaryFilename
  --dry-run                  Print summary to stdout without writing files.
  --help                     Show this message.

Outputs:
  human_import_handoff_sheet.csv   — one row per QC-approved segment, ready for import operator
  human_import_handoff_summary.md  — counts, breakdowns, and exclusion audit

Import status values:
  READY_FOR_IMPORT  Segment is approved and ready for the human import step.
  HOLD              Segment is in an approved lesson but blocked at segment level (REVIEW export state).
  BLOCKED           (future use) Segment blocked by upstream dependency.
  IMPORTED          (set by import operator) Segment has been imported into the app asset tree.

Exclusion rules:
  - REVISE_REQUIRED, NATIVE_REVIEW_REQUIRED, PLACEHOLDER_ONLY lessons are excluded.
  - Segments with export_state=HOLD are excluded (orthographic fragments, build artifacts).
  - Placeholder lessons 13-16 are excluded entirely.
''');
}

// ---------------------------------------------------------------------------
// CSV helpers (consistent with existing tool convention)
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

String _rowKey(Map<String, String> row) =>
    '${row['lesson_id']}|${row['segment_id']}|${row['planned_audio_filename']}';

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
    ..writeAsStringSync(buf.toString(), encoding: _utf8NoBom);
}

/// Wraps a CSV cell value in double-quotes and escapes inner quotes.
String _csvCell(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

List<Map<String, String>> _parseCsv(String text) {
  final records = _parseCsvRecords(text);
  if (records.isEmpty) return [];
  final headers = records.first
      .map((cell) => cell.replaceFirst('\uFEFF', '').trim())
      .toList();
  return records
      .skip(1)
      .where((r) => r.any((c) => c.trim().isNotEmpty))
      .map((r) {
    final map = <String, String>{};
    for (var i = 0; i < headers.length; i++) {
      map[headers[i]] = i < r.length ? r[i] : '';
    }
    return map;
  }).toList();
}

List<List<String>> _parseCsvRecords(String text) {
  final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final records = <List<String>>[];
  var current = <String>[];
  final cell = StringBuffer();
  var inQuote = false;

  for (var i = 0; i < normalized.length; i++) {
    final ch = normalized[i];
    if (inQuote) {
      if (ch == '"') {
        if (i + 1 < normalized.length && normalized[i + 1] == '"') {
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
        if (current.any((c) => c.isNotEmpty)) {
          records.add(current);
        }
        current = [];
      } else {
        cell.write(ch);
      }
    }
  }
  if (cell.isNotEmpty || current.isNotEmpty) {
    current.add(cell.toString());
    if (current.any((c) => c.isNotEmpty)) {
      records.add(current);
    }
  }
  return records;
}

// UTF-8 without BOM encoder, consistent with existing tools in this repo.
final _utf8NoBom = _Utf8NoBomEncoding();

class _Utf8NoBomEncoding extends Encoding {
  @override
  Converter<String, List<int>> get encoder => const Utf8Codec().encoder;
  @override
  Converter<List<int>, String> get decoder => const Utf8Codec().decoder;
  @override
  String get name => 'utf-8';
}
