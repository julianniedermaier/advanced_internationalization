/// A class representing a display option for a locale.
///
/// Use this class to create objects that represent different display options
/// for locales. Each display option includes a [title] (required) and an
/// optional [subtitle].
///
/// Example usage:
/// ```dart
/// final englishOption = LocaleDisplayOption('English');
/// final spanishOption = LocaleDisplayOption('Spanish', subtitle: 'Español');
/// ```
class LocaleDisplayOption {
  /// Creates a new [LocaleDisplayOption] instance with a [title] and an
  /// optional [subtitle].
  ///
  /// The [title] parameter is required and should provide a descriptive name
  /// for the locale option. The [subtitle] parameter, if provided, can give
  /// additional information about the locale.
  ///
  /// Example:
  /// ```dart
  /// final option = LocaleDisplayOption('Spanish', subtitle: 'Español');
  /// ```
  LocaleDisplayOption(this.title, {this.subtitle});

  /// The title of the locale display option.
  final String title;

  /// An optional subtitle providing additional information about the locale.
  final String? subtitle;
}
