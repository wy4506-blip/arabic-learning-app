import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/localized_text.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../view_models/learning_path_view_models.dart' as vm;
import '../widgets/app_widgets.dart';

const Duration _unlockLoadTimeout = Duration(seconds: 2);

class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  bool _loading = true;
  bool _processing = false;
  vm.LearningPathSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lessons = await LessonService().loadLessons().timeout(
            _unlockLoadTimeout,
            onTimeout: () => <Lesson>[],
          );
      final progress = await ProgressService.getSnapshot().timeout(
        _unlockLoadTimeout,
        onTimeout: () => const ProgressSnapshot(
          completedLessons: <String>{},
          startedLessons: <String>{},
          reviewCount: 0,
          streakDays: 0,
        ),
      );
      final unlocked = await UnlockService.isUnlocked().timeout(
        _unlockLoadTimeout,
        onTimeout: () => false,
      );
      if (!mounted) return;

      setState(() {
        _snapshot = vm.LearningPathViewModels.buildSnapshot(
          lessons: lessons,
          progress: progress,
          unlocked: unlocked,
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _snapshot = vm.LearningPathViewModels.buildSnapshot(
          lessons: const [],
          progress: const ProgressSnapshot(
            completedLessons: <String>{},
            startedLessons: <String>{},
            reviewCount: 0,
            streakDays: 0,
          ),
          unlocked: false,
        );
        _loading = false;
      });
    }
  }

  Future<void> _unlock() async {
    if (_processing) return;
    if (_snapshot?.unlocked == true) {
      Navigator.pop(context, true);
      return;
    }

    setState(() => _processing = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await UnlockService.unlockAllCourses();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.strings.t('unlock.success'))),
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _processing = false);
      messenger.showSnackBar(
        SnackBar(content: Text(context.strings.t('unlock.failure'))),
      );
    }
  }

  void _closeAsSecondaryAction() {
    if (_processing) return;
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _snapshot == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final strings = context.strings;
    final data = vm.LearningPathViewModels.buildUnlockPage(
      strings: strings,
      snapshot: _snapshot!,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
          children: [
            UnlockHeader(
              title: strings.t('unlock.title'),
              enabled: !_processing,
              onBack: _closeAsSecondaryAction,
            ),
            const SizedBox(height: 20),
            UnlockHeroCard(data: data),
            const SizedBox(height: 16),
            const _UnlockInfoNotice(),
            const SizedBox(height: 24),
            UnlockBenefitsSection(
              title: strings.t('unlock.benefits'),
              items: data.benefitItems,
            ),
            const SizedBox(height: 20),
            UnlockPurchaseNotes(
              title: strings.t('unlock.notes_title'),
              notes: data.purchaseNotes,
            ),
            const SizedBox(height: 18),
            UnlockSecondaryAction(
              label: data.secondaryActionText,
              enabled: !_processing,
              onTap: _closeAsSecondaryAction,
            ),
          ],
        ),
      ),
      bottomNavigationBar: UnlockBottomBar(
        actionText: _processing
            ? strings.t('unlock.action_processing')
            : data.primaryActionText,
        footerHint: data.footerHint,
        enabled: !_processing && !data.unlocked,
        loading: _processing,
        onTap: _unlock,
      ),
    );
  }
}

class UnlockHeader extends StatelessWidget {
  final String title;
  final bool enabled;
  final VoidCallback onBack;

  const UnlockHeader({
    super.key,
    required this.title,
    required this.enabled,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onBack : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.primaryText,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 56),
      ],
    );
  }
}

class UnlockHeroCard extends StatelessWidget {
  final vm.UnlockPageViewModel data;

  const UnlockHeroCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFEFF8F3),
            Color(0xFFF8FBF8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDCEAE3)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: text.headlineMedium?.copyWith(fontSize: 26, height: 1.18),
          ),
          const SizedBox(height: 10),
          Text(
            data.subtitle,
            style: text.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Text(
                data.priceText,
                style: text.headlineLarge?.copyWith(
                  fontSize: 36,
                  height: 1.0,
                ),
              ),
              Pill(
                label: data.priceTag,
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.accentMintDark,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.trustTags
                .map(
                  (tag) => Pill(
                    label: tag,
                    backgroundColor: Colors.white.withOpacity(0.92),
                    foregroundColor: AppTheme.textSecondary,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _UnlockInfoNotice extends StatelessWidget {
  const _UnlockInfoNotice();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.softAccent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.deepAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.strings.t('unlock.title'),
                  style: text.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  context.strings.t('unlock.subtitle'),
                  style: text.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizedText(
                    context,
                    zh: '旧的“解锁”入口现在改为会员说明页。',
                    en: 'The old Unlock entry now works as a membership info page.',
                  ),
                  style: text.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UnlockBenefitsSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const UnlockBenefitsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: UnlockBenefitItem(text: item),
          ),
        ),
      ],
    );
  }
}

class UnlockBenefitItem extends StatelessWidget {
  final String text;

  const UnlockBenefitItem({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.softAccent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppTheme.deepAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class UnlockPurchaseNotes extends StatelessWidget {
  final String title;
  final List<String> notes;

  const UnlockPurchaseNotes({
    super.key,
    required this.title,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: 10),
          ...notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppTheme.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      style: text.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UnlockSecondaryAction extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const UnlockSecondaryAction({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: enabled ? onTap : null,
        child: Text(label),
      ),
    );
  }
}

class UnlockBottomBar extends StatelessWidget {
  final String actionText;
  final String footerHint;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const UnlockBottomBar({
    super.key,
    required this.actionText,
    required this.footerHint,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: AppTheme.strokeLight),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: enabled ? onTap : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(actionText),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              footerHint,
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
