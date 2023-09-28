import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:advanced_internationalization/settings/locale_settings/locale_settings.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:settings_repository/settings_repository.dart';

part 'locale_settings_event.dart';

part 'locale_settings_state.dart';

/// [LocaleSettingsBloc] is responsible for managing the application's locale
/// settings.
///
/// [LocaleSettingsBloc] requires an [SettingsRepository] to save locale
/// data.
class LocaleSettingsBloc
    extends Bloc<LocaleSettingsEvent, LocaleSettingsState> {
  /// Creates an instance of [LocaleSettingsBloc] and handles bloc related event
  /// listeners:
  /// - [GetLocaleSettings]
  /// - [ChangeLocaleSettings]
  /// - [ChangeDeviceLocale]
  LocaleSettingsBloc({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(const LocaleSettingsState()) {
    on<GetLocaleSettings>(_onGetLocaleSettings);
    on<ChangeLocaleSettings>(_onChangeLocaleSettings);
    on<ChangeDeviceLocale>(_onChangeDeviceLocale);
  }

  final SettingsRepository _settingsRepository;

  /// [_onGetLocaleSettings] retrieves any saved locale and adapts the bloc
  /// state locale to either the retrieve locale or null if no (supported) saved
  /// locale could be found.
  void _onGetLocaleSettings(
    GetLocaleSettings event,
    Emitter<LocaleSettingsState> emit,
  ) {
    emit(state.copyWith(status: () => LocaleSettingsStatus.loading));

    var newLocale = systemLocaleOption;
    final storedLocale = _getStoredLocale();

    if (storedLocale != null) {
      if (AppLocalizations.supportedLocales.contains(storedLocale)) {
        // A supported locale has been saved (the user previously selected a
        // local manually)
        // Assign to emit variable
        newLocale = storedLocale;
      } else {
        // An unsupported locale has been saved
        // Delete entry
        _deleteStoredLocale();
      }
    }

    emit(
      state.copyWith(
        status: () => LocaleSettingsStatus.success,
        selectedLocale: () => newLocale,
      ),
    );
  }

  /// [_onChangeLocaleSettings] adjusts the bloc state locale to the new locale
  /// or null, if the app was changed to the device locale.
  /// If a new locale was selected the locale is saved to the device
  /// (overwriting any existing locale).
  /// If the locale was changed to the device locale any previously saved locale
  /// is deleted from the device.
  Future<void> _onChangeLocaleSettings(
    ChangeLocaleSettings event,
    Emitter<LocaleSettingsState> emit,
  ) async {
    emit(state.copyWith(status: () => LocaleSettingsStatus.loading));

    final newLocale = event.newLocale;

    if (newLocale != null) {
      if (AppLocalizations.supportedLocales.contains(newLocale)) {
        // Save or overwrite locale entry (the user has selected a supported
        // locale)
        await _saveLocale(locale: newLocale);
        // Emit new locale
        emit(
          state.copyWith(
            status: () => LocaleSettingsStatus.success,
            selectedLocale: () => newLocale,
          ),
        );
      } else {
        // Emit without changes
        emit(state.copyWith(status: () => LocaleSettingsStatus.success));
      }
    } else {
      // Delete locale entry (the user has changed so device locale)
      await _deleteStoredLocale();
      // Emit locale: null
      emit(
        state.copyWith(
          status: () => LocaleSettingsStatus.success,
          selectedLocale: () => systemLocaleOption,
        ),
      );
    }
  }

  /// [_onChangeDeviceLocale] updates the bloc state deviceLocale.
  void _onChangeDeviceLocale(
    ChangeDeviceLocale event,
    Emitter<LocaleSettingsState> emit,
  ) {
    emit(state.copyWith(deviceLocale: () => event.newDeviceLocale));
  }

  /// [_getStoredLocale] retrieves the stored locale from the device.
  /// Returns null if no locale can be found.
  Locale? _getStoredLocale() {
    if (_settingsRepository.containsKey(
      key: localePrefsKey,
    )) {
      final storedLocaleString =
          _settingsRepository.getString(key: localePrefsKey);

      final localeParts = storedLocaleString.split('_');
      final languageCode = localeParts[0];
      final scriptCode = localeParts.length > 1 ? localeParts[1] : null;
      final countryCode = localeParts.length > 2 ? localeParts[2] : null;

      return Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
    } else {
      return null;
    }
  }

  /// [_saveLocale] saves the specified [locale] to the device.
  Future<void> _saveLocale({
    required Locale locale,
  }) async {
    await _settingsRepository.saveString(
      key: localePrefsKey,
      value: locale.toString(),
    );
  }

  /// [_deleteStoredLocale] deletes any saved locale from the device.
  Future<void> _deleteStoredLocale() async {
    if (_settingsRepository.containsKey(
      key: localePrefsKey,
    )) {
      await _settingsRepository.deleteEntry(key: localePrefsKey);
    }
  }
}
