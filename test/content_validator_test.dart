import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/validate_content.dart';

void main() {
  test('content validator completes and prints a summary', () {
    final result = runContentValidation(root: Directory.current);

    final previewLines = result.lines.take(40);
    for (final line in previewLines) {
      // Keep the validator output visible in CI/test logs.
      // ignore: avoid_print
      print(line);
    }
    // ignore: avoid_print
    print(
      'Validation summary => errors=${result.errorCount}, warnings=${result.warningCount}, info=${result.infoCount}, exitCode=${result.exitCode}',
    );

    expect(result.lines, isNotEmpty);
    expect(result.exitCode, inInclusiveRange(0, 2));
  });
}
