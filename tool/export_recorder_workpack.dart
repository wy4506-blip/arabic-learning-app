import 'dart:convert';
import 'dart:io';

const _root = 'docs/voiceover_production_lessons_1_16';
const _taskSheetPath = '$_root/recording_task_sheet_lessons_01_12.csv';
const _summaryPath = '$_root/recording_export_summary_lessons_01_12.md';
const _outputRoot =
    '$_root/recorder_workpack_lessons_01_02_05_06_07_08';
const _readmePath = '$_outputRoot/README.md';
const _masterChecklistPath = '$_outputRoot/recorder_master_checklist.csv';
const _manifestPath = '$_outputRoot/workpack_manifest.json';

const _expectedLessonNumbers = <int>[1, 2, 5, 6, 7, 8];

const _workflowStatuses = <String>[
  'TO_RECORD',
  'RECORDED',
  'RETAKE',
  'QC_PASS',
];

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

const _filenameListColumns = <String>[
  'batch_id',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'segment_id',
  'segment_type',
  'planned_audio_filename',
  'planned_audio_asset_path',
  'human_master_filename_example',
  'human_import_filename_example',
  'human_retake_filename_example',
  'workflow_status',
];

void main() {
  final taskSheetFile = File(_taskSheetPath);
  final summaryFile = File(_summaryPath);
  if (!taskSheetFile.existsSync()) {
    stderr.writeln('Missing task sheet: $_taskSheetPath');
    exitCode = 1;
    return;
  }
  if (!summaryFile.existsSync()) {
    stderr.writeln('Missing summary file: $_summaryPath');
    exitCode = 1;
    return;
  }

  final summaryMarkdown = summaryFile.readAsStringSync();
  final allRows = _parseCsv(taskSheetFile.readAsStringSync());
  if (allRows.isEmpty) {
    stderr.writeln('Task sheet is empty: $_taskSheetPath');
    exitCode = 1;
    return;
  }

  final readyRows = allRows
      .where((row) => row['production_status'] == 'RECORDING_READY')
      .toList();
  final packsByKey = <String, List<Map<String, String>>>{};
  for (final row in readyRows) {
    final key = '${row['batch_id']}|${row['lesson_id']}';
    packsByKey.putIfAbsent(key, () => <Map<String, String>>[]).add(row);
  }

  final packs = packsByKey.entries
      .map((entry) => LessonPack.fromRows(entry.value))
      .toList()
    ..sort((a, b) {
      final batchCompare = _batchRank(a.batchId).compareTo(_batchRank(b.batchId));
      if (batchCompare != 0) {
        return batchCompare;
      }
      return a.lessonNumber.compareTo(b.lessonNumber);
    });

  final includedLessonNumbers = packs.map((pack) => pack.lessonNumber).toList();
  if (!_sameIntList(includedLessonNumbers, _expectedLessonNumbers)) {
    stderr.writeln(
      'Unexpected RECORDING_READY lesson scope. '
      'Expected $_expectedLessonNumbers but found $includedLessonNumbers.',
    );
    exitCode = 1;
    return;
  }

  final summaryGeneratedAt = _extractGeneratedAt(summaryMarkdown);
  final summaryStamp = _summaryStamp(summaryGeneratedAt);
  final summaryReadyCounts = _extractReadyCounts(summaryMarkdown);
  if (summaryReadyCounts.lessonCount != packs.length ||
      summaryReadyCounts.rowCount != readyRows.length) {
    stderr.writeln(
      'Summary mismatch. Summary says '
      '${summaryReadyCounts.lessonCount} ready lessons and '
      '${summaryReadyCounts.rowCount} rows, but task sheet produced '
      '${packs.length} lessons and ${readyRows.length} rows.',
    );
    exitCode = 1;
    return;
  }

  final outputRoot = Directory(_outputRoot)..createSync(recursive: true);
  final masterChecklistRows = <Map<String, String>>[];
  final manifestLessons = <Map<String, dynamic>>[];
  final batchRowCounts = <String, int>{};

  for (final pack in packs) {
    final batchDir = Directory('${outputRoot.path}/${pack.batchId}')
      ..createSync(recursive: true);
    final lessonDir = Directory('${batchDir.path}/${pack.folderName}')
      ..createSync(recursive: true);
    final lessonPrefix = 'lesson_${_pad2(pack.lessonNumber)}';
    final checklistRows = pack.rows
        .map((row) => _checklistRow(pack: pack, row: row))
        .toList();
    final filenameRows = pack.rows
        .map(
          (row) => _filenameRow(
            pack: pack,
            row: row,
            summaryStamp: summaryStamp,
          ),
        )
        .toList();

    _writeCsv(
      '${lessonDir.path}/${lessonPrefix}_segment_checklist.csv',
      _masterChecklistColumns,
      checklistRows,
    );
    _writeCsv(
      '${lessonDir.path}/${lessonPrefix}_filename_list.csv',
      _filenameListColumns,
      filenameRows,
    );
    File('${lessonDir.path}/${lessonPrefix}_script_sheet.md').writeAsStringSync(
      _scriptSheetMarkdown(pack),
    );
    File('${lessonDir.path}/${lessonPrefix}_delivery_notes.md').writeAsStringSync(
      _deliveryNotesMarkdown(pack),
    );

    masterChecklistRows.addAll(checklistRows);
    batchRowCounts[pack.batchId] =
        (batchRowCounts[pack.batchId] ?? 0) + pack.rows.length;
    manifestLessons.add(<String, dynamic>{
      'batch_id': pack.batchId,
      'lesson_number': pack.lessonNumber,
      'lesson_id': pack.lessonId,
      'lesson_title': pack.lessonTitle,
      'row_count': pack.rows.length,
      'folder': lessonDir.path.replaceAll('\\', '/'),
      'files': <String>[
        '${lessonDir.path}/${lessonPrefix}_script_sheet.md',
        '${lessonDir.path}/${lessonPrefix}_segment_checklist.csv',
        '${lessonDir.path}/${lessonPrefix}_filename_list.csv',
        '${lessonDir.path}/${lessonPrefix}_delivery_notes.md',
      ].map((path) => path.replaceAll('\\', '/')).toList(),
    });
  }

  _writeCsv(_masterChecklistPath, _masterChecklistColumns, masterChecklistRows);
  File(_readmePath).writeAsStringSync(
    _packageReadme(
      generatedAt: summaryGeneratedAt,
      summaryStamp: summaryStamp,
      packs: packs,
      totalRows: readyRows.length,
      batchRowCounts: batchRowCounts,
    ),
  );
  File(_manifestPath).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'generated_from': <String, String>{
        'task_sheet': _taskSheetPath,
        'summary': _summaryPath,
      },
      'output_root': _outputRoot,
      'workflow_statuses': _workflowStatuses,
      'included_lessons': _expectedLessonNumbers,
      'lesson_count': 6,
      'row_count': 119,
      'lessons': manifestLessons,
    }),
  );

  stdout.writeln(
    'Generated recorder workpack for ${packs.length} lessons and '
    '${readyRows.length} ready rows at $_outputRoot.',
  );
}

