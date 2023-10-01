import 'package:advanced_internationalization/settings/locale_settings/locale_settings.dart';
import 'package:flutter/material.dart';

/// Constructs a LocaleRadioListTile widget.
///
/// This widget displays a radio list tile for selecting a locale option for the
/// app. The list tile is displaying locale data using a title and a subtitle.
///
/// - [locale]: The locale associated with this radio list tile.
/// - [localeDisplayOption]: An object of type `LocaleDisplayOption` that
/// contains information about how to display the locale.
/// - [selectedLocaleOption]: The currently selected locale option.
/// - [onLocaleChanged]: A callback function that is called when the user
/// selects this locale option.
///
/// Example Usage:
/// ```dart
/// LocaleRadioListTile(
///   locale: Locale('es', 'ES'),
///   localeDisplayOption: LocaleDisplayOption(
///     'Spanish',
///     subtitle: 'Español',
///   ),
///   selectedLocaleOption: selectedLocale,
///   onLocaleChanged: (newLocale) {
///     // Handle locale selection here
///   },
/// )
/// ```

class LocaleRadioListTile extends StatelessWidget {
  /// Creates an instance of [LocaleRadioListTile].
  const LocaleRadioListTile({
    required this.locale,
    required this.localeDisplayOption,
    required this.selectedLocaleOption,
    required this.onLocaleChanged,
    super.key,
  });

  /// The locale associated with this radio list tile.
  final Locale locale;

  /// An object of type [LocaleDisplayOption] that contains information about
  /// how to display the locale.
  final LocaleDisplayOption localeDisplayOption;

  /// The locale that is currently selected.
  final Locale selectedLocaleOption;

  /// A callback function that is called when the user selects a new locale.
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyLarge!;
    final subtitleStyle = titleStyle.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.8),
      fontSize: 12,
    );

    return RadioListTile<Locale>(
      value: locale,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localeDisplayOption.title, style: titleStyle),
          if (localeDisplayOption.subtitle != null)
            Text(localeDisplayOption.subtitle!, style: subtitleStyle),
        ],
      ),
      groupValue: selectedLocaleOption,
      onChanged: (newLocale) {
        if (newLocale != null) {
          onLocaleChanged(newLocale);
        }
      },
      dense: true,
    );
  }
}
