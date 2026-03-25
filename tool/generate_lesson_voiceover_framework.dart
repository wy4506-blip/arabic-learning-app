import 'dart:convert';
import 'dart:io';

import 'package:arabic_learning_app/data/v2_micro_lesson_catalog.dart';
import 'package:arabic_learning_app/models/v2_micro_lesson.dart';

const _root = 'docs/voiceover_production_lessons_1_16';
const _finalDir = '$_root/scripts/final';
const _placeholderDir = '$_root/scripts/placeholders';
const _dataDir = '$_root/data';
const _manifestPath = '$_root/voiceover_manifest.json';
const _readmePath = '$_root/README.md';
const _reviewStatusPath = '$_root/review_status_lessons_01_12.md';
const _batchPlanPath = '$_root/recording_batch_plan_lessons_01_12.md';
const _filenameConventionPath = '$_root/audio_filename_convention_spec.md';
const _templatePath = '$_root/templates/lesson_voiceover_script_template.md';

class ReviewFlag {
  final String sourceRef;
  final String action;
  final bool nativeReview;
  final String reason;

  const ReviewFlag({
    required this.sourceRef,
    required this.action,
    required this.nativeReview,
    required this.reason,
  });
}

class ReviewConfig {
  final String status;
  final String summary;
  final String focus;
  final List<ReviewFlag> flags;

  const ReviewConfig({
    required this.status,
    required this.summary,
    required this.focus,
    required this.flags,
  });
}

const Map<int, List<String>> _sources = <int, List<String>>{
  1: <String>[
    'lib/data/generated_stage_a_preview_lessons.dart',
    'docs/generated_lessons/v2_a1_01_arabic_starts_here.md',
    'test/stage_a_preview_page_test.dart',
  ],
  2: <String>[
    'lib/data/generated_stage_a_preview_lessons.dart',
    'docs/generated_lessons/v2_a1_02_first_script_success.md',
    'test/stage_a_preview_page_test.dart',
  ],
  3: <String>[
    'lib/data/generated_stage_a_preview_lessons.dart',
    'docs/generated_lessons/v2_a1_03_same_letter_new_shape.md',
    'test/stage_a_preview_page_test.dart',
  ],
  4: <String>[
    'lib/data/generated_stage_a_preview_lessons.dart',
    'docs/generated_lessons/v2_a1_04_short_vowels_make_reading_possible.md',
    'test/stage_a_preview_page_test.dart',
  ],
  5: <String>[
    'lib/data/generated_stage_b_preview_lessons.dart',
    'docs/generated_lessons/v2_b1_05_qalam_first_real_word_extension.md',
    'test/stage_b_preview_page_test.dart',
  ],
  6: <String>[
    'lib/data/generated_stage_b_preview_lessons.dart',
    'docs/generated_lessons/v2_b1_06_hadha_first_fixed_expression.md',
    'test/stage_b_preview_page_test.dart',
  ],
  7: <String>[
    'lib/data/generated_stage_b_preview_lessons.dart',
    'docs/generated_lessons/v2_b1_07_audio_first_known_content_recognition.md',
    'test/stage_b_preview_page_test.dart',
  ],
  8: <String>[
    'lib/data/generated_stage_b_preview_lessons.dart',
    'docs/generated_lessons/v2_b1_08_first_usable_arabic_pack.md',
    'test/stage_b_preview_page_test.dart',
  ],
  9: <String>[
    'lib/data/generated_stage_c_preview_lessons.dart',
    'docs/generated_lessons/v2_c1_09_bayt_make_it_stick.md',
    'docs/generated_lessons/v2_c1_09_bayt_word_has_four_parts.md',
    'test/lesson_09_bayt_make_it_stick_test.dart',
  ],
  10: <String>[
    'lib/data/generated_stage_c_preview_lessons.dart',
    'docs/generated_lessons/v2_c1_10_arabic_gives_you_a_clue_ta_marbuta.md',
    'test/lesson_10_arabic_gives_you_a_clue_ta_marbuta_test.dart',
  ],
  11: <String>[
    'lib/data/generated_stage_c_preview_lessons.dart',
    'docs/generated_lessons/v2_c1_11_one_or_more_another_clue.md',
    'test/lesson_11_one_or_more_another_arabic_clue_test.dart',
  ],
  12: <String>[
    'lib/data/generated_stage_c_preview_lessons.dart',
    'test/lesson_12_you_can_read_a_tiny_arabic_card_test.dart',
  ],
};

const Map<int, String> _basis = <int, String>{
  1: 'Runtime lesson object plus generated markdown plus Stage A integration coverage.',
  2: 'Runtime lesson object plus generated markdown plus Stage A integration coverage.',
  3: 'Runtime lesson object plus generated markdown plus Stage A integration coverage.',
  4: 'Runtime lesson object plus generated markdown plus Stage A integration coverage.',
  5: 'Runtime lesson object plus generated markdown plus Stage B integration coverage.',
  6: 'Runtime lesson object plus generated markdown plus Stage B integration coverage.',
  7: 'Runtime lesson object plus generated markdown plus Stage B integration coverage.',
  8: 'Runtime lesson object plus generated markdown plus Stage B integration coverage.',
  9: 'Runtime lesson object plus dedicated test plus two markdown variants; runtime object is canonical.',
  10: 'Runtime lesson object plus generated markdown plus dedicated test.',
  11: 'Runtime lesson object plus generated markdown plus dedicated test.',
  12: 'Runtime lesson object plus dedicated test; runtime object is canonical because generated markdown is missing.',
};

const Map<int, String> _caveats = <int, String>{
  9: 'Lesson 9 has two generated markdown variants in the repository. This framework follows the runtime lesson object only.',
  12: 'Lesson 12 has no generated markdown spec in docs/generated_lessons. This framework follows the runtime lesson object and dedicated test only.',
};

const List<Map<String, Object>> _placeholders = <Map<String, Object>>[
  <String, Object>{
    'lesson_number': 13,
    'stage': 'Stage D',
    'title': 'Study A New Word By Yourself',
    'core_objective': 'Independently study one new Arabic word with a repeatable guided process.',
  },
  <String, Object>{
    'lesson_number': 14,
    'stage': 'Stage D',
    'title': 'Study A New Phrase By Yourself',
    'core_objective': 'Independently study one new short Arabic phrase with a repeatable phrase-learning process.',
  },
  <String, Object>{
    'lesson_number': 15,
    'stage': 'Stage D',
    'title': 'Use Review To Keep It',
    'core_objective': 'Experience how review stabilizes weak or fading Arabic items.',
  },
  <String, Object>{
    'lesson_number': 16,
    'stage': 'Stage D',
    'title': 'Graduation Mini-Project',
    'core_objective': 'Apply the course beginner study process to a tiny new guided Arabic learning task.',
  },
];

const ReviewConfig _defaultReview = ReviewConfig(
  status: 'pass',
  summary: 'No unresolved script issues were found beyond standard QA.',
  focus: 'Proceed with standard recording QA only.',
  flags: <ReviewFlag>[],
);