class LessonPack {
  LessonPack({
    required this.batchId,
    required this.lessonNumber,
    required this.lessonId,
    required this.lessonTitle,
    required this.rows,
  });

  factory LessonPack.fromRows(List<Map<String, String>> rows) {
    if (rows.isEmpty) {
      throw ArgumentError('Lesson pack rows cannot be empty.');
    }
    final first = rows.first;
    return LessonPack(
      batchId: first['batch_id'] ?? '',
      lessonNumber: _lessonNumber(first),
      lessonId: first['lesson_id'] ?? '',
      lessonTitle: first['lesson_title'] ?? '',
      rows: rows,
    );
  }

  final String batchId;
  final int lessonNumber;
  final String lessonId;
  final String lessonTitle;
  final List<Map<String, String>> rows;

  String get folderName =>
      'lesson_${_pad2(lessonNumber)}_${_slugifyTitle(lessonTitle)}';
}

class ReadyCounts {
  ReadyCounts({required this.lessonCount, required this.rowCount});

  final int lessonCount;
  final int rowCount;
}

Map<String, String> _checklistRow({
  required LessonPack pack,
  required Map<String, String> row,
}) {
  return <String, String>{
    'batch_id': pack.batchId,
    'lesson_number': _pad2(pack.lessonNumber),
    'lesson_id': pack.lessonId,
    'lesson_title': pack.lessonTitle,
    'segment_id': row['segment_id'] ?? '',
    'segment_type': row['segment_type'] ?? '',
    'row_kind': row['row_kind'] ?? '',
    'planned_audio_filename': row['planned_audio_filename'] ?? '',
    'planned_audio_asset_path': row['planned_audio_asset_path'] ?? '',
    'target_duration_sec': row['target_duration_sec'] ?? '',
    'repeatability': row['repeatability'] ?? '',
    'workflow_status': 'TO_RECORD',
    'delivery_note': row['delivery_note'] ?? '',
    'spoken_script': _spokenScript(row),
    'script_text_ar': row['script_text_ar'] ?? '',
    'script_text_support': row['script_text_support'] ?? '',
    'recorder_notes': '',
    'qc_notes': '',
  };
}

