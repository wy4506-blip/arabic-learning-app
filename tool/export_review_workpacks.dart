import 'dart:convert';
import 'dart:io';

const _root = 'docs/voiceover_production_lessons_1_16';
const _reviewStatusPath = '$_root/review_status_lessons_01_12.md';
const _reviewQueuePath = '$_root/review_queue_lessons_01_12.csv';
const _summaryPath = '$_root/recording_export_summary_lessons_01_12.md';
const _scriptsDir = '$_root/scripts/final';
const _dataDir = '$_root/data';
const _reviseOutputRoot = '$_root/revise_packet_lesson_03';
const _nativeOutputRoot =
    '$_root/native_review_packet_lessons_04_09_10_11_12';

const _lessonReviewSheetColumns = <String>[
  'packet_type',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'batch_id',
  'review_status',
  'review_focus',
  'segment_id',
  'row_kind',
  'segment_type',
  'asset_stem',
  'source_ref',
  'export_state',
  'native_review_flag',
  'planned_audio_filename',
  'planned_audio_asset_path',
  'target_duration_sec',
  'repeatability',
  'current_line_text',
  'script_text_ar',
  'script_text_support',
  'delivery_note',
  'risk_reason',
  'reviewer_comment',
  'suggested_revision',
  'decision',
  'final_resolution',
];

const _packetChecklistColumns = <String>[
  'packet_type',
  'lesson_number',
  'lesson_id',
  'lesson_title',
  'batch_id',
  'review_status',
  'flagged_item_count',
  'review_focus',
  'current_script_file',
  'flagged_segments_file',
  'review_sheet_file',
  'reviewer_comment',
  'decision',
  'final_resolution',
];

void main() {
  final reviewStatusFile = File(_reviewStatusPath);
  final reviewQueueFile = File(_reviewQueuePath);
  final summaryFile = File(_summaryPath);
  final scriptsDirectory = Directory(_scriptsDir);
  final dataDirectory = Directory(_dataDir);

  for (final file in <FileSystemEntity>[
    reviewStatusFile,
    reviewQueueFile,
    summaryFile,
    scriptsDirectory,
    dataDirectory,
  ]) {
    if (!file.existsSync()) {
      stderr.writeln('Missing required input: ${file.path}');
      exitCode = 1;
      return;
    }
  }

  final reviewStatusMarkdown = reviewStatusFile.readAsStringSync();
  final summaryMarkdown = summaryFile.readAsStringSync();
  final reviewQueueRows = _parseCsv(reviewQueueFile.readAsStringSync());
  final reviewQueueRowCount = _extractReviewQueueRowCount(summaryMarkdown);
  if (reviewQueueRows.length != reviewQueueRowCount) {
    stderr.writeln(
      'Review queue count mismatch. Summary says $reviewQueueRowCount rows '
      'but CSV has ${reviewQueueRows.length}.',
    );
    exitCode = 1;
    return;
  }

  final reviewStatusCounts = _parseReviewStatusMarkdown(reviewStatusMarkdown);
  if (reviewStatusCounts['revise'] != 1 ||
      reviewStatusCounts['needs_native_review'] != 5) {
    stderr.writeln(
      'Unexpected blocked-lesson counts in review status markdown: '
      '$reviewStatusCounts',
    );
    exitCode = 1;
    return;
  }

  final dataFilesByLesson = _indexFilesByLesson(dataDirectory, '.json');
  final scriptFilesByLesson = _indexFilesByLesson(scriptsDirectory, '.md');
  final packetSpecs = <PacketSpec>[
    PacketSpec(
      packetType: 'REVISE',
      outputRoot: _reviseOutputRoot,
      lessonNumbers: const <int>[3],
      expectedReviewStatus: 'revise',
      expectedProductionStatus: 'REVISE_REQUIRED',
      packetTitle: 'Revise Packet For Lesson 03',
      readmeScopeLine:
          'Scope: only Lesson 03 is included because it is the sole `revise` lesson in the current normalized package.',
      decisionOptions: const <String>[
        'KEEP_CURRENT',
        'REWRITE_REQUIRED',
        'REMOVE_FROM_EXPORT',
        'NEEDS_PRODUCT_DECISION',
        'CLEARED_AFTER_REVISION',
      ],
      expectedFlaggedCount: 2,
    ),
    PacketSpec(
      packetType: 'NATIVE_REVIEW',
      outputRoot: _nativeOutputRoot,
      lessonNumbers: const <int>[4, 9, 10, 11, 12],
      expectedReviewStatus: 'needs_native_review',
      expectedProductionStatus: 'NATIVE_REVIEW_REQUIRED',
      packetTitle: 'Native Review Packet For Lessons 04, 09, 10, 11, 12',
      readmeScopeLine:
          'Scope: only blocked native-review lessons are included. Recording-ready lessons and placeholders stay out of this packet.',
      decisionOptions: const <String>[
        'NATIVE_APPROVED',
        'NATIVE_APPROVED_WITH_NOTE',
        'NATIVE_REWRITE_REQUIRED',
        'HOLD_OUT_OF_EXPORT',
        'NEEDS_PRODUCT_DECISION',
      ],
      expectedFlaggedCount: 18,
    ),
  ];

  for (final spec in packetSpecs) {
    _buildPacket(
      spec: spec,
      reviewQueueRows: reviewQueueRows,
      dataFilesByLesson: dataFilesByLesson,
      scriptFilesByLesson: scriptFilesByLesson,
      sourceGeneratedAt: _extractGeneratedAt(reviewStatusMarkdown),
    );
  }

  stdout.writeln(
    'Generated blocked-lesson review packets at '
    '$_reviseOutputRoot and $_nativeOutputRoot.',
  );
}

