import 'package:advanced_internationalization/home/home.dart';
import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:advanced_internationalization/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

/// The `HomePage` widget represents the main page of the app.
class HomePage extends StatelessWidget {
  /// Constructor for HomePage
  ///
  /// Creates a new instance of the `HomePage` widget.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      key: homePageScaffoldKey,
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocSelector<LocaleSettingsBloc, LocaleSettingsState, Locale?>(
              selector: (state) => state.selectedLocale,
              builder: (context, selectedLocale) {
                final localeCode = selectedLocale.toString();
                final localeName =
                    LocaleNames.of(context)!.nameOf(localeCode) ?? localeCode;

                return Text(
                  l10n.selectedLocale(
                    selectedLocale == systemLocaleOption
                        ? l10n.settingsSystemDefault
                        : localeName,
                  ),
                );
              },
            ),
            ElevatedButton(
              key: changeLocaleButtonKey,
              onPressed: () => localeSettingsBottomSheet(context: context),
              child: Text(l10n.changeLocale),
            ),
          ],
        ),
      ),
    );
  }
}