const Map<int, ReviewConfig> _reviewConfigs = <int, ReviewConfig>{
  1: ReviewConfig(
    status: 'pass',
    summary: 'Single-word entry anchor is natural, beginner-safe, and ready after normalization.',
    focus: 'Keep the orientation language calm and do not over-dramatize the first Arabic word.',
    flags: <ReviewFlag>[],
  ),
  2: ReviewConfig(
    status: 'pass',
    summary: 'The first owned word script is short, stable, and ready after normalization.',
    focus: 'Keep prompts clean and let كتاب stay the clear center of the lesson.',
    flags: <ReviewFlag>[],
  ),
  3: ReviewConfig(
    status: 'revise',
    summary: 'The lesson word itself is fine, but connection-path build artifacts should not be sent into blind TTS export as normal speech.',
    focus: 'Record the core word content normally, but keep connection-path artifacts out of the first export pass.',
    flags: <ReviewFlag>[
      ReviewFlag(
        sourceRef: 'practice:recall_repeated_family_in_bab.expectedAnswer',
        action: 'hold',
        nativeReview: true,
        reason: 'The repeated-family cue is an orthographic fragment rather than a self-evident spoken target.',
      ),
      ReviewFlag(
        sourceRef: 'practice:build_bab_from_connection.expectedAnswer',
        action: 'hold',
        nativeReview: false,
        reason: 'The connection path بـ ا ـب is a UI build artifact, not natural continuous Arabic speech.',
      ),
    ],
  ),
  4: ReviewConfig(
    status: 'needs_native_review',
    summary: 'The lesson is structurally sound, but the vowelled support items should be checked by a native speaker before export.',
    focus: 'Confirm first-pass pronunciation and spoken-versus-display handling for the supported forms.',
    flags: <ReviewFlag>[
      ReviewFlag(
        sourceRef: 'content:input_kitab_supported',
        action: 'review',
        nativeReview: true,
        reason: 'The vowelled support form كِتاب should be confirmed for beginner-safe pronunciation and pacing.',
      ),
      ReviewFlag(
        sourceRef: 'content:input_bab_supported',
        action: 'review',
        nativeReview: true,
        reason: 'The vowelled support form بَاب should be confirmed for beginner-safe pronunciation and pacing.',
      ),
      ReviewFlag(
        sourceRef: 'content:tiny_usage_glimpse',
        action: 'review',
        nativeReview: true,
        reason: 'The spoken/display split around the tiny usage glimpse should be confirmed before export.',
      ),
    ],
  ),
  5: ReviewConfig(
    status: 'pass',
    summary: 'The new-word script for قلم is clean, short, and export-ready after normalization.',
    focus: 'Keep the delivery grounded and let the known pack stay supportive rather than dominant.',
    flags: <ReviewFlag>[],
  ),
  6: ReviewConfig(
    status: 'pass',
    summary: 'The first fixed-expression script is clear and beginner-suitable after normalization.',
    focus: 'Keep هذا steady and avoid turning the line into a grammar lecture in performance.',
    flags: <ReviewFlag>[],
  ),
  7: ReviewConfig(
    status: 'pass',
    summary: 'The audio-first recognition lesson is ready once pack-list pacing is kept explicit in delivery notes.',
    focus: 'Treat pack lines as clean, separate items rather than one run-on utterance.',
    flags: <ReviewFlag>[],
  ),
  8: ReviewConfig(
    status: 'pass',
    summary: 'The Stage B pack lesson is ready after normalization and consistent pacing notes.',
    focus: 'Keep the pack compact and avoid blurring word-versus-line contrasts.',
    flags: <ReviewFlag>[],
  ),
  9: ReviewConfig(
    status: 'needs_native_review',
    summary: 'The lesson is ready at the script level, but the supported-display version of بيت should be checked before export.',
    focus: 'Confirm whether the first-pass support on بَيْت should influence recording or stay display-only.',
    flags: <ReviewFlag>[
      ReviewFlag(
        sourceRef: 'content:input_bayt_word',
        action: 'review',
        nativeReview: true,
        reason: 'The source preserves a spoken/display split for بيت / بَيْت that should be confirmed before export.',
      ),
    ],
  ),
  10: ReviewConfig(
    status: 'needs_native_review',
    summary: 'The lesson concept is clear, but isolated ة references and clue-building artifacts should not be blindly exported.',
    focus: 'Decide how isolated ة should be spoken, if at all, before any human or TTS batch export.',
    flags: <ReviewFlag>[
      ReviewFlag(
        sourceRef: 'lesson.title',
        action: 'hold',
        nativeReview: true,
        reason: 'The title includes isolated ة, which needs a spoken-form decision before recording or TTS export.',
      ),
      ReviewFlag(
        sourceRef: 'lesson.outcomeSummary',
        action: 'review',
        nativeReview: true,
        reason: 'The isolated ة inside an English sentence may be misread by TTS unless its spoken rendering is fixed first.',
      ),
      ReviewFlag(
        sourceRef: 'objective:notice_ta_marbuta_clue',
        action: 'review',
        nativeReview: true,
        reason: 'The isolated glyph should not be left to narrator or engine guesswork.',
      ),
      ReviewFlag(
        sourceRef: 'content:goal_ta_marbuta_clue.body',
        action: 'review',
        nativeReview: true,
        reason: 'The isolated glyph inside the English narration needs a confirmed spoken treatment.',
      ),
      ReviewFlag(
        sourceRef: 'content:explain_ta_marbuta_clue.body',
        action: 'review',
        nativeReview: true,
        reason: 'The isolated glyph inside the English narration needs a confirmed spoken treatment.',
      ),
      ReviewFlag(
        sourceRef: 'practice:spot_ta_marbuta_in_sayyara.prompt',
        action: 'review',
        nativeReview: true,
        reason: 'The prompt contains an isolated orthographic clue and should be reviewed before TTS export.',
      ),
      ReviewFlag(
        sourceRef: 'practice:mark_ta_marbuta_output.prompt',
        action: 'review',
        nativeReview: true,
        reason: 'The prompt mixes an orthographic build instruction with isolated ة and needs reviewed spoken handling.',
      ),
      ReviewFlag(
        sourceRef: 'practice:spot_ta_marbuta_in_sayyara.arabicText',
        action: 'hold',
        nativeReview: true,
        reason: 'The standalone glyph ة is an orthographic clue, not a self-evident standalone spoken asset.',
      ),
      ReviewFlag(
        sourceRef: 'practice:mark_ta_marbuta_output.expectedAnswer',
        action: 'hold',
        nativeReview: true,
        reason: 'The build artifact سيار ة is not natural continuous Arabic speech and should not enter blind export.',
      ),
    ],
  ),
  11: ReviewConfig(
    status: 'needs_native_review',
    summary: 'The one-versus-more lesson is beginner-safe, but the سيارة / سيارات contrast should be checked for export clarity.',
    focus: 'Make sure the plural ending remains clearly audible and not blurred in pair recordings.',
    flags: <ReviewFlag>[
      ReviewFlag(
        sourceRef: 'content:input_main_pair_sayyara',
        action: 'review',
        nativeReview: true,
        reason: 'The main pair needs a native-checked pause and contrast pattern so سيارة and سيارات do not blur together.',
      ),
      ReviewFlag(
        sourceRef: 'content:contrast_support_pair',
        action: 'review',
        nativeReview: true,
        reason: 'The support pair كلمة / كلمات also needs clear plural contrast in audio delivery.',
      ),
    ],
  ),
  12: ReviewConfig(
    status: 'needs_native_review',
    summary: 'The Stage C payoff lesson is structurally ready, but clue-sensitive lines and the tiny-card list should be checked before export.',
    focus: 'Keep the tiny card readable as a paced list and do not let clue lines rely on unreviewed isolated glyph handling.',
    flags: <ReviewFlag>[
      ReviewFlag(
        sourceRef: 'content:input_tiny_supported_card',
        action: 'review',
        nativeReview: true,
        reason: 'The five-item tiny-card sequence needs controlled pauses so the list stays readable and contrastive.',
      ),
      ReviewFlag(
        sourceRef: 'practice:spot_clue_item_on_tiny_card.prompt',
        action: 'review',
        nativeReview: true,
        reason: 'The prompt includes an isolated ة clue inside English narration and should be checked before TTS export.',
      ),
      ReviewFlag(
        sourceRef: 'practice:rebuild_tiny_card_order.expectedAnswer',
        action: 'review',
        nativeReview: true,
        reason: 'The rebuilt card sequence is exportable only if list pacing is explicitly preserved in the spoken output.',
      ),
    ],
  ),
};