class PacketSpec {
  PacketSpec({
    required this.packetType,
    required this.outputRoot,
    required this.lessonNumbers,
    required this.expectedReviewStatus,
    required this.expectedProductionStatus,
    required this.packetTitle,
    required this.readmeScopeLine,
    required this.decisionOptions,
    required this.expectedFlaggedCount,
  });

  final String packetType;
  final String outputRoot;
  final List<int> lessonNumbers;
  final String expectedReviewStatus;
  final String expectedProductionStatus;
  final String packetTitle;
  final String readmeScopeLine;
  final List<String> decisionOptions;
  final int expectedFlaggedCount;
}

class LessonContext {
  LessonContext({
    required this.lessonNumber,
    required this.lessonId,
    required this.lessonTitle,
    required this.batchId,
    required this.reviewStatus,
    required this.reviewSummary,
    required this.reviewFocus,
    required this.estimatedSegmentRuntime,
    required this.estimatedArabicRuntime,
    required this.sourcePaths,
    required this.sourceDataPath,
    required this.sourceScriptPath,
    required this.currentScriptContent,
    required this.reviewRows,
    required this.outputFolderName,
  });

  final int lessonNumber;
  final String lessonId;
  final String lessonTitle;
  final String batchId;
  final String reviewStatus;
  final String reviewSummary;
  final String reviewFocus;
  final String estimatedSegmentRuntime;
  final String estimatedArabicRuntime;
  final List<String> sourcePaths;
  final String sourceDataPath;
  final String sourceScriptPath;
  final String currentScriptContent;
  final List<Map<String, String>> reviewRows;
  final String outputFolderName;
}