Map<String, String> _filenameRow({
  required LessonPack pack,
  required Map<String, String> row,
  required String summaryStamp,
}) {
  final batchTag = _batchRevisionTag(pack.batchId);
  final filename = row['planned_audio_filename'] ?? '';
  final stem = filename.replaceFirst(RegExp(r'\.mp3$', caseSensitive: false), '');
  return <String, String>{
    'batch_id': pack.batchId,
    'lesson_number': _pad2(pack.lessonNumber),
    'lesson_id': pack.lessonId,
    'lesson_title': pack.lessonTitle,
    'segment_id': row['segment_id'] ?? '',
    'segment_type': row['segment_type'] ?? '',
    'planned_audio_filename': filename,
    'planned_audio_asset_path': row['planned_audio_asset_path'] ?? '',
    'human_master_filename_example': '${stem}__human__${summaryStamp}-${batchTag}.wav',
    'human_import_filename_example': '${stem}__human__${summaryStamp}-${batchTag}.mp3',
    'human_retake_filename_example': '${stem}__human__${summaryStamp}-${batchTag}-retake01.wav',
    'workflow_status': 'TO_RECORD',
  };
}

String _scriptSheetMarkdown(LessonPack pack) {
  final b = StringBuffer()
    ..writeln('# Lesson ${_pad2(pack.lessonNumber)} Script Sheet')
    ..writeln()
    ..writeln('- Batch: `${pack.batchId}`')
    ..writeln('- Lesson ID: `${pack.lessonId}`')
    ..writeln('- Lesson title: `${pack.lessonTitle}`')
    ..writeln('- Included rows: `${pack.rows.length}`')
    ..writeln('- Production status: `RECORDING_READY`')
    ..writeln('- Default workflow status: `TO_RECORD`')
    ..writeln()
    ..writeln('Use one audio file per segment. Do not merge lines, and do not record any lesson outside this packet.')
    ..writeln();

  for (var i = 0; i < pack.rows.length; i++) {
    final row = pack.rows[i];
    b
      ..writeln('## ${_pad2(i + 1)}. `${row['segment_id'] ?? ''}`')
      ..writeln()
      ..writeln('- Type: `${row['segment_type'] ?? ''}`')
      ..writeln('- Row kind: `${row['row_kind'] ?? ''}`')
      ..writeln('- Planned filename: `${row['planned_audio_filename'] ?? ''}`')
      ..writeln('- Logical asset path: `${row['planned_audio_asset_path'] ?? ''}`')
      ..writeln('- Target duration: `${row['target_duration_sec'] ?? ''} sec`')
      ..writeln('- Repeatability: `${row['repeatability'] ?? ''}`')
      ..writeln('- Workflow status: `TO_RECORD`')
      ..writeln('- Delivery note: ${_inlineText(row['delivery_note'] ?? '')}')
      ..writeln()
      ..writeln('Spoken script:')
      ..writeln('```text')
      ..writeln(_spokenScript(row))
      ..writeln('```');

    final supportCue = _supportCue(row);
    if (supportCue.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Support cue:')
        ..writeln('```text')
        ..writeln(supportCue)
        ..writeln('```');
    }

    b.writeln();
  }

  return b.toString();
}

