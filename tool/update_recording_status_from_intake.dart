import 'dart:convert';
import 'dart:io';

const _root = 'docs/voiceover_production_lessons_1_16';
const _defaultWorkpackRoot =
    '$_root/recorder_workpack_lessons_01_02_05_06_07_08';
const _defaultWorkpackManifestPath =
    '$_defaultWorkpackRoot/workpack_manifest.json';
const _defaultMasterChecklistPath =
    '$_defaultWorkpackRoot/recorder_master_checklist.csv';
const _defaultOutputDir = '$_root/recording_intake_qc_outputs';

const _masterChecklistColumns = <String>[
  'batch_id',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'row_kind',
  'planned_audio_filename',
  'planned_audio_asset_path',
  'target_duration_sec',
  'repeatability',
  'workflow_status',
  'delivery_note',
  'spoken_script',
  'script_text_ar',
  'script_text_support',
  'recorder_notes',
  'qc_notes',
];

const _seedManifestColumns = <String>[
  'batch_id',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'row_kind',
  'planned_audio_filename',
  'planned_audio_asset_path',
  'target_duration_sec',
  'repeatability',
  'delivery_note',
  'received_filename',
  'receive_status',
  'qc_status',
  'qc_notes',
  'retake_reason',
  'final_resolution',
];

const _updatedChecklistColumns = <String>[
  'batch_id',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'row_kind',
  'planned_audio_filename',
  'planned_audio_asset_path',
  'target_duration_sec',
  'repeatability',
  'workflow_status',
  'delivery_note',
  'spoken_script',
  'script_text_ar',
  'script_text_support',
  'recorder_notes',
  'qc_notes',
  'received_filename',
  'receive_status',
  'qc_status',
  'retake_reason',
  'final_resolution',
];

const _retakeQueueColumns = <String>[
  'batch_id',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'row_kind',
  'planned_audio_filename',
  'received_filename',
  'receive_status',
  'qc_status',
  'qc_notes',
  'retake_reason',
  'final_resolution',
  'delivery_note',
];

const _completedReportColumns = <String>[
  'batch_id',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'row_kind',
  'planned_audio_filename',
  'received_filename',
  'receive_status',
  'qc_status',
  'qc_notes',
  'retake_reason',
  'final_resolution',
  'planned_audio_asset_path',
];

const _receiveStatuses = <String>{
  'TO_RECORD',
  'RECEIVED',
  'MISSING',
};

const _qcStatuses = <String>{
  'TO_RECORD',
  'QC_PASS',
  'RETAKE_REQUIRED',
};