void _buildPacket({
  required PacketSpec spec,
  required List<Map<String, String>> reviewQueueRows,
  required Map<int, File> dataFilesByLesson,
  required Map<int, File> scriptFilesByLesson,
  required String sourceGeneratedAt,
}) {
  final packetRows = reviewQueueRows
      .where((row) => spec.lessonNumbers.contains(_lessonNumberFromReviewRow(row)))
      .toList();
  if (packetRows.length != spec.expectedFlaggedCount) {
    stderr.writeln(
      'Unexpected flagged row count for ${spec.packetType}. '
      'Expected ${spec.expectedFlaggedCount} but found ${packetRows.length}.',
    );
    exitCode = 1;
    throw StateError('Packet row count mismatch for ${spec.packetType}.');
  }
  if (packetRows.any((row) => row['production_status'] != spec.expectedProductionStatus)) {
    stderr.writeln(
      'Packet ${spec.packetType} includes a row outside '
      '${spec.expectedProductionStatus}.',
    );
    exitCode = 1;
    throw StateError('Packet production status mismatch for ${spec.packetType}.');
  }

  final rowsByLesson = <int, List<Map<String, String>>>{};
  for (final row in packetRows) {
    final lessonNumber = _lessonNumberFromReviewRow(row);
    rowsByLesson.putIfAbsent(lessonNumber, () => <Map<String, String>>[]).add(row);
  }

  final includedLessons = rowsByLesson.keys.toList()..sort();
  if (!_sameIntList(includedLessons, spec.lessonNumbers)) {
    stderr.writeln(
      'Unexpected lesson set for ${spec.packetType}. '
      'Expected ${spec.lessonNumbers} but found $includedLessons.',
    );
    exitCode = 1;
    throw StateError('Packet lesson scope mismatch for ${spec.packetType}.');
  }

  final packetRoot = Directory(spec.outputRoot)..createSync(recursive: true);
  final packetChecklistRows = <Map<String, String>>[];
  final manifestLessons = <Map<String, dynamic>>[];
  final lessonContexts = <LessonContext>[];

  for (final lessonNumber in spec.lessonNumbers) {
    final dataFile = dataFilesByLesson[lessonNumber];
    final scriptFile = scriptFilesByLesson[lessonNumber];
    if (dataFile == null || scriptFile == null) {
      stderr.writeln(
        'Missing source data/script for lesson ${_pad2(lessonNumber)} '
        'while building ${spec.packetType}.',
      );
      exitCode = 1;
      throw StateError('Missing source lesson files.');
    }

    final data = jsonDecode(dataFile.readAsStringSync()) as Map<String, dynamic>;
    final reviewStatus = data['review_status'] as String? ?? '';
    if (reviewStatus != spec.expectedReviewStatus) {
      stderr.writeln(
        'Lesson ${_pad2(lessonNumber)} review status mismatch. '
        'Expected ${spec.expectedReviewStatus} but found $reviewStatus.',
      );
      exitCode = 1;
      throw StateError('Lesson review status mismatch.');
    }

    final orderIndex = _rowOrderIndex(data);
    final lessonRows = List<Map<String, String>>.from(rowsByLesson[lessonNumber]!)
      ..sort((a, b) {
        final aIndex = orderIndex[a['segment_id']] ?? 9999;
        final bIndex = orderIndex[b['segment_id']] ?? 9999;
        return aIndex.compareTo(bIndex);
      });

    final batchId = _batchId(data['batch'] as String? ?? '');
    final lessonTitle = data['title'] as String? ?? '';
    final folderName = 'lesson_${_pad2(lessonNumber)}_${_slugifyTitle(lessonTitle)}';
    final lessonContext = LessonContext(
      lessonNumber: lessonNumber,
      lessonId: data['lesson_id'] as String? ?? '',
      lessonTitle: lessonTitle,
      batchId: batchId,
      reviewStatus: reviewStatus,
      reviewSummary: data['review_summary'] as String? ?? '',
      reviewFocus: data['review_focus'] as String? ?? '',
      estimatedSegmentRuntime:
          data['estimated_segment_runtime'] as String? ?? '',
      estimatedArabicRuntime:
          data['estimated_arabic_asset_runtime'] as String? ?? '',
      sourcePaths: ((data['source_paths'] as List<dynamic>? ?? const <dynamic>[])
              .cast<String>())
          .toList(),
      sourceDataPath: dataFile.path.replaceAll('\\', '/'),
      sourceScriptPath: scriptFile.path.replaceAll('\\', '/'),
      currentScriptContent: scriptFile.readAsStringSync(),
      reviewRows: lessonRows,
      outputFolderName: folderName,
    );
    lessonContexts.add(lessonContext);

    final lessonDir = Directory('${packetRoot.path}/$folderName')
      ..createSync(recursive: true);
    final currentScriptPath =
        '${lessonDir.path}/lesson_${_pad2(lessonNumber)}_current_script.md';
    final flaggedSegmentsPath =
        '${lessonDir.path}/lesson_${_pad2(lessonNumber)}_flagged_segments.md';
    final reviewSheetPath =
        '${lessonDir.path}/lesson_${_pad2(lessonNumber)}_review_sheet.csv';

    File(currentScriptPath).writeAsStringSync(
      _currentScriptMarkdown(spec: spec, lesson: lessonContext),
    );
    File(flaggedSegmentsPath).writeAsStringSync(
      _flaggedSegmentsMarkdown(spec: spec, lesson: lessonContext),
    );
    _writeCsv(
      reviewSheetPath,
      _lessonReviewSheetColumns,
      lessonRows.map((row) => _reviewSheetRow(spec, lessonContext, row)).toList(),
    );

    packetChecklistRows.add(<String, String>{
      'packet_type': spec.packetType,
      'lesson_number': _pad2(lessonContext.lessonNumber),
      'lesson_id': lessonContext.lessonId,
      'lesson_title': lessonContext.lessonTitle,
      'batch_id': lessonContext.batchId,
      'review_status': lessonContext.reviewStatus,
      'flagged_item_count': lessonContext.reviewRows.length.toString(),
      'review_focus': lessonContext.reviewFocus,
      'current_script_file': currentScriptPath.replaceAll('\\', '/'),
      'flagged_segments_file': flaggedSegmentsPath.replaceAll('\\', '/'),
      'review_sheet_file': reviewSheetPath.replaceAll('\\', '/'),
      'reviewer_comment': '',
      'decision': '',
      'final_resolution': '',
    });

    manifestLessons.add(<String, dynamic>{
      'lesson_number': lessonContext.lessonNumber,
      'lesson_id': lessonContext.lessonId,
      'lesson_title': lessonContext.lessonTitle,
      'batch_id': lessonContext.batchId,
      'review_status': lessonContext.reviewStatus,
      'review_summary': lessonContext.reviewSummary,
      'review_focus': lessonContext.reviewFocus,
      'flagged_item_count': lessonContext.reviewRows.length,
      'source_data_path': lessonContext.sourceDataPath,
      'source_script_path': lessonContext.sourceScriptPath,
      'canonical_sources': lessonContext.sourcePaths,
      'output_folder': lessonDir.path.replaceAll('\\', '/'),
      'output_files': <String>[
        currentScriptPath,
        flaggedSegmentsPath,
        reviewSheetPath,
      ].map((path) => path.replaceAll('\\', '/')).toList(),
      'flagged_segment_ids': lessonContext.reviewRows
          .map((row) => row['segment_id'] ?? '')
          .where((id) => id.isNotEmpty)
          .toList(),
    });
  }

  final checklistPath = '${packetRoot.path}/packet_reviewer_checklist.csv';
  final readmePath = '${packetRoot.path}/README.md';
  final manifestPath = '${packetRoot.path}/packet_manifest.json';
  _writeCsv(checklistPath, _packetChecklistColumns, packetChecklistRows);
  File(readmePath).writeAsStringSync(
    _packetReadme(
      spec: spec,
      lessons: lessonContexts,
      sourceGeneratedAt: sourceGeneratedAt,
      checklistPath: checklistPath.replaceAll('\\', '/'),
    ),
  );
  File(manifestPath).writeAsStringSync(
    JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'packet_type': spec.packetType,
      'packet_title': spec.packetTitle,
      'source_generated_at': sourceGeneratedAt,
      'generated_from': <String, String>{
        'review_status': _reviewStatusPath,
        'review_queue': _reviewQueuePath,
        'summary': _summaryPath,
      },
      'included_lessons': spec.lessonNumbers,
      'lesson_count': spec.lessonNumbers.length,
      'flagged_item_count': packetRows.length,
      'decision_options': spec.decisionOptions,
      'review_sheet_columns': _lessonReviewSheetColumns,
      'packet_checklist': checklistPath.replaceAll('\\', '/'),
      'lessons': manifestLessons,
    }),
  );
}

