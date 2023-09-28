import 'package:advanced_internationalization/home/home.dart';
import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:advanced_internationalization/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_repository/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
    /// Validates the construction and the content of the `LocaleRadioListTile`.
    testWidgets('LocaleRadioListTile widget test', (WidgetTester tester) async {
    // Define a variable to test the callback function
    Locale? selectedLocale;

    // Define example locale with title and subtitle
    const testLocale = Locale('es', 'ES');
    const testLocaleTitle = 'Foo';
    const testLocaleSubtitle = 'Bar';

    // Define alternative locale as the initially selected option
    const initialSelectedLocale = Locale('fr', 'FR');

    // Build a testbed widget that contains the LocaleRadioListTile
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocaleRadioListTile(
            locale: testLocale,
            localeDisplayOption: LocaleDisplayOption(
              testLocaleTitle,
              subtitle: testLocaleSubtitle,
            ),
            selectedLocaleOption: initialSelectedLocale,
            onLocaleChanged: (newLocale) {
              selectedLocale = newLocale; // Set the selected locale
            },
          ),
        ),
      ),
    );

    // Find the radio button
    final radioFinder = find.byType(Radio<Locale>);

    // Verify that the radio button is present
    expect(radioFinder, findsOneWidget);

    // Find the title and subtitle Text widgets
    final titleFinder = find.text(testLocaleTitle);
    final subtitleFinder = find.text(testLocaleSubtitle);

    // Verify that the title and subtitle are present
    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);

    // Tap the radio button to simulate user selection
    await tester.tap(radioFinder);
    await tester.pump();

    // Verify that the callback function was called and returned the test locale
    expect(selectedLocale, testLocale);
  });

    /// This group of tests is designed to validate the functionality of the
    /// `LocaleSettingsBottomSheet` Widget.
    group('LocaleSettingsBottomSheet Widget Tests', () {
    late MockSettingsRepository mockSettingsRepository;

    setUpAll(() {
      assert(
        AppLocalizations.supportedLocales.isNotEmpty,
        'At least 1 supported locale is required for these tests.',
      );
    });

    /// Helper function configuring the behavior of the
    /// `MockSettingsRepository`.
    void _setupMockSettingsRepository() {
      // Stub repository contains key call
      when(() => mockSettingsRepository.containsKey(key: localePrefsKey))
          .thenAnswer((_) => false);

      // Stub repository save string call
      when(
        () => mockSettingsRepository.saveString(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
    }

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
      _setupMockSettingsRepository();
    });

    tearDown(() {
      reset(mockSettingsRepository);
    });

    /// Helper function to create a testable widget for the
    /// `LocaleSettingsBottomSheet`.
    Widget _buildTestableWidget(SettingsRepository mockSettingsRepository) {
      return RepositoryProvider<SettingsRepository>.value(
        value: mockSettingsRepository,
        child: BlocProvider(
          create: (context) => LocaleSettingsBloc(
            settingsRepository: context.read<SettingsRepository>(),
          )..add(const GetLocaleSettings()),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  key: changeLocaleButtonKey,
                  onPressed: () => localeSettingsBottomSheet(context: context),
                  child: const Text('Change Locale'),
                );
              },
            ),
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              LocaleNamesLocalizationsDelegate(),
            ],
          ),
        ),
      );
    }

    /// Helper function to simulate the opening of the modal bottom sheet.
    Future<void> _openModalBottomSheet(WidgetTester tester) async {
      await tester.pumpWidget(_buildTestableWidget(mockSettingsRepository));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ChangeLocaleButton')));
      await tester.pumpAndSettle();
    }

    /// Validates the construction and the content of the sheet.
    testWidgets('validate sheet construction and content',
        (WidgetTester tester) async {
      await _openModalBottomSheet(tester);

      // Confirm the sheet contains more than one LocaleRadioListTiles
      final localeTilesFinder = find.byType(LocaleRadioListTile);
      expect(localeTilesFinder.evaluate().length, greaterThan(1));

      // Check if the system LocaleRadioListTile (index 0) is selected
      final systemTileFinder = find.byKey(const ObjectKey(systemLocaleOption));
      final systemRadioTileFinder = find.descendant(
        of: systemTileFinder,
        matching: find.byType(RadioListTile<Locale>),
      );
      expect(
        tester.widget<RadioListTile<Locale>>(systemRadioTileFinder).checked,
        isTrue,
      );

      final firstTile =
          tester.widget<LocaleRadioListTile>(localeTilesFinder.at(0));
      final systemTile = tester.widget<LocaleRadioListTile>(systemTileFinder);

      expect(firstTile, equals(systemTile));
    });

    /// Validates the various options available to close the sheet.
    testWidgets('close sheet by various options', (WidgetTester tester) async {
      // 1. Close by selecting a new option
      await _openModalBottomSheet(tester);
      await tester.tap(find.byType(LocaleRadioListTile).at(1));
      await tester.pumpAndSettle();
      expect(find.byKey(localeSettingsOptionsSheetKey), findsNothing);

      // 2. Close sheet by tapping outside
      await _openModalBottomSheet(tester);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.byKey(localeSettingsOptionsSheetKey), findsNothing);

      // 3. Close sheet by tapping close button
      await _openModalBottomSheet(tester);
      await tester.tap(find.byKey(localeSheetCloseButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(localeSettingsOptionsSheetKey), findsNothing);

      // 4. Close sheet by flinging downwards
      await _openModalBottomSheet(tester);
      await tester.fling(
        find.byKey(localeSettingsOptionsSheetKey),
        const Offset(0, 50),
        2000,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(localeSettingsOptionsSheetKey), findsNothing);
    });
  });
}
