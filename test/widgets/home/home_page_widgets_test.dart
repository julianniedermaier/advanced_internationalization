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
  final mockSettingsRepository = MockSettingsRepository();

  setUp(() {
    // Stub repository contains key call
    when(() => mockSettingsRepository.containsKey(key: any(named: 'key')))
        .thenAnswer((_) => false);
  });

  /// Helper function to create a testable widget for the `HomePage`.
  Widget _buildTestableWidget(SettingsRepository mockSettingsRepository) {
    // Create a test widget with localization delegates and
    // mockSettingsRepository
    return RepositoryProvider<SettingsRepository>.value(
      value: mockSettingsRepository,
      child: BlocProvider(
        create: (context) => LocaleSettingsBloc(
          settingsRepository: context.read<SettingsRepository>(),
        )..add(const GetLocaleSettings()),
        child: const MaterialApp(
          home: HomePage(),
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            LocaleNamesLocalizationsDelegate(),
          ],
        ),
      ),
    );
  }

  /// Validates the construction and the content of the `HomePage`.
  testWidgets('HomePage widget test', (WidgetTester tester) async {
    // Build the test widget
    await tester.pumpWidget(_buildTestableWidget(mockSettingsRepository));
    await tester.pumpAndSettle();

    // Verify the home page scaffold is built
    expect(find.byKey(homePageScaffoldKey), findsOneWidget);

    // Tap the button and trigger a frame
    final buttonFinder = find.byKey(changeLocaleButtonKey);
    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Verify that the locale settings bottom sheet is displayed
    expect(
      find.byKey(localeSettingsOptionsSheetKey),
      findsOneWidget,
    );
  });
}
