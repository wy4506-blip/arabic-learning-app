import 'dart:convert';
import 'dart:io';

const _root = 'docs/voiceover_production_lessons_1_16';
const _manifestPath = '$_root/voiceover_manifest.json';
const _reviewStatusPath = '$_root/review_status_lessons_01_12.md';
const _taskSheetPath = '$_root/recording_task_sheet_lessons_01_12.csv';
const _reviewQueuePath = '$_root/review_queue_lessons_01_12.csv';
const _summaryPath = '$_root/recording_export_summary_lessons_01_12.md';

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

const _reviewQueueColumns = <String>[
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
  'review_reason',
  'review_source_ref',
];

void main() {
  final manifestFile = File(_manifestPath);
  final reviewStatusFile = File(_reviewStatusPath);
  if (!manifestFile.existsSync()) {
    stderr.writeln('Missing manifest: $_manifestPath');
    exitCode = 1;
    return;
  }
  if (!reviewStatusFile.existsSync()) {
    stderr.writeln('Missing review status file: $_reviewStatusPath');
    exitCode = 1;
    return;
  }

  final manifest = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  final reviewStatusMarkdown = reviewStatusFile.readAsStringSync();
  final generatedAt = manifest['generated_at_utc'] as String? ?? DateTime.now().toUtc().toIso8601String();
  final lessons = ((manifest['lessons'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>())
      .where((lesson) => (lesson['lesson_number'] as num?) != null)
      .where((lesson) => (lesson['lesson_number'] as num) <= 12)
      .where((lesson) => lesson['status'] == 'final_script_normalized')
      .toList()
    ..sort((a, b) => (a['lesson_number'] as num).compareTo(b['lesson_number'] as num));

  final taskRows = <Map<String, String>>[];
  final reviewRows = <Map<String, String>>[];
  final lessonCountsByStatus = <String, int>{};
  final lessonCountsByBatch = <String, Map<String, int>>{};
  final rowCountsByStatus = <String, int>{};
  final rowCountsByBatch = <String, Map<String, int>>{};
  final reviewQueueCountsByBatch = <String, int>{};

  for (final lesson in lessons) {
    final dataPath = lesson['data_path'] as String;
    final dataFile = File(dataPath);
    if (!dataFile.existsSync()) {
      stderr.writeln('Missing lesson data: $dataPath');
      exitCode = 1;
      return;
    }
    final data = jsonDecode(dataFile.readAsStringSync()) as Map<String, dynamic>;
    final lessonId = data['lesson_id'] as String? ?? '';
    final lessonTitle = data['title'] as String? ?? '';
    final lessonNumber = (data['lesson_number'] as num).toInt();
    final batchId = _batchId(data['batch'] as String? ?? '');
    final productionStatus = _productionStatus(data['review_status'] as String? ?? '');

    lessonCountsByStatus[productionStatus] =
        (lessonCountsByStatus[productionStatus] ?? 0) + 1;
    final batchLessonCounts =
        lessonCountsByBatch.putIfAbsent(batchId, () => <String, int>{});
    batchLessonCounts[productionStatus] =
        (batchLessonCounts[productionStatus] ?? 0) + 1;

    final rowById = <String, Map<String, String>>{};

    for (final segment
        in (data['normalized_segments'] as List<dynamic>? ?? const <dynamic>[])) {
      final row = _segmentRow(
        lessonNumber: lessonNumber,
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        batchId: batchId,
        productionStatus: productionStatus,
        segment: segment as Map<String, dynamic>,
      );
      taskRows.add(row);
      rowById[row['segment_id']!] = row;
      rowCountsByStatus[productionStatus] =
          (rowCountsByStatus[productionStatus] ?? 0) + 1;
      final batchRowCounts =
          rowCountsByBatch.putIfAbsent(batchId, () => <String, int>{});
      batchRowCounts[productionStatus] =
          (batchRowCounts[productionStatus] ?? 0) + 1;
    }

    for (final asset
        in (data['normalized_arabic_assets'] as List<dynamic>? ?? const <dynamic>[])) {
      final row = _arabicAssetRow(
        lessonNumber: lessonNumber,
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        batchId: batchId,
        productionStatus: productionStatus,
        asset: asset as Map<String, dynamic>,
      );
      taskRows.add(row);
      rowById[row['segment_id']!] = row;
      rowCountsByStatus[productionStatus] =
          (rowCountsByStatus[productionStatus] ?? 0) + 1;
      final batchRowCounts =
          rowCountsByBatch.putIfAbsent(batchId, () => <String, int>{});
      batchRowCounts[productionStatus] =
          (batchRowCounts[productionStatus] ?? 0) + 1;
    }

    for (final flagged
        in (data['flagged_items'] as List<dynamic>? ?? const <dynamic>[])) {
      final flag = flagged as Map<String, dynamic>;
      final currentId = flag['current_id'] as String? ?? '';
      final baseRow = rowById[currentId] ??
          _fallbackReviewRow(
            lessonNumber: lessonNumber,
            lessonId: lessonId,
            lessonTitle: lessonTitle,
            batchId: batchId,
            productionStatus: productionStatus,
            flag: flag,
          );
      final reviewRow = Map<String, String>.from(baseRow)
        ..['review_reason'] = flag['reason'] as String? ?? ''
        ..['review_source_ref'] = flag['source_ref'] as String? ?? '';
      reviewRows.add(reviewRow);
      reviewQueueCountsByBatch[batchId] =
          (reviewQueueCountsByBatch[batchId] ?? 0) + 1;
    }
  }

  final markdownCounts = _parseReviewStatusMarkdown(reviewStatusMarkdown);
  final computedCounts = <String, int>{
    'pass': lessons.where((lesson) => lesson['review_status'] == 'pass').length,
    'revise': lessons.where((lesson) => lesson['review_status'] == 'revise').length,
    'needs_native_review': lessons
        .where((lesson) => lesson['review_status'] == 'needs_native_review')
        .length,
  };
  final reviewCountsMatch =
      markdownCounts['pass'] == computedCounts['pass'] &&
      markdownCounts['revise'] == computedCounts['revise'] &&
      markdownCounts['needs_native_review'] ==
          computedCounts['needs_native_review'];

  _writeCsv(_taskSheetPath, _taskSheetColumns, taskRows);
  _writeCsv(_reviewQueuePath, _reviewQueueColumns, reviewRows);
  File(_summaryPath).writeAsStringSync(
    _summaryMarkdown(
      generatedAt: generatedAt,
      lessonCountsByStatus: lessonCountsByStatus,
      lessonCountsByBatch: lessonCountsByBatch,
      rowCountsByStatus: rowCountsByStatus,
      rowCountsByBatch: rowCountsByBatch,
      reviewQueueCountsByBatch: reviewQueueCountsByBatch,
      reviewCountsMatch: reviewCountsMatch,
      taskRowCount: taskRows.length,
      reviewRowCount: reviewRows.length,
    ),
  );

  stdout.writeln(
    'Exported ${taskRows.length} task rows and ${reviewRows.length} review rows for Lessons 01-12.',
  );
}

Map<String, String> _segmentRow({
  required int lessonNumber,
  required String lessonId,
  required String lessonTitle,
  required String batchId,
  required String productionStatus,
  required Map<String, dynamic> segment,
}) {
  final assetStem = segment['asset_stem'] as String? ?? '';
  return <String, String>{
    'lesson_id': lessonId,
    'lesson_title': lessonTitle,
    'segment_id': segment['segment_id'] as String? ?? '',
    'segment_type': segment['segment_type'] as String? ?? '',
    'script_text_ar': _extractArabic(segment['text'] as String? ?? ''),
    'script_text_support': segment['text'] as String? ?? '',
    'delivery_note': segment['delivery_notes'] as String? ?? '',
    'target_duration_sec': _durationMidpointSeconds(segment['duration_target'] as String? ?? ''),
    'repeatability': _repeatability(segment['repeatable'] as String? ?? ''),
    'native_review_flag': _nativeReviewFlag(segment['native_review'] as String? ?? ''),
    'export_state': _exportState(segment['export_state'] as String? ?? ''),
    'planned_audio_filename': '${assetStem}_normal.mp3',
    'batch_id': batchId,
    'production_status': productionStatus,
    'row_kind': 'NARRATION_SEGMENT',
    'asset_stem': assetStem,
    'source_ref': segment['source_ref'] as String? ?? '',
    'planned_audio_asset_path': 'lesson_${lessonNumber.toString().padLeft(2, '0')}/voiceover/${assetStem}_normal.mp3',
  };
}
Map<String, String> _arabicAssetRow({
  required int lessonNumber,
  required String lessonId,
  required String lessonTitle,
  required String batchId,
  required String productionStatus,
  required Map<String, dynamic> asset,
}) {
  final assetStem = asset['asset_stem'] as String? ?? '';
  return <String, String>{
    'lesson_id': lessonId,
    'lesson_title': lessonTitle,
    'segment_id': asset['bank_id'] as String? ?? '',
    'segment_type': asset['asset_type'] as String? ?? '',
    'script_text_ar': asset['spoken_text'] as String? ?? '',
    'script_text_support': _supportText(asset),
    'delivery_note': asset['delivery_notes'] as String? ?? '',
    'target_duration_sec': _durationMidpointSeconds(asset['duration_target'] as String? ?? ''),
    'repeatability': _repeatability(asset['repeatable'] as String? ?? ''),
    'native_review_flag': _nativeReviewFlag(asset['native_review'] as String? ?? ''),
    'export_state': _exportState(asset['export_state'] as String? ?? ''),
    'planned_audio_filename': '${assetStem}_normal.mp3',
    'batch_id': batchId,
    'production_status': productionStatus,
    'row_kind': 'ARABIC_ASSET',
    'asset_stem': assetStem,
    'source_ref': asset['source_ref'] as String? ?? '',
    'planned_audio_asset_path': 'lesson_${lessonNumber.toString().padLeft(2, '0')}/voiceover/${assetStem}_normal.mp3',
  };
}

Map<String, String> _fallbackReviewRow({
  required int lessonNumber,
  required String lessonId,
  required String lessonTitle,
  required String batchId,
  required String productionStatus,
  required Map<String, dynamic> flag,
}) {
  final assetStem = flag['asset_stem'] as String? ?? '';
  return <String, String>{
    'lesson_id': lessonId,
    'lesson_title': lessonTitle,
    'segment_id': flag['current_id'] as String? ?? '',
    'segment_type': '',
    'script_text_ar': _extractArabic(flag['text'] as String? ?? ''),
    'script_text_support': flag['text'] as String? ?? '',
    'delivery_note': '',
    'target_duration_sec': '',
    'repeatability': '',
    'native_review_flag': _nativeReviewFlag(flag['native_review'] as String? ?? ''),
    'export_state': _exportState(flag['export_state'] as String? ?? ''),
    'planned_audio_filename': assetStem.isEmpty ? '' : '${assetStem}_normal.mp3',
    'batch_id': batchId,
    'production_status': productionStatus,
    'row_kind': 'REVIEW_FALLBACK',
    'asset_stem': assetStem,
    'source_ref': flag['source_ref'] as String? ?? '',
    'planned_audio_asset_path': assetStem.isEmpty
        ? ''
        : 'lesson_${lessonNumber.toString().padLeft(2, '0')}/voiceover/${assetStem}_normal.mp3',
  };
}

String _supportText(Map<String, dynamic> asset) {
  final pieces = <String>[];
  final displayText = asset['display_text'] as String? ?? '';
  final transliteration = asset['transliteration'] as String? ?? '';
  final meaning = asset['meaning'] as String? ?? '';
  final notes = asset['notes'] as String? ?? '';
  if (displayText.isNotEmpty) {
    pieces.add('display=$displayText');
  }
  if (transliteration.isNotEmpty) {
    pieces.add('transliteration=$transliteration');
  }
  if (meaning.isNotEmpty) {
    pieces.add('meaning=$meaning');
  }
  if (notes.isNotEmpty) {
    pieces.add('notes=$notes');
  }
  return pieces.join(' ; ');
}

String _extractArabic(String value) {
  final matches = RegExp(r'[\u0600-\u06FF]+').allMatches(value);
  return matches.map((match) => match.group(0)!).join(' ').trim();
}

String _durationMidpointSeconds(String range) {
  final match =
      RegExp(r'^(\d{2}):(\d{2})-(\d{2}):(\d{2})$').firstMatch(range);
  if (match == null) {
    return '';
  }
  final startSeconds =
      int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
  final endSeconds =
      int.parse(match.group(3)!) * 60 + int.parse(match.group(4)!);
  return (((startSeconds + endSeconds) / 2).round()).toString();
}

String _repeatability(String value) {
  return value.toLowerCase() == 'yes' ? 'REPEATABLE' : 'ONE_PASS';
}

String _nativeReviewFlag(String value) {
  return value.toLowerCase() == 'check' ? 'REQUIRED' : 'NOT_REQUIRED';
}

String _exportState(String value) {
  switch (value.toLowerCase()) {
    case 'hold':
      return 'HOLD';
    case 'review':
      return 'REVIEW';
    default:
      return 'READY';
  }
}

String _productionStatus(String reviewStatus) {
  switch (reviewStatus) {
    case 'pass':
      return 'RECORDING_READY';
    case 'revise':
      return 'REVISE_REQUIRED';
    case 'needs_native_review':
      return 'NATIVE_REVIEW_REQUIRED';
    default:
      return 'PLACEHOLDER_ONLY';
  }
}

String _batchId(String batchLabel) {
  switch (batchLabel) {
    case 'Batch A':
      return 'BATCH_A';
    case 'Batch B':
      return 'BATCH_B';
    case 'Batch C':
      return 'BATCH_C';
    default:
      return 'UNASSIGNED';
  }
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

void _writeCsv(
  String path,
  List<String> columns,
  List<Map<String, String>> rows,
) {
  final buffer = StringBuffer()
    ..writeln(columns.map(_csvEscape).join(','));
  for (final row in rows) {
    buffer.writeln(
      columns.map((column) => _csvEscape(row[column] ?? '')).join(','),
    );
  }
  File(path).writeAsStringSync(buffer.toString());
}

String _csvEscape(String value) {
  final normalized = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final escaped = normalized.replaceAll('"', '""');
  return '"$escaped"';
}
String _summaryMarkdown({
  required String generatedAt,
  required Map<String, int> lessonCountsByStatus,
  required Map<String, Map<String, int>> lessonCountsByBatch,
  required Map<String, int> rowCountsByStatus,
  required Map<String, Map<String, int>> rowCountsByBatch,
  required Map<String, int> reviewQueueCountsByBatch,
  required bool reviewCountsMatch,
  required int taskRowCount,
  required int reviewRowCount,
}) {
  final b = StringBuffer()
    ..writeln('# Recording Export Summary For Lessons 01-12')
    ..writeln()
    ..writeln('- Generated at: `$generatedAt`')
    ..writeln('- Recording task sheet: `recording_task_sheet_lessons_01_12.csv`')
    ..writeln('- Review queue: `review_queue_lessons_01_12.csv`')
    ..writeln('- Summary scope: Lessons 1-12 only; Lessons 13-16 remain placeholder-only and are excluded from recording exports.')
    ..writeln('- Review status cross-check with markdown report: `${reviewCountsMatch ? 'MATCH' : 'MISMATCH'}`')
    ..writeln()
    ..writeln('## Counts By Production Status')
    ..writeln()
    ..writeln('| Production status | Lesson count | Row count |')
    ..writeln('| --- | --- | --- |');

  for (final status in <String>[
    'RECORDING_READY',
    'REVISE_REQUIRED',
    'NATIVE_REVIEW_REQUIRED',
  ]) {
    b.writeln(
      '| `$status` | `${lessonCountsByStatus[status] ?? 0}` | `${rowCountsByStatus[status] ?? 0}` |',
    );
  }

  b
    ..writeln()
    ..writeln('## Counts By Batch')
    ..writeln()
    ..writeln('| Batch | Lesson counts | Row counts | Review queue rows |')
    ..writeln('| --- | --- | --- | --- |');

  for (final batchId in <String>['BATCH_A', 'BATCH_B', 'BATCH_C']) {
    final lessonCounts = lessonCountsByBatch[batchId] ?? const <String, int>{};
    final rowCounts = rowCountsByBatch[batchId] ?? const <String, int>{};
    final lessonSummary = _statusSummary(lessonCounts);
    final rowSummary = _statusSummary(rowCounts);
    b.writeln(
      '| `$batchId` | ${_cell(lessonSummary)} | ${_cell(rowSummary)} | `${reviewQueueCountsByBatch[batchId] ?? 0}` |',
    );
  }

  b
    ..writeln()
    ..writeln('## Export Totals')
    ..writeln()
    ..writeln('- Task sheet rows: `$taskRowCount`')
    ..writeln('- Review queue rows: `$reviewRowCount`')
    ..writeln('- Ready batches: `BATCH_B` is fully `RECORDING_READY`; `BATCH_A` is mixed; `BATCH_C` remains fully review-gated.')
    ..writeln()
    ..writeln('## Production Rules Applied')
    ..writeln()
    ..writeln('- `pass` lessons map to `RECORDING_READY`.')
    ..writeln('- Lesson 3 maps to `REVISE_REQUIRED`.')
    ..writeln('- Lessons 4, 9, 10, 11, 12 map to `NATIVE_REVIEW_REQUIRED`.')
    ..writeln('- Lessons 13-16 stay `PLACEHOLDER_ONLY` and do not enter recording exports.');
  return b.toString();
}

String _statusSummary(Map<String, int> counts) {
  final parts = <String>[];
  for (final status in <String>[
    'RECORDING_READY',
    'REVISE_REQUIRED',
    'NATIVE_REVIEW_REQUIRED',
  ]) {
    parts.add('$status=${counts[status] ?? 0}');
  }
  return parts.join(' ; ');
}

String _cell(String value) {
  return value.replaceAll('|', r'\|').replaceAll('\n', '<br>');
}
