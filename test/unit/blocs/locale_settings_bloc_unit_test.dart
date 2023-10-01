import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:advanced_internationalization/settings/settings.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  group('Locale Settings Bloc Unit Tests', () {
    late MockSettingsRepository mockSettingsRepository;

    // Requires AppLocalizations.supportedLocales to have at least two entries
    final supportedLocale = AppLocalizations.supportedLocales[0];
    final supportedLocaleAlternative = AppLocalizations.supportedLocales[1];
    const unsupportedLocale = Locale('foo', 'BAR');

    setUpAll(() {
      assert(
        AppLocalizations.supportedLocales.length >= 2,
        'At least 2 supported locales are required for these tests.',
      );
    });

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
    });

    /// Helper function configuring the behavior of the
    /// `MockSettingsRepository`.
    void setupMockSettingsRepository({required Locale? storedLocale}) {
      if (storedLocale == null) {
        // Mocking an empty settings repository

        // Stub repository contains key call
        when(() => mockSettingsRepository.containsKey(key: localePrefsKey))
            .thenAnswer((_) => false);
      } else {
        // Mocking a Settings Repository with a stored locale

        // Stub repository contains key call
        when(() => mockSettingsRepository.containsKey(key: localePrefsKey))
            .thenAnswer((_) => true);

        // Stub repository get string call
        when(() => mockSettingsRepository.getString(key: localePrefsKey))
            .thenAnswer((_) => storedLocale.toString());

        // Stub repository delete entry call
        when(() => mockSettingsRepository.deleteEntry(key: localePrefsKey))
            .thenAnswer((_) async {});
      }

      // Stub repository save string call
      when(
        () => mockSettingsRepository.saveString(
          key: localePrefsKey,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
    }

    /// Helper function creating the LocaleSettingsBloc.
    LocaleSettingsBloc setupLocaleSettingsBloc({
      required Locale? storedLocale,
    }) {
      // Set up mock settings repository
      setupMockSettingsRepository(storedLocale: storedLocale);

      // Return bloc with the mocked settings repository
      return LocaleSettingsBloc(
        settingsRepository: mockSettingsRepository,
      );
    }

    /// This group of tests is designed to validate the functionality of the
    /// BLoCs `GetLocaleSettings` event.
    group('GetLocaleSettings', () {
      /// Validates the BLoC emits a saved supported locale.
      blocTest<LocaleSettingsBloc, LocaleSettingsState>(
        'Emit saved supported locale',
        build: () => setupLocaleSettingsBloc(storedLocale: supportedLocale),
        act: (bloc) => bloc.add(const GetLocaleSettings()),
        expect: () => [
          const LocaleSettingsState(status: LocaleSettingsStatus.loading),
          LocaleSettingsState(
            status: LocaleSettingsStatus.success,
            selectedLocale: supportedLocale,
          ),
        ],
      );

      /// Validates the BLoC emits system if the saved locale is not supported
      /// and deletes the unsupported locale database entry.
      blocTest<LocaleSettingsBloc, LocaleSettingsState>(
        'Emit system if saved locale is not supported',
        build: () => setupLocaleSettingsBloc(storedLocale: unsupportedLocale),
        act: (bloc) => bloc.add(const GetLocaleSettings()),
        expect: () => const [
          LocaleSettingsState(status: LocaleSettingsStatus.loading),
          LocaleSettingsState(status: LocaleSettingsStatus.success),
        ],
        verify: (_) {
          verify(
            () => mockSettingsRepository.deleteEntry(
              key: localePrefsKey,
            ),
          ).called(1);
        },
      );

      /// Validates the BLoC emits system if no locale is saved.
      blocTest<LocaleSettingsBloc, LocaleSettingsState>(
        'Emit null if no locale is saved',
        build: () => setupLocaleSettingsBloc(storedLocale: null),
        act: (bloc) => bloc.add(const GetLocaleSettings()),
        expect: () => const [
          LocaleSettingsState(status: LocaleSettingsStatus.loading),
          LocaleSettingsState(status: LocaleSettingsStatus.success),
        ],
      );
    });

    /// This group of tests is designed to validate the functionality of the
    /// BLoCs `ChangeLocaleSettings` event.
    group('ChangeLocaleSettings', () {

      /// This group of tests is designed to validate the functionality of the
      /// BLoCs `ChangeLocaleSettings` event if the current locale is manually
      /// selected.
      group('Starting on manually selected locale', () {

        /// Validates the BLoC does not emit any changes if the new locale is
        /// not supported.
        blocTest<LocaleSettingsBloc, LocaleSettingsState>(
          'Emit no change if new locale is not supported',
          build: () => setupLocaleSettingsBloc(storedLocale: supportedLocale),
          seed: () {
            return LocaleSettingsState(
              status: LocaleSettingsStatus.success,
              selectedLocale: supportedLocale,
            );
          },
          act: (bloc) =>
              bloc.add(const ChangeLocaleSettings(unsupportedLocale)),
          expect: () => [
            LocaleSettingsState(
              status: LocaleSettingsStatus.loading,
              selectedLocale: supportedLocale,
            ),
            LocaleSettingsState(
              status: LocaleSettingsStatus.success,
              selectedLocale: supportedLocale,
            ),
          ],
          verify: (_) {
            verifyNever(
              () => mockSettingsRepository.saveString(
                key: localePrefsKey,
                value: any(named: 'value'),
              ),
            );
          },
        );

        /// Validates the BLoC emits system if no new locale is provided and the
        /// database entry is deleted.
        blocTest<LocaleSettingsBloc, LocaleSettingsState>(
          'Emit device locale and delete saved entry if no locale is provided',
          build: () => setupLocaleSettingsBloc(storedLocale: supportedLocale),
          seed: () {
            return LocaleSettingsState(
              status: LocaleSettingsStatus.success,
              selectedLocale: supportedLocale,
            );
          },
          act: (bloc) => bloc.add(const ChangeLocaleSettings(null)),
          expect: () => [
            LocaleSettingsState(
              status: LocaleSettingsStatus.loading,
              selectedLocale: supportedLocale,
            ),
            const LocaleSettingsState(status: LocaleSettingsStatus.success),
          ],
          verify: (_) {
            verify(
              () => mockSettingsRepository.deleteEntry(
                key: localePrefsKey,
              ),
            ).called(1);
          },
        );
      });

      /// This group of tests is designed to validate the functionality of the
      /// BLoCs `ChangeLocaleSettings` event if the current locale is the device
      /// locale.
      group('Starting on device locale', () {

        /// Validates the BLoC emits the new locale and saves it on the
        /// database.
        blocTest<LocaleSettingsBloc, LocaleSettingsState>(
          'Emit new supported locale and save entry',
          build: () => setupLocaleSettingsBloc(storedLocale: null),
          seed: () {
            return LocaleSettingsState(
              status: LocaleSettingsStatus.success,
              deviceLocale: supportedLocaleAlternative,
            );
          },
          act: (bloc) => bloc.add(ChangeLocaleSettings(supportedLocale)),
          expect: () => [
            LocaleSettingsState(
              status: LocaleSettingsStatus.loading,
              deviceLocale: supportedLocaleAlternative,
            ),
            LocaleSettingsState(
              status: LocaleSettingsStatus.success,
              deviceLocale: supportedLocaleAlternative,
              selectedLocale: supportedLocale,
            ),
          ],
          verify: (_) {
            verify(
              () => mockSettingsRepository.saveString(
                key: localePrefsKey,
                value: supportedLocale.toString(),
              ),
            ).called(1);
          },
        );
      });
    });

    /// This group of tests is designed to validate the functionality of the
    /// BLoCs `ChangeDeviceLocale` event.
    group('ChangeDeviceLocale', () {

      /// Validates the BLoC emits the new device locale.
      blocTest<LocaleSettingsBloc, LocaleSettingsState>(
        'Emit new device locale',
        build: () => setupLocaleSettingsBloc(storedLocale: null),
        seed: () {
          return LocaleSettingsState(
            status: LocaleSettingsStatus.success,
            deviceLocale: supportedLocale,
          );
        },
        act: (bloc) => bloc.add(ChangeDeviceLocale(supportedLocaleAlternative)),
        expect: () => [
          LocaleSettingsState(
            status: LocaleSettingsStatus.success,
            deviceLocale: supportedLocaleAlternative,
          ),
        ],
      );
    });
  });
}
