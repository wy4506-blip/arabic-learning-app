import 'package:flutter/material.dart';
import 'alphabet_hub_page.dart';
import 'course_list_page.dart';
import 'unlock_page.dart';
import 'vocab_book_page.dart';
import 'review_page.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isUnlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlockState();
  }

  Future<void> _loadUnlockState() async {
    final unlocked = await UnlockService.isUnlocked();
    if (mounted) {
      setState(() {
        _isUnlocked = unlocked;
        _isLoading = false;
      });
    }
  }

  Future<void> _goToUnlockPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnlockPage()),
    );

    if (result == true) {
      await _loadUnlockState();
    }
  }

  Future<void> _toggleTestUnlock() async {
    if (_isUnlocked) {
      await UnlockService.resetUnlock();
    } else {
      await UnlockService.unlockAllCourses();
    }
    await _loadUnlockState();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppTheme.softShadow,
                    border: Border.all(color: AppTheme.border, width: 0.6),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: AppTheme.deepAccent,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أبا أبا', style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'abaaba · 阿巴阿巴',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                _SmallIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.softShadow,
                border: Border.all(color: AppTheme.border, width: 0.6),
              ),
              child: Row(
                children: [
                  Icon(
                    _isUnlocked
                        ? Icons.verified_rounded
                        : Icons.lock_outline_rounded,
                    size: 18,
                    color: _isUnlocked
                        ? AppTheme.deepAccent
                        : AppTheme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isUnlocked ? '当前状态：已解锁' : '当前状态：未解锁',
                      style: text.bodySmall?.copyWith(
                        color: _isUnlocked
                            ? AppTheme.deepAccent
                            : AppTheme.secondaryText,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleTestUnlock,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.softAccent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _isUnlocked ? '恢复未解锁' : '测试解锁',
                        style: text.labelMedium?.copyWith(
                          color: AppTheme.deepAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.softShadow,
                border: Border.all(color: AppTheme.border, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.softAccent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '继续学习',
                      style: text.labelMedium?.copyWith(
                        color: AppTheme.deepAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '从字母开始，逐步进入课程',
                    style: text.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '先把发音和字形打牢，再进入课程、复习和单词积累。',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AlphabetHubPage(),
                              ),
                            );
                          },
                          child: const Text('开始字母学习'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SquareAction(
                        icon: Icons.menu_book_rounded,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseListPage(isUnlocked: _isUnlocked),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('今天学什么', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              '保持入口简单，学习路径才会更清晰。',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            _FeatureCard(
              icon: Icons.sort_by_alpha_rounded,
              iconBg: AppTheme.softAccent,
              iconColor: AppTheme.deepAccent,
              title: '字母学习',
              subtitle: '进入字母入门、辨析、练习、听读和书写内容',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlphabetHubPage(),
                  ),
                );
              },
            ),
            _FeatureCard(
              icon: Icons.menu_book_rounded,
              iconBg: AppTheme.softBlue,
              iconColor: const Color(0xFF3478F6),
              title: '全部课程',
              subtitle: '查看完整学习路径与课程内容',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CourseListPage(isUnlocked: _isUnlocked),
                  ),
                );

                if (result is bool) {
                  await _loadUnlockState();
                }
              },
            ),
            _FeatureCard(
              icon: Icons.refresh_rounded,
              iconBg: AppTheme.softOrange,
              iconColor: const Color(0xFFF08A24),
              title: '今日复习',
              subtitle: '根据学习节奏回顾旧内容',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewPage(),
                  ),
                );
              },
            ),
            _FeatureCard(
              icon: Icons.bookmark_rounded,
              iconBg: AppTheme.softPurple,
              iconColor: const Color(0xFF7D58E6),
              title: '单词本',
              subtitle: '收藏重点词汇，管理错词',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VocabBookPage(),
                  ),
                );
              },
            ),
            if (!_isUnlocked)
              _FeatureCard(
                icon: Icons.lock_open_rounded,
                iconBg: AppTheme.softAccent,
                iconColor: AppTheme.deepAccent,
                title: '解锁全部课程',
                subtitle: '字母模块和前三课免费，后续一次性解锁',
                onTap: _goToUnlockPage,
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border, width: 0.6),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleMedium),
                      const SizedBox(height: 4),
                      Text(subtitle, style: text.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.tertiaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareAction({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border, width: 0.6),
            boxShadow: AppTheme.softShadow,
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primaryText,
          ),
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 0.6),
            boxShadow: AppTheme.softShadow,
          ),
          child: Icon(icon, color: AppTheme.primaryText, size: 20),
        ),
      ),
    );
  }
}
