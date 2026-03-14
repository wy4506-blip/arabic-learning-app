import '../models/app_settings.dart';

String grammarUiText(
  String value,
  AppLanguage language,
) {
  return _grammarText(value, english: language == AppLanguage.en);
}

String grammarContentText(
  String value,
  ContentLanguage language,
) {
  return _grammarText(value, english: language == ContentLanguage.en);
}

List<String> grammarContentList(
  List<String> values,
  ContentLanguage language,
) {
  return values
      .map((value) => grammarContentText(value, language))
      .toList(growable: false);
}

String _grammarText(
  String value, {
  required bool english,
}) {
  if (!value.contains('||')) {
    return value;
  }

  final parts = value.split('||');
  final zh = parts.first.trim();
  final en = parts.length > 1 ? parts[1].trim() : zh;
  return english ? en : zh;
}
