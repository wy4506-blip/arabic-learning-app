import 'package:flutter/widgets.dart';

import '../app_scope.dart';
import '../models/app_settings.dart';

String localizedText(
  BuildContext context, {
  required String zh,
  required String en,
}) {
  return context.appSettings.appLanguage == AppLanguage.en ? en : zh;
}

bool isEnglishUi(BuildContext context) {
  return context.appSettings.appLanguage == AppLanguage.en;
}