void main() {
  for (final path in <String>[_root, _finalDir, _placeholderDir, _dataDir]) {
    Directory(path).createSync(recursive: true);
  }

  final generatedAt = DateTime.now().toUtc().toIso8601String();
  final manifestEntries = <Map<String, Object?>>[];
  final completedEntries = <Map<String, Object?>>[];

  for (var i = 0; i < foundationPilotMicroLessons.length; i += 1) {
    final entry = _buildCompleted(i + 1, foundationPilotMicroLessons[i], generatedAt);
    _writeTextIfChanged(
      entry['script_path']! as String,
      entry['markdown']! as String,
    );
    _writeJsonIfChanged(entry['data_path']! as String, entry['data']!);
    manifestEntries.add(entry['manifest']! as Map<String, Object?>);
    completedEntries.add(entry);
  }

  for (final lesson in _placeholders) {
    final entry = _buildPlaceholder(lesson);
    _writeTextIfChanged(
      entry['script_path']! as String,
      entry['markdown']! as String,
    );
    _writeJsonIfChanged(entry['data_path']! as String, entry['data']!);
    manifestEntries.add(entry['manifest']! as Map<String, Object?>);
  }

  _writeJsonIfChanged(
    _manifestPath,
    <String, Object?>{
      'generated_at_utc': generatedAt,
      'framework_name': 'lesson_voiceover_production_framework_1_16',
      'source_policy': <String>[
        'Completed lessons use runtime V2MicroLesson objects as canonical content.',
        'Generated lesson markdown is referenced only when it already exists in the repository.',
        'Unfinished lessons stay placeholder-only until final runtime content exists.',
        'Lessons 1-12 now include normalized review-ready segment metadata before any TTS export work.',
      ],
      'review_status_path': _reviewStatusPath,
      'recording_batch_plan_path': _batchPlanPath,
      'filename_convention_path': _filenameConventionPath,
      'template_path': _templatePath,
      'lessons': manifestEntries,
    },
  );

  _writeTextIfChanged(_readmePath, _readmeMarkdown(generatedAt, completedEntries));
  _writeTextIfChanged(
    _reviewStatusPath,
    _reviewStatusMarkdown(generatedAt, completedEntries),
  );
  _writeTextIfChanged(
    _batchPlanPath,
    _batchPlanMarkdown(generatedAt, completedEntries),
  );
  _writeTextIfChanged(
    _filenameConventionPath,
    _filenameConventionMarkdown(generatedAt),
  );
  _writeTextIfChanged(_templatePath, _templateMarkdown());

  stdout.writeln(
    'Generated normalized voiceover framework for ${manifestEntries.length} lessons.',
  );
}

Map<String, Object?> _buildCompleted(
  int lessonNumber,
  V2MicroLesson lesson,
  String generatedAt,
) {
  final slug =
      'lesson_${lessonNumber.toString().padLeft(2, '0')}_${_slug(lesson.title)}';
  final scriptPath = '$_finalDir/$slug.md';
  final dataPath = '$_dataDir/$slug.json';
  final ordered = <Map<String, String>>[];
  final arabic = <Map<String, String>>[];
  var ord = 1;
  var ar = 1;
  final seenArabic = <String>{};

  void addOrdered(String role, String source, String text) {
    final value = _norm(text);
    if (value.isEmpty) {
      return;
    }
    ordered.add(<String, String>{
      'line_id':
          'L${lessonNumber.toString().padLeft(2, '0')}_ORD_${ord.toString().padLeft(3, '0')}',
      'asset_stem':
          'l${lessonNumber.toString().padLeft(2, '0')}_ord_${ord.toString().padLeft(3, '0')}',
      'role': role,
      'language': _lang(value),
      'source_ref': source,
      'text': value,
    });
    ord += 1;
  }

  void addArabic(
    String source,
    String? spoken, {
    String? display,
    String? transliteration,
    String? meaning,
    String? notes,
  }) {
    if (spoken == null) {
      return;
    }
    final spokenValue = _norm(spoken);
    if (!_isArabicRecordable(spokenValue)) {
      return;
    }
    final displayValue = _norm(display ?? '');
    final key = '$spokenValue|$displayValue';
    if (!seenArabic.add(key)) {
      return;
    }
    arabic.add(<String, String>{
      'bank_id':
          'L${lessonNumber.toString().padLeft(2, '0')}_AR_${ar.toString().padLeft(3, '0')}',
      'asset_stem':
          'l${lessonNumber.toString().padLeft(2, '0')}_ar_${ar.toString().padLeft(3, '0')}',
      'source_ref': source,
      'spoken_text': spokenValue,
      'display_text': displayValue,
      'transliteration': _norm(transliteration ?? ''),
      'meaning': _norm(meaning ?? ''),
      'notes': _norm(notes ?? ''),
    });
    ar += 1;
  }

  addOrdered('lesson_title', 'lesson.title', lesson.title);
  addOrdered('lesson_outcome', 'lesson.outcomeSummary', lesson.outcomeSummary);
  for (final objective in lesson.objectives) {
    addOrdered(
      'objective_summary',
      'objective:${objective.objectiveId}',
      objective.summary,
    );
  }
  for (final item in lesson.contentItems) {
    addOrdered('content_title', 'content:${item.itemId}.title', item.title);
    addOrdered('content_body', 'content:${item.itemId}.body', item.body);
    addArabic(
      'content:${item.itemId}',
      item.audioQueryText ?? item.arabicText,
      display: item.arabicText,
      transliteration: item.transliteration,
      meaning: item.meaning,
      notes:
          item.audioQueryText != null && item.audioQueryText != item.arabicText
              ? 'Spoken text follows audioQueryText; display text preserves on-screen form.'
              : '',
    );
  }
  for (final item in lesson.practiceItems) {
    addOrdered('practice_prompt', 'practice:${item.itemId}.prompt', item.prompt);
    addArabic(
      'practice:${item.itemId}.arabicText',
      item.arabicText,
      display: item.arabicText,
      transliteration: item.transliteration,
      meaning: item.meaning,
    );
    addArabic(
      'practice:${item.itemId}.expectedAnswer',
      item.expectedAnswer,
      display: item.expectedAnswer,
      transliteration: item.transliteration,
      meaning: item.meaning,
    );
  }
  final review = _reviewFor(lessonNumber);
  final segments = _normalizeSegments(lessonNumber, ordered, review);
  final arabicAssets = _normalizeArabicAssets(lessonNumber, arabic, review);
  final resolvedFlags = _resolveFlags(review, segments, arabicAssets);
  final segmentSeconds = _sumDurationMidpoints(segments, 'duration_target');
  final arabicSeconds = _sumDurationMidpoints(arabicAssets, 'duration_target');

  final data = <String, Object?>{
    'lesson_number': lessonNumber,
    'stage': _stage(lessonNumber),
    'lesson_id': lesson.lessonId,
    'title': lesson.title,
    'status': 'final_script_normalized',
    'generated_at_utc': generatedAt,
    'batch': _batchLabel(lessonNumber),
    'source_paths': _sources[lessonNumber] ?? const <String>[],
    'completeness_basis': _basis[lessonNumber] ?? '',
    'ordered_lines': ordered,
    'arabic_model_bank': arabic,
    'normalized_segments': segments,
    'normalized_arabic_assets': arabicAssets,
    'review_status': review.status,
    'review_summary': review.summary,
    'review_focus': review.focus,
    'flagged_items': resolvedFlags,
    'estimated_segment_runtime': _formatClock(segmentSeconds),
    'estimated_arabic_asset_runtime': _formatClock(arabicSeconds),
    'caveat': _caveats[lessonNumber] ?? '',
  };

  return <String, Object?>{
    'lesson_number': lessonNumber,
    'title': lesson.title,
    'batch': _batchLabel(lessonNumber),
    'script_path': scriptPath,
    'data_path': dataPath,
    'markdown': _completedMarkdown(
      lessonNumber: lessonNumber,
      lesson: lesson,
      generatedAt: generatedAt,
      review: review,
      segments: segments,
      arabicAssets: arabicAssets,
      resolvedFlags: resolvedFlags,
      segmentRuntime: _formatClock(segmentSeconds),
      arabicRuntime: _formatClock(arabicSeconds),
    ),
    'data': data,
    'manifest': <String, Object?>{
      'lesson_number': lessonNumber,
      'stage': _stage(lessonNumber),
      'title': lesson.title,
      'lesson_id': lesson.lessonId,
      'status': 'final_script_normalized',
      'review_status': review.status,
      'batch': _batchLabel(lessonNumber),
      'script_path': scriptPath,
      'data_path': dataPath,
      'source_paths': _sources[lessonNumber] ?? const <String>[],
      'completeness_basis': _basis[lessonNumber] ?? '',
      'segment_count': segments.length,
      'arabic_asset_count': arabicAssets.length,
      'flag_count': resolvedFlags.length,
      'estimated_segment_runtime': _formatClock(segmentSeconds),
      'estimated_arabic_asset_runtime': _formatClock(arabicSeconds),
      'caveat': _caveats[lessonNumber] ?? '',
    },
    'review_status': review.status,
    'review_summary': review.summary,
    'review_focus': review.focus,
    'segments': segments,
    'arabic_assets': arabicAssets,
    'resolved_flags': resolvedFlags,
    'segment_seconds': segmentSeconds,
    'arabic_seconds': arabicSeconds,
  };
}

