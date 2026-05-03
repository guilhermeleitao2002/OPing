import 'package:flutter/widgets.dart';
import 'package:oping/l10n/app_strings.dart';
import 'package:oping/models/app_language.dart';

class AppScope extends InheritedWidget {
  final AppLanguage language;
  final AppStrings strings;
  final void Function(AppLanguage) changeLanguage;

  AppScope({
    super.key,
    required this.language,
    required this.changeLanguage,
    required super.child,
  }) : strings = AppStrings(language);

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope old) => language != old.language;
}
