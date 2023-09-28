import 'package:advanced_internationalization/app.dart';
import 'package:advanced_internationalization/home/home.dart';
import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  group('Locale Integration Tests', () {
    late MockSettingsRepository mockSettingsRepository;

    // Requires AppLocalizations.supportedLocales to have at least three entries
    final defaultLocale = AppLocalizations.supportedLocales[0];
    final firstSupportedLocale = AppLocalizations.supportedLocales[1];
    final secondSupportedLocale = AppLocalizations.supportedLocales[2];
    const unsupportedLocale = Locale('foo', 'BAR');

    setUpAll(() async {
      assert(
        AppLocalizations.supportedLocales.length >= 3,
        'At least 3 supported locales are required for these tests.',
      );
    });

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
    });

    tearDown(() {
      reset(mockSettingsRepository);
    });

    /// Helper function configuring the behavior of the
    /// `MockSettingsRepository`.
    void _setupMockSettingsRepository(Locale storedLocale) {
      // Stub repository contains key call
      when(() => mockSettingsRepository.containsKey(key: any(named: 'key')))
          .thenAnswer((_) => true);

      // Stub repository get string call
      when(() => mockSettingsRepository.getString(key: any(named: 'key')))
          .thenAnswer((_) => storedLocale.toString());

      // Stub repository delete entry call
      when(() => mockSettingsRepository.deleteEntry(key: any(named: 'key')))
          .thenAnswer((_) async {});
    }

    /// Helper function configuring the test environment.
    void _setUpTestEnvironment({
      required WidgetTester tester,
      required List<Locale> testEnvLocales,
    }) {
      // Set test environment locales (simulating device locales) and verify
      tester.platformDispatcher.localesTestValue = testEnvLocales;
      expect(tester.platformDispatcher.locales, testEnvLocales);
    }

    /// Helper function returning the current locale of the `HomePage`.
    Locale _getAppLocale({required WidgetTester tester}) {
      final context = tester.element(find.byType(HomePage));
      return Localizations.localeOf(context);
    }

    /// Helper function to set the test environment, run the test and verify
    /// the outcome.
    Future<void> _testLocaleBehaviour({
      required WidgetTester tester,
      required List<Locale> testEnvLocales,
      required Locale expectedLocale,
    }) async {
      _setUpTestEnvironment(tester: tester, testEnvLocales: testEnvLocales);

      // Build the AppView widget with the mocked settings repository
      await tester.pumpWidget(App(settingsRepository: mockSettingsRepository));
      await tester.pumpAndSettle();

      // Verify result
      expect(_getAppLocale(tester: tester), expectedLocale);
    }

    /// This group of tests is designed to validate the functionality of the
    /// Apps localization behaviour given no saved locale data.
    group('Empty local storage', () {
      setUp(() {
        when(() => mockSettingsRepository.containsKey(key: any(named: 'key')))
            .thenAnswer((_) => false);
      });

      /// Validates that the app starts in the default locale if all given
      /// device locales are not supported.
      testWidgets('Start in default locale if device locale is not supported',
          (WidgetTester tester) async {
        // App starts in the default locale if the device locale(s) is not
        // supported and there is no locale saved in local storage
        await _testLocaleBehaviour(
          tester: tester,
          testEnvLocales: [unsupportedLocale],
          expectedLocale: defaultLocale,
        );
      });

      /// Validates that the app starts in the first device locale.
      testWidgets('Start in first device locale (supported)',
          (WidgetTester tester) async {
        // App starts in the first device locale if the device locale is
        // supported and there is no locale saved in local storage
        await _testLocaleBehaviour(
          tester: tester,
          testEnvLocales: [firstSupportedLocale, secondSupportedLocale],
          expectedLocale: firstSupportedLocale,
        );
      });

      /// Validates that the app starts in the second device locale if the
      /// first locale is not supported.
      testWidgets('Start in second device locale if first is not supported',
          (WidgetTester tester) async {
        // App starts in the second device locale if it is supported and the
        // first device locale is not supported and there is no locale saved in
        // local storage
        await _testLocaleBehaviour(
          tester: tester,
          testEnvLocales: [unsupportedLocale, firstSupportedLocale],
          expectedLocale: firstSupportedLocale,
        );
      });

      /// Validates that the app listens to device locale changes at changes its
      /// own locale accordingly.
      testWidgets('Change from one device locale to another',
          (WidgetTester tester) async {
        // App listens to device locales and changes locale if the device
        // locale changes
        _setUpTestEnvironment(
          tester: tester,
          testEnvLocales: [firstSupportedLocale],
        );

        // Build the AppView widget with the mocked settings repository
        await tester
            .pumpWidget(App(settingsRepository: mockSettingsRepository));
        await tester.pumpAndSettle();

        // Verify the app starts in the expected test environment locale (device
        // locale)
        expect(_getAppLocale(tester: tester), firstSupportedLocale);

        // Change the test environment
        _setUpTestEnvironment(
          tester: tester,
          testEnvLocales: [secondSupportedLocale],
        );

        // Rebuild the widget tree to reflect locale changes
        await tester.pumpAndSettle();

        // Verify the app locale has changed to the new test environment locale
        // (device locale)
        expect(_getAppLocale(tester: tester), secondSupportedLocale);
      });

      /// Validates that the app starts in a locale based on the language code
      /// only if the full locale is unknown.
      testWidgets(
          'Base locale decision on language code only if country code unknown',
          (WidgetTester tester) async {
        // App starts in language code only built locale if the device locale
        // country code is not supported and there is no locale saved in
        // local storage
        await _testLocaleBehaviour(
          tester: tester,
          testEnvLocales: [Locale(firstSupportedLocale.languageCode, 'FOO')],
          expectedLocale: Locale(firstSupportedLocale.languageCode),
        );
      });
    });

    /// This group of tests is designed to validate the functionality of the
    /// Apps localization behaviour given valid saved locale data.
    group('Supported locale saved to local storage', () {
      setUp(() {
        _setupMockSettingsRepository(firstSupportedLocale);
      });

      /// Validates that the app starts in the saved locale.
      testWidgets('Start in stored locale',
          (WidgetTester tester) async {
        // App starts in stored locale if locale is supported
        await _testLocaleBehaviour(
          tester: tester,
          testEnvLocales: [firstSupportedLocale, secondSupportedLocale],
          expectedLocale: firstSupportedLocale,
        );
      });
    });

    /// This group of tests is designed to validate the functionality of the
    /// Apps localization behaviour given invalid saved locale data.
    group('Unsupported locale saved to local storage', () {
      setUp(() {
        _setupMockSettingsRepository(unsupportedLocale);
      });

      /// Validates that the app starts in the device locale.
      testWidgets(
          'Start in supported device locale',
          (WidgetTester tester) async {
        // App starts in first supported device locale if the locale stored in
        // local storage is not supported. The stored locale is deleted
        await _testLocaleBehaviour(
          tester: tester,
          testEnvLocales: [firstSupportedLocale],
          expectedLocale: firstSupportedLocale,
        );
        verify(() => mockSettingsRepository.deleteEntry(key: any(named: 'key')))
            .called(1);
      });
    });
  });
}