Map<String, Object?> _buildPlaceholder(Map<String, Object> lesson) {
  final lessonNumber = lesson['lesson_number']! as int;
  final title = lesson['title']! as String;
  final slug =
      'lesson_${lessonNumber.toString().padLeft(2, '0')}_${_slug(title)}';
  final scriptPath = '$_placeholderDir/$slug.md';
  final dataPath = '$_dataDir/$slug.json';
  const missing = <String>[
    'No runtime V2MicroLesson object under lib/data/',
    'No generated lesson spec under docs/generated_lessons/',
    'No lesson-specific test under test/',
    'No final prompt/content line source for voiceover extraction',
  ];

  final data = <String, Object?>{
    ...lesson,
    'status': 'placeholder_only',
    'available_planning_sources': <String>[
      'docs/curriculum/v2_16_lesson_foundation_plan.md',
    ],
    'missing_artifacts': missing,
  };

  return <String, Object?>{
    'script_path': scriptPath,
    'data_path': dataPath,
    'markdown': _placeholderMarkdown(lesson, missing),
    'data': data,
    'manifest': <String, Object?>{
      'lesson_number': lessonNumber,
      'stage': lesson['stage'],
      'title': title,
      'status': 'placeholder_only',
      'script_path': scriptPath,
      'data_path': dataPath,
      'available_planning_sources': <String>[
        'docs/curriculum/v2_16_lesson_foundation_plan.md',
      ],
      'missing_artifacts': missing,
    },
  };
}

ReviewConfig _reviewFor(int lessonNumber) {
  return _reviewConfigs[lessonNumber] ?? _defaultReview;
}

List<Map<String, String>> _normalizeSegments(
  int lessonNumber,
  List<Map<String, String>> ordered,
  ReviewConfig review,
) {
  final flagsBySource = <String, ReviewFlag>{
    for (final flag in review.flags) flag.sourceRef: flag,
  };
  final segments = <Map<String, String>>[];
  var segmentIndex = 1;
  var objectiveIndex = 0;
  var teachIndex = 0;
  var promptIndex = 0;

  for (final line in ordered) {
    final role = line['role']!;
    final sourceRef = line['source_ref']!;
    final text = line['text']!;
    final flag = flagsBySource[sourceRef];

    if (role == 'objective_summary') {
      objectiveIndex += 1;
    }
    if (role == 'content_title') {
      teachIndex += 1;
    }
    if (role == 'practice_prompt') {
      promptIndex += 1;
    }

    segments.add(<String, String>{
      'segment_id':
          'L${lessonNumber.toString().padLeft(2, '0')}_SEG_${segmentIndex.toString().padLeft(3, '0')}',
      'source_line_id': line['line_id']!,
      'asset_stem': line['asset_stem']!,
      'segment_name': _segmentName(
        role,
        objectiveIndex,
        teachIndex,
        promptIndex,
      ),
      'segment_type': _segmentType(role),
      'duration_target': _segmentDuration(role, text),
      'delivery_notes': _segmentDeliveryNotes(role, text, flag),
      'repeatable': _segmentRepeatable(role, text),
      'native_review': flag?.nativeReview == true ? 'check' : 'no',
      'export_state': flag?.action ?? 'ready',
      'source_ref': sourceRef,
      'text': text,
    });
    segmentIndex += 1;
  }

  return segments;
}

List<Map<String, String>> _normalizeArabicAssets(
  int lessonNumber,
  List<Map<String, String>> arabic,
  ReviewConfig review,
) {
  final flagsBySource = <String, ReviewFlag>{
    for (final flag in review.flags) flag.sourceRef: flag,
  };
  final typeCounts = <String, int>{};
  final assets = <Map<String, String>>[];

  for (final line in arabic) {
    final sourceRef = line['source_ref']!;
    final spoken = line['spoken_text']!;
    final type = _arabicAssetType(sourceRef, spoken, line['display_text']!);
    final typeCount = (typeCounts[type] ?? 0) + 1;
    typeCounts[type] = typeCount;
    final flag = flagsBySource[sourceRef];
    final exportState = _arabicExportState(type, flag);

    assets.add(<String, String>{
      'bank_id': line['bank_id']!,
      'asset_stem': line['asset_stem']!,
      'asset_name':
          '${_arabicAssetName(type)}_${typeCount.toString().padLeft(2, '0')}',
      'asset_type': type,
      'duration_target': _arabicDuration(type, spoken),
      'delivery_notes': _arabicDeliveryNotes(type, line, flag, exportState),
      'repeatable': _arabicRepeatable(type),
      'native_review': flag?.nativeReview == true ? 'check' : 'no',
      'export_state': exportState,
      'source_ref': sourceRef,
      'spoken_text': spoken,
      'display_text': line['display_text']!,
      'transliteration': line['transliteration']!,
      'meaning': line['meaning']!,
      'notes': line['notes']!,
    });
  }

  return assets;
}

