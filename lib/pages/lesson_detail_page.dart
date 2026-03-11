import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';
import 'lesson_quiz_page.dart';

class LessonDetailPage extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailPage({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(lesson.titleCn),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.border, width: 0.6),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.titleCn,
                  style: text.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  lesson.titleAr,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(label: '难度 ${lesson.difficulty}'),
                    _MetaPill(label: '${lesson.estimatedMinutes} 分钟'),
                    _MetaPill(label: _categoryLabel(lesson.category)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '按顺序完成本课内容：目标 → 词汇 → 句型 → 对话 → 语法 → 练习。',
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(
            title: '学习目标',
            subtitle: '先知道这节课要学会什么',
          ),
          const SizedBox(height: 12),
          _WhiteCard(
            child: Column(
              children: lesson.objectives
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.softAccent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppTheme.deepAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e,
                              style: text.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (lesson.letters.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '本课字母',
              subtitle: '先熟悉字形和读音',
            ),
            const SizedBox(height: 12),
            _WhiteCard(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: lesson.letters
                    .map(
                      (letter) => Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          letter,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (lesson.vocabulary.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '核心词汇',
              subtitle: '优先掌握高频词',
            ),
            const SizedBox(height: 12),
            ...lesson.vocabulary.map(
              (word) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WhiteCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.softAccent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.translate_rounded,
                          color: AppTheme.deepAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.arabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              word.chinese,
                              style: text.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              word.transliteration,
                              style: text.bodySmall?.copyWith(
                                color: AppTheme.deepAccent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              word.wordType,
                              style: text.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (lesson.patterns.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '核心句型',
              subtitle: '先记住能直接开口用的句子',
            ),
            const SizedBox(height: 12),
            ...lesson.patterns.map(
              (pattern) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.arabic,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pattern.transliteration,
                        style: text.bodySmall?.copyWith(
                          color: AppTheme.deepAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pattern.chinese,
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (lesson.dialogues.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '对话',
              subtitle: '把词和句子放进真实交流里',
            ),
            const SizedBox(height: 12),
            _WhiteCard(
              child: Column(
                children: lesson.dialogues
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                line.speaker,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.arabic,
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    line.transliteration,
                                    style: text.bodySmall?.copyWith(
                                      color: AppTheme.deepAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    line.chinese,
                                    style: text.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const _SectionHeader(
            title: '语法点',
            subtitle: '只讲这一课最关键的一点',
          ),
          const SizedBox(height: 12),
          _WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.grammarTitle,
                  style: text.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  lesson.grammarExplanation,
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
          if (lesson.exercises.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '练习预览',
              subtitle: '做题前先看一眼题型',
            ),
            const SizedBox(height: 12),
            _WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.exercises.first.question,
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ...lesson.exercises.first.options.map(
                    (option) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        option,
                        style: text.bodyMedium?.copyWith(
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: lesson.exercises.isEmpty
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonQuizPage(lesson: lesson),
                      ),
                    );
                  },
            child: const Text('开始学习'),
          ),
        ],
      ),
    );
  }

  static String _categoryLabel(String category) {
    switch (category) {
      case 'alphabet':
        return '字母';
      case 'dialogue':
        return '对话';
      case 'grammar':
        return '语法';
      case 'review':
        return '复习';
      default:
        return category;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: text.bodyMedium),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border, width: 0.6),
        boxShadow: AppTheme.softShadow,
      ),
      child: child,
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.secondaryText,
        ),
      ),
    );
  }
}
