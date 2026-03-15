import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../services/alphabet_progress_service.dart';
import '../services/alphabet_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arabic_text_with_audio.dart';
import 'alphabet_letter_home_page.dart';
import 'alphabet_quiz_hub_page.dart';

class AlphabetGroupDetailPage extends StatefulWidget {
  final AlphabetGroup group;
  final String? initialLetterKey;

  const AlphabetGroupDetailPage({
    super.key,
    required this.group,
    this.initialLetterKey,
  });

  @override
  State<AlphabetGroupDetailPage> createState() =>
      _AlphabetGroupDetailPageState();
}

class _AlphabetGroupDetailPageState extends State<AlphabetGroupDetailPage> {
  final ScrollController _scrollController = ScrollController();
  int _reloadVersion = 0;
  bool _didAutoOpenInitialLetter = false;
  AlphabetLearningSnapshot _snapshot = AlphabetLearningSnapshot.empty;
  AlphabetGroupProgress _groupProgress = const AlphabetGroupProgress(
    completedLetterCount: 0,
    totalLetterCount: 0,
    isCompleted: false,
  );
  AlphabetGroup? _nextGroup;
  bool _isRefreshing = true;

  AlphabetGroup get group => widget.group;

  @override
  void initState() {
    super.initState();
    _reloadGroupProgress();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _reloadGroupProgress(
      {bool showCompletionFeedback = false}) async {
    final reloadVersion = ++_reloadVersion;
    final previousCompleted = _groupProgress.isCompleted;
    final snapshot = await AlphabetProgressService.getSnapshot();
    final groupProgress = await AlphabetProgressService.getGroupProgress(group);
    final allGroups = await AlphabetService.loadAlphabetGroups();
    final currentIndex = allGroups.indexWhere((item) => item.id == group.id);
    final nextGroup = currentIndex >= 0 && currentIndex + 1 < allGroups.length
        ? allGroups[currentIndex + 1]
        : null;

    if (!mounted || reloadVersion != _reloadVersion) return;

    setState(() {
      _snapshot = snapshot;
      _groupProgress = groupProgress;
      _nextGroup = nextGroup;
      _isRefreshing = false;
    });

    if (showCompletionFeedback &&
        !previousCompleted &&
        groupProgress.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizedText(
              context,
              zh: '这一组已完成，可以继续下一步了。',
              en: 'This group is complete. You can continue now.',
            ),
          ),
        ),
      );
    }

    _maybeOpenInitialLetter();
  }

  void _maybeOpenInitialLetter() {
    if (_didAutoOpenInitialLetter || widget.initialLetterKey == null) {
      return;
    }
    final targetLetter = AlphabetProgressService.findLetterByKey(
      group,
      widget.initialLetterKey,
    );
    if (targetLetter == null ||
        AlphabetProgressService.isLetterMainlineCompleted(
          snapshot: _snapshot,
          letter: targetLetter,
        )) {
      return;
    }

    _didAutoOpenInitialLetter = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _openLetter(targetLetter);
    });
  }

  bool _isLetterCompleted(AlphabetLetter letter) {
    return AlphabetProgressService.isLetterMainlineCompleted(
      snapshot: _snapshot,
      letter: letter,
    );
  }

  Future<void> _openLetter(AlphabetLetter letter) async {
    final wasCompleted = _isLetterCompleted(letter);
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AlphabetLetterHomePage(
          letter: letter,
          groupId: group.id,
        ),
      ),
    );
    if (completed == true && !wasCompleted && mounted) {
      final letterKey = letter.arabic.trim();
      final totalLetterCount = _groupProgress.totalLetterCount == 0
          ? group.letters.length
          : _groupProgress.totalLetterCount;
      final completedLetterCount = (_groupProgress.completedLetterCount + 1)
          .clamp(0, group.letters.length);
      setState(() {
        _snapshot = AlphabetLearningSnapshot(
          viewedLetters: <String>{..._snapshot.viewedLetters, letterKey},
          listenCompletedLetters: <String>{
            ..._snapshot.listenCompletedLetters,
            letterKey,
          },
          writeCompletedLetters: _snapshot.writeCompletedLetters,
          totalLetterCount: _snapshot.totalLetterCount,
          totalGroupCount: _snapshot.totalGroupCount,
          completedGroupCount: _snapshot.completedGroupCount,
        );
        _groupProgress = AlphabetGroupProgress(
          completedLetterCount: completedLetterCount,
          totalLetterCount: totalLetterCount,
          isCompleted: completedLetterCount >= totalLetterCount,
        );
      });
    }
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    await _reloadGroupProgress(showCompletionFeedback: true);

    if (!mounted || completed != true || _groupProgress.isCompleted) {
      return;
    }

    final allGroups = await AlphabetService.loadAlphabetGroups();
    final action = await AlphabetProgressService.getNextAlphabetAction(
      groups: allGroups,
      preferredGroupId: group.id,
    );
    if (!mounted || action.actionType != AlphabetNextActionType.resumeLetter) {
      return;
    }

    final nextLetter = AlphabetProgressService.findLetterByKey(
      group,
      action.currentLetterKey,
    );
    if (nextLetter == null || nextLetter.arabic.trim() == letter.arabic.trim()) {
      return;
    }

    await _openLetter(nextLetter);
  }

  Future<void> _continueToNextGroup() async {
    if (_nextGroup == null) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AlphabetGroupDetailPage(group: _nextGroup!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final totalLetterCount = _groupProgress.totalLetterCount == 0
        ? group.letters.length
        : _groupProgress.totalLetterCount;
    final progressLabel = localizedText(
      context,
      zh: '当前组进度 ${_groupProgress.completedLetterCount} / $totalLetterCount',
      en: 'Group progress ${_groupProgress.completedLetterCount} / $totalLetterCount',
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
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
                        AlphabetContentLocalizer.groupTitle(
                          group,
                          context.appSettings.appLanguage,
                        ),
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AlphabetContentLocalizer.groupSubtitle(
                          group,
                          context.appSettings.meaningLanguage,
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
                      Icons.auto_stories_rounded,
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
                            zh: '这一组共 ${group.letters.length} 个字母',
                            en: '${group.letters.length} letters in this group',
                          ),
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRefreshing
                              ? localizedText(
                                  context,
                                  zh: '正在刷新本组学习进度…',
                                  en: 'Refreshing this group progress...',
                                )
                              : progressLabel,
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              progressLabel,
              style: text.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      progressLabel,
                      style: text.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 82,
                    child: LinearProgressIndicator(
                      value: totalLetterCount == 0
                          ? 0
                          : _groupProgress.completedLetterCount /
                              totalLetterCount,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.deepAccent,
                      ),
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
                _buildGuideChip(
                  label: localizedText(
                    context,
                    zh: '先认字形',
                    en: 'See the Shape',
                  ),
                  icon: Icons.visibility_rounded,
                ),
                _buildGuideChip(
                  label: localizedText(
                    context,
                    zh: '再听发音',
                    en: 'Hear the Sound',
                  ),
                  icon: Icons.hearing_rounded,
                ),
                _buildGuideChip(
                  label: localizedText(
                    context,
                    zh: '可选书写巩固',
                    en: 'Optional Writing',
                  ),
                  icon: Icons.edit_rounded,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: group.letters
                    .map(
                      (letter) => Container(
                        width: 64,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4FBF8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: ArabicTextWithAudio(
                            textAr: letter.arabic,
                            request: LearningAudioRequest.alphabet(
                              type: 'letter',
                              textAr: letter.arabic,
                              textPlain: letter.arabic,
                              debugLabel: 'alphabet_group_chip',
                            ),
                            variant: ArabicAudioTextVariant.word,
                            style: text.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                            spacing: 4,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizedText(
                context,
                zh: '本组字母',
                en: 'Letters in This Group',
              ),
              style: text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              localizedText(
                context,
                zh: '每次先学少量内容，更适合初学者。',
                en: 'Small batches work better for beginners.',
              ),
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...group.letters.map(
              (letter) => _buildLetterCard(context, letter),
            ),
            if (_groupProgress.isCompleted) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    Text(
                      localizedText(
                        context,
                        zh: '本组已完成',
                        en: 'This Group Is Complete',
                      ),
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizedText(
                        context,
                        zh: '你已经完成了这一组的首轮字母学习，可以继续下一组或转入练习。',
                        en: 'You finished the mainline pass for this group. Continue to the next group, and keep writing or drills as follow-up reinforcement.',
                      ),
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.deepAccent,
                          ),
                          onPressed: _continueToNextGroup,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            localizedText(
                              context,
                              zh: '继续下一组',
                              en: 'Continue Next Group',
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AlphabetQuizHubPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.quiz_rounded),
                          label: Text(
                            localizedText(
                              context,
                              zh: '做本组小测',
                              en: 'Practice This Group',
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.grid_view_rounded),
                          label: Text(
                            localizedText(
                              context,
                              zh: '返回字母总览',
                              en: 'Back to Alphabet Overview',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildGuideChip({
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

  Widget _buildLetterCard(BuildContext context, AlphabetLetter letter) {
    final text = Theme.of(context).textTheme;
    final isCompleted = _isLetterCompleted(letter);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openLetter(letter),
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
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: ArabicTextWithAudio(
                      textAr: letter.arabic,
                      request: LearningAudioRequest.alphabet(
                        type: 'letter',
                        textAr: letter.arabic,
                        textPlain: letter.arabic,
                        debugLabel: 'alphabet_group_card_letter',
                      ),
                      variant: ArabicAudioTextVariant.word,
                      style: text.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      spacing: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArabicTextWithAudio(
                        textAr: letter.arabicName,
                        request: LearningAudioRequest.alphabet(
                          type: 'letter',
                          textAr: letter.arabicName,
                          textPlain: letter.arabicName,
                          debugLabel: 'alphabet_group_card_name',
                        ),
                        variant: ArabicAudioTextVariant.word,
                        style: text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        spacing: 6,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        letter.latinName,
                        style: text.labelLarge?.copyWith(
                          color: AppTheme.deepAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AlphabetContentLocalizer.hint(
                          letter,
                          context.appSettings.meaningLanguage,
                        ),
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetaTag(
                            context,
                            isCompleted
                                ? localizedText(
                                    context,
                                    zh: '已完成',
                                    en: 'Completed',
                                  )
                                : localizedText(
                                    context,
                                    zh: '未完成',
                                    en: 'Not completed',
                                  ),
                            color: isCompleted
                                ? const Color(0xFFE8F5F0)
                                : const Color(0xFFF4F6F8),
                            textColor: isCompleted
                                ? AppTheme.deepAccent
                                : AppTheme.textSecondary,
                          ),
                          _buildMetaTag(
                            context,
                            localizedText(
                              context,
                              zh: '基础音值 ${letter.phoneme}',
                              en: 'Core Sound ${letter.phoneme}',
                            ),
                          ),
                          _buildMetaTag(
                            context,
                            localizedText(
                              context,
                              zh: '示例 ${letter.example.arabic}',
                              en: 'Example ${letter.example.arabic}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF98A2B3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaTag(
    BuildContext context,
    String label, {
    Color color = const Color(0xFFF4F6F8),
    Color textColor = AppTheme.textSecondary,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: text.labelMedium?.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