List<Map<String, String>> _resolveFlags(
  ReviewConfig review,
  List<Map<String, String>> segments,
  List<Map<String, String>> arabicAssets,
) {
  final bySource = <String, Map<String, String>>{};
  for (final segment in segments) {
    bySource[segment['source_ref']!] = segment;
  }
  for (final asset in arabicAssets) {
    bySource[asset['source_ref']!] = asset;
  }

  final resolved = <Map<String, String>>[];
  for (final flag in review.flags) {
    final record = bySource[flag.sourceRef];
    resolved.add(<String, String>{
      'source_ref': flag.sourceRef,
      'current_id': record?['segment_id'] ?? record?['bank_id'] ?? '',
      'asset_stem': record?['asset_stem'] ?? '',
      'export_state': flag.action,
      'native_review': flag.nativeReview ? 'check' : 'no',
      'reason': flag.reason,
      'text': record?['text'] ?? record?['spoken_text'] ?? '',
    });
  }
  return resolved;
}
String _completedMarkdown({
  required int lessonNumber,
  required V2MicroLesson lesson,
  required String generatedAt,
  required ReviewConfig review,
  required List<Map<String, String>> segments,
  required List<Map<String, String>> arabicAssets,
  required List<Map<String, String>> resolvedFlags,
  required String segmentRuntime,
  required String arabicRuntime,
}) {
  final b = StringBuffer()
    ..writeln(
      '# Lesson ${lessonNumber.toString().padLeft(2, '0')} Voiceover Script',
    )
    ..writeln()
    ..writeln('- Status: final script normalized from existing repository content')
    ..writeln('- Review status: `${review.status}`')
    ..writeln('- Review summary: ${review.summary}')
    ..writeln('- Batch: `${_batchLabel(lessonNumber)}`')
    ..writeln('- Stage: ${_stage(lessonNumber)}')
    ..writeln('- Lesson ID: `${lesson.lessonId}`')
    ..writeln('- Working title: ${lesson.title}')
    ..writeln('- Estimated narration runtime: `$segmentRuntime`')
    ..writeln('- Estimated Arabic asset runtime: `$arabicRuntime`')
    ..writeln('- Generated at: `$generatedAt`')
    ..writeln(
      '- Canonical source policy: use the runtime `V2MicroLesson` object only; do not add new teaching copy.',
    )
    ..writeln()
    ..writeln('## Recording Profile')
    ..writeln()
    ..writeln('- Audience: absolute beginners')
    ..writeln('- Baseline delivery: warm, calm, clear, and beginner-safe')
    ..writeln(
      '- Arabic handling: keep every Arabic item intact, do not paraphrase, and leave one clean beat around short Arabic inserts',
    )
    ..writeln(
      '- Repeatability rule: short prompts and short Arabic models should sound easy to repeat once',
    )
    ..writeln('- Review focus: ${review.focus}')
    ..writeln()
    ..writeln('## Canonical Sources')
    ..writeln();
  for (final path in _sources[lessonNumber] ?? const <String>[]) {
    b.writeln('- `$path`');
  }
  b
    ..writeln()
    ..writeln('## Normalized Voiceover Segments')
    ..writeln()
    ..writeln(
      '| segment_id | asset_stem | segment_name | segment_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | text |',
    )
    ..writeln(
      '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
    );
  for (final line in segments) {
    b.writeln(
      '| `${line['segment_id']}` | `${line['asset_stem']}` | `${line['segment_name']}` | `${line['segment_type']}` | `${line['duration_target']}` | `${line['export_state']}` | ${_cell(line['delivery_notes']!)} | `${line['repeatable']}` | `${line['native_review']}` | `${line['source_ref']}` | ${_cell(line['text']!)} |',
    );
  }
  b
    ..writeln()
    ..writeln('## Normalized Arabic Model Bank')
    ..writeln()
    ..writeln(
      '| bank_id | asset_stem | asset_name | asset_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | spoken_text | display_text | transliteration | meaning | notes |',
    )
    ..writeln(
      '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
    );
  for (final line in arabicAssets) {
    b.writeln(
      '| `${line['bank_id']}` | `${line['asset_stem']}` | `${line['asset_name']}` | `${line['asset_type']}` | `${line['duration_target']}` | `${line['export_state']}` | ${_cell(line['delivery_notes']!)} | `${line['repeatable']}` | `${line['native_review']}` | `${line['source_ref']}` | ${_cell(line['spoken_text']!)} | ${_cell(line['display_text']!)} | ${_cell(line['transliteration']!)} | ${_cell(line['meaning']!)} | ${_cell(line['notes']!)} |',
    );
  }
  b
    ..writeln()
    ..writeln('## Review Flags')
    ..writeln();
  if (resolvedFlags.isEmpty) {
    b.writeln(
      '- No line-level issues require manual revision or native review before export.',
    );
  } else {
    b
      ..writeln(
        '| source_ref | current_id | asset_stem | export_state | native_review | reason | text |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final flag in resolvedFlags) {
      b.writeln(
        '| `${flag['source_ref']}` | `${flag['current_id']}` | `${flag['asset_stem']}` | `${flag['export_state']}` | `${flag['native_review']}` | ${_cell(flag['reason']!)} | ${_cell(flag['text']!)} |',
      );
    }
  }
  b
    ..writeln()
    ..writeln('## Completeness Basis')
    ..writeln()
    ..writeln(_basis[lessonNumber] ?? '');
  if (_caveats.containsKey(lessonNumber)) {
    b
      ..writeln()
      ..writeln('## Source Caveat')
      ..writeln()
      ..writeln('- ${_caveats[lessonNumber]}');
  }
  return b.toString();
}

String _placeholderMarkdown(Map<String, Object> lesson, List<String> missing) {
  final b = StringBuffer()
    ..writeln(
      '# Lesson ${(lesson['lesson_number'] as int).toString().padLeft(2, '0')} Placeholder',
    )
    ..writeln()
    ..writeln('- Status: placeholder only')
    ..writeln('- Stage: ${lesson['stage']}')
    ..writeln('- Working title: ${lesson['title']}')
    ..writeln(
      '- Core objective from planning docs: ${lesson['core_objective']}',
    )
    ..writeln(
      '- Recording instruction: do not record final voiceover for this lesson yet.',
    )
    ..writeln()
    ..writeln('## Available Planning Source')
    ..writeln()
    ..writeln('- `docs/curriculum/v2_16_lesson_foundation_plan.md`')
    ..writeln()
    ..writeln('## Missing Artifacts')
    ..writeln();
  for (final item in missing) {
    b.writeln('- $item');
  }
  b
    ..writeln()
    ..writeln('## Placeholder Rule')
    ..writeln()
    ..writeln('- Keep the file path and package slug stable.')
    ..writeln(
      '- Wait for final runtime lesson content before generating a final script.',
    )
    ..writeln(
      '- Do not infer final Arabic targets or prompts from planning summaries alone.',
    );
  return b.toString();
}

