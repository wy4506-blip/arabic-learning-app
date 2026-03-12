import 'package:flutter/material.dart';

import '../models/word_item.dart';
import '../services/vocab_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class VocabBookPage extends StatefulWidget {
  const VocabBookPage({super.key});

  @override
  State<VocabBookPage> createState() => _VocabBookPageState();
}

enum WordFilter { all, recent }

class _VocabBookPageState extends State<VocabBookPage> {
  List<WordItem> _favoriteWords = [];
  bool _isLoading = true;
  final TextEditingController _controller = TextEditingController();
  WordFilter _filter = WordFilter.all;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final words = await VocabService.getFavoriteWords();
    if (!mounted) return;
    setState(() {
      _favoriteWords = words;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(WordItem word) async {
    await VocabService.toggleFavorite(word);
    await _loadFavorites();
  }

  List<WordItem> get _visible {
    final q = _controller.text.trim().toLowerCase();
    Iterable<WordItem> words = _favoriteWords;
    if (_filter == WordFilter.recent) {
      words = words.toList().reversed;
    }
    if (q.isNotEmpty) {
      words = words.where((w) =>
          w.arabic.toLowerCase().contains(q) ||
          w.pronunciation.toLowerCase().contains(q) ||
          w.meaning.toLowerCase().contains(q));
    }
    return words.toList();
  }

  @override
  Widget build(BuildContext context) {
    final words = _visible;
    return Scaffold(
      appBar: AppBar(title: const Text('单词本')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  SectionTitle(title: 'Wordbook', subtitle: '重点是检索、复习与掌握状态，而不是堆列表'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      hintText: '搜索阿语 / 中文 / 音译',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.strokeLight)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.strokeLight)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(label: const Text('全部'), selected: _filter == WordFilter.all, onSelected: (_) => setState(() => _filter = WordFilter.all)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('最近加入'), selected: _filter == WordFilter.recent, onSelected: (_) => setState(() => _filter = WordFilter.recent)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_favoriteWords.isEmpty)
                    AppSurface(
                      child: Column(
                        children: [
                          const Icon(Icons.bookmark_border_rounded, size: 40, color: AppTheme.accentMintDark),
                          const SizedBox(height: 10),
                          Text('学习中可随时加入单词本', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    )
                  else if (words.isEmpty)
                    AppSurface(
                      child: Text('没有搜索到结果，试试切换带音符/去音符的检索方式。', style: Theme.of(context).textTheme.bodyMedium),
                    )
                  else
                    ...words.map((word) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppSurface(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(word.arabic, style: const TextStyle(fontSize: 26, height: 1.35, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(word.meaning, style: Theme.of(context).textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(word.pronunciation, style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                IconButton(onPressed: () => _toggleFavorite(word), icon: const Icon(Icons.bookmark_remove_outlined)),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
      ),
    );
  }
}
