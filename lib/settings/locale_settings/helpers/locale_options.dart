import 'dart:collection';

import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:advanced_internationalization/settings/settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

/// Generates a sorted map of locale options for selection.
///
/// The function creates a map of supported locales sorted by their native
/// name with the system locale option as the first entry and the currently
/// selected Locale (if not the system option) as the second entry.
///
/// - [selectedLocaleOption]: The currently selected locale in the
/// application.
/// - [isDeviceLocale]: Indicates if the application's locale matches the
/// device's locale.
/// - [deviceLocale]: (Optional) The locale currently set on the device.
///
/// Returns a [LinkedHashMap] with locale objects as keys and
/// [LocaleDisplayOption] objects as values for display purposes.
///
/// Example:
/// ```dart
/// localeOptions(
///   context: context,
///   selectedLocaleOption: selectedLocale,
///   isDeviceLocale: isDeviceLocale,
///   deviceLocale: deviceLocale,
/// )
/// ```
LinkedHashMap<Locale, LocaleDisplayOption> localeOptions({
  required BuildContext context,
  required Locale selectedLocaleOption,
  required bool isDeviceLocale,
  required Locale? deviceLocale,
}) {
  final localeOptions = LinkedHashMap.of({
    systemLocaleOption: LocaleDisplayOption(
      context.l10n.settingsSystemDefault +
          (deviceLocale != null
              ? ' - ${_buildLocaleDisplayOption(context, deviceLocale).title}'
              : ''),
    ),
  });

  final supportedLocales = List<Locale>.from(AppLocalizations.supportedLocales);

  if (!isDeviceLocale) {
    supportedLocales.removeWhere((locale) => locale == selectedLocaleOption);
    localeOptions.addAll(
      LinkedHashMap.of({
        selectedLocaleOption:
            _buildLocaleDisplayOption(context, selectedLocaleOption),
      }),
    );
  }

  final displayLocales = Map<Locale, LocaleDisplayOption>.fromIterable(
    supportedLocales,
    value: (dynamic locale) =>
        _buildLocaleDisplayOption(context, locale as Locale?),
  ).entries.toList()
    ..sort(
      (l1, l2) => compareAsciiUpperCase(
        l1.value.title,
        l2.value.title,
      ),
    );

  localeOptions.addAll(LinkedHashMap.fromEntries(displayLocales));
  return localeOptions;
}

/// Retrieves a [LocaleDisplayOption] for a given [Locale].
///
/// Constructs a [LocaleDisplayOption] based on the provided [Locale] and the
/// current [BuildContext]. This function retrieves both the native name and
/// standard name of the locale for display.
///
/// This function relies on the `flutter_localized_locales` package.
///
/// - [context]: The BuildContext for the current widget.
/// - [locale]: The Locale object used to generate the [LocaleDisplayOption].
///
/// Returns a [LocaleDisplayOption] with the native name as the title and the
/// locale name as the subtitle, if available.
///
/// Example:
/// ```dart
/// _getLocaleDisplayOption(context: context, locale: someLocale)
/// ```
LocaleDisplayOption _buildLocaleDisplayOption(
  BuildContext context,
  Locale? locale,
) {
  final localeCode = locale.toString();
  final localeName = LocaleNames.of(context)!.nameOf(localeCode);

  if (localeName != null) {
    final localeNativeName =
        LocaleNamesLocalizationsDelegate.nativeLocaleNames[localeCode];
    return localeNativeName != null
        ? LocaleDisplayOption(
            localeNativeName,
            subtitle: localeName,
          )
        : LocaleDisplayOption(localeName);
  }

  return LocaleDisplayOption(localeCode);
}