String _deliveryNotesMarkdown(LessonPack pack) {
  final byNote = <String, List<Map<String, String>>>{};
  final typeCounts = <String, int>{};
  for (final row in pack.rows) {
    final note = row['delivery_note'] ?? '';
    byNote.putIfAbsent(note, () => <Map<String, String>>[]).add(row);
    final type = row['segment_type'] ?? 'unknown';
    typeCounts[type] = (typeCounts[type] ?? 0) + 1;
  }

  final b = StringBuffer()
    ..writeln('# Lesson ${_pad2(pack.lessonNumber)} Delivery Notes')
    ..writeln()
    ..writeln('- Batch: `${pack.batchId}`')
    ..writeln('- Lesson ID: `${pack.lessonId}`')
    ..writeln('- Lesson title: `${pack.lessonTitle}`')
    ..writeln('- Unique delivery note groups: `${byNote.length}`')
    ..writeln('- Default workflow status: `TO_RECORD`')
    ..writeln()
    ..writeln('## Segment Type Mix')
    ..writeln();

  for (final entry in typeCounts.entries) {
    b.writeln('- `${entry.key}`: `${entry.value}`');
  }

  b
    ..writeln()
    ..writeln('## Delivery Note Groups')
    ..writeln();

  var groupIndex = 1;
  for (final entry in byNote.entries) {
    final segmentIds = entry.value
        .map((row) => row['segment_id'] ?? '')
        .where((id) => id.isNotEmpty)
        .join(', ');
    b
      ..writeln('### Group ${_pad2(groupIndex)}')
      ..writeln()
      ..writeln('- Applies to `${entry.value.length}` rows')
      ..writeln('- Segment IDs: `$segmentIds`')
      ..writeln('- Note: ${_inlineText(entry.key)}')
      ..writeln();
    groupIndex += 1;
  }

  return b.toString();
}

String _packageReadme({
  required String generatedAt,
  required String summaryStamp,
  required List<LessonPack> packs,
  required int totalRows,
  required Map<String, int> batchRowCounts,
}) {
  final includedLessons = packs
      .map((pack) => 'Lesson ${_pad2(pack.lessonNumber)}: ${pack.lessonTitle}')
      .join(' ; ');
  final batchLines = <String>[];
  for (final batchId in <String>['BATCH_A', 'BATCH_B']) {
    final batchPacks = packs.where((pack) => pack.batchId == batchId).toList();
    if (batchPacks.isEmpty) {
      continue;
    }
    final lessonList = batchPacks
        .map((pack) => 'Lesson ${_pad2(pack.lessonNumber)}')
        .join(', ');
    batchLines.add(
      '- `${batchId}`: `${batchRowCounts[batchId] ?? 0}` rows across $lessonList',
    );
  }

  return '''# Recorder Workpack For Lessons 01, 02, 05, 06, 07, 08

- Generated from: `$_taskSheetPath`
- Source summary: `$_summaryPath`
- Source summary generated at: `$generatedAt`
- Scope: only `RECORDING_READY` lessons are included in this package.
- Included lessons: $includedLessons
- Excluded by rule: Lesson 03 (`REVISE_REQUIRED`), Lessons 04/09/10/11/12 (`NATIVE_REVIEW_REQUIRED`), Lessons 13-16 (`PLACEHOLDER_ONLY`)
- Total included rows: `$totalRows`

## Folder Structure

- `BATCH_A/`: Lessons 01-02
- `BATCH_B/`: Lessons 05-08
- `recorder_master_checklist.csv`: all included rows with recorder workflow status
- `workpack_manifest.json`: machine-readable package manifest for reproducible rebuilds

## Batch Totals

${batchLines.join('\n')}

## Naming Convention

Use the planned logical filename from the task sheet as the source of truth, for example `l01_ord_012_normal.mp3`.

- Logical asset path stays `lesson_{NN}/voiceover/{asset_stem}_normal.mp3`
- Preferred human master export is `{asset_stem}_normal__human__${summaryStamp}-batch-x.wav`
- Final human import variant can be `{asset_stem}_normal__human__${summaryStamp}-batch-x.mp3`
- Do not rename the `asset_stem`, even if you need a new take

## Retake Convention

If a segment needs another pass:

- Change the checklist status from `RECORDED` to `RETAKE`
- Keep the same logical stem
- Put the retake identifier in the revision token, for example `l01_ord_012_normal__human__${summaryStamp}-batch-a-retake02.wav`
- Once the retake is approved, the import-ready filename should go back to the clean revision form without the temporary retake suffix if you are only delivering the final chosen take

## Pace And Pause Expectations

- Treat the per-segment `delivery_note` as the first source of truth
- Keep pacing beginner-safe: calm, clear, and not theatrical
- Leave clean answer space where prompts ask for a pause
- Keep Arabic model assets neutral and isolated unless the segment note says otherwise
- Record one file per segment only; do not merge adjacent lines

## Export Format Expectations

- Preferred delivery master: mono `.wav`
- Current import pipeline also accepts `.wav`, `.mp3`, `.m4a`, and `.aac` when needed
- Planned logical filenames in the package remain `.mp3` because they point at the stable app-facing asset slot
- Avoid clipping consonants or trimming the tail so tightly that the ending sounds rushed

## Recorder Workflow Statuses

- `TO_RECORD`: not captured yet
- `RECORDED`: a clean take exists and is waiting for QC
- `RETAKE`: another take is required before acceptance
- `QC_PASS`: accepted for import and packaging
''';
}