Map<String, String> _reviewSheetRow(
  PacketSpec spec,
  LessonContext lesson,
  Map<String, String> row,
) {
  return <String, String>{
    'packet_type': spec.packetType,
    'lesson_number': _pad2(lesson.lessonNumber),
    'lesson_id': lesson.lessonId,
    'lesson_title': lesson.lessonTitle,
    'batch_id': lesson.batchId,
    'review_status': lesson.reviewStatus,
    'review_focus': lesson.reviewFocus,
    'segment_id': row['segment_id'] ?? '',
    'row_kind': row['row_kind'] ?? '',
    'segment_type': row['segment_type'] ?? '',
    'asset_stem': row['asset_stem'] ?? '',
    'source_ref': row['source_ref'] ?? '',
    'export_state': row['export_state'] ?? '',
    'native_review_flag': row['native_review_flag'] ?? '',
    'planned_audio_filename': row['planned_audio_filename'] ?? '',
    'planned_audio_asset_path': row['planned_audio_asset_path'] ?? '',
    'target_duration_sec': row['target_duration_sec'] ?? '',
    'repeatability': row['repeatability'] ?? '',
    'current_line_text': _currentLineText(row),
    'script_text_ar': row['script_text_ar'] ?? '',
    'script_text_support': row['script_text_support'] ?? '',
    'delivery_note': row['delivery_note'] ?? '',
    'risk_reason': row['review_reason'] ?? '',
    'reviewer_comment': '',
    'suggested_revision': '',
    'decision': '',
    'final_resolution': '',
  };
}