Future<void> main(List<String> args) async {
  final config = _Config.fromArgs(args);
  if (config.showHelp) {
    _printUsage();
    return;
  }

  final workpackManifestFile = File(config.workpackManifestPath);
  final masterChecklistFile = File(config.masterChecklistPath);
  if (!workpackManifestFile.existsSync()) {
    stderr.writeln('Workpack manifest does not exist: ${config.workpackManifestPath}');
    exitCode = 2;
    return;
  }
  if (!masterChecklistFile.existsSync()) {
    stderr.writeln('Master checklist does not exist: ${config.masterChecklistPath}');
    exitCode = 2;
    return;
  }

  final workpackManifest =
      jsonDecode(workpackManifestFile.readAsStringSync()) as Map<String, dynamic>;
  final baseRows = _parseCsv(masterChecklistFile.readAsStringSync());
  _requireColumns(baseRows, _masterChecklistColumns, config.masterChecklistPath);

  final expectedRowCount = (workpackManifest['row_count'] as num?)?.toInt();
  if (expectedRowCount != null && expectedRowCount != baseRows.length) {
    stderr.writeln(
      'Master checklist row count mismatch. Workpack manifest says '
      '$expectedRowCount rows but checklist has ${baseRows.length}.',
    );
    exitCode = 2;
    return;
  }

  final baseKeyMap = <String, Map<String, String>>{};
  for (final row in baseRows) {
    final key = _rowKey(row);
    if (baseKeyMap.containsKey(key)) {
      stderr.writeln('Duplicate checklist key detected: $key');
      exitCode = 2;
      return;
    }
    baseKeyMap[key] = row;
  }

  final outputDir = Directory(config.outputDir)..createSync(recursive: true);
  final seedRows = baseRows.map(_seedRowFromBase).toList();
  _writeCsv(
    '${outputDir.path}/recording_return_manifest_seed.csv',
    _seedManifestColumns,
    seedRows,
  );

  final intakeRows = <Map<String, String>>[];
  if (config.intakeManifestPath.isNotEmpty) {
    final intakeFile = File(config.intakeManifestPath);
    if (!intakeFile.existsSync()) {
      stderr.writeln('Intake manifest does not exist: ${config.intakeManifestPath}');
      exitCode = 2;
      return;
    }
    intakeRows.addAll(_parseCsv(intakeFile.readAsStringSync()));
    _requireColumns(intakeRows, _seedManifestColumns, config.intakeManifestPath);
  }

  final intakeMap = <String, Map<String, String>>{};
  for (final row in intakeRows) {
    final key = _rowKey(row);
    if (!baseKeyMap.containsKey(key)) {
      stderr.writeln(
        'Intake manifest row does not match the current workpack: $key',
      );
      exitCode = 2;
      return;
    }
    if (intakeMap.containsKey(key)) {
      stderr.writeln('Duplicate intake row detected: $key');
      exitCode = 2;
      return;
    }
    intakeMap[key] = row;
  }

  final mergedRows = <Map<String, String>>[];
  for (final baseRow in baseRows) {
    final seedRow = _seedRowFromBase(baseRow);
    final intakeRow = intakeMap[_rowKey(baseRow)];
    final mergedRow = <String, String>{
      for (final entry in seedRow.entries) entry.key: entry.value,
    };
    if (intakeRow != null) {
      for (final column in _seedManifestColumns) {
        final incoming = (intakeRow[column] ?? '').trim();
        if (incoming.isNotEmpty) {
          mergedRow[column] = incoming;
        }
      }
    }
    _normalizeAndValidateStatusRow(mergedRow);
    mergedRows.add(mergedRow);
  }

  final updatedChecklistRows = <Map<String, String>>[];
  final retakeRows = <Map<String, String>>[];
  final completedRows = <Map<String, String>>[];
  final workflowCounts = <String, int>{};
  final receiveCounts = <String, int>{};
  final qcCounts = <String, int>{};

  for (final mergedRow in mergedRows) {
    final baseRow = baseKeyMap[_rowKey(mergedRow)]!;
    final workflowStatus = _workflowStatusFromMerged(mergedRow);
    workflowCounts[workflowStatus] = (workflowCounts[workflowStatus] ?? 0) + 1;
    final receiveStatus = mergedRow['receive_status'] ?? 'TO_RECORD';
    final qcStatus = mergedRow['qc_status'] ?? 'TO_RECORD';
    receiveCounts[receiveStatus] = (receiveCounts[receiveStatus] ?? 0) + 1;
    qcCounts[qcStatus] = (qcCounts[qcStatus] ?? 0) + 1;

    updatedChecklistRows.add(
      _updatedChecklistRow(
        baseRow: baseRow,
        mergedRow: mergedRow,
        workflowStatus: workflowStatus,
      ),
    );

    if (receiveStatus == 'MISSING' || qcStatus == 'RETAKE_REQUIRED') {
      retakeRows.add(_retakeQueueRow(mergedRow));
    }
    if (qcStatus == 'QC_PASS') {
      completedRows.add(_completedReportRow(mergedRow));
    }
  }

  _writeCsv(
    '${outputDir.path}/recorder_master_checklist_updated.csv',
    _updatedChecklistColumns,
    updatedChecklistRows,
  );
  _writeCsv(
    '${outputDir.path}/retake_queue.csv',
    _retakeQueueColumns,
    retakeRows,
  );
  _writeCsv(
    '${outputDir.path}/completed_segments_report.csv',
    _completedReportColumns,
    completedRows,
  );
  File('${outputDir.path}/recording_status_summary.md').writeAsStringSync(
    _summaryMarkdown(
      generatedAt: DateTime.now().toUtc().toIso8601String(),
      workpackManifestPath: config.workpackManifestPath,
      masterChecklistPath: config.masterChecklistPath,
      intakeManifestPath: config.intakeManifestPath,
      baseRowCount: baseRows.length,
      receiveCounts: receiveCounts,
      qcCounts: qcCounts,
      workflowCounts: workflowCounts,
      retakeCount: retakeRows.length,
      completedCount: completedRows.length,
    ),
  );

  stdout.writeln('Recording intake/QC artifacts written to ${outputDir.path}.');
  stdout.writeln('  Seed manifest rows: ${seedRows.length}');
  stdout.writeln('  Updated checklist rows: ${updatedChecklistRows.length}');
  stdout.writeln('  Retake queue rows: ${retakeRows.length}');
  stdout.writeln('  Completed report rows: ${completedRows.length}');
}

