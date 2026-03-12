import 'package:flutter/material.dart';

import '../models/word_item.dart';
import '../services/progress_service.dart';
import '../services/vocab_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<WordItem> _words = const [];
  int _index = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final words = await VocabService.getFavoriteWords();
    if (!mounted) return;
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  Future<void> _next() async {
    await ProgressService.incrementReviewCount();
    if (!mounted) return;
    setState(() => _index = (_index + 1) % (_words.isEmpty ? 1 : _words.length));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final word = _words.isEmpty ? null : _words[_index];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            SectionTitle(title: 'Review', subtitle: '清晰答题、降低压力，优先复习已收藏内容'),
            const SizedBox(height: 16),
            if (word == null)
              AppSurface(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Icon(Icons.celebration_outlined, size: 42, color: AppTheme.accentMintDark),
                    const SizedBox(height: 12),
                    Text('当前没有待复习内容', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('先去课程详情页或单词本收藏几个重点词。', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              )
            else ...[
              AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Pill(label: '今日复习'),
                        const Spacer(),
                        Text('${_index + 1} / ${_words.length}', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(word.arabic, style: const TextStyle(fontSize: 34, height: 1.4, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(word.pronunciation, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(word.meaning, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('复习提示', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text('一次只服务一个决策：看 → 想 → 记 → 下一步。', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _next, child: const Text('稍后复习'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: _next, child: const Text('我记住了'))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
