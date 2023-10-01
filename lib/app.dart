import 'package:advanced_internationalization/home/home.dart';
import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:advanced_internationalization/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:settings_repository/settings_repository.dart';

/// The top-level widget representing the entire application.
class App extends StatelessWidget {
  /// Creates an instance of the [App] widget and initializes the required
  /// BLoC providers.
  const App({
    required this.settingsRepository,
    super.key,
  });

  /// The [settingsRepository] is responsible for managing the application's
  /// settings, such as locale preferences.
  final SettingsRepository settingsRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SettingsRepository>.value(
      value: settingsRepository,
      child: BlocProvider(
        create: (context) => LocaleSettingsBloc(
          settingsRepository: context.read<SettingsRepository>(),
        )..add(const GetLocaleSettings()),
        child: const AppView(),
      ),
    );
  }
}

/// The root for the [MaterialApp].
class AppView extends StatefulWidget {
  /// Creates an instance of the [AppView] widget.
  ///
  /// This widget acts as the root for the material application and listens to
  /// device locale changes.
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    context.read<LocaleSettingsBloc>().add(ChangeDeviceLocale(locales!.first));
    super.didChangeLocales(locales);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleSettingsBloc, LocaleSettingsState>(
      builder: (context, state) {
        final locale = state.selectedLocale == systemLocaleOption
            ? null
            : state.selectedLocale;

        return MaterialApp(
          title: 'Flutter Advanced Internationalization',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
            useMaterial3: true,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          localeListResolutionCallback: (locales, supportedLocales) {
            if (state.deviceLocale == null) {
              // Setting initial device locale
              context
                  .read<LocaleSettingsBloc>()
                  .add(ChangeDeviceLocale(locales!.first));
            }
            return basicLocaleListResolution(locales, supportedLocales);
          },
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            LocaleNamesLocalizationsDelegate(),
          ],
          home: const HomePage(),
        );
      },
    );
  }
}