String _readmeMarkdown(
  String generatedAt,
  List<Map<String, Object?>> completedEntries,
) {
  final passCount = completedEntries
      .where((entry) => entry['review_status'] == 'pass')
      .length;
  final reviseCount = completedEntries
      .where((entry) => entry['review_status'] == 'revise')
      .length;
  final nativeCount = completedEntries
      .where((entry) => entry['review_status'] == 'needs_native_review')
      .length;

  return '''# Lesson Voiceover Production Framework 1-16

This package builds a reusable voiceover production framework for Foundation lessons 1-16 while enforcing two non-negotiable rules:

1. only lessons with final repository content receive final voiceover scripts
2. no lesson is cleared for blind TTS export before normalized review metadata exists

Generated at: `$generatedAt`

## Included Outputs

- `voiceover_manifest.json`: top-level lesson status manifest
- `scripts/final/`: normalized final voiceover scripts for completed lessons already in the repo
- `scripts/placeholders/`: stable placeholder files for unfinished lessons
- `data/`: machine-readable per-lesson manifests for recording or synthesis tooling
- `review_status_lessons_01_12.md`: per-lesson pass / revise / needs-native-review summary
- `recording_batch_plan_lessons_01_12.md`: proposed recording batches for Lessons 1-12
- `audio_filename_convention_spec.md`: stable filename convention for human recording and TTS export
- `templates/lesson_voiceover_script_template.md`: normalized template for future lesson script generation
- `missing_content_report.md`: explicit blocker report for Lessons 13-16

## Source-of-Truth Policy

1. Runtime `V2MicroLesson` objects are canonical whenever they exist.
2. Generated lesson markdown is referenced only when it already exists in the repository.
3. Planning-only lessons stay placeholder-only. No final prompt text, Arabic targets, or narration is inferred from planning summaries.
4. Review-ready normalization may add delivery notes, duration targets, export-state flags, and native-review flags, but it does not invent final lesson content.

## Current Status

- Final scripts normalized: Lessons 1-12
- Placeholder only: Lessons 13-16
- Review summary: `$passCount` pass, `$reviseCount` revise, `$nativeCount` needs native review

## Regeneration

```powershell
dart run tool/generate_lesson_voiceover_framework.dart
```

## Export Guidance

- Use `asset_stem` as the canonical logical stem for future recording and TTS work.
- Treat `review_status_lessons_01_12.md` and the per-script `Review Flags` section as export gates.
- Preserve placeholder-only state for Lessons 13-16 until runtime lesson content exists.
''';
}

String _reviewStatusMarkdown(
  String generatedAt,
  List<Map<String, Object?>> completedEntries,
) {
  final passCount = completedEntries
      .where((entry) => entry['review_status'] == 'pass')
      .length;
  final reviseCount = completedEntries
      .where((entry) => entry['review_status'] == 'revise')
      .length;
  final nativeCount = completedEntries
      .where((entry) => entry['review_status'] == 'needs_native_review')
      .length;

  final b = StringBuffer()
    ..writeln('# Lessons 01-12 Voiceover Review Status')
    ..writeln()
    ..writeln('- Generated at: `$generatedAt`')
    ..writeln('- Pass: `$passCount` lessons')
    ..writeln('- Revise: `$reviseCount` lessons')
    ..writeln('- Needs native review: `$nativeCount` lessons')
    ..writeln(
      '- Lessons 13-16 remain placeholder-only and were not moved into final-script status.',
    )
    ..writeln()
    ..writeln('## Lesson Status')
    ..writeln()
    ..writeln(
      '| Lesson | Batch | Status | Segment runtime | Arabic asset runtime | Summary |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- |');

  for (final entry in completedEntries) {
    b.writeln(
      '| `${(entry['lesson_number']! as int).toString().padLeft(2, '0')}` | `${entry['batch']}` | `${entry['review_status']}` | `${_formatClock(entry['segment_seconds']! as int)}` | `${_formatClock(entry['arabic_seconds']! as int)}` | ${_cell(entry['review_summary']! as String)} |',
    );
  }

  b
    ..writeln()
    ..writeln('## Flagged Lines')
    ..writeln();

  for (final entry in completedEntries.where(
    (entry) =>
        (entry['resolved_flags']! as List<Map<String, String>>).isNotEmpty,
  )) {
    final lessonNumber = entry['lesson_number']! as int;
    final lessonTitle = entry['title']! as String;
    final flags = entry['resolved_flags']! as List<Map<String, String>>;
    b
      ..writeln(
        '### Lesson ${lessonNumber.toString().padLeft(2, '0')} - $lessonTitle',
      )
      ..writeln()
      ..writeln(
        '| source_ref | current_id | asset_stem | export_state | native_review | reason | text |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final flag in flags) {
      b.writeln(
        '| `${flag['source_ref']}` | `${flag['current_id']}` | `${flag['asset_stem']}` | `${flag['export_state']}` | `${flag['native_review']}` | ${_cell(flag['reason']!)} | ${_cell(flag['text']!)} |',
      );
    }
    b.writeln();
  }

  return b.toString();
}

String _batchPlanMarkdown(
  String generatedAt,
  List<Map<String, Object?>> completedEntries,
) {
  final batches = <String, List<Map<String, Object?>>> {
    'Batch A': completedEntries.where((entry) => entry['batch'] == 'Batch A').toList(),
    'Batch B': completedEntries.where((entry) => entry['batch'] == 'Batch B').toList(),
    'Batch C': completedEntries.where((entry) => entry['batch'] == 'Batch C').toList(),
  };

  final b = StringBuffer()
    ..writeln('# Recording Batch Plan For Lessons 01-12')
    ..writeln()
    ..writeln('- Generated at: `$generatedAt`')
    ..writeln('- Batch A: Lessons 1-4')
    ..writeln('- Batch B: Lessons 5-8')
    ..writeln('- Batch C: Lessons 9-12')
    ..writeln()
    ..writeln(
      'Use this plan before any TTS export work. Record ready items first, keep `review` items behind native-speaker confirmation, and keep `hold` items out of the first export pass.',
    )
    ..writeln();

  for (final label in <String>['Batch A', 'Batch B', 'Batch C']) {
    final lessons = batches[label]!;
    final statuses = lessons.fold<Map<String, int>>(
      <String, int>{},
      (counts, entry) {
        final status = entry['review_status']! as String;
        counts[status] = (counts[status] ?? 0) + 1;
        return counts;
      },
    );
    final segmentSeconds = lessons.fold<int>(
      0,
      (sum, entry) => sum + (entry['segment_seconds']! as int),
    );
    final arabicSeconds = lessons.fold<int>(
      0,
      (sum, entry) => sum + (entry['arabic_seconds']! as int),
    );
    final flagged = lessons
        .expand(
          (entry) => entry['resolved_flags']! as List<Map<String, String>>,
        )
        .toList();

    b
      ..writeln('## $label')
      ..writeln()
      ..writeln('- Scope: `${lessons.length}` lessons')
      ..writeln(
        '- Review mix: `${statuses['pass'] ?? 0}` pass, `${statuses['revise'] ?? 0}` revise, `${statuses['needs_native_review'] ?? 0}` needs native review',
      )
      ..writeln('- Estimated narration runtime: `${_formatClock(segmentSeconds)}`')
      ..writeln('- Estimated Arabic asset runtime: `${_formatClock(arabicSeconds)}`')
      ..writeln()
      ..writeln('| Lesson | Status | Main focus |')
      ..writeln('| --- | --- | --- |');

    for (final entry in lessons) {
      b.writeln(
        '| `${(entry['lesson_number']! as int).toString().padLeft(2, '0')}` ${_cell(entry['title']! as String)} | `${entry['review_status']}` | ${_cell(entry['review_focus']! as String)} |',
      );
    }

    b
      ..writeln()
      ..writeln('Recommended order:')
      ..writeln('1. Record all ready narration segments for the batch first.')
      ..writeln('2. Record ready Arabic word or phrase assets next.')
      ..writeln(
        '3. Leave `review` and `hold` items until the batch-specific review gate is cleared.',
      )
      ..writeln()
      ..writeln('QA focus:');

    if (label == 'Batch A') {
      b
        ..writeln('- Keep early-stage Arabic words slow, steady, and low-pressure.')
        ..writeln('- Do not let Lesson 3 connection-path artifacts slip into the normal export batch.')
        ..writeln('- Confirm Lesson 4 supported forms with a native speaker before export.')
        ..writeln();
    } else if (label == 'Batch B') {
      b
        ..writeln('- Preserve the word-versus-line contrast in Lessons 6-8.')
        ..writeln('- Treat pack lists as clearly separated items, not as run-on sentences.')
        ..writeln('- Keep the overall tone encouraging rather than performative.')
        ..writeln();
    } else {
      b
        ..writeln('- Stage C is clue-sensitive: do not let TTS guess isolated orthographic symbols.')
        ..writeln('- Preserve contrast between سيارة and سيارات with explicit pauses and clear plural endings.')
        ..writeln('- Keep the tiny-card list in Lesson 12 readable as a list, not as a sentence.')
        ..writeln();
    }

    b.writeln('Review-first or hold items:');
    if (flagged.isEmpty) {
      b.writeln('- None.');
    } else {
      for (final flag in flagged) {
        b.writeln(
          '- `${flag['current_id']}` `${flag['asset_stem']}` `${flag['export_state']}` `${flag['native_review']}`: ${flag['reason']}',
        );
      }
    }
    b.writeln();
  }

  return b.toString();
}

