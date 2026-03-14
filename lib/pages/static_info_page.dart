import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StaticInfoPage extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const StaticInfoPage({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            ...paragraphs.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  paragraph,
                  style: text.bodyLarge?.copyWith(height: 1.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
