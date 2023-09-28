part of 'locale_settings_bloc.dart';

/// [LocaleSettingsEvent] is the base class for bloc events of the
/// `LocaleSettingsBloc`.
abstract class LocaleSettingsEvent {
  /// Creates an instance of [LocaleSettingsEvent].
  const LocaleSettingsEvent();
}

/// [GetLocaleSettings] is a `LocaleSettingsBloc` event to retrieve current
/// locale settings.
class GetLocaleSettings extends LocaleSettingsEvent {
  /// Creates an instance of [GetLocaleSettings].
  const GetLocaleSettings();
}

/// [ChangeDeviceLocale] is a `LocaleSettingsBloc` event triggered when the
/// device locale is changed. It takes the [newDeviceLocale] as a parameter.
class ChangeDeviceLocale extends LocaleSettingsEvent {
  /// Creates an instance of [ChangeDeviceLocale].
  const ChangeDeviceLocale(this.newDeviceLocale);

  /// The new locale the device has changed to.
  final Locale? newDeviceLocale;
}

/// [ChangeLocaleSettings] is a `LocaleSettingsBloc` event triggered when the
/// chosen app locale is changed. It takes the [newLocale] as a parameter.
class ChangeLocaleSettings extends LocaleSettingsEvent {
  /// Creates an instance of [ChangeLocaleSettings].
  const ChangeLocaleSettings(this.newLocale);

  /// The new locale the user has selected.
  final Locale? newLocale;
}
