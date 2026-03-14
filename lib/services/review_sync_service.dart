import 'package:flutter/foundation.dart';

class ReviewSyncService {
  ReviewSyncService._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void bump() {
    changes.value = changes.value + 1;
  }
}