String _currentScriptMarkdown({
  required PacketSpec spec,
  required LessonContext lesson,
}) {
  return '''# Lesson ${_pad2(lesson.lessonNumber)} Current Script Copy

- Packet type: `${spec.packetType}`
- Review status: `${lesson.reviewStatus}`
- Batch: `${lesson.batchId}`
- Lesson ID: `${lesson.lessonId}`
- Lesson title: `${lesson.lessonTitle}`
- Review summary: ${lesson.reviewSummary}
- Review focus: ${lesson.reviewFocus.isEmpty ? '(none)' : lesson.reviewFocus}
- Source script: `${lesson.sourceScriptPath}`
- Source data: `${lesson.sourceDataPath}`
- Estimated narration runtime: `${lesson.estimatedSegmentRuntime}`
- Estimated Arabic asset runtime: `${lesson.estimatedArabicRuntime}`

Use this copy as read-only context. Put reviewer comments and decisions in the lesson review sheet, not in this file.

---

${lesson.currentScriptContent}''';
}

String _flaggedSegmentsMarkdown({
  required PacketSpec spec,
  required LessonContext lesson,
}) {
  final b = StringBuffer()
    ..writeln('# Lesson ${_pad2(lesson.lessonNumber)} Flagged Review Items')
    ..writeln()
    ..writeln('- Packet type: `${spec.packetType}`')
    ..writeln('- Review status: `${lesson.reviewStatus}`')
    ..writeln('- Batch: `${lesson.batchId}`')
    ..writeln('- Lesson ID: `${lesson.lessonId}`')
    ..writeln('- Lesson title: `${lesson.lessonTitle}`')
    ..writeln('- Review summary: ${lesson.reviewSummary}')
    ..writeln('- Review focus: ${lesson.reviewFocus.isEmpty ? '(none)' : lesson.reviewFocus}')
    ..writeln('- Flagged item count: `${lesson.reviewRows.length}`')
    ..writeln('- Full current script copy: `lesson_${_pad2(lesson.lessonNumber)}_current_script.md`')
    ..writeln('- Review sheet: `lesson_${_pad2(lesson.lessonNumber)}_review_sheet.csv`')
    ..writeln();

  for (var i = 0; i < lesson.reviewRows.length; i++) {
    final row = lesson.reviewRows[i];
    b
      ..writeln('## ${_pad2(i + 1)}. `${row['segment_id'] ?? ''}`')
      ..writeln()
      ..writeln('- Row kind: `${row['row_kind'] ?? ''}`')
      ..writeln('- Segment type: `${row['segment_type'] ?? ''}`')
      ..writeln('- Asset stem: `${row['asset_stem'] ?? ''}`')
      ..writeln('- Source ref: `${row['source_ref'] ?? ''}`')
      ..writeln('- Export state: `${row['export_state'] ?? ''}`')
      ..writeln('- Native review flag: `${row['native_review_flag'] ?? ''}`')
      ..writeln('- Planned audio filename: `${row['planned_audio_filename'] ?? ''}`')
      ..writeln('- Logical asset path: `${row['planned_audio_asset_path'] ?? ''}`')
      ..writeln('- Risk reason: ${row['review_reason'] ?? ''}')
      ..writeln('- Delivery note: ${row['delivery_note'] ?? ''}')
      ..writeln()
      ..writeln('Current line text:')
      ..writeln('```text')
      ..writeln(_currentLineText(row))
      ..writeln('```');

    final supportText = (row['script_text_support'] ?? '').trim();
    final arabicText = (row['script_text_ar'] ?? '').trim();
    if (supportText.isNotEmpty && supportText != _currentLineText(row)) {
      b
        ..writeln()
        ..writeln('Support reference:')
        ..writeln('```text')
        ..writeln(supportText)
        ..writeln('```');
    } else if (arabicText.isNotEmpty && arabicText != _currentLineText(row)) {
      b
        ..writeln()
        ..writeln('Support reference:')
        ..writeln('```text')
        ..writeln(arabicText)
        ..writeln('```');
    }

    b
      ..writeln()
      ..writeln('Reviewer comment:')
      ..writeln('`<fill in>`')
      ..writeln()
      ..writeln('Suggested revision:')
      ..writeln('`<fill in>`')
      ..writeln()
      ..writeln('Decision:')
      ..writeln('`<fill in>`')
      ..writeln()
      ..writeln('Final resolution:')
      ..writeln('`<fill in>`')
      ..writeln();
  }

  return b.toString();
}