class _Config {
  _Config({
    required this.workpackManifestPath,
    required this.masterChecklistPath,
    required this.intakeManifestPath,
    required this.outputDir,
    required this.showHelp,
  });

  factory _Config.fromArgs(List<String> args) {
    var workpackManifestPath = _defaultWorkpackManifestPath;
    var masterChecklistPath = _defaultMasterChecklistPath;
    var intakeManifestPath = '';
    var outputDir = _defaultOutputDir;
    var showHelp = false;

    for (final arg in args) {
      if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else if (arg.startsWith('--workpack-manifest=')) {
        workpackManifestPath =
            arg.substring('--workpack-manifest='.length).trim();
      } else if (arg.startsWith('--master-checklist=')) {
        masterChecklistPath =
            arg.substring('--master-checklist='.length).trim();
      } else if (arg.startsWith('--intake-manifest=')) {
        intakeManifestPath =
            arg.substring('--intake-manifest='.length).trim();
      } else if (arg.startsWith('--output-dir=')) {
        outputDir = arg.substring('--output-dir='.length).trim();
      } else if (arg.trim().isNotEmpty) {
        throw FormatException('Unknown argument: $arg');
      }
    }

    return _Config(
      workpackManifestPath: workpackManifestPath,
      masterChecklistPath: masterChecklistPath,
      intakeManifestPath: intakeManifestPath,
      outputDir: outputDir,
      showHelp: showHelp,
    );
  }

  final String workpackManifestPath;
  final String masterChecklistPath;
  final String intakeManifestPath;
  final String outputDir;
  final bool showHelp;
}

void _printUsage() {
  stdout.writeln('''
Recording intake/QC updater for the lesson voiceover pipeline

Usage:
  dart run tool/update_recording_status_from_intake.dart [options]

Default inputs:
  --workpack-manifest=$_defaultWorkpackManifestPath
  --master-checklist=$_defaultMasterChecklistPath
  --output-dir=$_defaultOutputDir

Options:
  --workpack-manifest=PATH   Workpack manifest generated by export_recorder_workpack.dart
  --master-checklist=PATH    Recorder master checklist CSV generated by the workpack export
  --intake-manifest=PATH     Optional filled intake manifest CSV. If omitted, the script emits seed/default outputs only.
  --output-dir=PATH          Directory for generated intake/QC artifacts
  --help                     Show this help message

Outputs:
  recording_return_manifest_seed.csv
  recorder_master_checklist_updated.csv
  retake_queue.csv
  completed_segments_report.csv
  recording_status_summary.md
''');
}

Map<String, String> _seedRowFromBase(Map<String, String> baseRow) {
  return <String, String>{
    'batch_id': baseRow['batch_id'] ?? '',
    'lesson_number': baseRow['lesson_number'] ?? '',
    'lesson_id': baseRow['lesson_id'] ?? '',
    'lesson_title': baseRow['lesson_title'] ?? '',
    'segment_id': baseRow['segment_id'] ?? '',
    'segment_type': baseRow['segment_type'] ?? '',
    'row_kind': baseRow['row_kind'] ?? '',
    'planned_audio_filename': baseRow['planned_audio_filename'] ?? '',
    'planned_audio_asset_path': baseRow['planned_audio_asset_path'] ?? '',
    'target_duration_sec': baseRow['target_duration_sec'] ?? '',
    'repeatability': baseRow['repeatability'] ?? '',
    'delivery_note': baseRow['delivery_note'] ?? '',
    'received_filename': '',
    'receive_status': 'TO_RECORD',
    'qc_status': 'TO_RECORD',
    'qc_notes': '',
    'retake_reason': '',
    'final_resolution': 'OPEN',
  };
}

