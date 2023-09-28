import 'package:advanced_internationalization/app.dart';
import 'package:advanced_internationalization/utilities/utilities.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:local_storage_settings_api/local_storage_settings_api.dart';
import 'package:settings_repository/settings_repository.dart';

/// The entry point for the Flutter application.
void main() async {
  // Ensure Flutter is initialized before running the application.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the application settings API using SharedPreferences.
  final settingsApi = LocalStorageSettingsApi(
    plugin: await SharedPreferences.getInstance(),
  );

  // Set the Bloc observer to the custom AppBlocObserver.
  Bloc.observer = const AppBlocObserver();

  // Create an instance of the SettingsRepository.
  final settingsRepository = SettingsRepository(settingsApi: settingsApi);

  // Run the Flutter application, passing the SettingsRepository instance.
  runApp(App(settingsRepository: settingsRepository));
}
