import 'package:flutter/material.dart';
import '../models/word_item.dart';
import '../services/vocab_service.dart';
import '../theme/app_theme.dart';

class VocabBookPage extends StatefulWidget {
  const VocabBookPage({super.key});

  @override
  State<VocabBookPage> createState() => _VocabBookPageState();
}

class _VocabBookPageState extends State<VocabBookPage> {
  List<WordItem> _favoriteWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final words = await VocabService.getFavoriteWords();
    if (mounted) {
      setState(() {
        _favoriteWords = words;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(WordItem word) async {
    await VocabService.toggleFavorite(word);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    children: [
                      _buildTopButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('单词本', style: text.titleLarge),
                            const SizedBox(height: 2),
                            Text(
                              '收藏重点词汇，方便反复复习',
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
                            Icons.bookmark_rounded,
                            color: AppTheme.deepAccent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('已收藏 ${_favoriteWords.length} 个单词',
                                  style: text.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '把重要词汇先记下来，后面集中复习。',
                                style: text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_favoriteWords.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
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
                        children: [
                          const Icon(
                            Icons.bookmarks_outlined,
                            size: 42,
                            color: Color(0xFF98A2B3),
                          ),
                          const SizedBox(height: 12),
                          Text('还没有收藏的单词', style: text.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            '去课程详情页把重要单词收藏起来吧。',
                            style: text.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._favoriteWords.map((word) {
                      return _buildWordCard(
                        context: context,
                        word: word,
                        onRemove: () => _toggleFavorite(word),
                      );
                    }),
                ],
              ),
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

  Widget _buildWordCard({
    required BuildContext context,
    required WordItem word,
    required VoidCallback onRemove,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F0),
              borderRadius: BorderRadius.circular(20),
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
                  style: text.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(word.pronunciation, style: text.bodySmall),
                const SizedBox(height: 4),
                Text(word.meaning, style: text.titleMedium),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.bookmark_remove_rounded,
              color: Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }
}
