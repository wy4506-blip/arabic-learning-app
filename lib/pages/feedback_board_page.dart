import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme/app_theme.dart';

class FeedbackBoardPage extends StatefulWidget {
  final Future<void> Function(String category, String message) onSubmit;
  final String initialCategory;

  const FeedbackBoardPage({
    super.key,
    required this.onSubmit,
    this.initialCategory = 'feedback.category_suggestion',
  });

  @override
  State<FeedbackBoardPage> createState() => _FeedbackBoardPageState();
}

class _FeedbackBoardPageState extends State<FeedbackBoardPage> {
  final TextEditingController _messageController = TextEditingController();
  late String _selectedCategory;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('feedback.empty_error'))),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_selectedCategory, message);
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final categories = <String>[
      'feedback.category_suggestion',
      'feedback.category_bug',
      'feedback.category_experience',
    ];
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.t('feedback.title'))),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.bgCardSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('feedback.hero_title'), style: text.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    strings.t('feedback.hero_subtitle'),
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(strings.t('feedback.category'), style: text.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(strings.t(category)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                  selectedColor: const Color(0xFFEAF7F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: selected
                          ? AppTheme.accentMintDark
                          : AppTheme.strokeLight,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text(strings.t('feedback.message'), style: text.titleSmall),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 10,
              minLines: 8,
              decoration: InputDecoration(
                hintText: strings.t('feedback.hint'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: AppTheme.strokeLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: AppTheme.strokeLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                      color: AppTheme.accentMintDark, width: 1.2),
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _submitting
                      ? strings.t('feedback.submitting')
                      : strings.t('feedback.submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