String _spokenScript(Map<String, String> row) {
  if (row['row_kind'] == 'ARABIC_ASSET') {
    final arabic = (row['script_text_ar'] ?? '').trim();
    if (arabic.isNotEmpty) {
      return arabic;
    }
  }
  final support = (row['script_text_support'] ?? '').trim();
  if (support.isNotEmpty) {
    return support;
  }
  return (row['script_text_ar'] ?? '').trim();
}

String _supportCue(Map<String, String> row) {
  if (row['row_kind'] == 'ARABIC_ASSET') {
    return (row['script_text_support'] ?? '').trim();
  }
  final arabic = (row['script_text_ar'] ?? '').trim();
  final support = (row['script_text_support'] ?? '').trim();
  if (arabic.isEmpty || arabic == support) {
    return '';
  }
  return arabic;
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

ReadyCounts _extractReadyCounts(String markdown) {
  final match = RegExp(r'\| `RECORDING_READY` \| `(\d+)` \| `(\d+)` \|')
      .firstMatch(markdown);
  if (match == null) {
    throw StateError('Could not parse RECORDING_READY counts from summary.');
  }
  return ReadyCounts(
    lessonCount: int.parse(match.group(1)!),
    rowCount: int.parse(match.group(2)!),
  );
}

String _extractGeneratedAt(String markdown) {
  final match = RegExp(r'- Generated at: `([^`]+)`').firstMatch(markdown);
  if (match == null) {
    throw StateError('Could not parse generated-at stamp from summary.');
  }
  return match.group(1)!;
}

String _summaryStamp(String generatedAt) {
  final parsed = DateTime.tryParse(generatedAt);
  if (parsed == null) {
    final digitsOnly = generatedAt.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length >= 8 ? digitsOnly.substring(0, 8) : '00000000';
  }
  final utc = parsed.toUtc();
  return '${utc.year.toString().padLeft(4, '0')}'
      '${utc.month.toString().padLeft(2, '0')}'
      '${utc.day.toString().padLeft(2, '0')}';
}

int _lessonNumber(Map<String, String> row) {
  final path = row['planned_audio_asset_path'] ?? '';
  final pathMatch = RegExp(r'lesson_(\d{2})/').firstMatch(path);
  if (pathMatch != null) {
    return int.parse(pathMatch.group(1)!);
  }
  final segmentId = row['segment_id'] ?? '';
  final segmentMatch = RegExp(r'L(\d{2})_').firstMatch(segmentId);
  if (segmentMatch != null) {
    return int.parse(segmentMatch.group(1)!);
  }
  throw StateError('Could not determine lesson number for row ${row['segment_id']}.');
}

int _batchRank(String batchId) {
  switch (batchId) {
    case 'BATCH_A':
      return 1;
    case 'BATCH_B':
      return 2;
    case 'BATCH_C':
      return 3;
    default:
      return 99;
  }
}

bool _sameIntList(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

String _batchRevisionTag(String batchId) {
  switch (batchId) {
    case 'BATCH_A':
      return 'batch-a';
    case 'BATCH_B':
      return 'batch-b';
    case 'BATCH_C':
      return 'batch-c';
    default:
      return batchId.toLowerCase();
  }
}

String _slugifyTitle(String title) {
  final ascii = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  final compact = ascii.trim().replaceAll(RegExp(r'\s+'), '_');
  return compact.isEmpty ? 'lesson' : compact;
}

String _pad2(int value) => value.toString().padLeft(2, '0');

String _inlineText(String value) => value.isEmpty ? '`(none)`' : value;

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