String _filenameConventionMarkdown(String generatedAt) {
  return '''# Audio Filename Convention Spec

Generated at: `$generatedAt`

## Goal

Use one stable logical stem per script segment or Arabic model asset, while still allowing multiple concrete outputs from human recording or TTS.

## Stable Base Rule

- Use the script `asset_stem` as the canonical logical stem.
- Never derive filenames from the lesson title or free-text segment name.
- Keep the logical filename stable even if the concrete source switches from TTS to human recording later.

## Logical Asset Path

```text
lesson_{NN}/voiceover/{asset_stem}_{speed}.{ext}
```

Examples:

- `lesson_01/voiceover/l01_ord_012_normal.mp3`
- `lesson_06/voiceover/l06_ar_002_normal.mp3`
- `lesson_10/voiceover/l10_ord_014_normal.mp3`

## Concrete Produced Asset Path

```text
lesson_{NN}/voiceover/{asset_stem}_{speed}__{source}__{stamp}.{ext}
```

Where:

- `{source}` = `human` or `tts-{provider}-{voice_slug}`
- `{stamp}` = `YYYYMMDD-{batch_or_run}`
- `{ext}` = `.wav` for masters, `.mp3` for bundled app assets unless a different delivery format is required

Examples:

- `lesson_01/voiceover/l01_ord_012_normal__human__20260321-batch-a.wav`
- `lesson_01/voiceover/l01_ord_012_normal__human__20260321-batch-a.mp3`
- `lesson_10/voiceover/l10_ord_014_normal__tts-azure-ar-saana__20260321-batch-c.wav`
- `lesson_10/voiceover/l10_ar_004_normal__tts-azure-ar-saana__20260321-batch-c.wav`

## Token Rules

- `lesson_{NN}` uses zero-padded lesson numbers, for example `lesson_03`.
- `asset_stem` must come directly from the normalized script or Arabic model bank, for example `l03_ord_015` or `l10_ar_004`.
- `speed` should stay explicit even for the default speed. Use `normal` unless the batch explicitly creates a `slow` variant.
- `ord` stems are narration or prompt segments.
- `ar` stems are Arabic model assets.

## Manifest Rule

- Content references should point at the logical filename.
- The audio manifest may redirect that logical request to a concrete human or TTS-produced file with suffixes such as `__human__20260321-batch-a`.
- This matches the current audio-service pattern where a stable logical request can resolve to a more specific concrete asset at runtime.

## Export Safety Rules

1. One segment or one Arabic model asset per file.
2. Do not bundle multiple script segments into one audio file.
3. Do not rename an existing `asset_stem` just because delivery notes changed.
4. Keep `hold` items out of automatic TTS export until the flagged review step is complete.
''';
}

String _templateMarkdown() {
  return '''# Lesson Voiceover Script Template

- Status: `final_script_normalized` or `placeholder_only`
- Review status: `pass`, `revise`, or `needs_native_review`
- Batch:
- Stage:
- Lesson ID:
- Working title:
- Estimated narration runtime:
- Estimated Arabic asset runtime:
- Canonical source policy:

## Recording Profile

- Audience:
- Baseline delivery:
- Arabic handling:
- Repeatability rule:
- Review focus:

## Canonical Sources

- `lib/data/...`
- `docs/generated_lessons/...`
- `test/...`

## Normalized Voiceover Segments

| segment_id | asset_stem | segment_name | segment_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | text |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `LXX_SEG_001` | `lxx_ord_001` | `OPEN_TITLE` | `opening` | `00:02-00:03` | `ready` | ... | `no` | `no` | `lesson.title` | ... |

## Normalized Arabic Model Bank

| bank_id | asset_stem | asset_name | asset_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | spoken_text | display_text | transliteration | meaning | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `LXX_AR_001` | `lxx_ar_001` | `AR_WORD_01` | `word` | `00:02-00:03` | `ready` | ... | `yes` | `no` | `content:input_main_word` | ... | ... | ... | ... | ... |

## Review Flags

- Use this section only when a line needs revision, hold, or native-speaker review before export.

## Completeness Basis

Explain why this lesson is safe for final voiceover extraction.
''';
}

String _stage(int lessonNumber) {
  if (lessonNumber <= 4) return 'Stage A';
  if (lessonNumber <= 8) return 'Stage B';
  if (lessonNumber <= 12) return 'Stage C';
  return 'Stage D';
}

String _batchLabel(int lessonNumber) {
  if (lessonNumber <= 4) return 'Batch A';
  if (lessonNumber <= 8) return 'Batch B';
  if (lessonNumber <= 12) return 'Batch C';
  return 'Not batched';
}

String _segmentName(
  String role,
  int objectiveIndex,
  int teachIndex,
  int promptIndex,
) {
  switch (role) {
    case 'lesson_title':
      return 'OPEN_TITLE';
    case 'lesson_outcome':
      return 'OPEN_OUTCOME';
    case 'objective_summary':
      return 'OPEN_OBJECTIVE_${objectiveIndex.toString().padLeft(2, '0')}';
    case 'content_title':
      return 'TEACH_HEADER_${teachIndex.toString().padLeft(2, '0')}';
    case 'content_body':
      return 'TEACH_BODY_${teachIndex.toString().padLeft(2, '0')}';
    case 'practice_prompt':
      return 'PROMPT_${promptIndex.toString().padLeft(2, '0')}';
    default:
      return 'SEGMENT_GENERIC';
  }
}

String _segmentType(String role) {
  switch (role) {
    case 'lesson_title':
    case 'lesson_outcome':
    case 'objective_summary':
      return 'opening';
    case 'content_title':
      return 'section_header';
    case 'content_body':
      return 'teaching_narration';
    case 'practice_prompt':
      return 'instruction_prompt';
    default:
      return 'narration';
  }
}

