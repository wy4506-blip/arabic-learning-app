import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../services/alphabet_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'alphabet_group_detail_page.dart';

class AlphabetPage extends StatefulWidget {
  const AlphabetPage({super.key});

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  List<AlphabetGroup> _groups = [];
  bool _isLoading = true;

  int get _letterCount => _groups.fold<int>(
        0,
        (total, group) => total + group.letters.length,
      );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final groups = await AlphabetService.loadAlphabetGroups();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final letterCount = _letterCount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading
            ? ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    children: [
                      _buildTopButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizedText(
                                context,
                                zh: '字母入门',
                                en: 'Alphabet Basics',
                              ),
                              style: text.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizedText(
                                context,
                                zh: '先按分组学习字母，再进入详细内容',
                                en: 'Start with grouped letters, then move into deeper study.',
                              ),
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  AppSurface(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            localizedText(
                              context,
                              zh: '正在整理字母分组内容…',
                              en: 'Preparing your alphabet groups...',
                            ),
                            style: text.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    children: [
                      _buildTopButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizedText(
                                context,
                                zh: '字母入门',
                                en: 'Alphabet Basics',
                              ),
                              style: text.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizedText(
                                context,
                                zh: '先按分组学习字母，再进入详细内容',
                                en: 'Start with grouped letters, then move into deeper study.',
                              ),
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEAF8F3),
                          Color(0xFFDFF2EB),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.82),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.spellcheck_rounded,
                            color: AppTheme.deepAccent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizedText(
                                  context,
                                  zh: '7 组学完 28 个字母',
                                  en: 'Learn 28 Letters in 7 Groups',
                                ),
                                style: text.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizedText(
                                  context,
                                  zh: '先按分组学清字形和发音，再进入字母练习，路径会更稳。',
                                  en: 'Lock in shapes and sounds by group before moving into drills.',
                                ),
                                style: text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildSummaryChip(
                        label: localizedText(
                          context,
                          zh: '${_groups.length} 个学习分组',
                          en: '${_groups.length} study groups',
                        ),
                        icon: Icons.layers_rounded,
                      ),
                      _buildSummaryChip(
                        label: localizedText(
                          context,
                          zh: '$letterCount 个基础字母',
                          en: '$letterCount core letters',
                        ),
                        icon: Icons.sort_by_alpha_rounded,
                      ),
                      _buildSummaryChip(
                        label: localizedText(
                          context,
                          zh: '听读 + 书写 + 练习',
                          en: 'Listen + Write + Drill',
                        ),
                        icon: Icons.task_alt_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizedText(
                      context,
                      zh: '字母分组',
                      en: 'Letter Groups',
                    ),
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    localizedText(
                      context,
                      zh: '每次先学一小组，降低记忆压力。',
                      en: 'Take one small group at a time to reduce memory load.',
                    ),
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ..._groups.map((group) => _buildGroupCard(context, group)),
                ],
              ),
      ),
    );
  }

  static Widget _buildSummaryChip({
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.deepAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryText,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, AlphabetGroup group) {
    final text = Theme.of(context).textTheme;
    final previewLetters = group.letters.take(4).toList();
    final remainingCount = group.letters.length - previewLetters.length;
    final subtitle = AlphabetContentLocalizer.groupSubtitle(
      group,
      context.appSettings.meaningLanguage,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlphabetGroupDetailPage(group: group),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AlphabetContentLocalizer.groupTitle(
                          group,
                          context.appSettings.appLanguage,
                        ),
                        style: text.titleMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        localizedText(
                          context,
                          zh: '${group.letters.length} 个字母',
                          en: '${group.letters.length} letters',
                        ),
                        style: text.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: text.bodySmall),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: previewLetters.map((letter) {
                    return Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5F0),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: ArabicText.word(
                          letter.arabic,
                          style: text.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (remainingCount > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    localizedText(
                      context,
                      zh: '其余 $remainingCount 个字母进入本组后继续学习',
                      en: '$remainingCount more letters continue inside this group.',
                    ),
                    style: text.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      localizedText(
                        context,
                        zh: '进入学习',
                        en: 'Open Group',
                      ),
                      style: text.labelLarge?.copyWith(
                        color: AppTheme.deepAccent,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF98A2B3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
