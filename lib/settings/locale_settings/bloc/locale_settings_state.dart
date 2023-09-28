part of 'locale_settings_bloc.dart';

/// [LocaleSettingsState] represents the state of the `LocaleSettingsBloc`.
///
/// Its parameters are [status], [deviceLocale] and [selectedLocale].
class LocaleSettingsState extends Equatable {
  /// Creates an instance of [LocaleSettingsState] and initializes the [status]
  /// to `initial`.
  const LocaleSettingsState({
    this.status = LocaleSettingsStatus.initial,
    this.deviceLocale,
    Locale? selectedLocale,
  }) : selectedLocale = selectedLocale ?? systemLocaleOption;

  /// The current [status] of the `LocaleSettingsBloc`.
  final LocaleSettingsStatus status;

  /// The `locale` set for the device.
  final Locale? deviceLocale;

  /// The `locale` set for the application.
  final Locale selectedLocale;

  /// Creates a new [LocaleSettingsState] with updated values.
  LocaleSettingsState copyWith({
    LocaleSettingsStatus Function()? status,
    Locale? Function()? deviceLocale,
    Locale? Function()? selectedLocale,
  }) {
    return LocaleSettingsState(
      status: status != null ? status() : this.status,
      deviceLocale: deviceLocale != null ? deviceLocale() : this.deviceLocale,
      selectedLocale:
          selectedLocale != null ? selectedLocale() : this.selectedLocale,
    );
  }

  @override
  List<Object?> get props => [
        status,
        deviceLocale,
        selectedLocale,
      ];
}