String _segmentDuration(String role, String text) {
  final tokens = _tokenCount(text);
  var minSeconds = 3;
  if (role == 'lesson_title' || role == 'content_title') {
    minSeconds = 2;
  } else if (role == 'practice_prompt') {
    minSeconds = 3;
  } else if (role == 'lesson_outcome' || role == 'objective_summary') {
    minSeconds = 4;
  }
  var maxSeconds = minSeconds + ((tokens / 4).ceil());
  if (_containsArabic(text)) {
    maxSeconds += 1;
  }
  if (role == 'practice_prompt') {
    maxSeconds += 1;
  }
  minSeconds = _clampInt(minSeconds, 2, 12);
  maxSeconds = _clampInt(maxSeconds, minSeconds + 1, 14);
  return _range(minSeconds, maxSeconds);
}

String _segmentDeliveryNotes(String role, String text, ReviewFlag? flag) {
  String base;
  if (role == 'lesson_title' || role == 'content_title') {
    base = 'Short open. Calm lift on the first words, then a clean stop.';
  } else if (role == 'lesson_outcome' || role == 'objective_summary') {
    base = _containsArabic(text)
        ? 'Steady overview line. Keep the English flowing and slow slightly around Arabic inserts.'
        : 'Steady overview line. Keep it calm, clear, and lightly encouraging.';
  } else if (role == 'practice_prompt') {
    base = _containsArabic(text)
        ? 'Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end.'
        : 'Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end.';
  } else {
    base = _containsArabic(text)
        ? 'Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it.'
        : 'Teaching line. Warm, calm, and conversational with one clear sentence boundary.';
  }
  return _applyFlagNote(base, flag);
}

String _segmentRepeatable(String role, String text) {
  if (role == 'practice_prompt') {
    return 'yes';
  }
  if (_containsArabic(text) && _tokenCount(text) <= 12) {
    return 'yes';
  }
  return 'no';
}

String _arabicAssetType(String sourceRef, String spoken, String display) {
  if (sourceRef.contains('expectedAnswer') &&
      (spoken.contains(' ') || spoken.contains('ـ'))) {
    return 'build_artifact';
  }
  if (RegExp(r'^[\u0600-\u06FF]$').hasMatch(spoken)) {
    return 'fragment';
  }
  if (spoken.contains('/') || display.contains('<br>') || _tokenCount(spoken) > 3) {
    return 'list';
  }
  if (_tokenCount(spoken) > 1) {
    return 'short_phrase';
  }
  return 'word';
}

String _arabicAssetName(String type) {
  switch (type) {
    case 'word':
      return 'AR_WORD';
    case 'short_phrase':
      return 'AR_PHRASE';
    case 'list':
      return 'AR_LIST';
    case 'fragment':
      return 'AR_FRAGMENT';
    case 'build_artifact':
      return 'AR_BUILD';
    default:
      return 'AR_MODEL';
  }
}

String _arabicDuration(String type, String spoken) {
  switch (type) {
    case 'word':
      return _range(2, 3);
    case 'short_phrase':
      return _range(2, 4);
    case 'list':
      return _range(3, _clampInt(3 + _tokenCount(spoken), 5, 8));
    case 'fragment':
      return _range(1, 2);
    case 'build_artifact':
      return _range(2, 4);
    default:
      return _range(2, 4);
  }
}

String _arabicDeliveryNotes(
  String type,
  Map<String, String> line,
  ReviewFlag? flag,
  String exportState,
) {
  final spoken = line['spoken_text']!;
  final display = line['display_text']!;
  String base;
  switch (type) {
    case 'word':
      base =
          'Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody.';
      break;
    case 'short_phrase':
      base =
          'Short Arabic phrase. Keep the word boundary clear and easy to repeat once.';
      break;
    case 'list':
      base =
          'Arabic list, not a sentence. Give each item its own beat and keep the order clean.';
      break;
    case 'fragment':
      base =
          'Orthographic fragment. Keep it isolated and do not improvise its spoken treatment.';
      break;
    case 'build_artifact':
      base =
          'Build artifact, not natural continuous speech. Keep it out of blind TTS export until confirmed.';
      break;
    default:
      base = 'Short Arabic model. Keep the delivery clean and repeatable.';
  }
  if (_norm(display).isNotEmpty && display != spoken) {
    base =
        '$base Preserve the source spoken-versus-display split exactly as written.';
  }
  if (line['notes']!.isNotEmpty) {
    base = '$base ${line['notes']!}';
  }
  if (exportState == 'hold' && flag == null) {
    base = '$base Hold from automatic export until scope is confirmed.';
  }
  return _applyFlagNote(base, flag);
}

String _arabicRepeatable(String type) {
  switch (type) {
    case 'word':
    case 'short_phrase':
    case 'list':
      return 'yes';
    default:
      return 'no';
  }
}

String _arabicExportState(String type, ReviewFlag? flag) {
  if (flag != null) {
    return flag.action;
  }
  if (type == 'build_artifact') {
    return 'hold';
  }
  if (type == 'fragment') {
    return 'review';
  }
  return 'ready';
}

String _applyFlagNote(String base, ReviewFlag? flag) {
  if (flag == null) {
    return base;
  }
  if (flag.action == 'hold') {
    return '$base Hold from export until this line is manually cleared. ${flag.reason}';
  }
  return '$base Review before export. ${flag.reason}';
}

String _slug(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

String _norm(String value) {
  return value.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
}

String _lang(String value) {
  final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  final hasLatin = RegExp(r'[A-Za-z]').hasMatch(value);
  if (hasArabic && hasLatin) return 'mixed';
  if (hasArabic) return 'ar';
  return 'en';
}

bool _containsArabic(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}

bool _isArabicRecordable(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value) &&
      !RegExp(r'[A-Za-z]').hasMatch(value);
}

int _tokenCount(String value) {
  return _norm(value)
      .split(RegExp(r'[\s\.,!\?\u061F\u060C\u061B/<>|:;\-]+'))
      .where((part) => part.trim().isNotEmpty)
      .length;
}

int _clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

String _range(int minSeconds, int maxSeconds) {
  return '${_formatClock(minSeconds)}-${_formatClock(maxSeconds)}';
}

String _formatClock(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

int _sumDurationMidpoints(List<Map<String, String>> rows, String key) {
  var total = 0;
  for (final row in rows) {
    total += _durationMidpoint(row[key]!);
  }
  return total;
}

int _durationMidpoint(String range) {
  final match =
      RegExp(r'^(\d{2}):(\d{2})-(\d{2}):(\d{2})$').firstMatch(range);
  if (match == null) {
    return 0;
  }
  final start =
      int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
  final end = int.parse(match.group(3)!) * 60 + int.parse(match.group(4)!);
  return ((start + end) / 2).round();
}

String _cell(String value) {
  final v = _norm(value);
  if (v.isEmpty) return '';
  return v.replaceAll('|', r'\|').replaceAll('\n', '<br>');
}

void _writeTextIfChanged(String path, String content) {
  final file = File(path);
  if (file.existsSync() && file.readAsStringSync() == content) {
    return;
  }
  file.writeAsStringSync(content);
}

void _writeJsonIfChanged(String path, Object? data) {
  final content = const JsonEncoder.withIndent('  ').convert(data);
  _writeTextIfChanged(path, content);
}