void _normalizeAndValidateStatusRow(Map<String, String> row) {
  final receiveStatus = (row['receive_status'] ?? 'TO_RECORD').trim().toUpperCase();
  final qcStatus = (row['qc_status'] ?? 'TO_RECORD').trim().toUpperCase();
  row['receive_status'] = receiveStatus.isEmpty ? 'TO_RECORD' : receiveStatus;
  row['qc_status'] = qcStatus.isEmpty ? 'TO_RECORD' : qcStatus;

  if (!_receiveStatuses.contains(row['receive_status'])) {
    throw FormatException(
      'Invalid receive_status `${row['receive_status']}` for ${_rowKey(row)}.',
    );
  }
  if (!_qcStatuses.contains(row['qc_status'])) {
    throw FormatException(
      'Invalid qc_status `${row['qc_status']}` for ${_rowKey(row)}.',
    );
  }

  final receivedFilename = (row['received_filename'] ?? '').trim();
  final receiveStatusValue = row['receive_status']!;
  final qcStatusValue = row['qc_status']!;
  if (receiveStatusValue == 'RECEIVED' && receivedFilename.isEmpty) {
    throw FormatException(
      'received_filename is required when receive_status=RECEIVED for ${_rowKey(row)}.',
    );
  }
  if (receiveStatusValue != 'RECEIVED' && receivedFilename.isNotEmpty) {
    throw FormatException(
      'received_filename must be blank unless receive_status=RECEIVED for ${_rowKey(row)}.',
    );
  }
  if (qcStatusValue != 'TO_RECORD' && receiveStatusValue != 'RECEIVED') {
    throw FormatException(
      'qc_status ${row['qc_status']} requires receive_status=RECEIVED for ${_rowKey(row)}.',
    );
  }
  if (qcStatusValue == 'RETAKE_REQUIRED' && (row['retake_reason'] ?? '').trim().isEmpty) {
    throw FormatException(
      'retake_reason is required when qc_status=RETAKE_REQUIRED for ${_rowKey(row)}.',
    );
  }

  if ((row['final_resolution'] ?? '').trim().isEmpty) {
    row['final_resolution'] = _defaultFinalResolution(row);
  }
}

String _defaultFinalResolution(Map<String, String> row) {
  final receiveStatus = row['receive_status'] ?? 'TO_RECORD';
  final qcStatus = row['qc_status'] ?? 'TO_RECORD';
  if (qcStatus == 'QC_PASS') {
    return 'READY_FOR_IMPORT';
  }
  if (qcStatus == 'RETAKE_REQUIRED') {
    return 'WAITING_ON_RETAKE';
  }
  if (receiveStatus == 'RECEIVED') {
    return 'QC_PENDING';
  }
  if (receiveStatus == 'MISSING') {
    return 'NOT_RETURNED';
  }
  return 'OPEN';
}

String _workflowStatusFromMerged(Map<String, String> row) {
  final receiveStatus = row['receive_status'] ?? 'TO_RECORD';
  final qcStatus = row['qc_status'] ?? 'TO_RECORD';
  if (qcStatus == 'QC_PASS') {
    return 'QC_PASS';
  }
  if (qcStatus == 'RETAKE_REQUIRED') {
    return 'RETAKE';
  }
  if (receiveStatus == 'RECEIVED') {
    return 'RECORDED';
  }
  return 'TO_RECORD';
}

Map<String, String> _updatedChecklistRow({
  required Map<String, String> baseRow,
  required Map<String, String> mergedRow,
  required String workflowStatus,
}) {
  return <String, String>{
    'batch_id': baseRow['batch_id'] ?? '',
    'lesson_number': baseRow['lesson_number'] ?? '',
    'lesson_id': baseRow['lesson_id'] ?? '',
    'lesson_title': baseRow['lesson_title'] ?? '',
    'segment_id': baseRow['segment_id'] ?? '',
    'segment_type': baseRow['segment_type'] ?? '',
    'row_kind': baseRow['row_kind'] ?? '',
    'planned_audio_filename': baseRow['planned_audio_filename'] ?? '',
    'planned_audio_asset_path': baseRow['planned_audio_asset_path'] ?? '',
    'target_duration_sec': baseRow['target_duration_sec'] ?? '',
    'repeatability': baseRow['repeatability'] ?? '',
    'workflow_status': workflowStatus,
    'delivery_note': baseRow['delivery_note'] ?? '',
    'spoken_script': baseRow['spoken_script'] ?? '',
    'script_text_ar': baseRow['script_text_ar'] ?? '',
    'script_text_support': baseRow['script_text_support'] ?? '',
    'recorder_notes': baseRow['recorder_notes'] ?? '',
    'qc_notes': mergedRow['qc_notes'] ?? '',
    'received_filename': mergedRow['received_filename'] ?? '',
    'receive_status': mergedRow['receive_status'] ?? '',
    'qc_status': mergedRow['qc_status'] ?? '',
    'retake_reason': mergedRow['retake_reason'] ?? '',
    'final_resolution': mergedRow['final_resolution'] ?? '',
  };
}