String _packetReadme({
  required PacketSpec spec,
  required List<LessonContext> lessons,
  required String sourceGeneratedAt,
  required String checklistPath,
}) {
  final lessonLine = lessons
      .map((lesson) => 'Lesson ${_pad2(lesson.lessonNumber)}: ${lesson.lessonTitle}')
      .join(' ; ');
  final totalFlags = lessons.fold<int>(0, (sum, lesson) => sum + lesson.reviewRows.length);
  final decisionList = spec.decisionOptions.map((option) => '- `$option`').join('\n');

  return '''# ${spec.packetTitle}

- Source generated at: `$sourceGeneratedAt`
- ${spec.readmeScopeLine}
- Included lessons: $lessonLine
- Total flagged items: `$totalFlags`
- Packet reviewer checklist: `${checklistPath}`

## How To Review

1. Open the lesson folder you are reviewing.
2. Read `lesson_{NN}_current_script.md` for full lesson context.
3. Use `lesson_{NN}_flagged_segments.md` if you want a reviewer-friendly view of only the blocked items.
4. Fill the structured fields in `lesson_{NN}_review_sheet.csv`.
5. Mirror the lesson-level outcome back into `packet_reviewer_checklist.csv` so packet status stays visible in one place.

## Required Reviewer Fields

- `reviewer_comment`: explain what is wrong, unclear, or confirmed safe.
- `suggested_revision`: write the exact spoken form, pacing note, or export instruction you want used.
- `decision`: pick one of the packet decision values below.
- `final_resolution`: record the final accepted handling after discussion or revision.

## Decision Values

$decisionList

## Reviewer Guidance

- Do not review recording-ready lessons in this packet.
- Do not add Lessons 13-16; they remain placeholder-only.
- If a blocked line is actually safe, note why and mark the decision clearly.
- If the issue is not linguistic but product or export-policy related, use a product-decision outcome rather than forcing a script guess.
- Keep edits attached to the canonical line or asset stem already in the package; do not invent a new lesson structure.
''';
}

