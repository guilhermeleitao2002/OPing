enum AppLanguage {
  english,
  french,
  spanish,
  japanese,
  chinese,
  italian,
  german,
  portuguese;

  String get code => switch (this) {
        AppLanguage.english => 'en',
        AppLanguage.french => 'fr',
        AppLanguage.spanish => 'es-la',
        AppLanguage.japanese => 'ja',
        AppLanguage.chinese => 'zh',
        AppLanguage.italian => 'it',
        AppLanguage.german => 'de',
        AppLanguage.portuguese => 'pt-br',
      };

  String get label => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.french => 'French',
        AppLanguage.spanish => 'Spanish (LA)',
        AppLanguage.japanese => 'Japanese',
        AppLanguage.chinese => 'Chinese',
        AppLanguage.italian => 'Italian',
        AppLanguage.german => 'German',
        AppLanguage.portuguese => 'Portuguese (BR)',
      };

  static AppLanguage fromCode(String code) => AppLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguage.english,
      );

  static String labelForCode(String code) {
    for (final l in AppLanguage.values) {
      if (l.code == code) return l.label;
    }
    return code.toUpperCase();
  }
}