Map<String, String> _retakeQueueRow(Map<String, String> row) {
  return <String, String>{
    'batch_id': row['batch_id'] ?? '',
    'lesson_number': row['lesson_number'] ?? '',
    'lesson_id': row['lesson_id'] ?? '',
    'lesson_title': row['lesson_title'] ?? '',
    'segment_id': row['segment_id'] ?? '',
    'segment_type': row['segment_type'] ?? '',
    'row_kind': row['row_kind'] ?? '',
    'planned_audio_filename': row['planned_audio_filename'] ?? '',
    'received_filename': row['received_filename'] ?? '',
    'receive_status': row['receive_status'] ?? '',
    'qc_status': row['qc_status'] ?? '',
    'qc_notes': row['qc_notes'] ?? '',
    'retake_reason': row['retake_reason'] ?? '',
    'final_resolution': row['final_resolution'] ?? '',
    'delivery_note': row['delivery_note'] ?? '',
  };
}

Map<String, String> _completedReportRow(Map<String, String> row) {
  return <String, String>{
    'batch_id': row['batch_id'] ?? '',
    'lesson_number': row['lesson_number'] ?? '',
    'lesson_id': row['lesson_id'] ?? '',
    'lesson_title': row['lesson_title'] ?? '',
    'segment_id': row['segment_id'] ?? '',
    'segment_type': row['segment_type'] ?? '',
    'row_kind': row['row_kind'] ?? '',
    'planned_audio_filename': row['planned_audio_filename'] ?? '',
    'received_filename': row['received_filename'] ?? '',
    'receive_status': row['receive_status'] ?? '',
    'qc_status': row['qc_status'] ?? '',
    'qc_notes': row['qc_notes'] ?? '',
    'retake_reason': row['retake_reason'] ?? '',
    'final_resolution': row['final_resolution'] ?? '',
    'planned_audio_asset_path': row['planned_audio_asset_path'] ?? '',
  };
}

String _summaryMarkdown({
  required String generatedAt,
  required String workpackManifestPath,
  required String masterChecklistPath,
  required String intakeManifestPath,
  required int baseRowCount,
  required Map<String, int> receiveCounts,
  required Map<String, int> qcCounts,
  required Map<String, int> workflowCounts,
  required int retakeCount,
  required int completedCount,
}) {
  final b = StringBuffer()
    ..writeln('# Recording Intake And QC Summary')
    ..writeln()
    ..writeln('- Generated at: `$generatedAt`')
    ..writeln('- Workpack manifest: `$workpackManifestPath`')
    ..writeln('- Recorder master checklist: `$masterChecklistPath`')
    ..writeln('- Intake manifest: `${intakeManifestPath.isEmpty ? 'not provided' : intakeManifestPath}`')
    ..writeln('- Scope rows: `$baseRowCount`')
    ..writeln()
    ..writeln('## Receive Status Counts')
    ..writeln()
    ..writeln('| Status | Count |')
    ..writeln('| --- | --- |');

  for (final status in <String>['TO_RECORD', 'RECEIVED', 'MISSING']) {
    b.writeln('| `$status` | `${receiveCounts[status] ?? 0}` |');
  }

  b
    ..writeln()
    ..writeln('## QC Status Counts')
    ..writeln()
    ..writeln('| Status | Count |')
    ..writeln('| --- | --- |');

  for (final status in <String>['TO_RECORD', 'QC_PASS', 'RETAKE_REQUIRED']) {
    b.writeln('| `$status` | `${qcCounts[status] ?? 0}` |');
  }

  b
    ..writeln()
    ..writeln('## Derived Workpack Workflow Counts')
    ..writeln()
    ..writeln('| Workflow status | Count |')
    ..writeln('| --- | --- |');

  for (final status in <String>['TO_RECORD', 'RECORDED', 'RETAKE', 'QC_PASS']) {
    b.writeln('| `$status` | `${workflowCounts[status] ?? 0}` |');
  }

  b
    ..writeln()
    ..writeln('## Derived Outputs')
    ..writeln()
    ..writeln('- Retake queue rows: `$retakeCount`')
    ..writeln('- Completed segments rows: `$completedCount`')
    ..writeln('- Seed return manifest rows: `$baseRowCount`')
    ..writeln()
    ..writeln('## Rules Applied')
    ..writeln()
    ..writeln('- `received_filename` must stay blank unless `receive_status=RECEIVED`.')
    ..writeln('- `qc_status=QC_PASS` and `qc_status=RETAKE_REQUIRED` both require `receive_status=RECEIVED`.')
    ..writeln('- `retake_reason` is required when `qc_status=RETAKE_REQUIRED`.')
    ..writeln('- Workpack `workflow_status` is derived from receive/QC state: `RECEIVED -> RECORDED`, `RETAKE_REQUIRED -> RETAKE`, `QC_PASS -> QC_PASS`.');
  return b.toString();
}