Map<int, File> _indexFilesByLesson(Directory directory, String extension) {
  final map = <int, File>{};
  for (final entity in directory.listSync()) {
    if (entity is! File || !entity.path.endsWith(extension)) {
      continue;
    }
    final fileName = entity.uri.pathSegments.last;
    final match = RegExp(r'^lesson_(\d{2})_').firstMatch(fileName);
    if (match == null) {
      continue;
    }
    map[int.parse(match.group(1)!)] = entity;
  }
  return map;
}

Map<String, int> _rowOrderIndex(Map<String, dynamic> data) {
  final order = <String, int>{};
  var index = 0;
  for (final item in (data['normalized_segments'] as List<dynamic>? ?? const <dynamic>[])) {
    final id = (item as Map<String, dynamic>)['segment_id'] as String? ?? '';
    if (id.isNotEmpty) {
      order[id] = index;
      index += 1;
    }
  }
  for (final item in (data['normalized_arabic_assets'] as List<dynamic>? ?? const <dynamic>[])) {
    final id = (item as Map<String, dynamic>)['bank_id'] as String? ?? '';
    if (id.isNotEmpty) {
      order[id] = index;
      index += 1;
    }
  }
  return order;
}

String _currentLineText(Map<String, String> row) {
  final support = (row['script_text_support'] ?? '').trim();
  final arabic = (row['script_text_ar'] ?? '').trim();
  if (row['row_kind'] == 'ARABIC_ASSET') {
    return arabic.isNotEmpty ? arabic : support;
  }
  return support.isNotEmpty ? support : arabic;
}

int _lessonNumberFromReviewRow(Map<String, String> row) {
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

Map<String, int> _parseReviewStatusMarkdown(String markdown) {
  int extract(String label) {
    final match = RegExp('- $label: `([0-9]+)` lessons').firstMatch(markdown);
    return match == null ? -1 : int.parse(match.group(1)!);
  }

  return <String, int>{
    'pass': extract('Pass'),
    'revise': extract('Revise'),
    'needs_native_review': extract('Needs native review'),
  };
}

int _extractReviewQueueRowCount(String markdown) {
  final match = RegExp(r'- Review queue rows: `([0-9]+)`').firstMatch(markdown);
  if (match == null) {
    throw StateError('Could not parse review queue row count from summary.');
  }
  return int.parse(match.group(1)!);
}

String _extractGeneratedAt(String markdown) {
  final match = RegExp(r'- Generated at: `([^`]+)`').firstMatch(markdown);
  if (match == null) {
    throw StateError('Could not parse generated-at stamp.');
  }
  return match.group(1)!;
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

String _batchId(String batch) {
  switch (batch) {
    case 'Batch A':
      return 'BATCH_A';
    case 'Batch B':
      return 'BATCH_B';
    case 'Batch C':
      return 'BATCH_C';
    default:
      return batch.replaceAll(' ', '_').toUpperCase();
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

String _slugifyTitle(String title) {
  final ascii = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  final compact = ascii.trim().replaceAll(RegExp(r'\s+'), '_');
  return compact.isEmpty ? 'lesson' : compact;
}

String _pad2(int value) => value.toString().padLeft(2, '0');

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
