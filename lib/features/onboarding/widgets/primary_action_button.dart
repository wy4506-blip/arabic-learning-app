import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isEnabled;

  const PrimaryActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isEnabled ? onTap : null,
        child: Text(text),
      ),
    );
  }
}