void _requireColumns(
  List<Map<String, String>> rows,
  List<String> requiredColumns,
  String path,
) {
  if (rows.isEmpty) {
    return;
  }
  final firstRow = rows.first;
  final missing = requiredColumns
      .where((column) => !firstRow.containsKey(column))
      .toList();
  if (missing.isNotEmpty) {
    throw FormatException('Missing columns in $path: ${missing.join(', ')}');
  }
}

String _rowKey(Map<String, String> row) {
  return '${row['lesson_id']}|${row['segment_id']}|${row['planned_audio_filename']}';
}

List<Map<String, String>> _parseCsv(String text) {
  final records = _parseCsvRecords(text);
  if (records.isEmpty) {
    return <Map<String, String>>[];
  }
  final headers = records.first
      .map((cell) => cell.replaceFirst('\ufeff', ''))
      .toList();
  final rows = <Map<String, String>>[];
  for (var i = 1; i < records.length; i++) {
    final record = records[i];
    if (record.every((cell) => cell.trim().isEmpty)) {
      continue;
    }
    final row = <String, String>{};
    for (var j = 0; j < headers.length; j++) {
      row[headers[j]] = j < record.length ? record[j] : '';
    }
    rows.add(row);
  }
  return rows;
}

List<List<String>> _parseCsvRecords(String input) {
  final records = <List<String>>[];
  var row = <String>[];
  var field = StringBuffer();
  var inQuotes = false;

  void endField() {
    row.add(field.toString());
    field = StringBuffer();
  }

  void endRow() {
    endField();
    records.add(row);
    row = <String>[];
  }

  var i = 0;
  while (i < input.length) {
    final char = input[i];
    if (char == '"') {
      if (inQuotes && i + 1 < input.length && input[i + 1] == '"') {
        field.write('"');
        i += 2;
        continue;
      }
      inQuotes = !inQuotes;
      i += 1;
      continue;
    }
    if (!inQuotes && char == ',') {
      endField();
      i += 1;
      continue;
    }
    if (!inQuotes && char == '\n') {
      endRow();
      i += 1;
      continue;
    }
    if (!inQuotes && char == '\r') {
      if (i + 1 < input.length && input[i + 1] == '\n') {
        i += 1;
      }
      endRow();
      i += 1;
      continue;
    }
    field.write(char);
    i += 1;
  }

  final hasResidualField = field.length > 0;
  final hasResidualRow = row.isNotEmpty;
  if (hasResidualField || hasResidualRow) {
    endRow();
  }
  return records;
}

void _writeCsv(
  String path,
  List<String> columns,
  List<Map<String, String>> rows,
) {
  final buffer = StringBuffer()
    ..writeln(columns.map(_csvEscape).join(','));
  for (final row in rows) {
    buffer.writeln(columns.map((column) => _csvEscape(row[column] ?? '')).join(','));
  }
  File(path).writeAsStringSync(buffer.toString());
}

String _csvEscape(String value) {
  final normalized = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final escaped = normalized.replaceAll('"', '""');
  return '"$escaped"';
}
